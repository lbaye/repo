<?php

namespace Event;

use Repository\UserRepo as UserRepository;
use \Service\Search\ApplicationSearchFactory as AppSearchFactory;

class CreateSearchCache extends Base {
    /**
     * @var UserRepository
     */
    protected $userRepository;
    private $cacheRefRepo;

    protected function setFunction() {
        $this->function = 'create_search_cache';
    }

    public function __construct($conf, $services) {
        parent::__construct($conf, $services);
        $this->userRepository = $this->services['dm']->getRepository('Document\User');
        $this->cacheRefRepo = $this->services['dm']->getRepository('Document\CacheRef');
    }

    public function run(\GearmanJob $job) {
        $this->info("Executing Event::CreateSearchCache with job - {$job->unique()}");

        $workload = json_decode($job->workload());
        $this->debug('Workload - ' . json_encode($workload));

        $user = $this->userRepository->find($workload->userId);
        if ($user) {
            $this->userRepository->refresh($user);
            $this->userRepository->setCurrentUser($user);

            $this->createCache($user);

            $this->runTasks();
        }
    }

    private function createCache(\Document\User &$user) {
        $inst = AppSearchFactory::getInstance(
            AppSearchFactory::AS_DEFAULT, $user, $this->services['dm'], $this->serviceConf);

        $result = $inst->searchAll($user->getCurrentLocation(), array('user' => $user));

        // Remove existing cache reference
        $this->cacheRefRepo->cleanupExistingReferences($user);

        // Create cache file name
        $cacheFile = \Helper\CacheUtil::buildSearchCachePath($user, $user->getCurrentLocation());

        // Ensure target directory does exist
        \Helper\CacheUtil::ensureDirectoryExistence($cacheFile);

        // Write data to cache file
        file_put_contents($cacheFile, json_encode($result));

        // Create cache reference
        \Helper\CacheUtil::createCacheReference(
            $this->cacheRefRepo, $user, $cacheFile, $user->getCurrentLocation(), $result['people']);
    }
}
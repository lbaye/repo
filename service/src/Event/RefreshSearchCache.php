<?php

namespace Event;

use Repository\UserRepo as UserRepository;

class RefreshSearchCache extends Base {
    /**
     * @var UserRepository
     */
    protected $userRepository;
    private $cacheRefRepo;

    protected function setFunction() {
        $this->function = 'refresh_search_cache';
    }

    public function __construct($conf, $services) {
        parent::__construct($conf, $services);
        $this->userRepository = $this->services['dm']->getRepository('Document\User');
        $this->cacheRefRepo = $this->services['dm']->getRepository('Document\CacheRef');
    }

    public function run(\GearmanJob $job) {
        $this->info("Executing Event::RefreshSearchCache with job - {$job->unique()}");

        $workload = json_decode($job->workload());
        $this->debug('Workload - ' . json_encode($workload));

        $user = $this->userRepository->find($workload->userId);
        if ($user) {
            $this->userRepository->refresh($user);

            // cacheOwners = []
            $participants = array($user->getAuthToken());

            // if user is in other's caches
            //   cacheOwners[] = all other caches owner
            $existingCaches = $this->cacheRefRepo->getReferencesWhereImIn($user);
            foreach ($existingCaches as $cache) {
                $this->removeCacheRef($cache);
            }

            var_dump($participants);

            // cacheOwners[] = those who are in user's current location
            #$this->userRepository->getNearbyUsers($user);

            // cacheOwners = make this list unique cacheOwners
            $participants = array_unique($participants);

            // cacheOwners = filter out all offline users
            //
            // request for refreshing cache for cacheOwners

            $this->runTasks();
        }
    }

    private function removeCacheRef($cache) {
        try {
            if (!is_null($cache)) {
                $this->cacheRefRepo->delete($cache['_id']->{'$id'});

                $cacheFile = $cache['cacheFile'];
                $this->debug('Removing cache path - ' . $cacheFile);
                @unlink($cacheFile);
                $this->debug('Cache cleaned up');
            }
        } catch (\Exception $e) {
            $this->error($e->getMessage());
        }
    }
}
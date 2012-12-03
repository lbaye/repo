<?php

namespace Event;

use Repository\UserRepo as UserRepository;
use \Service\Search\ApplicationSearchFactory as AppSearchFactory;

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
            $this->userRepository->setCurrentUser($user);

            // cacheOwners = []
            $newCacheRequiredUserIds = array($user->getId());

            // if user is in other's caches
            //   cacheOwners[] = all other caches owner
            $this->loadThoseWhoCachedMe($user, $newCacheRequiredUserIds);

            // cacheOwners[] = those who are in user's current location
            // cacheOwners = filter out all offline users
            $this->loadUsersNearMe($user, $newCacheRequiredUserIds);

            // cacheOwners = make this list unique cacheOwners
            $newCacheRequiredUserIds = array_unique($newCacheRequiredUserIds);

            // request for refreshing cache for cacheOwners
            $this->debug('Updating cache for users - ' . implode(',', $newCacheRequiredUserIds));
            $this->requestForNewCache($newCacheRequiredUserIds);
        }
    }

    private function loadUsersNearMe(\Document\User &$user, &$newCacheRequiredUserIds) {
        $peopleAroundMe = $this->userRepository
                ->searchNearByPeople(null, $user->getCurrentLocation(),
                                     array('limit' => \Helper\Constants::PEOPLE_LIMIT,
                                          'offset' => 0, 'select' => array('id', 'lastPulse')));
        foreach ($peopleAroundMe as $person) {
            if (!empty($person['lastPulse']) &&
                \Document\User::isOnline($person['lastPulse']))
                $newCacheRequiredUserIds[] = $person['_id']->{'$id'};
        }

    }

    private function loadThoseWhoCachedMe(\Document\User &$user, array &$newCacheRequiredUserIds) {
        $existingCaches = $this->cacheRefRepo->getReferencesWhereImCached($user);
        foreach ($existingCaches as $cacheRef) {
            $newCacheRequiredUserIds[] = $cacheRef['owner']->{'$id'};
        }
    }

    private function requestForNewCache(array $userIds) {
        $this->debug('Requesting for new cache generation');

        foreach ($userIds as $userId)
            $this->addTaskBackground('create_search_cache', json_encode(array('userId' => $userId)));

        $this->runTasks();
    }
}
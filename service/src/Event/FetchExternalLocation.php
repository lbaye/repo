<?php

namespace Event;

use Repository\UserRepo as UserRepository;

class FetchExternalLocation extends Base
{
    /**
     * @var UserRepository
     */
    protected $userRepository;

    protected function setFunction()
    {
        $this->function = 'fetch_external_location';
    }

    public function run(\GearmanJob $job)
    {
        $workload = json_decode($job->workload());
        $this->userRepository = $this->services['dm']->getRepository('Document\User');

        $fbUsers = $this->userRepository->getFacebookUsers();
        echo "Initiating friend location retrieval task for ", count($fbUsers), " facebook users.", PHP_EOL;
//        $this->addTaskBackground('fetch_facebook_location', json_encode(array(
//                'facebookId' => "670897589",
//                'facebookAuthToken' => "AAADs3J74sUgBALCX1FFsrFJxNsA9GAoFMNlqqzSJJlwNHxdWL0pcOeh7ZBaAuMxN8vyZCYdxJqio4yAwCqnZCE1lZB69pablngpGiQwIKwZDZD"
//            )));

        foreach ($fbUsers as $fbUser) {
            $this->addTaskBackground('fetch_facebook_location', json_encode(array(
                'facebookId' => $fbUser->getFacebookId(),
                'facebookAuthToken' => $fbUser->getFacebookAuthToken()
            )));
        }

        $this->runTasks();
    }
}
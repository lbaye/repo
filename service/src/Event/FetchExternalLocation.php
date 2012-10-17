<?php

namespace Event;

use Repository\UserRepo as UserRepository;

class FetchExternalLocation extends Base {
    /**
     * @var UserRepository
     */
    protected $userRepository;

    protected function setFunction() {
        $this->function = 'fetch_external_location';
    }

    public function run(\GearmanJob $job) {
        $this->logJob('FetchExternalLocation', $job);
        $this->checkMemoryBefore();

        $workload = json_decode($job->workload());
        $this->userRepository = $this->services['dm']->getRepository('Document\User');

        $fbUsers = $this->userRepository->getFbConnectedUsers();
        $this->debug("Iterate through " . count($fbUsers) . " facebook users to retrieve facebook checkins");

        foreach ($fbUsers as $fbUser) {
            $fbId = $fbUser['facebookId'];
            $fbAuthToken = $fbUser['facebookAuthToken'];

            if (!empty($fbId) && !empty($fbAuthToken)) {
                $this->debug(
                    'Retrieve checkins from - ' .
                    @$fbUser['firstName'] . ' UID: ' . $fbUser['_id'] .
                    ', FBID: ' . $fbId);
            }
            $this->addTaskBackground(
                'fetch_facebook_location',
                json_encode(array( 'userId' => $fbUser['_id']->{'$id'}, 'facebookId' => $fbId, 'facebookAuthToken' => $fbAuthToken ))
            );
        }

        $this->runTasks();
        $this->checkMemoryAfter();
    }
}
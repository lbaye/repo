<?php

namespace Event;

use Repository\UserRepo as UserRepository;

class LastSeenAddress extends Base
{
    /**
     * @var UserRepository
     */
    protected $userRepository;

    protected function setFunction()
    {
        $this->function = 'update_last_seen_address';
    }

    public function run(\GearmanJob $job)
    {
        $workload = json_decode($job->workload());

        $this->userRepository = $this->services['dm']->getRepository('Document\User');
        $user = $this->userRepository->find($workload->user_id);

        echo 'Running update_last_seen_address for '.$user->getId().' ('. $user->getName() .') '. PHP_EOL;
        try {
            $address = $this->_getAddress($user);
            $this->_updateUserAddress($user, $address);
        } catch (\Exception $e) {
            echo 'Exception from google API in update_last_seen_address: '. $e->getMessage() . PHP_EOL;
        }

        $this->runTasks();
    }

    public function _updateUserAddress(\Document\User $user, $address)
    {
        $user->setLastSeenAt($address);

        $this->services['dm']->persist($user);
        $this->services['dm']->flush();
    }

    public function _getAddress(\Document\User $user)
    {
        $reverseGeo = new \Service\Geolocation\Reverse($this->serviceConf['googlePlace']['apiKey']);
        return $reverseGeo->getAddress($user->getCurrentLocation());
    }
}
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

    public function __construct($conf, $services) {
        parent::__construct($conf, $services);
        $this->userRepository = $this->services['dm']->getRepository('Document\User');
    }

    public function run(\GearmanJob $job)
    {
        $this->debug("Executing Event::LastSeenAddress with job - {$job->unique()}");
        
        $workload = json_decode($job->workload());

        $user = $this->userRepository->find($workload->user_id);
        $this->userRepository->refresh($user);

        try {
            $current_location = $user->getCurrentLocation();
            $this->debug("Requesting for reverse geo location at position ({$current_location['lat']}, {$current_location['lng']}) for {$user->getFirstName()} ({$user->getId()})");

            $address = $this->_getAddress($current_location);
            $this->_updateUserAddress($user, $address);
        } catch (\Exception $e) {
            $this->error('Failed to retrieve "reverse geo location", might be an issue with google API');
            $this->error($e);
        }

        $this->runTasks();
    }

    public function _updateUserAddress(\Document\User $user, $address)
    {
        $user->setLastSeenAt($address);

        $this->services['dm']->persist($user);
        $this->services['dm']->flush();
        $this->debug("Updating address - $address to {$user->getFirstName()}");
    }

    public function _getAddress($current_location)
    {
        $reverseGeo = new \Service\Geolocation\Reverse($this->serviceConf['googlePlace']['apiKey']);
        $address = $reverseGeo->getAddress($current_location);
        $this->debug("Found reversed geo location - $address ({$current_location['lat']}, {$current_location['lng']})");

        return $address;
    }
}
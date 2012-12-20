<?php

namespace Event;

use Repository\UserRepo as UserRepository;

/**
 * Background job for updating user's last seen at attribute based on it's current location
 */
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
        $this->info("Executing Event::LastSeenAddress with job - {$job->unique()}");
        
        $workload = json_decode($job->workload());
        $this->debug('Workload - ' . json_encode($workload));

        $user = $this->userRepository->find($workload->user_id);
        if ($user) {
            $this->userRepository->refresh($user);

            try {
                $current_location = $user->getCurrentLocation();
                $this->debug("Requesting for reverse geo location at position ({$current_location['lat']}, {$current_location['lng']}) for {$user->getFirstName()} ({$user->getId()})");

                $this->setAddress($user);
                $this->setCoverPhotoIfStreetImage($user);
                $this->storeChanges($user);

                $this->services['dm']->clear();
            } catch (\Exception $e) {
                $this->error('Failed to retrieve "reverse geo location", might be an issue with google API');
                $this->error($e);
            }

            $this->runTasks();
        }
    }

    private function storeChanges(\Document\User &$user) {
        $this->services['dm']->persist($user);
        $this->services['dm']->flush();

        return true;
    }

    private function setAddress(\Document\User &$user) {
        try {
            $address = $this->_getAddress($user->getCurrentLocation());
            $user->setLastSeenAt($address);
            $this->debug("Updating address - $address to {$user->getFirstName()}");
        } catch (\Exception $e) {
            $this->error('Failed to retrieve address from google service - ' . $e->getMessage());
        }
    }

    private function setCoverPhotoIfStreetImage(\Document\User &$user){
        if ($user->hasCurrentLocation()) {
            $coverImage = $user->getCoverPhoto();
            $streetImage = (preg_match('/^https?:\/\/maps.googleapis.com/', $coverImage) > 0) ? 1 : 0;

            // If Not user defined image
            if (empty($coverImage) || $streetImage) {
                $current_location = $user->getCurrentLocation();
                $coverImage = \Helper\Url::getStreetViewImageOrReturnEmpty($this->conf, $current_location);
                $user->setCoverPhoto($coverImage);
                $this->debug('Updating user cover photo - ' . $user->getName() . ' - ' . $coverImage);
            }
        }
    }
}
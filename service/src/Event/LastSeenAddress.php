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
        $this->info("Executing Event::LastSeenAddress with job - {$job->unique()}");
        
        $workload = json_decode($job->workload());
        $this->debug('Workload - ' . json_encode($workload));

        $user = $this->userRepository->find($workload->user_id);
        if ($user) {
            $this->userRepository->refresh($user);

            try {
                $current_location = $user->getCurrentLocation();
                $this->debug("Requesting for reverse geo location at position ({$current_location['lat']}, {$current_location['lng']}) for {$user->getFirstName()} ({$user->getId()})");

                $address = $this->_getAddress($current_location);
                $this->_updateUserAddress($user, $address);
                $this->_updateCoverPhotoIfStreetImage($user, $current_location);
                $this->services['dm']->clear();
            } catch (\Exception $e) {
                $this->error('Failed to retrieve "reverse geo location", might be an issue with google API');
                $this->error($e);
            }

            $this->runTasks();
        }
    }

    public function _updateUserAddress(\Document\User $user, $address)
    {
        $user->setLastSeenAt($address);

        $this->services['dm']->persist($user);
        $this->services['dm']->flush();
        $this->debug("Updating address - $address to {$user->getFirstName()}");
    }

    public function _updateCoverPhotoIfStreetImage(\Document\User $user, $current_location){
        if(empty($current_location['lat']) || empty($current_location['lng'])) {

        } else {
            $coverImage = $user->getCoverPhoto();
            $update = (preg_match('/^http:\/\/maps.googleapis.com/', $coverImage) > 0) ? 1 : 0;
            if($update){
                $coverImage = \Helper\Url::getStreetViewImageOrReturnEmpty(null,$current_location);
                $user->setCoverPhoto($coverImage);
            }
        }
        $this->services['dm']->persist($user);
        $this->services['dm']->flush();
    }
}
<?php

namespace Event;

use Repository\UserRepo as UserRepository;

class NewFriendRequest extends Base
{
    /**
     * @var UserRepository
     */
    protected $userRepository;

    protected function setFunction()
    {
        $this->function = 'new_friend_request';
    }

    public function run(\GearmanJob $job)
    {
        $workload = json_decode($job->workload());
        $this->userRepository = $this->services['dm']->getRepository('Document\User');

        $friendRequestData = array(
            'objectId' => $workload->objectId,
            'objectType' => $workload->objectType,
            'message' => $workload->message
        );

        $this->userRepository->addNotification($workload->userId, $friendRequestData);
        echo 'Added notification for friend request.', PHP_EOL;
    }
}
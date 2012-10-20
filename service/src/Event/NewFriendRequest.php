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
        $this->logJob('Event::NewFriendRequest', $job);

        $workload = json_decode($job->workload());
        $this->userRepository = $this->services['dm']->getRepository('Document\User');
        $user = $this->userRepository->find($workload->userId);
        $friend = $this->userRepository->find($workload->objectId);

        if (!empty($user)) {
            $this->debug($user->getFirstName() . " sent friend request to `" . $friend->getFirstName() . '`');

            $friendRequestData = array(
                'objectId' => $workload->objectId,
                'objectType' => $workload->objectType,
                'message' => $workload->message
            );

            $this->userRepository->addNotification($workload->userId, $friendRequestData);
            $this->debug("New notification added.");
        } else {
            $this->warn("Could not retrieve valid user for id - {$workload->userId}");
        }
    }
}
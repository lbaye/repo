<?php

namespace Event;

use Repository\User as UserRepository;

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

        $sender = $this->userRepository->find($workload->sender);
        $receiver = $this->userRepository->find($workload->receiver);
        $message = $workload->message;

        \Doctrine\Common\Util\Debug::dump($sender);
        \Doctrine\Common\Util\Debug::dump($receiver);
        echo $message;

        //TODO: Complete the actual functionality

        return $message;
    }
}
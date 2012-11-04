<?php

namespace Event;

use Repository\UserRepo as UserRepository;
use Repository\MessageRepo as MessageRepository;

class SendPushNotification extends Base
{
    /**
     * @var UserRepository
     */
    protected $userRepository;

    /**
     * @var MessageRepository
     */
    protected $messageRepository;

    protected function setFunction()
    {
        $this->function = 'send_push_notification';
    }

    public function run(\GearmanJob $job)
    {
        $this->logJob('Event::SendPushNotification', $job);
        $this->checkMemoryBefore();
        $workload = json_decode($job->workload());
        $this->debug('Workload - ' . $job->workload());

        if ($this->isFreshRequest($workload)) {
            $this->debug('Is still valid request.');

            $dm = $this->services['dm'];
            $this->userRepository = $this->services['dm']->getRepository('Document\User');
            $this->messageRepository = $this->services['dm']->getRepository('Document\Message');

            $users = $dm->createQueryBuilder('Document\User')
                    ->select('id', 'firstName', 'pushSettings')
                    ->field('id')->equals($workload->user_id)
                    ->hydrate(false)->getQuery()->execute()->toArray();

            if (!empty($users)) {
                $userHash = $users[$workload->user_id];
                $this->_sendPushNotification($userHash, $workload->notification);
                $this->debug("Push notification sent to user - {$userHash['firstName']}");
            } else {
                $this->debug("No valid user for id - {$workload->user_id} found");
            }
            $this->services['dm']->clear();

        } else {
            $this->debug("Invalid request, it has expired it's valid time boundary.");
        }

        $this->checkMemoryAfter();

        $this->runTasks();
    }

    /**
     * $notificationData must have the following keys -
     *   - title
     *   - badge
     *   - tabCounts
     *   - objectId
     *   - objectType
     * @param array $notificationData
     */
    private function _sendPushNotification(array $userHash, $notification)
    {
        $notificationHash = array(
            'title' => $notification->title,
            'objectId' => $notification->objectId,
            'objectType' => $notification->objectType
        );

        $this->debug("Sending push notification to user - {$userHash['firstName']} ({$userHash['_id']})");
        $pushSettings = $userHash['pushSettings'];

        # TODO: Badge count is intentionally disabled.
        #$notifications_friendrequest = $this->userRepository->getNotificationsCount($user->getId());
        #$notifications_friendrequest_extract = explode(":",$notifications_friendrequest);

        #$message = count($this->messageRepository->getByRecipientCount($user));

        #$countTotal = (int)$notifications_friendrequest_extract[0]+(int)$notifications_friendrequest_extract[1]+ $message;

        $notificationHash['badge'] = 0;
        $notificationHash['tabCounts'] = "0:0"; #$notifications_friendrequest.":" . $message;

        $pushNotifier = \Service\PushNotification\PushFactory::getNotifier(@$pushSettings['device_type']);

        if ($pushNotifier) {
            $this->info("Sending push notification for {$pushSettings['device_type']}");
            echo $pushNotifier->send($notificationHash, array($pushSettings['device_id'])) . PHP_EOL;
        }
    }
}
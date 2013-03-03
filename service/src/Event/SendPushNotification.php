<?php

namespace Event;

use Repository\UserRepo as UserRepository;
use Repository\MessageRepo as MessageRepository;

/**
 * Background job for sending push notification to a specific user
 */
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
                $succeed = $this->_sendPushNotification($userHash, $workload->notification);
                if ($succeed)
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
        $hash = array(
            'title' => $notification->title,
            'objectId' => $notification->objectId,
            'objectType' => $notification->objectType,
            'receiverId' => $userHash['_id']
        );

        $notificationCountHash = $this->userRepository->generateNotificationCount($userHash['_id']);
        $notificationHash = array_merge($hash, $notificationCountHash);
        $this->debug("Sending push notification to user - {$userHash['firstName']} ({$userHash['_id']})");
        $pushSettings = $userHash['pushSettings'];

        if (isset($pushSettings['device_id']) && !empty($pushSettings['device_id'])) {
            $pushNotifier = \Service\PushNotification\PushFactory::getNotifier(@$pushSettings['device_type']);
             $this->info($pushNotifier);
             $this->info("+++");
            if ($pushNotifier) {
                $this->info("Sending push notification for {$pushSettings['device_type']} with id ({$pushSettings['device_id']})");
                 $this->info($notificationHash);
                echo $pushNotifier->send($notificationHash, array($pushSettings['device_id'])) . PHP_EOL;
            }

            return true;
        } else {
            $this->info("Device id not found.");

            return false;
        }
    }
}
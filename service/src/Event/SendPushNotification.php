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
        $workload = json_decode($job->workload());
        $this->debug('Workload - ' . $job->workload());

        if ($this->_stillValid($workload)) {
            $this->debug('Is still valid request.');

            $this->userRepository = $this->services['dm']->getRepository('Document\User');
            $this->messageRepository = $this->services['dm']->getRepository('Document\Message');

            $user = $this->userRepository->find($workload->user_id);

            if (!empty($user)) {
                $this->userRepository->refresh($user);
                $this->_sendPushNotification($user, get_object_vars($workload->notification));
                $this->debug("Push notification sent to user - {$user->getFirstName()}");
            } else {
                $this->debug("No valid user for id - {$workload->user_id} found");
            }
            $this->services['dm']->clear();

        } else {
            $this->debug("Invalid request, it has expired it's valid time boundary.");
        }

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
    private function _sendPushNotification(\Document\User $user, array $notificationData)
    {
        $this->debug("Sending push notification for user - {$user->getFirstName()} ({$user->getId()})");
        $pushSettings = $user->getPushSettings();

        # TODO: Badge count is intentionally disabled.
        #$notifications_friendrequest = $this->userRepository->getNotificationsCount($user->getId());
        #$notifications_friendrequest_extract = explode(":",$notifications_friendrequest);

        #$message = count($this->messageRepository->getByRecipientCount($user));

        #$countTotal = (int)$notifications_friendrequest_extract[0]+(int)$notifications_friendrequest_extract[1]+ $message;

        $notificationData['badge'] = 0;
        $notificationData['tabCounts'] = "0:0"; #$notifications_friendrequest.":" . $message;

        $pushNotifier = \Service\PushNotification\PushFactory::getNotifier(@$pushSettings['device_type']);

        if ($pushNotifier) {
            $this->info("Sending push notification for {$pushSettings['device_type']}");
            echo $pushNotifier->send($notificationData, array($pushSettings['device_id'])) . PHP_EOL;
        }
    }
}
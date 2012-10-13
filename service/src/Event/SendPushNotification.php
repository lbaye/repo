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
        //file_put_contents('/tmp/workload.txt', json_encode(count($friends)));
        $workload = json_decode($job->workload());

        if ($this->_stillValid($workload)) {

            echo 'Running send_push_notification for ' . $workload->user_id . " [{$workload->notification->objectType} : {$workload->notification->title}] " . PHP_EOL;
            $this->userRepository = $this->services['dm']->getRepository('Document\User');
            $this->messageRepository = $this->services['dm']->getRepository('Document\Message');

            $user = $this->userRepository->find($workload->user_id);
            $this->_sendPushNotification($user, get_object_vars($workload->notification));

            echo 'Done send_push_notification for ' . $workload->user_id . " [{$workload->notification->objectType} : {$workload->notification->title}] " . PHP_EOL;

        } else {
            echo 'Skipping proximity alert push for ' . $workload->user_id . ' because of outdated' . PHP_EOL;
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
        $pushSettings = $user->getPushSettings();

        # TODO: Badge count is intentionally disabled.
        #$notifications_friendrequest = $this->userRepository->getNotificationsCount($user->getId());
        #$notifications_friendrequest_extract = explode(":",$notifications_friendrequest);

        #$message = count($this->messageRepository->getByRecipientCount($user));

        #$countTotal = (int)$notifications_friendrequest_extract[0]+(int)$notifications_friendrequest_extract[1]+ $message;

        $notificationData['badge'] = 0;
        $notificationData['tabCounts'] = "0:0"; #$notifications_friendrequest.":" . $message;

        $pushNotifier = \Service\PushNotification\PushFactory::getNotifier(@$pushSettings['device_type']);

        if ($pushNotifier)
            echo $pushNotifier->send($notificationData, array($pushSettings['device_id']));
    }
}
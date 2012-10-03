<?php

namespace Event;

use Repository\UserRepo as UserRepository;

class SendPushNotification extends Base
{
    /**
     * @var UserRepository
     */
    protected $userRepository;

    protected function setFunction()
    {
        $this->function = 'send_push_notification';
    }

    public function run(\GearmanJob $job)
    {
        //file_put_contents('/tmp/workload.txt', json_encode(count($friends)));
        $workload = json_decode($job->workload());

        if($this->_stillValid($workload)) {

            echo 'Running send_push_notification for '.$workload->user_id. " [{$workload->notification->objectType} : {$workload->notification->title}] " . PHP_EOL;
            $this->userRepository = $this->services['dm']->getRepository('Document\User');

            $user = $this->userRepository->find($workload->user_id);

            $this->_sendPushNotification($user, get_object_vars($workload->notification));

            echo 'Done send_push_notification for '. $workload->user_id. " [{$workload->notification->objectType} : {$workload->notification->title}] " . PHP_EOL;

        } else {
            echo 'Skipping proximity alert push for '. $workload->user_id .' because of outdated'. PHP_EOL;
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
     *
     * @param \Document\User $user
     * @param array $notificationData
     */
    private function _sendPushNotification(\Document\User $user, array $notificationData)
    {
        $pushSettings = $user->getPushSettings();

        $pushNotifier = \Service\PushNotification\PushFactory::getNotifier(@$pushSettings['device_type']);
        if ($pushNotifier)
            echo $pushNotifier->send($notificationData, array($pushSettings['device_id']));
    }
}
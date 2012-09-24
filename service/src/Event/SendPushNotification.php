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

        $this->userRepository = $this->services['dm']->getRepository('Document\User');

        // Retrieve target user
        $user = $this->userRepository->find($workload->user_id);

        // Find friends who needs to be informed
        $this->sendNotificationToNearbyFriends($user);

        $this->runTasks();
    }

    private function sendNotification($user)
    {
        if (empty($user))
            return;

        // Retrieve target user's friends
        $friends = $this->userRepository->getAllByIds($user->getFriends(), false);

        // Retrieve target user's current location
        $from = $user->getCurrentLocation();

        // Collect list of friends who needs to be notified.
        $friendsToNotify = array();
        $friendsNotificationData = $this->_createNotificationData($user);

        foreach($friends as $friend) {
            // Retrieve friend's current location
            $to = $friend->getCurrentLocation();

            // Calculate distance between friend and target user
            $distance = \Helper\Location::distance($from['lat'], $from['lng'], $to['lat'], $to['lng']);

            // Determine whether target user should be notified if friend with in the range
            if($this->_shouldNotify($user, $friend, $distance)){
                $userNotificationData = $this->_createNotificationData($friend);
                \Helper\Notification::send($userNotificationData, array($user));
                $this->_sendPushNotification($user, $userNotificationData);
            }

            // Determine whether friend should be notified if user is in range
            if($this->_shouldNotify($friend, $user, $distance)){
               $friendsToNotify[] = $friend;

                $this->_sendPushNotification($friend, $friendsNotificationData);
            }
        }

        \Helper\Notification::send($friendsNotificationData, $friendsToNotify);
    }

    private function _sendPushNotification($user, $userNotificationData)
    {
        $pushSettings = $user->getPushSettings();

        $pushNotifier = \Service\PushNotification\PushFactory::getNotifier(@$pushSettings['device_type']);
        if ($pushNotifier)
            echo $pushNotifier->send($userNotificationData, array($pushSettings['device_id']));
    }

    private function _createNotificationData(\Document\User $friend)
    {
        return array(
            'title' => 'Your friend '. $friend->getName() .' is here!',
            'photoUrl' => $friend->getAvatar(),
            'objectId' => $friend->getId(),
            'objectType' => 'proximity_alert',
            'message' => 'Your friend '. $friend->getName() .' is near your location!',
        );
    }
}
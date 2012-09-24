<?php

namespace Event;

use Repository\UserRepo as UserRepository;

class ProximityAlert extends Base
{
    /**
     * @var UserRepository
     */
    protected $userRepository;

    const DEFAULT_RADIUS = 4;

    protected function setFunction()
    {
        $this->function = 'proximity_alert';
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

    private function sendNotificationToNearbyFriends($user)
    {
        if (empty($user))
            return;

        print_r($user->getFriends());
        // Retrieve target user's friends
        $friends = $this->userRepository->getAllByIds($user->getFriends(), false);

        // Retrieve target user's current location
        $from = $user->getCurrentLocation();

        // Collect list of friends who needs to be notified.
        $friendsToBeNotified  = array();
        $friendsNotifyAbout = array();

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
                $friendsNotifyAbout[] = $friend;
            }

            // Determine whether friend should be notified if user is in range
            if($this->_shouldNotify($friend, $user, $distance)){
                $friendsToBeNotified[] = $friend;

                $this->_sendPushNotification($friend, $friendsNotificationData);
            }
        }

        // Send grouped push notification about friends to user
        if(count($friendsNotifyAbout) > 0) {
            $this->_sendPushNotification($user, $this->_createNotificationData($friendsNotifyAbout));
        }

        // Send SM notification to all friends
        \Helper\Notification::send($friendsNotificationData, $friendsToBeNotified);
    }

    private function _sendPushNotification($user, $userNotificationData)
    {
        $pushSettings = $user->getPushSettings();

        $pushNotifier = \Service\PushNotification\PushFactory::getNotifier(@$pushSettings['device_type']);
        if ($pushNotifier)
            echo $pushNotifier->send($userNotificationData, array($pushSettings['device_id']));
    }

    private function _shouldNotify($user, $friend, $distance)
    {
        $notificationSettings = $user->getNotificationSettings();

        return self::DEFAULT_RADIUS >= $distance &&
               $friend->getVisible() &&
               $notificationSettings['proximity_alerts']['sm'];
    }

    private function _createNotificationData($friend)
    {
        if(is_array($friend)) {
            $groupedNames = $this->_createGroupedFriendNames($friend);
            return array(
                'title' => 'Your friend '. $groupedNames .' here!',
                'objectType' => 'proximity_alert',
                'message' => 'Your friend '. $groupedNames .' near your location!'
            );

        } else {
            return array(
                'title' => 'Your friend '. $friend->getName() .' is here!',
                'photoUrl' => $friend->getAvatar(),
                'objectId' => $friend->getId(),
                'objectType' => 'proximity_alert',
                'message' => 'Your friend '. $friend->getName() .' is near your location!'
            );
        }
    }

    private function _createGroupedFriendNames($friends)
    {
        if (count($friends) > 2) {
            return $friends[0]->getFirstName() .', '. $friends[1]->getFirstName(). ' and '. (count($friends) -2) . ' others are';
        } else if (count($friends) == 2) {
            return $friends[0]->getFirstName() .' and '. $friends[1]->getFirstName(). ' are';
        } else {
            return $friends[0]->getName() .' is ';
        }
    }
}
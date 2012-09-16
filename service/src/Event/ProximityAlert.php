<?php

namespace Event;

use Repository\UserRepo as UserRepository;

class ProximityAlert extends Base
{
    /**
     * @var UserRepository
     */
    protected $userRepository;

    const DEFAULT_RADIUS = 7;

    protected function setFunction()
    {
        $this->function = 'proximity_alert';
    }

    public function run(\GearmanJob $job)
    {
        //file_put_contents('/tmp/workload.txt', json_encode(count($friends)));
        $workload = json_decode($job->workload());

        $this->userRepository = $this->services['dm']->getRepository('Document\User');
        $user = $this->userRepository->find($workload->user_id);

        $friends = $this->userRepository->getAllByIds($user->getFriends(), false);

        $notificationSettings = $user->getNotificationSettings();
        $from = $user->getCurrentLocation();
        $friendsToNotify = array();

        foreach($friends as $friend) {
            $friendsNotificationSettings = $friend->getNotificationSettings();
            $to = $friend->getCurrentLocation();
            $distance = \Helper\Location::distance($from['lat'], $from['lng'], $to['lat'], $to['lng']);

            if($this->_shouldNotify($user, $friend, $distance)){
                \Helper\Notification::send($this->_createNotificationData($friend), array($user));
            }

            if($this->_shouldNotify($friend, $user, $distance)){
               $friendsToNotify[] = $friend;
            }
        }

        \Helper\Notification::send($this->_createNotificationData($user), $friendsToNotify);

        $this->runTasks();
    }

    private function _shouldNotify($user, $friend, $distance)
    {
        $notificationSettings = $user->getNotificationSettings();

        return     $friend->getVisible()
                && $notificationSettings['proximity_alerts']['sm']
                //&& $friendsNotificationSettings['proximity_radius'] >= $distance){
                && self::DEFAULT_RADIUS >= $distance;
    }

    private function _createNotificationData($friend)
    {
        return array(
            'title' => 'Your friend is here!',
            'photoUrl' => $friend->getAvatar(),
            'objectId' => $friend->getId(),
            'objectType' => 'proximity_alert',
            'message' => 'Your friend '. $friend->getName() .' is near your location!',
        );
    }
}
<?php

namespace Event;

use Repository\UserRepo as UserRepository;

class ProximityAlert extends Base {
    /**
     * @var UserRepository
     */
    protected $userRepository;

    const DEFAULT_RADIUS = 4;

    protected function setFunction() {
        $this->function = 'proximity_alert';
    }

    public function run(\GearmanJob $job) {
        $this->checkMemoryBefore();
        $this->logJob('Event::ProximityAlert', $job);
        $workload = json_decode($job->workload());
        $this->debug('Received workload - ' . $job->workload());

        try {
            if ($this->_stillValid($workload)) {
                $this->debug("Is still valid request");

                $this->userRepository = $this->services['dm']->getRepository('Document\User');
                $user = $this->userRepository->find($workload->user_id);

                if (!empty($user)) {
                    $this->userRepository->refresh($user);
                    $this->sendNotificationToNearbyFriends($user);
                }
                $this->services['dm']->clear();
            } else {
                echo 'Skipping proximity alert push for ' . $workload->user_id . ' because of outdated' . PHP_EOL;
            }

        } catch (\Exception $e) {
            $this->error("Failed to send proximity alert - " . $e->getMessage());
        }

        $this->runTasks();
        $this->checkMemoryAfter();
    }

    private function sendNotificationToNearbyFriends(\Document\User $user) {
        if (empty($user))
            return;

        $this->debug("Sending notification to {$user->getFirstName()}'s nearby friends");
        $friends = $this->services['dm']
                ->createQueryBuilder('Document\User')
                ->select('firstName', 'currentLocation')
                ->field('id')->in($user->getFriends())
                ->hydrate(false)
                ->getQuery()->execute();

        // Retrieve target user's current location
        $from = $user->getCurrentLocation();

        // Collect list of friends who needs to be notified.
        $friendsToBeNotified = array();
        $friendsNotifyAbout = array();

        $friendsNotificationData = $this->_createNotificationData($user);

        foreach ($friends as $friend) {
            try {
                // Retrieve friend's current location
                $to = $friend['currentLocation'];

                // Calculate distance between friend and target user
                $distance = \Helper\Location::distance($from['lat'], $from['lng'], $to['lat'], $to['lng']);

                // Determine whether target user should be notified if friend with in the range
                if ($this->_shouldNotify($user, $friend, $distance)) {
                    $userNotificationData = $this->_createNotificationData($friend);
                    \Helper\Notification::send($userNotificationData, array($user));
                    $friendsNotifyAbout[] = $friend;
                }

                // Determine whether friend should be notified if user is in range
                if ($this->_shouldNotify($friend, $user, $distance)) {
                    $friendsToBeNotified[] = $friend;

                    $this->_sendPushNotification($friend, $friendsNotificationData);
                }
            } catch (\Exception $e) {
                $this->warn('Failed to determine nearby friends to send proximity alert - ' . $e->getMessage());
            }
        }

        // Send grouped push notification about friends to user
        if (count($friendsNotifyAbout) > 0) {
            $this->_sendPushNotification($user, $this->_createNotificationData($friendsNotifyAbout));
        }

        // Send SM notification to all friends
        \Helper\Notification::send($friendsNotificationData, $friendsToBeNotified);
    }

    private function _sendPushNotification($user, $userNotificationData) {
        $pushSettings = $user->getPushSettings();

        $pushNotifier = \Service\PushNotification\PushFactory::getNotifier(@$pushSettings['device_type']);
        if ($pushNotifier)
            echo $pushNotifier->send($userNotificationData, array($pushSettings['device_id']));
    }

    private function _shouldNotify($user, $friend, $distance) {
        if (is_array($user))
            $notificationSettings = isset($user['notificationSettings']) ? $user['notificationSettings'] : array();
        else
            $notificationSettings = $user->getNotificationSettings();

        return $distance <= self::DEFAULT_RADIUS &&
               $friend->getVisible() &&
               $notificationSettings['proximity_alerts']['sm'];
    }

    private function _createNotificationData($friend) {
        if (is_array($friend)) {
            $groupedNames = $this->_createGroupedFriendNames($friend);
            return array(
                'title' => 'Your friend ' . $groupedNames . ' here!',
                'objectType' => 'proximity_alert',
                'message' => 'Your friend ' . $groupedNames . ' near your location!'
            );

        } else {
            return array(
                'title' => 'Your friend ' . $friend->getName() . ' is here!',
                'photoUrl' => $friend->getAvatar(),
                'objectId' => $friend->getId(),
                'objectType' => 'proximity_alert',
                'message' => 'Your friend ' . $friend->getName() . ' is near your location!'
            );
        }
    }

    private function _createGroupedFriendNames($friends) {
        if (count($friends) > 2) {
            return $friends[0]->getFirstName() . ', ' . $friends[1]->getFirstName() . ' and ' . (count($friends) - 2) . ' others are';
        } else if (count($friends) == 2) {
            return $friends[0]->getFirstName() . ' and ' . $friends[1]->getFirstName() . ' are';
        } else {
            return $friends[0]->getName() . ' is ';
        }
    }
}
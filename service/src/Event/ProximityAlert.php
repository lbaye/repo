<?php

namespace Event;

use Repository\UserRepo as UserRepository;

class ProximityAlert extends Base {
    /**
     * @var UserRepository
     */
    protected $userRepository;

    const ACCEPTABLE_DISTANCE_IN_METERS = 100;
    const MAX_ALLOWED_DISTANCE = 0.0621371;

    protected function setFunction() {
        $this->function = 'proximity_alert';
    }

    public function run(\GearmanJob $job) {
        $this->checkMemoryBefore();
        $this->logJob('Event::ProximityAlert', $job);
        $workload = json_decode($job->workload());
        $this->debug('Received workload - ' . $job->workload());

        try {
            if ($this->isFreshRequest($workload)) {
                $this->debug("Still valid request");
                $this->debug('Looking up user by id - ' . $workload->user_id);

                $this->userRepository = $this->services['dm']->getRepository('Document\User');
                $user = $this->userRepository->find($workload->user_id);

                if (!empty($user)) {
                    $this->debug('Searching nearby friends for user - ' . $user->getFirstName());
                    $this->services['dm']->refresh($user);
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
        $this->logCurrentLocation($user);

        # If current location is not 100 meters far from last location
        # Do nothing

        # Find friends from the nearby radius
        $friends = $this->findNearbyFriends($user);
        $this->debug('Found ' . count($friends) . ' friends from - ' . $user->getFirstName());

        # Inform friends about user's presence (one to one notification)
        #$this->informFriends($user, $friends);

        # Inform user about nearby friends (many to one notification)
        #$this->informUser($user, $friends);

        # Update current location in last location field

    }

    private function findNearbyFriends(\Document\User $user) {
        $from = $user->getCurrentLocation();

        $friendIds = array();
        $friends = $user->getFriends();
        foreach ($friends as $friendId) $friendIds[] = 'ObjectId(' . $friendId . ')';

        $friends = $this->services['dm']
                ->createQueryBuilder('Document\User')
                ->select('firstName', 'currentLocation', 'pushSettings')
                ->field('id')->in($friendIds)
                ->hydrate(false)
                ->field('currentLocation')->near($from['lng'], $from['lat']);

        $query = $friends->getQueryArray();
        $query['currentLocation']['$maxDistance'] = self::MAX_ALLOWED_DISTANCE;
        $friends->setQueryArray($query);

        $this->debug('QUERY - ' . json_encode($friends->getQuery()->debug()));

        return $friends->getQuery()->execute();
    }

    private function logCurrentLocation($user) {
        $this->debug($user->getFirstName() . '\'s current location - ' .
                     json_encode($user->getCurrentLocation()));
    }

    private function informUser(\Document\User $user, $friends) {
        # Aggregate all user's first name
        # Join them with 'comma'
        # And send out notification
    }

    private function informFriends(\Document\User $user, $friends) {
        $this->debug('Informing friends about - ' . $user->getFirstName() . ' presence.');

        # Iterate through each friend
        foreach ($friends as $friendHash) {
            $friend = $this->userRepository->map($friendHash);
            $friend->setId($friendHash['_id']->{'$id'});
            var_dump($friend->getId());

            # TODO: if friend allows inform her
            # Create in-app notification
            # Send push notification
            $this->debug("Sending notification to - " . $friend->getFirstName());
            $this->sendNotification($user, $friend);
        }
    }

    private function sendNotification(\Document\User $user, $friendOrFriends) {
        $from = $user->getCurrentLocation();

        if (is_array($friendOrFriends)) {
            $groupedNames = $this->_createGroupedFriendNames($friendOrFriends);
            $notification = array(
                'title' => 'Proximity Alert',
                'objectType' => 'proximity_alert',
                'message' => $groupedNames . 'near you!'
            );

        } else {
            $to = $friendOrFriends->getCurrentLocation();
            $distance = \Helper\Location::distance(
                $from['lat'], $from['lng'],
                $to['lat'], $to['lng']); // METER

            $message = $friendOrFriends->getFirstName() . ' is ' . ceil($distance) . 'm away';
            $notification = array(
                'title' => 'Proximity Alert',
                'photoUrl' => $friendOrFriends->getAvatar(),
                'objectId' => $friendOrFriends->getId(),
                'objectType' => 'proximity_alert',
                'message' => $message
            );
        }

        \Helper\Notification::send($notification, array($friendOrFriends));
        $this->pushNotification($friendOrFriends, $notification);

        return $notification;
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

    private function pushNotification($user, $notification) {
        $this->debug('Sending push notification to ' . $user->getFirstName());
        $this->debug(print_r($notification, true));

        $pushSettings = $user->getPushSettings();
        $pushNotifier = \Service\PushNotification\PushFactory::getNotifier(@$pushSettings['device_type']);
        $this->debug('Sending notification to ' . @$pushSettings['device_type']);

        if ($pushNotifier)
            echo $pushNotifier->send($notification, array($pushSettings['device_id']));
    }
}
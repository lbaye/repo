<?php

namespace Event;

use Repository\UserRepo as UserRepository;

class ProximityAlert extends Base {
    /**
     * @var UserRepository
     */
    protected $userRepository;

    const ACCEPTABLE_DISTANCE_IN_METERS = 100;
    const MAX_ALLOWED_DISTANCE = 0.033; # 3 KM

    protected function setFunction() {
        $this->function = 'proximity_alert';
    }

    public function run(\GearmanJob $job) {
        $this->checkMemoryBefore();
        $this->logJob('Event::ProximityAlert', $job);
        $workload = json_decode($job->workload());
        $this->debug('Received workload - ' . $job->workload());

        try {
            if ($this->isValidRequest($workload) && $this->isFreshRequest($workload)) {
                $this->debug("Still valid request");
                $this->debug('Looking up user by id - ' . $workload->user_id);

                $this->userRepository = $this->services['dm']->getRepository('Document\User');
                $user = $this->userRepository->find($workload->user_id);

                if (!empty($user)) {
                    $this->debug('Searching nearby friends for user - ' . $user->getFirstName());
                    $this->services['dm']->refresh($user);
                    $this->notifyNearbyFriends($user);
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

    private function isValidRequest($workload) {
        return !empty($workload->user_id);
    }

    private function notifyNearbyFriends(\Document\User $user) {
        if (empty($user))
            return;

        $this->debug("Sending notification to {$user->getFirstName()}'s nearby friends");
        $this->logCurrentLocation($user);

        # If current location is not 100 meters far from last location
        # Do nothing

        # Find friends from the nearby radius
        $friends = $this->findNearbyFriends($user);
        $this->debug('Found ' . count($friends) . ' friends from - ' . $user->getFirstName());

        if (count($friends) > 0) {
            # Inform friends about user's presence (one to one notification)
            $this->informFriends($user, $friends);

            # Inform user about nearby friends (many to one notification)
            $this->informUser($user, $friends);
        } else {
            $this->debug('Sad! No one is nearby ' . $user->getFirstName());
        }
    }

    private function findNearbyFriends(\Document\User $user) {
        $from = $user->getCurrentLocation();

        $friendIds = array();
        $friends = $user->getFriends();
        foreach ($friends as $friendId) $friendIds[] = $friendId;

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

    private function informUser(\Document\User $user, &$friendsCursor) {

        if ($friendsCursor instanceof \Doctrine\ODM\MongoDB\Cursor) {
            $friends = array_values($friendsCursor->toArray());
        }

        $this->debug('Informing user - ' . $user->getName() . ' about his nearby friends');

        if (count($friendsCursor) == 1) {
            $friend = $this->userRepository->find($friends[0]['_id']->{'$id'});
            $message = $this->createNotificationMessage($friend, $user);
        } else {
            $message = $this->createGroupNotificationMessage($friendsCursor);
        }

        $this->sendNotification($user, $this->addNotificationsCounts($user, $message));
    }

    private function informFriends(\Document\User $user, $friends) {
        $this->debug('Informing friends about - ' . $user->getFirstName() . ' presence.');

        # Iterate through each friend
        foreach ($friends as $friendHash) {
            $friend = $this->userRepository->find($friendHash['_id']->{'$id'});
            $this->userRepository->refresh($friend);

            # TODO: if friend allows inform her
            # Create in-app notification
            # Send push notification
            $this->sendNotification(
                $friend, $this->addNotificationsCounts(
                           $friend, $this->createNotificationMessage($user, $friend)));
        }
    }

    private function addNotificationsCounts(\Document\User $user, array $messages) {
        $countHash = $this->userRepository->generateNotificationCount($user->getId());
        return array_merge($messages, $countHash);
    }

    private function sendNotification(\Document\User $user, array $notification) {
        $this->debug("Sending notification to - " . $user->getName());

        \Helper\Notification::send($notification, array($user));
        $this->pushNotification($user, $notification);

        return $notification;
    }

    private function createNotificationMessage(\Document\User $user, \Document\User $friend) {
        $from = $user->getCurrentLocation();
        $to = $friend->getCurrentLocation();

        $distance = \Helper\Location::distance(
            $from['lat'], $from['lng'],
            $to['lat'], $to['lng']); // In METER

        $message = $user->getFirstName() . ' is ' . ceil($distance) . 'm away';

        return array(
            'title' => $message,
            'photoUrl' => $user->getAvatar(),
            'objectId' => $user->getId(),
            'objectType' => 'proximity_alert',
            'message' => $message
        );
    }

    private function createGroupNotificationMessage(\Doctrine\ODM\MongoDB\Cursor $friendsCursor) {
        $friends = array_values($friendsCursor->toArray());

        if (count($friends) > 2) {
            $message = $friends[0]['firstName'] . ', ' .
                       $friends[1]['firstName'] . ' and ' .
                       (count($friends) - 2) . ' others are';
        } else if (count($friends) == 2) {
            $message = $friends[0]['firstName'] . ' and ' .
                       $friends[1]['firstName'] . ' are';
        } else {
            $name = implode(" ", array_filter(
                                   array($friends[0]['firstName'],
                                        $friends[0]['lastName'])));
            $message = $name . ' is';
        }

        $message .= ' near you!';

        return array(
            'title' => $message,
            'objectType' => 'proximity_alert',
            'message' => $message
        );
    }

    private function pushNotification(\Document\User $user, $notification) {
        $this->debug('Sending push notification to ' . $user->getName());
        $this->debug(print_r($notification, true));

        $pushSettings = $user->getPushSettings();
        $pushNotifier = \Service\PushNotification\PushFactory::getNotifier(@$pushSettings['device_type']);
        $this->debug('Sending notification to ' . @$pushSettings['device_type']);

        if ($pushNotifier)
            echo $pushNotifier->send($notification, array($pushSettings['device_id']));
    }
}
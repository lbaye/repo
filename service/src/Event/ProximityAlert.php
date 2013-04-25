<?php

namespace Event;

use Repository\UserRepo as UserRepository;

/**
 * Background job for sending out proximity alert based on user's current location
 */
class ProximityAlert extends Base
{
    /**
     * @var UserRepository
     */
    protected $userRepository;

    const ACCEPTABLE_DISTANCE_IN_METERS = 500;
    const MAX_ALLOWED_DISTANCE = 0.033; # 3 KM

    protected function setFunction()
    {
        $this->function = 'proximity_alert';
    }

    public function run(\GearmanJob $job)
    {
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
                    $this->debug('Searching nearby friends for user - ' . $user->getUsernameOrFirstName());
                    $this->services['dm']->refresh($user);
                    $this->notifyNearbyFriends($user, $workload->newLoc, $workload->oldLoc);
                } else {
                    $this->debug("No such user found for id - " . $workload->user_id);
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

    private function isValidRequest($workload)
    {
        return !empty($workload->user_id);
    }

    private function notifyNearbyFriends(\Document\User $user, $newLoc = null, $oldLoc = null)
    {
        if (empty($user)) return;

        $this->debug("Sending notification to {$user->getUsernameOrFirstName()}'s nearby friends");
        $this->logCurrentLocation($user);

        # Find friends from the nearby radius
        $friends = $this->findClosebyFriends($user, $newLoc, $oldLoc);
        $this->debug('Found ' . count($friends) . ' friends from - ' . $user->getUsernameOrFirstName());

        if (count($friends) > 0) {
            # Inform friends about user's presence (one to one notification)
            $this->informFriends($user, $friends);

            # Inform user about nearby friends (many to one notification)
            $this->informUser($user, $friends);

        } else {
            $this->debug('Sad! No one is nearby ' . $user->getFirstName());
        }
    }

    private function findClosebyFriends(\Document\User $user, $newLoc, $oldLoc) {
        $this->debug('Finding closeby friends comparing users last location');
        $this->debug('Old location - ' . json_encode($oldLoc));
        $this->debug('New location - ' . json_encode($newLoc));

        $friendsSetNew = $this->findNearbyFriends($user, (array) $newLoc);
        $friendsSetOld = $this->findNearbyFriends($user, (array) $oldLoc);

        $this->debug('Friends from New SET - ' . json_encode($friendsSetNew));
        $this->debug('Friends from Old SET - ' . json_encode($friendsSetOld));

        // Get friends who has just in new radius
        $friends = array_diff($friendsSetNew, $friendsSetOld);

        $this->debug('Friends from difference - ' . json_encode($friends));

        return $friends;
    }

    private function mapWithId(array &$users) {
        $this->debug('Map with id');
        var_dump($users);
        $items = array();
        foreach ($users as $k => $user) $items[$user['_id']] = $user;
        return $items;
    }

    private function findNearbyFriends(\Document\User &$user, array $location = null)
    {
        $from = empty($location) ? $user->getCurrentLocation() : $location;

        $friendIds = array();
        $friends = $user->getFriends();
        foreach ($friends as $friendId) $friendIds[] = new \MongoId($friendId);

        $friends = $this->services['dm']
            ->createQueryBuilder('Document\User')
            ->select('_id', 'firstName', 'lastName', 'currentLocation', 'pushSettings', 'username')
            ->field('id')->in($friendIds)
            ->hydrate(false);

        $friendsCursor = $friends->getQuery()->execute();
        $friendsList = array();

        foreach ($friendsCursor as $friendHash) {
            if (isset($friendHash['currentLocation'])) {
                $to = $friendHash['currentLocation'];
                $distance = \Helper\Location::distance($from['lat'], $from['lng'], $to['lat'], $to['lng']);
                $this->debug($this->getUsername($friendHash) . ' is about - ' . $distance . ' m away');

                if ($distance <= self::ACCEPTABLE_DISTANCE_IN_METERS)
                    $friendsList[] = $friendHash;
            }
        }

        return $friendsList;
    }

    private function logCurrentLocation($user)
    {
        $this->debug($user->getUsernameOrFirstName() . '\'s current location - ' .
            json_encode($user->getCurrentLocation()));
    }

    private function informUser(\Document\User $user, &$allFriends)
    {
        $this->debug('Informing user - ' . $user->getName() . ' about his nearby friends');

        $friends = $this->filterFriendsByVisibility($user, $allFriends);

        if (!empty($friends)) {
            if (count($friends) == 1) {
                $friend = $this->userRepository->find($friends[0]['_id']->{'$id'});
                $message = $this->createNotificationMessage($friend, $user);
            } else {
                $message = $this->createGroupNotificationMessage($friends, $user);
            }

            $this->sendNotification($user, $this->addNotificationsCounts($user, $message));
        } else {
            $this->debug('No visible friend found');
        }
    }

    private function informFriends(\Document\User &$user, &$friends)
    {
        $this->debug('Informing friends about - ' . $user->getUsernameOrFirstName() . ' presence.');

        # Iterate through each friend
        foreach ($friends as $friendHash) {
            $friend = $this->userRepository->find($friendHash['_id']->{'$id'});
            $this->userRepository->refresh($friend);

            if (($user->isVisibleTo($friend))) {
                $this->sendNotification(
                    $friend, $this->addNotificationsCounts(
                    $friend, $this->createNotificationMessage($user, $friend)));
            }
        }
    }

    private function filterFriendsByVisibility(\Document\User &$user, &$friends)
    {
        $friendList = array();

        foreach ($friends as $friendHash) {
            $friend = $this->userRepository->find($friendHash['_id']->{'$id'});
            $this->userRepository->refresh($friend);

            if (($friend->isVisibleTo($user))) {
                $friendList[] = $friendHash;
            } else {
                $this->debug(sprintf('%s is not visible', $friend->getName()));
            }
            $friend = null;
        }
        return $friendList;
    }

    private function addNotificationsCounts(\Document\User $user, array $messages)
    {
        $countHash = $this->userRepository->generateNotificationCount($user->getId());
        return array_merge($messages, $countHash);
    }

    private function sendNotification(\Document\User $user, array $notification)
    {
        $this->debug("Sending notification to - " . $user->getName());

        \Helper\Notification::send($notification, array($user));
        $this->pushNotification($user, $notification);

        return $notification;
    }

    private function createNotificationMessage(\Document\User $user, \Document\User $friend)
    {
        $from = $user->getCurrentLocation();
        $to = $friend->getCurrentLocation();

        $distance = \Helper\Location::distance(
            $from['lat'], $from['lng'],
            $to['lat'], $to['lng']); // In METER

        $message = $user->getUsernameOrFirstName() . ' is ' . ceil($distance) . 'm away';

        return array(
            'title' => $message,
            'photoUrl' => $user->getAvatar(),
            'objectId' => $user->getId(),
            'objectType' => 'proximity_alert',
            'message' => $message,
            'receiverId' => $friend->getId()
        );
    }

    private function createGroupNotificationMessage(&$friends, \Document\User $user)
    {

        if (count($friends) > 2) {
            $message = $this->getUsername($friends[0], true) . ', ' .
                $this->getUsername($friends[1], true) . ' and ' .
                (count($friends) - 2) . ' others are';
        } else if (count($friends) == 2) {
            $message = $this->getUsername($friends[0], true) . ' and ' .
                $this->getUsername($friends[1], true) . ' are';
        } else {
            $message = $this->getUsername($friends[0], true) . ' is';
        }

        $message .= ' near you!';

        return array(
            'title' => $message,
            'objectType' => 'proximity_alert',
            'message' => $message,
            'receiverId' => $user->getId()
        );
    }

    private function pushNotification(\Document\User $user, $notification)
    {
        $this->debug('Sending push notification to ' . $user->getName());
        $this->debug(print_r($notification, true));

        $pushSettings = $user->getPushSettings();
        $pushNotifier = \Service\PushNotification\PushFactory::getNotifier(@$pushSettings['device_type']);
        $this->debug('Sending notification to ' . @$pushSettings['device_type']);

        if ($pushNotifier)
            echo $pushNotifier->send($notification, array($pushSettings['device_id']));
    }

    private function getUsername(array &$userHash, $fullName = false) {
        if (!empty($userHash)) {
            if (isset($userHash['username']) && !$fullName)
                return $userHash['username'];
            else if ($fullName && !isset($userHash['username']))
                return implode(" ", array_filter(
                       array($userHash['firstName'], $userHash['lastName'])));
            else
                return $userHash['firstName'];
        } else {
            return null;
        }
    }
}
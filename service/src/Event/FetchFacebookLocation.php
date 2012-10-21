<?php

namespace Event;

use Repository\ExternalUserRepo as ExtUserRepo;
use Repository\UserRepo as UserRepo;
use Document\User as User;
use Document\ExternalUser as ExtUser;
use Service\Location\Facebook as FB;

class FetchFacebookLocation extends Base {

    /**
     * Maximum number of users's checkins to show on map
     */
    const MAX_CHECKINS = 50;

    protected function setFunction() {
        $this->function = 'fetch_facebook_location';
    }

    public function run(\GearmanJob $job) {
        $this->logJob('FetchFacebookLocation', $job);
        $this->checkMemoryBefore();

        # Retrieve existing checkin repository's reference.
        $dm = $this->services['dm'];
        $extUserRepo = $dm->getRepository('Document\ExternalUser');
        $userRepo = $dm->getRepository('Document\User');

        # Process workload data
        $workload = json_decode($job->workload());
        $facebookId = $workload->facebookId;
        $facebookAuthToken = $workload->facebookAuthToken;
        $userId = $workload->userId;

        $this->debug("Retrieve Facebook Checkins for FBID - " .
                     $facebookId . ' and UID - ' . $userId);

        # Load SM user
        $smUser = $userRepo->find($userId);

        # Initiate facebook connection
        $facebook = new FB($facebookId, $facebookAuthToken);

        $this->debug('Connecting with facebook with authToken - ' .
                     $facebookAuthToken);

        # Retrieve all facebook friend's checkins
        $fbCheckIns = $facebook->getFbFriendsCheckins();
        $this->debug('Found ' . @count($fbCheckIns['data']) .
                                 ' facebook checkins from ' . $smUser->getFirstName() . ' checkins');

        # Retrieve checkins with meta data
        if (!empty($fbCheckIns)) {
            $fbCheckIns = $this->orderCheckinsByTimestamp($this->keepSingleCheckinPerUser($fbCheckIns['data']));
            $this->importExtUsersFromCheckins($dm, $extUserRepo, $smUser, $fbCheckIns, $facebook);
        } else {
            $this->debug("No facebook checkins found");
        }

        $this->checkMemoryAfter();
    }

    private function keepSingleCheckinPerUser($fbCheckIns) {
        $userCheckinMap = array();

        # Iterate through each checkin
        for ($i = 0; $i < count($fbCheckIns); $i++) {
            $checkin = $fbCheckIns[$i];
            $authorId = $checkin['author_uid'];

            # Map hash with user id and checkin object
            if (!array_key_exists($authorId, $userCheckinMap))
                $userCheckinMap[$authorId] = $checkin;

            # if user is already exists in hash don't add to the hash
        }

        # Keep maximum only 50 users
        return array_values(array_slice($userCheckinMap, 0, self::MAX_CHECKINS));
    }

    private function orderCheckinsByTimestamp(array $fbCheckIns) {
        $this->debug('Ordering ' . count($fbCheckIns) . ' by timestamp');
        $orderedCheckins = array();

        for ($i = 0; $i < count($fbCheckIns); $i++) {
            $checkin = $fbCheckIns[$i];
            $orderedCheckins[(int)$checkin['timestamp']] = $checkin;
        }

        ksort($orderedCheckins);
        return array_values(array_reverse($orderedCheckins));
    }

    private function importExtUsersFromCheckins(
        \Doctrine\ODM\MongoDB\DocumentManager $dm,
        ExtUserRepo $extUserRepo,
        User $smUser,
        array $fbCheckIns,
        FB $facebook) {

        $this->info('Importing external users (' . count($fbCheckIns) .
                    ') from ' . $smUser->getFirstName() . ' facebook checkins');

        $checkinsWithMetaData = $this->getCheckinsWithMetaData($facebook, $fbCheckIns);
        $changed = false;

        # Iterate through each check in
        for ($i = 0; $i < count($checkinsWithMetaData); $i++) {
            $checkinWithMeta = $checkinsWithMetaData[$i];

            try {
                if (isset($checkinWithMeta['refId'])) {
                    $this->debug("Looking for existing ExtUser - " . $checkinWithMeta['refId']);

                    # Retrieve or create new external user
                    $extUser = $this->findOrCreateOrUpdateExtUser($extUserRepo, $checkinWithMeta, $smUser, $changed);

                    if ($changed) {
                        $this->debug("There are unsaved changes, Now performing persist operation");
                        $dm->persist($extUser);
                    }

                    if ($i % 10)
                        $dm->flush();
                } else {
                    $this->warn("Found inconsistent data - " . json_encode($checkinWithMeta));
                }

            } catch (\Exception $e) {
                $this->error("Failed to handle checkin data - " . json_encode($checkinWithMeta));
            }
        }

        if ($changed)
            $dm->flush();

        $dm->clear();

        return $changed;
    }

    private function findOrCreateOrUpdateExtUser(
        ExtUserRepo $extUserRepo,
        array $checkinWithMeta, User $smUser, &$changed) {

        $extUser = $extUserRepo->findOneBy(
            array('refId' => $checkinWithMeta['refId'] . ''));

        if ($extUser == null) {
            $this->debug("Create ExtUser since it's not an existing ExtUser - " .
                         $checkinWithMeta['refId']);

            $extUser = $extUserRepo->map($checkinWithMeta);
            $extUser->setSmFriends(array($smUser->getId()));
            $this->setCurrentAddress($extUser);

            $changed = true;

        } else {

            $this->debug("Existing ExtUser found");
            $location = $extUser->getCurrentLocation();

            # Set new location if location is changed since last fetch.
            if ((float)$location['lat'] != (float)$checkinWithMeta['currentLocation']['lat'] ||
                (float)$location['lng'] != (float)$checkinWithMeta['currentLocation']['lng']
            ) {
                $this->debug("Location changed for user - {$extUser->getFirstName()}");
                $extUser = $extUserRepo->map($checkinWithMeta, $extUser);
                $this->setCurrentAddress($extUser);

                $changed = true;
            }

            # TODO: How to handle potentially larger friends list ?
            # If current user is not in SM Friends list add him to the list
            if (!in_array($smUser->getId(), $extUser->getSmFriends())) {
                $this->debug("Adding to {$extUser->getFirstName()} SM friends list");
                $extUser->setSmFriends(array_merge($extUser->getSmFriends(), $smUser->getId()));
            }
        }

        return $extUser;
    }

    private function setCurrentAddress(ExtUser &$extUser) {
        try {
            $this->debug("Retrieving location address for - {$extUser->getFirstName()}'s current location");
            $extUser->setLastSeenAt($this->_getAddress($extUser->getCurrentLocation()));
            $this->debug("User - {$extUser->getFirstName()} is at {$extUser->getLastSeenAt()}");
        } catch (\Exception $e) {
            $this->warn("Failed to retrieve address from google service - " . $e);
        }
    }

    private function getCheckinsWithMetaData(&$facebook, $fbCheckIns) {
        $this->debug("Building checkins with meta data");

        $checkinsInfo = array();

        # Iterate through each checkin data and map into a hash map
        for ($i = 0; $i < count($fbCheckIns); $i++) {
            $fbCheckIn = $fbCheckIns[$i];
            $fbFriendId = $fbCheckIn['author_uid'];
            $fbCoords = $fbCheckIn['coords'];
            $fbTimestamp = $fbCheckIn['timestamp'];

            $checkinsInfo[$fbFriendId] = array(
                'friendId' => $fbFriendId,
                'coords' => $fbCoords,
                'timestamp' => $fbTimestamp
            );
        }

        # Retrieve all users information
        $this->debug("Retrieving checkin associated friends detail information");
        $users = $facebook->getFbFriendsInfo(array_keys($checkinsInfo));

        $fullCheckinsInfo = array();

        # Map users info with user id
        foreach ($users['data'] as $user) {
            $this->debug('Building checkin information for user - ' . $user['first_name']);
            $uid = $user['uid'];
            $info = $checkinsInfo[$uid];

            $created_at = new \DateTime();
            $created_at->setTimestamp((int)$info['timestamp']);

            $fullCheckinsInfo[$uid] = array(
                'refId' => $uid,
                'refType' => \Document\ExternalUser::SOURCE_FB,
                'firstName' => $user['first_name'],
                'lastName' => $user['last_name'],
                'email' => $user['email'],
                'avatar' => $user['pic_square'],
                'createdAt' => $created_at,
                'currentLocation' => array(
                    'lat' => $info['coords']['latitude'],
                    'lng' => $info['coords']['longitude']
                )
            );
        }

        $this->debug("Found and constructed checkins with meta data");

        return array_values($fullCheckinsInfo);
    }
}
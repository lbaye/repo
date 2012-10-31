<?php

namespace Event;

use Repository\ExternalUserRepo as ExtUserRepo;
use Repository\UserRepo as UserRepo;
use Document\User as User;
use Document\ExternalUser as ExtUser;
use Service\Location\Facebook as FB;
use \Doctrine\ODM\MongoDB\DocumentManager as DM;

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
        $fbCheckIns = $facebook->getFriendsCheckins();
        $totalCheckins = @count($fbCheckIns['data']);
        $this->debug('Found ' . $totalCheckins . ' facebook checkins from ' .
                     $smUser->getFirstName() . ' checkins');

        # Retrieve checkins with meta data
        if (!empty($fbCheckIns)) {
            $fbCheckIns = $this->keepSingleCheckinPerUser($this->orderCheckinsByTimestamp($fbCheckIns['data']));

            $this->debug('Out of ' . $totalCheckins . ' only ' . count($fbCheckIns) . ' none expired checkins found.');

            if (count($fbCheckIns) > 0) {
                $this->importExtUsersFromCheckins($dm, $extUserRepo, $smUser, $fbCheckIns, $facebook);
            }
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

    /*
     * Order checkins by their creation date.
     */
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
        DM $dm, ExtUserRepo $extUserRepo, User $smUser, array $fbCheckIns, FB $facebook) {

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

    private function getCheckinsWithMetaData(FB &$facebook, $fbCheckIns) {
        $this->debug("Building checkins with meta data");

        $checkinsInfo = array();
        $pageIds = array();

        # Iterate through each checkin data and map into a hash map
        for ($i = 0; $i < count($fbCheckIns); $i++) {
            $fbCheckIn = $fbCheckIns[$i];
            $fbFriendId = $fbCheckIn['author_uid'];
            $fbCoords = $fbCheckIn['coords'];
            $fbTimestamp = $fbCheckIn['timestamp'];
            $fbPageId = $fbCheckIn['page_id'];

            $checkinsInfo[$fbFriendId] = array(
                'friendId' => $fbFriendId,
                'coords' => $fbCoords,
                'timestamp' => $fbTimestamp,
                'pageId' => $fbPageId
            );

            $pageIds[] = $fbPageId;
        }

        # Retrieve all users information
        $this->debug("Retrieving checkin associated friends detail information");
        $users = $facebook->getFriends(array_keys($checkinsInfo));

        $this->debug('Retrieving checkin detail information');
        $pages = $this->mapByPageId($facebook->getPages($pageIds));

        $fullCheckinsInfo = array();

        # Map users info with user id
        foreach ($users['data'] as $userInfo) {
            $this->debug('Building checkin information for user - ' . $userInfo['first_name']);
            $uid = $userInfo['uid'];
            $checkinInfo = $checkinsInfo[$uid];
            $pageInfo = $pages[$checkinInfo['pageId']];
            $this->debug('Found page info - ' . json_encode($pageInfo));

            $created_at = new \DateTime();
            $created_at->setTimestamp((int)$checkinInfo['timestamp']);

            $fullCheckinsInfo[$uid] = array(
                'refId' => $uid,
                'refType' => \Document\ExternalUser::SOURCE_FB,
                'firstName' => $userInfo['first_name'],
                'lastName' => $userInfo['last_name'],
                'email' => $userInfo['email'],
                'avatar' => $userInfo['pic_square'],
                'gender' => $userInfo['sex'],
                'createdAt' => $created_at,
                'lastSeenAt' => $pageInfo['name'],
                'currentLocation' => array(
                    'lat' => $checkinInfo['coords']['latitude'],
                    'lng' => $checkinInfo['coords']['longitude'],
                    'address' => $this->buildAddress($pageInfo)
                )
            );
        }

        $this->debug("Found and constructed checkins with meta data");

        return array_values($fullCheckinsInfo);
    }

    private function buildAddress(array $info) {
        $location = $info['location'];
        if (!empty($location)) {
            return implode(", ", array_filter(array($location['street'], $location['city'], $location['country'])));
        }

        return null;
    }

    private function mapByPageId(array $pagesResult) {
        $this->debug('Remapping pages with page_id as key and data as value');

        if (!empty($pagesResult)) {
            $pages = $pagesResult['data'];

            if (!empty($pages)) {
                $map = array();
                foreach ($pages as $page) $map[$page['page_id']] = $page;
                return $map;
            } else {
                $this->warn('Could not find pages information');
            }
        } else {
            $this->warn('Could not find pages information');
        }

        return array();

    }
}
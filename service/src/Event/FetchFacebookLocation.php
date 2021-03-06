<?php

namespace Event;

use Repository\ExternalUserRepo as ExtUserRepo;
use Repository\UserRepo as UserRepo;
use Document\User as User;
use Document\ExternalUser as ExtUser;
use Service\Location\Facebook as FB;
use \Doctrine\ODM\MongoDB\DocumentManager as DM;

/**
 * Background job for retrieving facebook friends from a facebook connected user.
 */
class FetchFacebookLocation extends Base
{

    /**
     * Maximum number of users's checkins to show on map
     */
    const MAX_CHECKINS = 1500;

    protected function setFunction()
    {
        $this->function = 'fetch_facebook_location';
    }

    public function run(\GearmanJob $job)
    {
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

        if (is_null($smUser)) {
            $this->debug('Invalid user id - ' . $userId);
            $this->runTasks();
            return;
        }

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

            # Reset current instance variables
            $fbCheckIns = null;
            $facebook = null;
            $smUser = null;
            $extUserRepo = null;
        } else {
            $this->debug("No facebook checkins found");
        }

        $this->debug('Cleaning up objects - ' . gc_collect_cycles());

        $this->checkMemoryAfter();
    }

    private function requestForCacheRefresh(User &$smUser)
    {
        $this->debug('Requesting for cache refresh');
        $this->addTaskBackground(\Helper\Constants::APN_CREATE_SEARCH_CACHE,
            json_encode(array('userId' => $smUser->getId())));
        $this->runTasks();
    }

    private function keepSingleCheckinPerUser(&$fbCheckIns)
    {
        $userCheckinMap = array();

        # Iterate through each checkin
        for ($i = 0; $i < count($fbCheckIns); $i++) {
            $checkin = &$fbCheckIns[$i];
            $authorId = &$checkin['author_uid'];

            # Map hash with user id and checkin object
            if (!array_key_exists($authorId, $userCheckinMap))
                $userCheckinMap[$authorId] = &$checkin;

            # if user is already exists in hash don't add to the hash
        }

        # Keep maximum only 100 users
        return array_values(array_slice($userCheckinMap, 0, self::MAX_CHECKINS));
    }

    /*
     * Order checkins by their creation date.
     */
    private function orderCheckinsByTimestamp(array &$fbCheckIns)
    {
        $this->debug('Ordering ' . count($fbCheckIns) . ' by timestamp');
        $orderedCheckins = array();

        for ($i = 0; $i < count($fbCheckIns); $i++) {
            $checkin = &$fbCheckIns[$i];
            $orderedCheckins[(int)$checkin['timestamp']] = &$checkin;
        }

        ksort($orderedCheckins);
        return array_values(array_reverse($orderedCheckins));
    }

    private function importExtUsersFromCheckins(
        DM &$dm, ExtUserRepo &$extUserRepo, User &$smUser, array &$fbCheckIns, FB &$facebook)
    {

        $this->info('Importing external users (' . count($fbCheckIns) .
            ') from ' . $smUser->getFirstName() . ' facebook checkins');

        $checkinsWithMetaData = $this->getCheckinsWithMetaData($facebook, $fbCheckIns);
        $changed = false;
        $changedCounts = 0;

        # Iterate through each check in
        for ($i = 0; $i < count($checkinsWithMetaData); $i++) {
            $checkinWithMeta = $checkinsWithMetaData[$i];

            try {
                if (isset($checkinWithMeta['refId'])) {
                    $this->debug("Looking for existing ExtUser - " . $checkinWithMeta['refId']);

                    # Retrieve or create new external user
                    $extUser = $this->findOrCreateOrUpdateExtUser($extUserRepo, $checkinWithMeta, $smUser, $changed);

                    if ($changed) {
                        $changedCounts++;
                        $this->debug("There are unsaved changes, Now performing persist operation");
                        $dm->persist($extUser);
                        $dm->flush();
                        $this->debug("Successfully inserted into database..." . $changedCounts . "refId: " . $checkinWithMeta['refId']);
                    } else {
                        $this->debug("Not changed  {$checkinWithMeta['refId']} to smFriends Hash ");
                    }

//                    if ($i % 10){
//                        $dm->flush();
//                        $this->debug("Successfully added into database...");
//                    }
                } else {
                    $this->warn("Found inconsistent data - " . json_encode($checkinWithMeta));
                }

            } catch (\Exception $e) {
                $this->error("Failed to handle checkin data - " . json_encode($checkinWithMeta));
            }
        }

        if ($changed) {
            $dm->flush();
            $this->requestForCacheRefresh($smUser);
        }

        $dm->clear();

        return $changed;
    }

    private function findOrCreateOrUpdateExtUser(
        ExtUserRepo &$extUserRepo,
        array &$checkinWithMeta, User &$smUser, &$changed)
    {

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
            } else {
                $this->debug("Just changed lat lng for user - {$extUser->getFirstName()}");
                $extUser = $extUserRepo->map($checkinWithMeta, $extUser);

                $changed = true;
            }

            # TODO: How to handle potentially larger friends list ?
            # If current user is not in SM Friends list add him to the list
            $this->debug("in_array check " . var_dump($smUser->getId()) . " smFriends: " . var_dump($extUser->getSmFriends()));
            if (!in_array($smUser->getId(), $extUser->getSmFriends())) {
                $this->debug("Adding to {$extUser->getFirstName()} SM friends list");
                $smFriendsList = array();
                $smFriendsList = $extUser->getSmFriends();
                if (!empty($smFriendsList)) {
                    $this->debug("Result of array_merge" . var_dump(array_merge($extUser->getSmFriends(), (array)$smUser->getId())));
                    $extUser->setSmFriends(array_merge($extUser->getSmFriends(), (array)$smUser->getId()));
                    $this->debug("smfriends is not empty!");
                } else {
                    $extUser->setSmFriends(array($smUser->getId()));
                    $this->debug("Existing smfriends is empty!");
                }
                $changed = true;

            } else {
//                $extUser->setSmFriends($smUser->getId());
                $this->debug("Adding  {$smUser->getId()} to smFriends Hash " . var_dump($extUser->getSmFriends()));
            }

        }

        return $extUser;
    }

    private function getCheckinsWithMetaData(FB &$facebook, &$fbCheckIns)
    {
        $this->debug("Building checkins with meta data");

        $checkinsInfo = array();
        $pageIds = array();

        # Iterate through each checkin data and map into a hash map
        for ($i = 0; $i < count($fbCheckIns); $i++) {
            $fbCheckIn = $fbCheckIns[$i];
            if (!empty($fbCheckIn['author_uid']) && !empty($fbCheckIn['page_id'])) {
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
                $this->debug("Get friend id: " . $fbFriendId . " page_id : " . $fbPageId);
            }
        }

        # Retrieve all users information
        $this->debug("Retrieving checkin associated friends detail information");
        $users = $facebook->getFriends(array_keys($checkinsInfo));

        $this->debug('Retrieving checkin detail information');
        $pages = $this->mapByPageId($facebook->getPages($pageIds));

        $fullCheckinsInfo = array();

        # Map users info with user id
        foreach ($users['data'] as &$userInfo) {
            $this->debug('Building checkin information for user - ' . $userInfo['first_name']);
            $uid = $userInfo['uid'];
            $checkinInfo = &$checkinsInfo[$uid];
            $pageInfo = &$pages[$checkinInfo['pageId']];
            $this->debug('Get page_id with info after mapping - ' . $checkinInfo['pageId']);
            $this->debug('Found page info - ' . json_encode($pageInfo));

            $created_at = new \DateTime();
            $created_at->setTimestamp((int)$checkinInfo['timestamp']);

            if (!empty($pageInfo['name'])) {
                $lastSeenAt = $pageInfo['name'];
            } else {
                $lastSeenAt = $this->buildAddress($pageInfo);
            }

            $fullCheckinsInfo[$uid] = array(
                'refId' => $uid,
                'refType' => \Document\ExternalUser::SOURCE_FB,
                'firstName' => $userInfo['first_name'],
                'lastName' => $userInfo['last_name'],
                'email' => $userInfo['email'],
                'avatar' => $userInfo['pic_square'],
                'gender' => $userInfo['sex'],
                'createdAt' => $created_at,
                'lastSeenAt' => $lastSeenAt,
//                'lastSeenAt' => $this->buildAddress($pageInfo),
                'currentLocation' => array(
                    'lat' => $checkinInfo['coords']['latitude'],
                    'lng' => $checkinInfo['coords']['longitude'],
                    'address' => $this->buildAddress($pageInfo)
                )
            );
            $this->debug("Full checkin info: " . json_encode($fullCheckinsInfo[$uid]));
        }

        $this->debug("Found and constructed checkins with meta data");

        return array_values($fullCheckinsInfo);
    }

    private function buildAddress(array $info)
    {
        $location = $info['location'];
        if (!empty($location)) {
            return implode(", ", array_filter(array(@$location['street'], @$location['city'], @$location['country'])));
        }

        return null;
    }

    private function mapByPageId(array &$pagesResult)
    {
        $this->debug('Remapping pages with page_id as key and data as value');
        $this->debug('page_id with location - ' . json_encode($pagesResult['data']));

        if (!empty($pagesResult['data'])) {
            $pages = $pagesResult['data'];

            $this->debug('page_id from page table - ' . json_encode($pages));

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
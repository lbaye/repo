<?php

namespace Event;

use Repository\ExternalUserRepo as ExtUserRepo;
use Repository\UserRepo as UserRepo;

class FetchFacebookLocation extends Base {
    protected function setFunction() {
        $this->function = 'fetch_facebook_location';
    }

    public function run(\GearmanJob $job) {
        $this->logJob('FetchFacebookLocation', $job);

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
        $facebook = new \Service\Location\Facebook(
            $facebookId, $facebookAuthToken);

        $this->debug('Connecting with facebook with authToken - ' .
                     $facebookAuthToken);

        # Retrieve all facebook friend's checkins
        $fbCheckIns = $facebook->getFbFriendsCheckins();
        $this->debug('Found ' . count($fbCheckIns) . ' facebook friends checkins');

        # Retrieve checkins with meta data
        if (!empty($fbCheckIns)) {
            $checkinsWithMetaData = $this->getCheckinsWithMetaData($facebook, $fbCheckIns);
            $changed = false;

            # Iterate through each check in
            foreach ($checkinsWithMetaData as $checkinWithMeta) {
                try {
                    if (isset($checkinWithMeta['refId'])) {
                        # Retrieve or create new external user
                        $extUser = $extUserRepo->findOneBy(
                            array('refId' => $checkinWithMeta['refId'] . ''));

                        if ($extUser == null) {
                            $this->debug("Not an existing facebook user - " .
                                         $checkinWithMeta['refId']);

                            $extUser = $extUserRepo->map($checkinWithMeta);
                            $extUser->setSmFriends(array($userId));
                            $changed = true;
                        } else {

                            # If current location is changed update!
                            $location = $extUser->getCurrentLocation();

                            if ((float)$location['lat'] != (float)$checkinWithMeta['currentLocation']['lat'] ||
                                (float)$location['lng'] != (float)$checkinWithMeta['currentLocation']['lng']
                            ) {
                                $this->debug("Location changed for user - {$extUser->getFirstName()}");
                                $extUser = $extUserRepo->map($checkinWithMeta, $extUser);
                                $changed = true;
                            }

                            # If current user is not in smUsers list add him
                            if (!in_array($smUser->getId(), $extUser->getSmFriends())) {
                                $this->debug("Adding to {$extUser->getFirstName()} SM friends list");
                                $extUser->setSmFriends(
                                    array_merge($extUser->getSmFriends(),
                                                array($userId)));
                            }
                        }
                    }

                    if ($changed)
                        $dm->persist($extUser);
                    
                } catch (\Exception $e) {
                    $this->error("Failed to handle checkin data - " . json_encode($checkinWithMeta));
                }

                # TODO: Bring it out of this loop
                if ($changed)
                    $dm->flush();

                # Clear from cached memory
                $dm->detach($extUser);
            }

        } else {
            $this->debug("No facebook checkins found");
        }
    }

    private function getCheckinsWithMetaData(&$facebook, $fbCheckIns) {
        $this->debug("Retrieving checkins with meta data");

        $checkinsInfo = array();

        # Iterate through each checkin data and map into a hash map
        foreach ($fbCheckIns['data'] as $fbCheckIn) {
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
        $users = $facebook->getFbFriendsInfo(array_keys($checkinsInfo));

        # Map users info with user id
        foreach ($users['data'] as $user) {
            $uid = $user['uid'];
            $info = $checkinsInfo[$uid];

            $created_at = new \DateTime();
            $created_at->setTimestamp((int)$info['timestamp']);

            $checkinsInfo[$uid] = array(
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

            try {
                $checkinsInfo[$uid]['lastSeenAt'] =
                        $this->_getAddress($checkinsInfo[$uid]['currentLocation']);
                
            } catch (\Exception $e) {
                $this->warn("Failed to retrieve address from google service - " . $e);
            }
        }

        $this->debug("Found and constructed checkins with meta data");

        return $checkinsInfo;
    }

    private function _getAddress($current_location) {
        $reverseGeo = new \Service\Geolocation\Reverse(
            $this->serviceConf['googlePlace']['apiKey']);

        $address = $reverseGeo->getAddress($current_location);
        $this->debug('Found reversed geo location - ' .
                     "$address ({$current_location['lat']}" . ', ' .
                     "{$current_location['lng']})");

        return $address;
    }
}
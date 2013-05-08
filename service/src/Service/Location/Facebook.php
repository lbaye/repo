<?php

namespace Service\Location;

/**
 * Facebook Graph API integration
 */
class Facebook extends Base
{
    public function getFriendLocation($userId, $authToken)
    {
        $fql = '
            SELECT id, author_uid, page_id, type, coords, timestamp, tagged_uids
            FROM location_post
            WHERE author_uid
            IN (SELECT uid2 FROM friend WHERE uid1=me())
            ';

        $results = $this->fetchFqlResult($fql);

        return ($results) ? $results : array();
    }

    /**
     * @param $checkinId
     * @return array|bool|mixed
     */
    public function getFriendsPageId($checkinId)
    {
        $fql = '
            SELECT author_uid, coords, timestamp, page_id
            FROM location_post
            WHERE checkin_id = ' . $checkinId . ')
            ';

        $results = $this->fetchFqlResult($fql);

        return ($results) ? $results : array();
    }

    /**
     * Retrieve checkins from all facebook friends.
     *
     * @param  $authToken string
     * @return array of checkins
     */
    public function getFriendsCheckins()
    {
        $fql = '
            SELECT id, author_uid, page_id, type, coords, timestamp, tagged_uids
            FROM location_post
            WHERE author_uid
            IN (SELECT uid2 FROM friend WHERE uid1=me()) AND type="checkin" AND timestamp > ' . strtotime("-2 week") . '
            ';

        $fbCheckins = $this->fetchFqlResult($fql);

        return (!empty($fbCheckins)) ? $fbCheckins : array();
    }

    /**
     * Retrieve checkins from all facebook friends.
     *
     * @param  $authToken string
     * @return array of checkins
     */
    public function prev_getFriendsCheckins()
    {
        $fql = '
            SELECT author_uid, coords, checkin_id, timestamp
            FROM checkin
            WHERE author_uid
            IN (SELECT uid2 FROM friend WHERE uid1 = me()) AND timestamp > ' . strtotime("-2 week") . '
            ';

        $fbCheckins = $this->fetchFqlResult($fql);

        return (!empty($fbCheckins)) ? $fbCheckins : array();
    }

    public function getFriends(array $friendIds)
    {
        $fql = '
            SELECT uid, first_name, last_name, pic_square, sex, email
            FROM user
            WHERE uid 
            IN (' . implode(', ', $friendIds) . ')
            ';

        $results = $this->fetchFqlResult($fql);

        return ($results) ? $results : array();
    }

    public function getPages(array &$pageIds)
    {
        $fql = '
            SELECT
                page_id, name, location
            FROM page
            WHERE page_id IN (' . implode(', ', $pageIds) . ')
            ';
        $results = $this->fetchFqlResult($fql);
        return (!empty($results)) ? $results : array();
    }

    public function getCheckInByAuth($userId, $authToken)
    {
        $fql = 'SELECT author_uid,coords,timestamp FROM checkin WHERE author_uid = $userId  AND author_uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) ORDER by timestamp desc';
        $results = $this->fetchFqlResult($fql);
        return ($results) ? $results : array();
    }


    public function getPublicProfile($facebookId)
    {
        $profile = $this->fetchGraphResult($facebookId);
        return $profile;
    }

    public function getPublicAvatar($facebookId)
    {
        $avatar = $this->getProfilePicture($facebookId);
        return $avatar;
    }

    private function fetchFqlResult($q)
    {
        $fql_query_url = 'https://graph.facebook.com' . '/fql?q='
            . urlencode($q)
            . '&access_token='
            . urlencode($this->getFacebookAuthToken());

        $fql_query_result = @file_get_contents($fql_query_url);

        if ($fql_query_result !== false) {
            $length = strlen(PHP_INT_MAX);
            $fql_query_result = preg_replace('/"(user_id)":(\d{' . $length . ',})/', '"\1":"\2"', $fql_query_result);
            return json_decode($fql_query_result, true);
        } else {
            return false;
        }
    }

    private function fetchGraphResult($path, array $params = array())
    {
        $graphUrl = 'https://graph.facebook.com' . '/' . $path .
            '?access_token=' . urlencode($this->getFacebookAuthToken());
        foreach ($params as $key => $value) {
            $graphUrl .= '&' . urlencode($key) . '=' . urlencode($value);
        }

        $graphResult = @file_get_contents($graphUrl);

        if ($graphResult !== false) {
            $length = strlen(PHP_INT_MAX);
            $graphResult = preg_replace('/"(user_id)":(\d{' . $length . ',})/', '"\1":"\2"', $graphResult);
            return json_decode($graphResult, true);
        } else {
            return false;
        }

    }

    private function getProfilePicture($facebookId)
    {
        $picUrl = 'https://graph.facebook.com' . '/' . $facebookId . '/picture';

        @file_get_contents($picUrl);
        $headers = $http_response_header;

        foreach ($headers as $header) {
            $parts = explode(':', $header);
            if ($parts[0] === 'Location') {
                return trim(implode(':', array_slice($parts, 1)));
            }
        }

        return false;
    }
}
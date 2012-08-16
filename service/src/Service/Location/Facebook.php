<?php

namespace Service\Location;

class Facebook extends Base
{
    public function getFriendLocation($userId, $authToken)
    {
        $fql = 'SELECT id, author_uid, page_id, type, coords, timestamp, tagged_uids FROM location_post WHERE author_uid IN (SELECT uid2 FROM friend WHERE uid1=me())';
        $results = $this->fetchFqlResult($fql, $authToken);

        return ($results) ? $results : array();
    }

    public function getPublicProfile($facebookId)
    {
        echo 'Fetching profile information for facebook user: ', $facebookId, PHP_EOL;
        $profile = $this->fetchGraphResult($facebookId);
        return $profile;
    }

    public function getPublicAvatar($facebookId)
    {
        echo 'Fetching avatar for facebook user: ', $facebookId, PHP_EOL;
        $avatar = $this->getProfilePicture($facebookId);
        return $avatar;
    }

    private function fetchFqlResult($q, $accessToken)
    {
        $fql_query_url = 'https://graph.facebook.com' . '/fql?q='
                       . urlencode($q)
                       . '&access_token='
                       . urlencode($accessToken);

        $fql_query_result = @file_get_contents($fql_query_url);

        if ($fql_query_result !== false) {
            $length = strlen(PHP_INT_MAX);
            $fql_query_result = preg_replace('/"(user_id)":(\d{' . $length . ',})/', '"\1":"\2"', $fql_query_result);
            return json_decode($fql_query_result, true);
        } else {
            return false;
        }
    }

    private function fetchGraphResult($path, $accessToken = null)
    {
        $graphUrl = 'https://graph.facebook.com' . '/' . $path;

        if ($accessToken) {
            $graphUrl .= '?access_token=' . urlencode($accessToken);
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
<?php

namespace Service\Location;

class Facebook extends Base
{
    public function getFriendLocation($userId, $authToken)
    {
        $fql = 'SELECT id, author_uid, page_id, type, coords, timestamp, tagged_uids
                FROM location_post
                WHERE author_uid IN (SELECT uid2 FROM friend WHERE uid1=me())';

        $locations = $this->fetchFqlResult($fql, $authToken);
        return $locations;
    }

    private function fetchFqlResult($q, $access_token)
    {
        $fql_query_url = 'https://graph.facebook.com' . '/fql?q='
                       . urlencode($q)
                       . '&access_token='
                       . urlencode($access_token);

        $fql_query_result = file_get_contents($fql_query_url);

        $length = strlen(PHP_INT_MAX);
        $fql_query_result = preg_replace('/"(user_id)":(\d{' . $length . ',})/', '"\1":"\2"', $fql_query_result);

        return json_decode($fql_query_result, true);
    }
}
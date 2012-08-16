<?php

namespace Service\Venue;

class GooglePlaces extends Base
{
    protected $apiKey;
    protected $endpoint;

    public function __construct($apiKey, $endpoint = "https://maps.googleapis.com/maps/api/place/search/json")
    {
        $this->apiKey = $apiKey;
        $this->endpoint = $endpoint;
    }

    public function search($keyword = null, $location = array())
    {
        $params['location'] = $location['lat'] . ',' . $location['lng'];

        if (!is_null($keyword)) {
            $params['keyword'] = $keyword;
            $params['rankby'] = 'distance';
        } else {
            $params['radius'] = '50000';
        }

        $params['sensor'] = 'false';
        $params['key'] = urlencode($this->apiKey);

        $target = $this->endpoint . "?" . http_build_query($params);
        list($responseCode, $responseBody) = \Helper\Remote::sendGetRequest($target);

        if ($responseCode != 200) {
            throw new \Exception("Service unavailable, cannot reach Google Places.", 503);
        }

        $content = json_decode($responseBody);

        if ($content->status == 'OK' || $content->status == 'ZERO_RESULTS') {
            return $content->results;
        } else {
            throw new \Exception("Service Unavailable (Google Places API said: '{$content->status}')", 503);
        }
    }
}
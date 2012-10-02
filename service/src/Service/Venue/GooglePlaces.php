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

    public function search($keyword = null, $location = array(), $radius = '2000')
    {
        $params['location'] = $location['lat'] . ',' . $location['lng'];

        if (!is_null($keyword)) {
            $params['keyword'] = $keyword;
        }

        $params['radius'] = $radius;
        $params['sensor'] = 'false';
        $params['key'] = urlencode($this->apiKey);

        $target = $this->endpoint . "?" . http_build_query($params);
        list($responseCode, $responseBody) = \Helper\Remote::sendGetRequest($target);

        if ($responseCode != 200) {
            throw new \Exception("Service unavailable, cannot reach Google Places.", 503);
        }

        $content = json_decode($responseBody);

        if ($content->status == 'OK' || $content->status == 'ZERO_RESULTS') {

            $sorted = array();

            foreach ($content->results as &$result) {
                $result->distance = \Helper\Location::distance($location['lat'], $location['lng'], $result->geometry->location->lat, $result->geometry->location->lng);
                $result->streetViewImage = "http://maps.googleapis.com/maps/api/streetview?size=450x200&location={$result->geometry->location->lat},%20{$result->geometry->location->lng}&sensor=false&key=$this->apiKey";
                $sorted[] = $result;
            }

            usort($sorted, function($a, $b) {

                if ($a === $b) {
                    return 0;
                }

                return ($a->distance < $b->distance) ? -1 : 1;
            });

            return $sorted;

        } else {

            throw new \Exception("Service Unavailable (Google Places API said: '{$content->status}')", 503);

        }
    }

}
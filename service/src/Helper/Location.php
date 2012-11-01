<?php

namespace Helper;

class Location
{
    const PLACES_KEY = 'AIzaSyAblaI77qQF6DDi5wbhWKePxK00zdFzg-w';

    /**
     * @static
     *
     * @param $lat1        float  latitude of point 1 (in decimal degrees)
     * @param $lon1        float  longitude of point 1 (in decimal degrees)
     * @param $lat2        float  latitude of point 2 (in decimal degrees)
     * @param $lon2        float  longitude of point 2 (in decimal degrees)
     * @param $unit        string  float  the unit you desire for results
     *                     where: 'm' is statute miles
     *                            'k' is kilometers (default)
     *                            'n' is nautical miles
     *                            'me' is meter
     *
     * @return float
     */
    public static function distance($lat1, $lon1, $lat2, $lon2, $unit = 'ME')
    {
        if (!empty($lat1) && !empty($lat2) && !empty($lon1) && !empty($lon2)) {
            if ($lat1 == $lat2 && $lon1 == $lon2) {
                $dist = 0.0;

            } else {
                $theta = $lon1 - $lon2;
                $dist = sin(deg2rad($lat1)) * sin(deg2rad($lat2)) + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * cos(deg2rad($theta));
                $dist = acos($dist);
                $dist = rad2deg($dist);

            }
        } else {
            return 0;
        }

        $miles = $dist * 60 * 1.1515;
        $unit  = strtoupper($unit);

        if ($unit == "ME") {
            return ($miles * 1609.344);
        } else if ($unit == "N") {
            return ($miles * 0.8684);
        } else {
            return $miles;
        }
    }

    public static function getNearbyVenues($lat, $lng, $endpoint = null)
    {
        $endpoint = $endpoint ? : "https://maps.googleapis.com/maps/api/place/search/json?location=$lat,$lng&rankby=distance&sensor=false&key=" . self::PLACES_KEY;

        list($responseCode, $responseBody) = Remote::sendGetRequest($endpoint);

        if ($responseCode != 200) {
            throw new \Exception("Service Unavailable, cannot reach 3rd party venue provider", 503);
        }

        $content = json_decode($responseBody);
        if ($content->status == 'OK' || $content->status == 'ZERO_RESULTS') {
            return $content->results;
        } else {
            throw new \Exception("Service Unavailable (Google said '{$content->status}')", 503);
        }
    }

}
<?php

namespace Service\Geolocation;

use Service\Cache\CacheAPI as CacheAPI;

class Reverse extends Base
{

    public function getAddress(array $location)
    {
        $lat = $location['lat'];
        $lng = $location['lng'];
        $type = "geocode";
        $id = $type . ':' . round($lat, 3) . ":" . round($lng, 3);

        $params['q'] = $lat . ',' . $lng;
        $params['output'] = 'json';
        $params['sensor'] = 'false';
        $params['key'] = urlencode($this->apiKey);

        $cache = new CacheAPI($this->dm);

        $response = $cache->get($id);

        if ($response) {                         // Found in Cache(db)
            $content = json_decode($response);
            return $content->Placemark[0]->address;
        }

        else {                                   // Not in Cache, have to fetch from google

        $target = $this->endpoint . "?" . http_build_query($params);
        list($responseCode, $responseBody) = \Helper\Remote::sendGetRequest($target);

        if ($responseCode != 200) {
            throw new \Exception("Service unavailable, cannot reach Google Maps.", 503);
        }

        $content = json_decode($responseBody);

        if ($content->Status->code == 200) {    // Save in Cache for future use

            $cache_object = new \Document\CachedData();
            $cache_object->setId($id);
            $cache_object->setData($responseBody);
            $cache_object->setType($type);


            $cache->put($cache_object);


            return $content->Placemark[0]->address;
        } else {
            throw new \Exception("Service Unavailable (Google Maps API said: '{$content->Status->code}')", 503);
        }
    }
    }
}
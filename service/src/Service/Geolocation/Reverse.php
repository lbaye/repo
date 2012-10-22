<?php

namespace Service\Geolocation;

use Service\Cache\CacheAPI as CacheAPI;

class Reverse extends Base
{



    const GEO_ACCURACY_LEVEL = 3;   // This saves up to N decimal places of a geocode. FOr example if lat = 72.111456 then for N=3 it will save 72.111


    public function getAddress(array $location)
    {
        $lat = $location['lat'];
        $lng = $location['lng'];
        $type = "geocode";
        $cacheKey = $type . ':' . round($lat, self::GEO_ACCURACY_LEVEL) . ":" . round($lng, self::GEO_ACCURACY_LEVEL);

        $params['q'] = $lat . ',' . $lng;
        $params['output'] = 'json';
        $params['sensor'] = 'false';
        $params['key'] = urlencode($this->apiKey);

        return $this->getFreshOrCachedAddress($cacheKey, $params, $lat, $lng, $type);
    }

    private function getFreshOrCachedAddress($cacheKey, $params, $lat, $lng, $type) {
        $cacheApi = new CacheAPI($this->dm);

        $data = $cacheApi->get($cacheKey);

        if ($data) {    // Found in Cache(db)
            return $data->getData();
        } else {
            $address = $this->getFreshAddress($params);
            $this->cacheAddress($cacheKey, $address, $lat, $lng, $type);
            return $address;

        }
    }

    private function cacheAddress($cacheKey, $address, $lat, $lng, $type) {

        $cacheApi = new CacheAPI($this->dm);
        return $cacheApi->put($cacheKey, $address, $lat, $lng, $type);

    }

    private function getFreshAddress($params) {
        $target = $this->endpoint . "?" . http_build_query($params);
        list($responseCode, $responseBody) = \Helper\Remote::sendGetRequest($target);

        if ($responseCode != 200) {
            throw new \Exception("Service unavailable, cannot reach Google Maps.", 503);
        }

        $content = json_decode($responseBody);

        if ($content->Status->code == 200) {    // Save in Cache for future use
            return $content->Placemark[0]->address;
        } else {
            throw new \Exception("Service Unavailable (Google Maps API said: '{$content->Status->code}')", 503);
        }
    }
}
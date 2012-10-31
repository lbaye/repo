<?php

namespace Service\Geolocation;

use \Service\Cache\CacheServiceFactory as CacheServiceFactory;

class Reverse extends Base
{

    // This saves up to N decimal places of a geocode. FOr example if lat = 72.111456 then for N=3 it will save 72.111
    const GEO_ACCURACY_LEVEL = 3;

    public function getAddress(array $location)
    {
        $this->logger->debug('Get address from - ' . json_encode($location));

        $lat = $location['lat'];
        $lng = $location['lng'];
        $type = "geocode";

        $cacheKey = $type . '_' . round($lat, self::GEO_ACCURACY_LEVEL) . "_" . round($lng, self::GEO_ACCURACY_LEVEL);
        $this->logger->debug('Built cache key - ' . $cacheKey);

        $params['q'] = $lat . ',' . $lng;
        $params['output'] = 'json';
        $params['sensor'] = 'false';
        $params['key'] = urlencode($this->apiKey);

        $cacheApi = CacheServiceFactory::getService(CacheServiceFactory::TYPE_MONGO);
        return $this->getFreshOrCachedAddress($cacheApi, $cacheKey, $params, $lat, $lng, $type);
    }

    private function getFreshOrCachedAddress($cacheApi, $cacheKey, $params, $lat, $lng, $type) {
        $data = $cacheApi->get($cacheKey);

        if ($data) {    // Found in Cache(db)
            $this->logger->debug('Found address from cache - ' . $data->getData());
            return $data->getData();
        } else {
            $address = $this->getFreshAddress($params);
            $data = new \Document\CachedData();
            $data->setLat($lat);
            $data->setLng($lng);
            $data->setType($type);
            $data->setData($address);
            $cacheApi->put($cacheKey, $data);
            $this->logger->debug('Not found in cache - ' . $address);
            $this->logger->debug('Created new cache at #' . $data->getId());

            return $address;
        }
    }

    private function getFreshAddress($params) {
        $target = $this->endpoint . "?" . http_build_query($params);
        list($responseCode, $responseBody) = \Helper\Remote::sendGetRequest($target);

        if ($responseCode != 200) {
            $this->logger->warn('Failed to get address');
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
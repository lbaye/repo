<?php

namespace Service\Geolocation;

use \Service\Cache\CacheServiceFactory as CacheServiceFactory;

/**
 * Convert geo location to a specific address using google places API
 */
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

    private function getFreshOrCachedAddress($cacheApi, $cacheKey, $params, $lat, $lng, $type)
    {
        $data = $cacheApi->get($cacheKey);
//        $address = $this->getAddressFromReverseGeo($lat, $lng);
//        $this->logger->debug('Get reversegeocode with new API - ' . $address);
//        return $address;

        if ($data) { // Found in Cache(db)
            $this->logger->debug('Found address from cache - ' . $data->getData());
            return $data->getData();
        } else {
//            $address = $this->getFreshAddress($params);
            $address = $this->getAddressFromReverseGeo($lat, $lng);
            $this->logger->debug('Get reversegeocode with new API - ' . $address);
            $this->logger->debug('Get Address From reversegeocode - ' . $address);
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

    private function getFreshAddress($params)
    {
        $target = $this->endpoint . "?" . http_build_query($params);
        list($responseCode, $responseBody) = \Helper\Remote::sendGetRequest($target);

        if ($responseCode != 200) {
            $this->logger->warn('Failed to get address');
            throw new \Exception("Service unavailable, cannot reach Google Maps.", 503);
        }

        $content = json_decode($responseBody);

//        if ($content->Status->code == 200) {    // Save in Cache for future use
//            return $content->Placemark[0]->address;
//        } else {
//            throw new \Exception("Service Unavailable (Google Maps API said: '{$content->Status->code}')", 503);
//        }
        if (!empty($content)) { // Save in Cache for future use
            $this->logger->debug('Get reversegeocode pos[0] - ' . $content);
            return $content->results[0]->formatted_address;
        } else {
            throw new \Exception("Service Unavailable (Google Maps API said: '{$content->results[0]->formatted_address}')", 503);
        }
    }

    private function getAddressFromReverseGeo($lat, $lng)
    {
        // set your API key here
        $api_key = "AIzaSyD_R73_cR92W83gUHkiqw35-yO4erVYsaw";
        // format this string with the appropriate latitude longitude

        $url = 'http://maps.googleapis.com/maps/api/geocode/json?latlng=' . $lat . ',' . $lng . '&sensor=false';
        // make the HTTP request
        $data = @file_get_contents($url);
        // parse the json response
        $jsondata = json_decode($data, true);

        if (is_array($jsondata) && !empty($jsondata ['results'][0]['formatted_address'])) {
            $address = $jsondata ['results'][0]['formatted_address'];
        } else {
            $address = "";
        }

        return $address;

    }
}
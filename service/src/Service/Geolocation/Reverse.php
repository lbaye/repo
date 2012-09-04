<?php

namespace Service\Geolocation;

class Reverse extends Base
{

    public function getAddress(array $location)
    {
        $params['q'] = $location['lat'] . ',' . $location['lng'];
        $params['output'] = 'json';
        $params['sensor'] = 'false';
        $params['key'] = urlencode($this->apiKey);

        $target = $this->endpoint . "?" . http_build_query($params);
        list($responseCode, $responseBody) = \Helper\Remote::sendGetRequest($target);

        if ($responseCode != 200) {
            throw new \Exception("Service unavailable, cannot reach Google Maps.", 503);
        }

        $content = json_decode($responseBody);

        if ($content->Status->code == 200) {
            return $content->Placemark[0]->address;
        } else {
            throw new \Exception("Service Unavailable (Google Maps API said: '{$content->Status->code}')", 503);
        }
    }
}
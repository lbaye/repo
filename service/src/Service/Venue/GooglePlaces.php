<?php

namespace Service\Venue;

/**
 * Search venue using google places API
 */
class GooglePlaces extends Base
{
    private $apiKey;
    private $endpoint;
    private $config;

    public function __construct(
        $apiKey, $config = array(),
        $endpoint = "https://maps.googleapis.com/maps/api/place/search/json")
    {
        $this->apiKey = $apiKey;
        $this->endpoint = $endpoint;
        $this->config = $config;
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
                $result->distance = \Helper\Location::distance(
                    $location['lat'], $location['lng'],
                    $result->geometry->location->lat,
                    $result->geometry->location->lng);

                $result->streetViewImage = \Helper\Url::getStreetViewImageOrReturnEmpty(
                    $this->config, (array) $result->geometry->location);

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

    private function get_street_view_image($lat, $lng, $key) {
        $endpoint = "http://maps.google.com/cbk?output=json&hl=en&ll=" . $lat . "," . $lng . "&radius=50&cb_client=maps_sv&v=4&key=" . $key ;

        $handler = curl_init();
        curl_setopt($handler, CURLOPT_HEADER, 0);
        curl_setopt($handler, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($handler, CURLOPT_URL, $endpoint);
        $data = curl_exec($handler);

        $http_status = curl_getinfo($handler, CURLINFO_HTTP_CODE);

        curl_close($handler);

        // if data value is an empty json document ('{}') , the panorama is not available for that point
        if ($data === '{}' || $http_status != 200) {

            // setting the range for lat, lng
            $lat_min = $lat - 1;
            $lat_max = $lat + 1;
            $lng_min = $lng - 1;
            $lng_max = $lng + 1;

            $url = "http://www.panoramio.com/map/get_panoramas.php?set=full&from=0&to=2&minx={$lng_min}&miny={$lat_min}&maxx={$lng_max}&maxy={$lat_max}&size=medium&mapfilter=true";
            
            $handler = curl_init($url);
            curl_setopt($handler, CURLOPT_RETURNTRANSFER, true);
            
            $response = curl_exec($handler);
            $http_status = curl_getinfo($handler,CURLINFO_HTTP_CODE);
            curl_close($handler);
            
            $response = json_decode($response);
            $result = $response->photos[0];
            $image_url = $result->photo_file_url;
            
            if (is_null($image_url) || $http_status != 200) {
                    return "";
                } else {
                    return $image_url;
                }
        }
        else {
             return "http://maps.googleapis.com/maps/api/streetview?size=" . $size ."&location=" . $lat . "," . $lng . "&fov=90&heading=235&pitch=10&sensor=false&key={$key}";
        }

    }

}
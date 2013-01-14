<?php

namespace Helper;

/**
 * Helper for URL related utility methods
 */
class Url
{
    public static function getSlug($str, $replace = array(), $delimiter = '-')
    {
        if (!empty($replace)) {
            $str = str_replace((array)$replace, ' ', $str);
        }

        $clean = iconv('UTF-8', 'ASCII//TRANSLIT', $str);
        $clean = preg_replace("/[^a-zA-Z0-9\/_|+ -]/", '', $clean);
        $clean = strtolower(trim($clean, '-'));
        $clean = preg_replace("/[\/_|+ -]+/", $delimiter, $clean);

        return $clean;
    }

    public static function buildAbsoluteUrl($prefix, $suffix)
    {
        $http_prefixed = preg_match("/http:\/\//i", $suffix) ||
            preg_match("/https:\/\//i", $suffix);

        if (empty($suffix)) {
            return null;
        } else if ($http_prefixed) {
            return $suffix;
        } else {

            return $prefix . $suffix;
        }
    }

    public static function buildCoverPhotoUrl($data)
    {
        return self::buildAbsoluteUrl(Dependencies::$rootUrl, $data['coverPhoto']);
    }

    public static function buildAvatarUrl($data)
    {
        return self::buildAbsoluteUrl(Dependencies::$rootUrl, $data['avatar']);
    }

    public static function buildEventPhotoUrl($data)
    {
        return self::buildAbsoluteUrl(Dependencies::$rootUrl, $data['eventImage']);
    }

    public static function buildPlacePhotoUrl($data)
    {
        return self::buildAbsoluteUrl(Dependencies::$rootUrl, $data['photo']);
    }

    public static function buildPlaceIconUrl($data)
    {
        return self::buildAbsoluteUrl(Dependencies::$rootUrl, $data['icon']);
    }

    public static function buildPhotoUrl($data)
    {
        return self::buildAbsoluteUrl(Dependencies::$rootUrl, $data['photo']);
    }

    public static function buildStreetViewImage($key, array $position, $size = "320x130")
    {
        $lat = $position['lat'];
        $lng = $position['lng'];
        return "http://maps.googleapis.com/maps/api/streetview?size=" .
            $size . "&location=" . $lat . "," . $lng .
            "&fov=90&heading=235&pitch=10&sensor=false&key=" . $key;
    }

    public static function getStreetViewImageOrReturnEmpty($config, array $location, $size = "320x130")
    {
        $key = $config['googlePlace']['apiKey'];
        $baseUrl = $config['web']['root'];

        $lat = $location['lat'];
        $lng = $location['lng'];
        $endpoint = "http://maps.google.com/cbk?output=json&hl=en&ll=" . $lat . "," . $lng .
            "&radius=50&cb_client=maps_sv&v=4&key=" . $key;

        $handler = curl_init();
        curl_setopt($handler, CURLOPT_HEADER, 0);
        curl_setopt($handler, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($handler, CURLOPT_URL, $endpoint);
        $data = curl_exec($handler);

        $http_status = curl_getinfo($handler, CURLINFO_HTTP_CODE);

        curl_close($handler);

        // if data value is an empty json document ('{}') , the panorama is not available for that point
        if ($data === '{}' || $http_status != 200) {
            return $baseUrl . '/assets/images/default-cover-photo.png';
        } else {
            return self::buildStreetViewImage($key, $location, $size);
        }
    }

    public static function buildFacebookAvatar($fbId) {
        return 'https://graph.facebook.com/' . $fbId . '/picture?type=normal';
    }
}
<?php

namespace Helper;

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

    public static function buildAbsoluteUrl($prefix, $suffix) {
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

    public static function buildCoverPhotoUrl($data) {
        return self::buildAbsoluteUrl(Dependencies::$rootUrl, $data['coverPhoto']);
    }

    public static function buildAvatarUrl($data) {
        return self::buildAbsoluteUrl(Dependencies::$rootUrl, $data['avatar']);
    }
}
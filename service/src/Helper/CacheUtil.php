<?php

namespace Helper;

class CacheUtil {

    public static function hasExpired(&$cachePath) {
        return !file_exists($cachePath);
    }

    public static function createCacheReference(&$cacheRefRepo, &$user, &$cachePath, &$params, &$people) {
        # Collect all participants
        $userIds = array();
        foreach ($people as $person) $userIds[] = $person['id'];

        $ref = new \Document\CacheRef();
        $ref->setCacheFile($cachePath);
        $ref->setLocation(array('lat' => $params['lat'], 'lng' => $params['lng']));
        $ref->setParticipants($userIds);
        $ref->setOwner($user);
        $cacheRefRepo->insert($ref);

        return true;
    }

    public static function ensureDirectoryExistence($cachePath) {
        $directory = dirname($cachePath);
        if (!file_exists($directory))
            mkdir($directory, 0777, true);
    }

    public static function buildSearchCachePath(\Document\User &$user, $data) {
        $lat = round((float)$data['lat'], 3);
        $lng = round((float)$data['lng'], 3);

        return implode(DIRECTORY_SEPARATOR,
                       array(ROOTDIR, '..', 'app', 'cache', 'static_caches', 'search',
                            $user->getAuthToken() . '-' . $lat . '-' . $lng));
    }


}

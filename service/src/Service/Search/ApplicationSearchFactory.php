<?php

namespace Service\Search;

class ApplicationSearchFactory {

    const AS_DEFAULT = 'default';
    const AS_CACHED = 'cached';

    static $mInstances = array();

    public static function getInstance(
        $key, \Document\User $user,
        \Doctrine\ODM\MongoDB\DocumentManager &$dm,
        array &$config) {

        return isset(self::$mInstances[$key]) ?
                self::$mInstances[$key] :
                self::buildInstance($key, $user, $dm, $config);
    }

    private static function buildInstance(&$key, $user, &$dm, &$config) {
        switch ($key) {
            case self::AS_DEFAULT :
                return self::$mInstances[self::AS_DEFAULT] =
                        new \Service\Search\ApplicationSearch($user, $dm, $config);
        }
    }
}
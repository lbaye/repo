<?php

namespace Service\Search;

/**
 * Application search factory
 */
class ApplicationSearchFactory {

    const AS_DEFAULT = 'default';
    const AS_CACHED = 'cached';

    static $mInstances = array();

    public static function getInstance(
        $type, \Document\User $user,
        \Doctrine\ODM\MongoDB\DocumentManager &$dm,
        array &$config) {

        return isset(self::$mInstances[$type]) ?
                self::$mInstances[$type] :
                self::buildInstance($type, $user, $dm, $config);
    }

    private static function buildInstance(&$type, $user, &$dm, &$config) {
        switch ($type) {
            case self::AS_DEFAULT :
                return self::$mInstances[self::AS_DEFAULT] =
                        new \Service\Search\ApplicationSearch($user, $dm, $config);
        }
    }
}
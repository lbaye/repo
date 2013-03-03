<?php

namespace Service\Cache;

/**
 * Factory for providing caching implementation
 */
abstract class CacheServiceFactory {

    const TYPE_MONGO = 'mongo';
    static $instances = array();

    public static function getService($type) {
        switch ($type) {
            case self::TYPE_MONGO:
                $inst = self::$instances[self::TYPE_MONGO];
                if ($inst)
                    return $inst;
                else
                    return self::$instances[self::TYPE_MONGO] =
                            new \Service\Cache\impl\MongoCacheStorage(\Helper\Dependencies::$dm);


        }
    }
}

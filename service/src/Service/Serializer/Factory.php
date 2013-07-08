<?php
namespace Service\Serializer;

/**
 * Serializer factory
 */
class Factory
{
    static $serializerInstances = array();

    public static function getSerializer($type)
    {
        if (!empty(self::$serializerInstances[$type])) {
            return self::$serializerInstances[$type];
        } else {
            return self::$serializerInstances[$type] =
                    self::createSerializerInstance($type);
        }
    }

    private static function createSerializerInstance($type)
    {
        switch (strtolower($type)) {
            case 'json':
                return new JSONSerializable();
            default:
                throw new \Exception("Invalid serializer name - $type");
        }
    }
}

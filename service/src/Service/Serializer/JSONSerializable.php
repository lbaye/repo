<?php
namespace Service\Serializer;

class JSONSerializable implements Serializable
{

    public function serialize(array &$hash, array $options = array())
    {
        if (array_key_exists('except', $options))
            $this->applyExcept($options['except'], $hash);

        return @json_encode($hash);
    }

    private function applyExcept(array $exceptFields, array &$hash)
    {
        foreach ($hash as &$item) {
            foreach ($exceptFields as &$field) {
                unset($item[$field]);
            }
        }
    }
}

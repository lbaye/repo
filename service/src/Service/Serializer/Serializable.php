<?php
namespace Service\Serializer;

/**
 * Interface for implementing serializer
 */
interface Serializable
{
    public function serialize(array &$hash, array $options = array());
}
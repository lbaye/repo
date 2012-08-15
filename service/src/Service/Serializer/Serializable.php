<?php
namespace Service\Serializer;

interface Serializable
{

    public function serialize(array &$hash, array $options = array());
}
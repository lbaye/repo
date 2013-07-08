<?php

namespace Service\Venue;

/**
 * @ignore
 */
abstract class Base
{
    abstract public function search($keyword = null, $location = array());
}
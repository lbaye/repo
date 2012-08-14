<?php

namespace Service\Venue;

abstract class Base
{
    abstract public function search($keyword = null, $location = array());
}
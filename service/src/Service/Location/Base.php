<?php

namespace Service\Location;

abstract class Base
{
    abstract public function getFriendLocation($userId, $authToken);
}
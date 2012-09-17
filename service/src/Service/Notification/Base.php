<?php

namespace Service\Notification;

abstract class Base
{
    abstract public function send(array $data, array $deviceIds);
}
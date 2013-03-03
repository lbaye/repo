<?php

namespace Service\PushNotification;

/**
 * @ignore
 */
abstract class Notifier
{
    protected $apiKey;
    protected $endpoint;

    public function __construct($apiKey, $endpoint)
    {
        $this->apiKey = $apiKey;
        $this->endpoint = $endpoint;
    }

    abstract public function send(array $data, array $deviceIds);
}
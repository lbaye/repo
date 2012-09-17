<?php

namespace Service\Geolocation;

abstract class Base
{
    protected $apiKey;
    protected $endpoint;

    public function __construct($apiKey, $endpoint = "http://maps.google.com/maps/geo")
    {
        $this->apiKey = $apiKey;
        $this->endpoint = $endpoint;
    }
}
<?php

namespace Service\Geolocation;

abstract class Base
{
    protected $apiKey;
    protected $endpoint;
    protected $dm;

    public function __construct($apiKey, \Doctrine\ODM\MongoDB\DocumentManager $dm,
                                $endpoint = "http://maps.google.com/maps/geo")
    {
        $this->apiKey = $apiKey;
        $this->endpoint = $endpoint;
        $this->dm = $dm;
    }
}
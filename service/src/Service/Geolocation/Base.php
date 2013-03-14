<?php

namespace Service\Geolocation;

/**
 * @ignore
 */
abstract class Base
{
    protected $apiKey;
    protected $endpoint;
    protected $dm;
    protected $logger;

    public function __construct(
        $logger, $apiKey, \Doctrine\ODM\MongoDB\DocumentManager $dm,
        $endpoint = "http://maps.googleapis.com/maps/api/geocode/json")
    {
        $this->apiKey = $apiKey;
        $this->endpoint = $endpoint;
        $this->dm = $dm;
        $this->logger = $logger;
    }
}
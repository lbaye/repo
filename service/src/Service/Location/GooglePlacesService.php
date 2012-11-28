<?php

namespace Service\Location;

use Monolog\Logger as Logger;

/**
 * Implements google places API
 */
class GooglePlacesService implements IPlacesService {

    private $mApiKey;
    private $mApiInstance;
    private $mLogger;

    public function __construct(Logger $logger, $pApiKey) {
        $this->mLogger = $logger;
        $this->mApiKey = $pApiKey;
        $this->mApiInstance = new \Service\Venue\GooglePlaces($this->mApiKey);
    }

    function search(array $location, $keywords, $radius = 2000) {
        return $this->mApiInstance->search($keywords, $location, $radius);
    }
}

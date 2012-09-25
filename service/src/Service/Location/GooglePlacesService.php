<?php

namespace Service\Location;

/**
 * Implements google places API
 */
class GooglePlacesService implements IPlacesService {

    private $mApiKey;
    private $mApiInstance;

    public function __construct($pApiKey) {
        $this->mApiKey = $pApiKey;
        $this->mApiInstance = new \Service\Venue\GooglePlaces($this->mApiKey);
    }

    function search(array $location, $keywords, $radius = 2000) {
        return $this->mApiInstance->search($keywords, $location, $radius);
    }
}

<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

/**
 * @ODM\Document(collection="cacheRefs", repositoryClass="Repository\CacheRefRepo")
 * @ODM\Index(keys={"currentLocation"="2d"})
 */
class CacheRef extends Content {
    /** @ODM\Id */
    protected $id;

    /** @ODM\String */
    protected $cacheFile;

    /** @ODM\Hash */
    protected $currentLocation = array(
        'lng' => 0, 'lat' => 0
    );

    /** @ODM\Hash */
    protected $participants = array();

    public function isValid() {
        return true;
    }

    public function setCacheFile($cacheFile) {
        $this->cacheFile = $cacheFile;
    }

    public function getCacheFile() {
        return $this->cacheFile;
    }

    public function setCurrentLocation($currentLocation) {
        $this->currentLocation = $currentLocation;
    }

    public function getCurrentLocation() {
        return $this->currentLocation;
    }

    public function setParticipants($participants) {
        $this->participants = $participants;
    }

    public function getParticipants() {
        return $this->participants;
    }
}
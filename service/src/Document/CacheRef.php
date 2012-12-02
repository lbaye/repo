<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

/**
 * @ODM\Document(collection="cacheRefs", repositoryClass="Repository\CacheRefRepo")
 * @ODM\Index(keys={"location"="2d"})
 */
class CacheRef {
    /** @ODM\Id */
    protected $id;

    /** @ODM\String */
    protected $cacheFile;

    /** @ODM\Hash */
    protected $location = array(
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

    public function setParticipants($participants) {
        $this->participants = $participants;
    }

    public function getParticipants() {
        return $this->participants;
    }

    public function setLocation($location) {
        $this->location = $location;
    }

    public function getLocation() {
        return $this->location;
    }
}
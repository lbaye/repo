<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

/**
 * Domain model for cache reference, this model is linked with "cacheRefs" collection
 *
 * @ODM\Document(collection="cacheRefs", repositoryClass="Repository\CacheRefRepo")
 * @ODM\Index(keys={"location"="2d"})
 */
class CacheRef {
    /** @ODM\Id */
    private $id;

    /** @ODM\String */
    private $cacheFile;

    /** @ODM\Hash */
    private $location = array(
        'lng' => 0, 'lat' => 0
    );

    /**
     * @ODM\ReferenceOne(targetDocument="User", simple=true)
     */
    private $owner;

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

    public function setOwner($owner) {
        $this->owner = $owner;
    }

    public function getOwner() {
        return $this->owner;
    }


}
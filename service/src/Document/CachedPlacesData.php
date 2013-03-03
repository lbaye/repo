<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

/**
 * Domain model for storing cached places data, this model is linked with "cached_places_data" collection
 *
 * @ODM\Document(collection="cached_places_data",repositoryClass="Repository\CachedPlacesDataRepo")
 */
class CachedPlacesData {
    /**
     * @ODM\Id(strategy="none")
     */
    protected $id;

    /** @ODM\String */
    protected $cachedData;

    /** @ODM\String */
    protected $lat;

    /** @ODM\String */
    protected $lng;

    /** @ODM\String */
    protected $source;

    public function toArray() {
        $data = array(
            'id' => $this->getId(),
            'lat' => $this->getLat(),
            'lng' => $this->getLng(),
            'cachedData' => $this->getCachedData(),
            'source' => $this->getSource()
        );

        return $data;
    }

    public function setCachedData($cachedData) {
        if (!empty($cachedData)) {
            $this->cachedData = json_encode($cachedData);
        } else {
            $this->cachedData = $cachedData;
        }
    }

    public function getCachedData() {
        if (!empty($this->cachedData)) {
            return json_decode($this->cachedData);
        } else {
            return $this->cachedData;
        }
    }

    public function setId($id) {
        $this->id = $id;
    }

    public function getId() {
        return $this->id;
    }

    public function setSource($source) {
        $this->source = $source;
    }

    public function getSource() {
        return $this->source;
    }

    public function setLat($lat) {
        $this->lat = $lat;
    }

    public function getLat() {
        return $this->lat;
    }

    public function setLng($lng) {
        $this->lng = $lng;
    }

    public function getLng() {
        return $this->lng;
    }

    public function isValid() { return true; }

}
<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

/**
 * @ODM\EmbeddedDocument
 */
class Marker
{
    /** @ODM\Id */
    protected $id;

    /** @ODM\Id */
    protected $venueID;

    public function setVenueID($venueID)
    {
        $this->venueID = $venueID;
    }

    public function getVenueID()
    {
        return $this->venueID;
    }

    /** @ODM\Float */
    protected $lat;

    /** @ODM\Float */
    protected $lng;

    /** @ODM\Float */
    protected $markerNumber;

    public function setMarkerNumber($markerNumber)
    {
        $this->markerNumber = $markerNumber;
    }

    public function getMarkerNumber()
    {
        return $this->markerNumber;
    }

    /** @ODM\Hash */
    protected $photos = array();


    public function setLng($lng)
    {
        $this->lng = $lng;
    }

    public function getLng()
    {
        return $this->lng;
    }

    public function setLat($lat)
    {
        $this->lat = $lat;
    }

    public function getLat()
    {
        return $this->lat;
    }

    public function setId($id)
    {
        $this->id = $id;
    }

    public function getId()
    {
        return $this->id;
    }

    public function setPhotos($photos)
    {
        $this->photos = $photos;
    }

    public function addPhoto($photo)
    {
        $this->photos[$photo] = $photo;
    }

    public function deletePhoto($photo)
    {
        unset($this->photos[$photo]);
    }

    public function getPhotos()
    {
        return $this->photos;
    }


    public function toArray()
    {
        $fieldsToExpose = array('trailID', 'lat', 'lng', 'markerNumber');
        $result = array();

        foreach($fieldsToExpose as $field) {
            $result[$field] = $this->{"get{$field}"}();
        }

        return $result;
    }

    public function map(array $data)
    {
        $setIfExistFields = array('trailID', 'lat', 'lng', 'markerNumber');

        foreach($setIfExistFields as $field) {
            if (isset($data[$field]) && !is_null($data[$field])) {
                $this->{"set{$field}"}($data[$field]);
            }
        }

        return $this;
    }

    public function isValid()
    {
        try {
            Validator::create()->float()->assert($this->getLat());
            Validator::create()->float()->assert($this->getLng());

        } catch (\InvalidArgumentException $e) {
            return false;
        }

        return true;
    }

}

<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

/**
 * Domain model for storing location specific data, this is used as embedded model.
 *
 * @ODM\EmbeddedDocument
 */
class Location
{
    /** @ODM\Float */
    protected $lat;

    /** @ODM\Float */
    protected $lng;

    /** @ODM\String */
    protected $title;

    /** @ODM\String */
    protected $address;

    function __construct(array $data = null)
    {
        if(!is_null($data)){
            $this->map($data);
        }

        return $this;
    }

    //<editor-fold defaultstate="collapsed" desc="Setters">

    public function setLat($lat)
    {
        $this->lat = $lat;
    }

    public function setLng($lng)
    {
        $this->lng = $lng;
    }

    public function setTitle($title)
    {
        $this->title = $title;
    }

    public function setAddress($address)
    {
        $this->address = $address;
    }
    //</editor-fold>

    //<editor-fold desc="Getters" >

    public function getLat()
    {
        return $this->lat;
    }

    public function getLng()
    {
        return $this->lng;
    }

    public function getTitle()
    {
        return $this->title;
    }

    public function getAddress()
    {
        return $this->address;
    }
    //</editor-fold>

    public function toArray()
    {
        $fieldsToExpose = array('title', 'lat', 'lng', 'address');
        $result = array();

        foreach($fieldsToExpose as $field) {
            $result[$field] = $this->{"get{$field}"}();
        }

        return $result;
    }

    public function map(array $data)
    {
        $setIfExistFields = array('title', 'lat', 'lng', 'address');

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
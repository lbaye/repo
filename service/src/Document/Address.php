<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

/**
 * @ODM\EmbeddedDocument
 */
class Address
{
    /** @ODM\Id */
    protected $id;

    /** @ODM\String */
    protected $street;

    /** @ODM\String */
    protected $city;

    /** @ODM\String */
    protected $state;

    /** @ODM\String */
    protected $postCode;

    /** @ODM\String */
    protected $country;

    /**
       * @ODM\EmbedOne(targetDocument="Location")
       * @var Location
    */
    protected $location;

    function __construct(array $data = null)
    {
        if(!is_null($data)){
            $this->map($data);
        }

        return $this;
    }

    //<editor-fold defaultstate="collapsed" desc="Setters">
    public function setId($id)
    {
        $this->id = $id;
    }

    public function getId()
    {
        return $this->id;
    }

    public function setStreet($street)
    {
        $this->street = $street;
    }

    public function getStreet()
    {
        return $this->street ;
    }

    public function setCity($city)
    {
        $this->city = $city;
    }

    public function getCity()
    {
        return $this->city;
    }

    public function setState($state)
    {
        $this->state = $state;
    }

    public function getState()
    {
        return $this->state ;
    }

    public function setPostCode($postal)
    {
        $this->postCode = $postal;
    }

    public function getPostCode()
    {
        return $this->postCode;
    }

    public function setCountry($country)
    {
        return $this->country = $country;
    }

    public function getCountry()
    {
        return $this->country;
    }

    public function setLocation($location)
    {
        $this->location = $location;
    }

    public function getLocation($location)
    {
        return $this->location;
    }

    //</editor-fold>

    public function toArray()
    {
        $fieldsToExpose = array('id', 'street', 'city', 'state', 'postCode', 'country');
        $result = array();

        foreach($fieldsToExpose as $field) {
            $result[$field] = $this->{"get{$field}"}();
        }

        return $result;
    }

    public function map(array $data)
    {
        $setIfExistFields = array('id', 'street', 'city', 'state', 'postCode', 'country');

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
            Validator::create()->notEmpty()->assert($this->getStreet());
            Validator::create()->notEmpty()->assert($this->getCity());
            Validator::create()->notEmpty()->assert($this->getState());
            Validator::create()->notEmpty()->assert($this->getPostCode());
            Validator::create()->notEmpty()->assert($this->getCountry());
        } catch (\InvalidArgumentException $e) {
            return false;
        }

        return true;
    }
}
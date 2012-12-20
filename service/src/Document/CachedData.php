<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;

/**
 * Domain model for storing cached data, this model is linked with "cached_data" collection
 *
 * @ODM\Document(collection="cached_data",repositoryClass="Repository\CachedDataRepo")
 */
class CachedData
{

    /**
     * @ODM\Id(strategy="none")
     */
    private $id;

    /**
     * @ODM\String
     */
    private $data;

    /**
     * @ODM\String
     */
    private $type;

    /**
     * @ODM\String
     */
    private $lat;

    /**
     * @ODM\String
     */
    private $lng;

    public function setLat($lat)
    {
        $this->lat = $lat;
    }

    public function getLat()
    {
        return $this->lat;
    }

    public function setLng($lng)
    {
        $this->lng = $lng;
    }

    public function getLng()
    {
        return $this->lng;
    }


    public function setData($data)
    {
        $this->data = $data;
    }

    public function getData()
    {
        return $this->data;
    }

    public function setId($id)
    {
        $this->id = $id;
    }

    public function getId()
    {
        return $this->id;
    }

    public function setType($type)
    {
        $this->type = $type;
    }

    public function getType()
    {
        return $this->type;
    }


    public function isValid()
    {
        return true;
    }

}
<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

/**
 * Domain model for storing position related data. this model is used as an embedded model
 *
 * @ODM\EmbeddedDocument
 */
class Position
{
    /** @ODM\Id */
    protected $id;

    /**
    * @ODM\EmbedMany(targetDocument="Location")
    * @var Location
    */
    protected $location = array();

    /**
    * @ODM\EmbedMany(targetDocument="Image")
    * @var Image
    */
    protected $image = array();

    /** @ODM\Date */
    protected $createDate;

    /** @ODM\Date */
    protected $updateDate;

    function __construct(array $data = null)
    {
        if(!is_null($data)){
            $this->map($data);
        }

        return $this;
    }

    public function setId($id)
    {
        $this->id = $id;
    }

    public function getId()
    {
        return $this->id;
    }


    public function setCreateDate($createDate)
    {
        $this->createDate = $createDate;
    }

    public function getCreateDate()
    {
        return $this->createDate;
    }


    public function setUpdateDate($updateDate)
    {
        $this->updateDate = $updateDate;
    }

    public function getUpdateDate()
    {
        return $this->updateDate;
    }

        public function toArray()
    {
        $fieldsToExpose = array('id', 'createDate', 'updateDate');
        $result = array();

        foreach($fieldsToExpose as $field) {
            $result[$field] = $this->{"get{$field}"}();
        }

        return $result;
    }

    public function map(array $data)
    {
        $setIfExistFields = array('id', 'createDate', 'updateDate');

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
            Validator::create()->notEmpty()->assert($this->getLocation());

        } catch (\InvalidArgumentException $e) {
            return false;
        }

        return true;
    }

    public function addLocation($location)
    {
        $this->location[] = $location;
    }

    public function getLocation()
    {
        return $this->location;
    }


    public function addImage($image)
    {
        $this->image[] = $image;
    }

    public function getImage()
    {
        return $this->image;
    }

}
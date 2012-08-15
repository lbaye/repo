<?php
namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

/**
 * @ODM\EmbeddedDocument
 */

class Image
{
    /** @ODM\Id */
    protected $id;

    /** @ODM\String */
    protected $caption;

    /** @ODM\String */
    protected $photoUrl;

    /** @ODM\Float */
    protected $lat;

    /** @ODM\Float */
    protected $lng;

    /** @ODM\Float */
    protected $size;

    /** @ODM\Date */
    protected $createDate;

    function __construct(array $data = null)
    {
        if(!is_null($data)){
            $this->map($data);
        }

        return $this;
    }

    public function setCaption($caption)
    {
        $this->caption = $caption;
    }

    public function getCaption()
    {
        return $this->caption;
    }

    public function setCreateDate($createDate)
    {
        $this->createDate = $createDate;
    }

    public function getCreateDate()
    {
        return $this->createDate;
    }

    public function setId($id)
    {
        $this->id = $id;
    }

    public function getId()
    {
        return $this->id;
    }

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

    public function setPhotoUrl($photoUrl)
    {
        $this->photoUrl = $photoUrl;
    }

    public function getPhotoUrl()
    {
        return $this->photoUrl;
    }

    public function setSize($size)
    {
        $this->size = $size;
    }

    public function getSize()
    {
        return $this->size;
    }

        public function toArray()
    {
        $fieldsToExpose = array('id','caption','photoUrl','lat','lng','size', 'createDate');
        $result = array();

        foreach($fieldsToExpose as $field) {
            $result[$field] = $this->{"get{$field}"}();
        }

        return $result;
    }

    public function map(array $data)
    {
        $setIfExistFields = array('id','caption','photoUrl','lat','lng','size', 'createDate');

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
            Validator::create()->notEmpty()->assert($this->getCaption());
            Validator::create()->notEmpty()->assert($this->getPhotoUrl());
            Validator::create()->notEmpty()->assert($this->getLat());
            Validator::create()->notEmpty()->assert($this->getLng());

        } catch (\InvalidArgumentException $e) {
            return false;
        }

        return true;
    }
}

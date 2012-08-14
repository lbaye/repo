<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

/**
 * @ODM\EmbeddedDocument
 */
class Notification
{
    /** @ODM\Id */
    protected $id;

    /** @ODM\String */
    protected $title;

    /** @ODM\String */
    protected $photoUrl;

    /** @ODM\String */
    protected $objectId;

    /** @ODM\String */
    protected $objectType;

    /** @ODM\String */
    protected $message;

    /** @ODM\Boolean */
    protected $viewed;


    function __construct(array $data = null)
    {
        if (!is_null($data)) {
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

    public function setObjectId($objectId)
    {
        $this->objectId = $objectId;
    }

    public function getObjectId()
    {
        return $this->objectId;
    }

    public function setObjectType($objectType)
    {
        $this->objectType = $objectType;
    }

    public function getObjectType()
    {
        return $this->objectType;
    }

    public function setMessage($message)
    {
        $this->message = $message;
    }

    public function getMessage()
    {
        return $this->message;
    }

    public function setTitle($title)
    {
        $this->title = $title;
    }

    public function getTitle()
    {
        return $this->title;
    }

    public function setPhotoUrl($photoUrl)
    {
        $this->photoUrl = $photoUrl;
    }

    public function getPhotoUrl()
    {
        return $this->photoUrl;
    }

    public function setViewed($viewed)
    {
        $this->viewed = $viewed;
    }

    public function getViewed()
    {
        return $this->viewed;
    }

    public function toArray()
    {
        $fieldsToExpose = array('id', 'title','photoUrl', 'objectId', 'objectType', 'message', 'viewed');
        $result = array();

        foreach ($fieldsToExpose as $field) {
            $result[$field] = $this->{"get{$field}"}();
        }

        return $result;
    }

    public function map(array $data)
    {
        $setIfExistFields = array('id', 'title','photoUrl', 'objectId', 'objectType', 'message', 'viewed');

        foreach ($setIfExistFields as $field) {
            if (isset($data[$field]) && !is_null($data[$field])) {
                $this->{"set{$field}"}($data[$field]);
            }
        }

        return $this;
    }

    public function isValid()
    {
        try {
            Validator::create()->notEmpty()->assert($this->getObjectId());
            Validator::create()->notEmpty()->assert($this->getObjectType());
            Validator::create()->bool()->assert($this->getViewed());

        } catch (\InvalidArgumentException $e) {
            return false;
        }

        return true;
    }


}
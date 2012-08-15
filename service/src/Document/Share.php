<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

use Document\Notification as Notification;

class Share extends Content
{
    /** @ODM\Id */
    protected $id;

    /**
    * @ODM\EmbedMany(targetDocument="Notification")
    * @var Notification
    */
    protected $notification = array();

    /** @ODM\Date */
    protected $createDate;

    /** @ODM\Date */
    protected $updateDate;

    public function addNotification($notification)
    {
        $this->notification[] = $notification;
    }

    public function getNotification()
    {
        return $this->notification;
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
        $fieldsToExpose = array('id', 'notification','createDate','updateDate');
        $result = array();

        foreach($fieldsToExpose as $field) {
            $result[$field] = $this->{"get{$field}"}();
        }

        $result['owner'] = $this->getOwner()->getId();
        $result['notification'] = $this->getNotification()->toArray();

        return $result;
    }

    public function isValid()
    {
        try {
            Validator::create()->notEmpty()->assert($this->getNotification());

        } catch (\InvalidArgumentException $e) {
            return false;
        }

        return true;
    }
}


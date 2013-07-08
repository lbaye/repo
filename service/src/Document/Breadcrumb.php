<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

use Document\Position;


/**
 * Domain model for storing breadcrumb related data, this model is connected with "breadcrumbs" collection
 * @ignore
 * @ODM\Document(collection="breadcrumbs",repositoryClass="Repository\BreadcrumbRepo")
 */
class Breadcrumb extends Content
{
    /** @ODM\Id */
    protected $id;

    /** @ODM\String */
    protected $title;

    /**
    * @ODM\EmbedMany(targetDocument="Position")
    * @var Position
    */
    protected $position = array();

     /** @ODM\Date */
    protected $createDate;

    /** @ODM\Date */
    protected $updateDate;

    public function setId($id)
    {
        $this->id = $id;
    }

    public function getId()
    {
        return $this->id;
    }

    public function setTitle($title)
    {
        $this->title = $title;
    }

    public function getTitle()
    {
        return $this->title;
    }

    public function addPosition($position)
    {
        $this->position[] = $position;
    }

    public function getPosition()
    {
        return $this->position;
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
        $fieldsToExpose = array('id', 'title','createDate','updateDate');
        $result = array();

        foreach($fieldsToExpose as $field) {
            $result[$field] = $this->{"get{$field}"}();
        }

        $result['owner'] = $this->getOwner()->getId();
        $result['position'] = $this->getPosition()->toArray();

        return $result;
    }

    public function isValid()
    {
        try {
            Validator::create()->notEmpty()->assert($this->getTitle());

        } catch (\InvalidArgumentException $e) {
            return false;
        }

        return true;
    }


}

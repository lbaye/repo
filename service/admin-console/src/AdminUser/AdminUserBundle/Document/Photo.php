<?php

namespace AdminUser\AdminUserBundle\Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as MongoDB;
use Symfony\Component\Validator\Constraints as Assert;
use Doctrine\Bundle\MongoDBBundle\Validator\Constraints\Unique as MongoDBUnique;

/**
 * @MongoDB\Document(collection="photos")
 * @MongoDBUnique(fields="id")
 */
class Photo
{
    /** @MongoDB\Id */
    protected $id;

    /** @MongoDB\String */
    protected $uriThumb;

    /** @MongoDB\String */
    protected $uriMedium;

    /** @MongoDB\String */
    protected $uriLarge;

    /** @MongoDB\String */
    protected $title;

    /** @MongoDB\String */
    protected $description;

    public function setId($id)
    {
        $this->id = $id;
    }

    public function getId()
    {
        return $this->id;
    }

    public function setDescription($description)
    {
        $this->description = $description;
    }

    public function getDescription()
    {
        return $this->description;
    }

    public function setTitle($title)
    {
        $this->title = $title;
    }

    public function getTitle()
    {
        return $this->title;
    }

    public function setUriLarge($uriLarge)
    {
        $this->uriLarge = $uriLarge;
    }

    public function getUriLarge()
    {
        return $this->uriLarge;
    }

    public function setUriMedium($uriMedium)
    {
        $this->uriMedium = $uriMedium;
    }

    public function getUriMedium()
    {
        return $this->uriMedium;
    }

    public function setUriThumb($uriThumb)
    {
        $this->uriThumb = $uriThumb;
    }

    public function getUriThumb()
    {
        return $this->uriThumb;
    }

}
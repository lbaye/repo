<?php

namespace AdminUser\AdminUserBundle\Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as MongoDB;
use Symfony\Component\Validator\Constraints as Assert;
use Doctrine\Bundle\MongoDBBundle\Validator\Constraints\Unique as MongoDBUnique;

/**
 * @MongoDB\Document(collection="places")
 *
 */
class Place
{
    /**
     * @MongoDB\Id
     */
    protected $id;

    /** @MongoDB\String */
    protected $title;

    /** @MongoDB\String */
    protected $category;

    /** @MongoDB\String */
    protected $description;

    /** @MongoDB\String
     * @Assert\File(maxSize="6000000")
     */
    protected $photo;

    /** @MongoDB\String
     * @Assert\File(maxSize="6000000")
     */
    protected $icon;

    /** @MongoDB\String */
    protected $type = 'custom_place';

    /** @MongoDB\String */
    protected $path;

    /** @MongoDB\String */
    protected $createDate;

    /** @MongoDB\Hash */
    protected $likes = array();

    /** @MongoDB\String */
    protected $note;

    /** @MongoDB\Float */
    protected $lat;

    /** @MongoDB\Float */
    protected $lng;

    /** @MongoDB\String */
    protected $address;

    /**
     * @MongoDB\ReferenceOne(targetDocument="User", simple=true)
     */
    protected $owner;

    /** @MongoDB\Hash */
    protected $location = array(
        'address' => null,'lng' => 0, 'lat' => 0
    );

    function __construct()
    {
        $this->setType('custom_place');
    }

    //<editor-fold desc="Setters">
    public function setTitle($title)
    {
        $this->title = $title;
    }

    public function setType($type)
    {
        $this->type = $type;
    }

    public function setLocation(array $location)
    {
        $this->location = $location;
    }

    //</editor-fold>

    //<editor-fold desc="Getters">

    public function getTitle()
    {
        return $this->title;
    }


    public function setCategory($category)
    {
        $this->category = $category;
    }

    public function getCategory()
    {
        return $this->category;
    }

    public function setDescription($description)
    {
        $this->description = $description;
    }

    public function getDescription()
    {
        return $this->description;
    }

    public function setPhoto($photo)
    {
        $this->photo = $photo;
    }

    public function getPhoto()
    {
        return $this->photo;
    }

    public function getType()
    {
        return $this->type;
    }

    public function getLocation()
    {
        return $this->location;
    }

    //</editor-fold>

    public function toArray()
    {
        $fieldsToExpose = array('id', 'title', 'category', 'description', 'photo', 'createDate');
        $result = array();

        foreach ($fieldsToExpose as $field) {
            $result[$field] = $this->{"get{$field}"}();
        }

        return $result;
    }

    public function map(array $data, \AdminUser\AdminUserBundle\Document\Place $place = null)
    {
        $setIfExistFields = array('id', 'title', 'category', 'description', 'location', 'type', 'photo', 'icon', 'note', 'createDate');

        foreach ($setIfExistFields as $field) {
            if (isset($data[$field]) && !is_null($data[$field])) {
                $this->{"set" . ucfirst($field) . ""}($data[$field]);
            }
        }

        return $place;
    }

    public function isValid()
    {
        try {

            Validator::create()->equals($this->getLocation()->isValid())->assert(true);

        } catch (\InvalidArgumentException $e) {
            return false;
        }

        return true;
    }

    public function setLikes($likes)
    {
        $this->likes = $likes;
    }

    public function getLikes()
    {
        return $this->likes;
    }

    public function getCommentsCount()
    {
        return 0;
    }

    public function getLikesCount()
    {
        return count($this->likes);
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

    public function setIcon($icon)
    {
        $this->icon = $icon;
    }

    public function getIcon()
    {
        return $this->icon;
    }

    public function setPath($path)
    {
        $this->path = $path;
    }

    public function getPath()
    {
        return $this->path;
    }

    public function setNote($note)
    {
        $this->note = $note;
    }

    public function getNote()
    {
        return $this->note;
    }

    public function setAddress($address)
    {
        $this->address = $address;
    }

    public function getAddress()
    {
        return $this->address;
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

    public function setOwner($owner)
    {
        $this->owner = $owner;
    }

    public function getOwner()
    {
        return $this->owner;
    }


}
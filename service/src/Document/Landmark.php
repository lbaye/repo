<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

use Document\User as User;
use Document\Location as Location;

/**
 * @abstract
 * @ODM\Document(collection="places",repositoryClass="Repository\Place")
 * @ODM\InheritanceType("SINGLE_COLLECTION")
 * @ODM\DiscriminatorField(fieldName="type")
 * @ODM\DiscriminatorMap({"place"="Document\Place", "geotag"="Document\Geotag"})
 */
class Landmark extends Content implements ParticipativeDoc
{
    /** @ODM\String */
    protected $title;

    /** @ODM\String */
    protected $category;

    /** @ODM\String */
    protected $description;

    /** @ODM\String */
    protected $photo;

    /** @ODM\String */
    protected $objectType;

    /** @ODM\Hash */
    protected $likes = array();

    /**
     * @ODM\EmbedOne(targetDocument="Location")
     * @var Location
     */
    protected $location;

    function __construct() {
        $this->setType('place');
    }

    //<editor-fold desc="Setters">
    public function setTitle($title)
    {
        $this->title = $title;
    }

    public function setType($type)
    {
        $this->objectType =  $type;
    }

    public function setLocation($location)
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
        return $this->objectType;
    }

    /**
     * @return Location
     */
    public function getLocation()
    {
        return $this->location;
    }
    //</editor-fold>

    public function toArray()
    {
        $fieldsToExpose = array('id', 'title','category', 'description', 'photo', 'createDate');
        $result = array();

        foreach($fieldsToExpose as $field) {
            $result[$field] = $this->{"get{$field}"}();
        }

        $result['owner'] = $this->getOwner()->getId();
        $result['location'] = $this->getLocation()->toArray();

        return $result;
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

    public function setLikes($likes) {
        $this->likes = $likes;
    }

    public function getLikes() {
        return $this->likes;
    }

    public function setObjectType($objectType) {
        $this->objectType = $objectType;
    }

    public function getObjectType() {
        return $this->objectType;
    }

    public function getCommentsCount() {
        return 0;
    }

    public function getLikesCount() {
        return count($this->likes);
    }

}
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
class Landmark extends Content
{
    /** @ODM\String */
    protected $title;

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
        $this->type =  $type;
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

    public function getType()
    {
        return $this->type;
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
        $fieldsToExpose = array('id', 'title', 'createDate');
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

            Validator::create()->alnum()->assert($this->getTitle());
            Validator::create()->equals($this->getLocation()->isValid())->assert(true);

        } catch (\InvalidArgumentException $e) {
            return false;
        }

        return true;
    }

}
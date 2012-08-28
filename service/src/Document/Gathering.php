<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

use Document\User as User;
use Document\Location as Location;

/**
 * @abstract
 * @ODM\InheritanceType("COLLECTION_PER_CLASS")
 */
abstract class Gathering extends Content
{
    /** @ODM\String */
    protected $title;

    /** @ODM\String */
    protected $description;

    /** @ODM\String */
    protected $duration;

    /** @ODM\Hash */
    protected $guests = array();

    /**
     * @ODM\EmbedOne(targetDocument="Location")
     * @var Location
     */
    protected $location;

    /** @ODM\Date */
    protected $time;

    //<editor-fold desc="Setters">
    public function setTitle($title)
    {
        $this->title = $title;
    }

    public function setDescription($description)
    {
        $this->description = $description;
    }

    public function setDuration($duration)
    {
        $this->duration = $duration;
    }

    public function setLocation($location)
    {
        $this->location = $location;
    }

    public function setTime($meetingTimeStr)
    {
        $this->time = new \DateTime($meetingTimeStr);
    }

    public function setType($type)
    {
        $this->type =  $type;
    }

    public function setGuests(array $guests)
    {
        $this->guests = $guests;
    }
    //</editor-fold>

    //<editor-fold desc="Getters">

    public function getTitle()
    {
        return $this->title;
    }

    public function getDescription()
    {
        return $this->description;
    }

    public function getDuration()
    {
        return $this->duration;
    }

    /**
     * @return Location
     */
    public function getLocation()
    {
        return $this->location;
    }

    public function getTime()
    {
        return $this->time;
    }

    public function getType()
    {
        return $this->type;
    }

    public function getGuests()
    {
        return $this->guests;
    }
    //</editor-fold>

    public function toArray()
    {
        $fieldsToExpose = array('id', 'title','description', 'time', 'createDate');
        $result = array();

        foreach($fieldsToExpose as $field) {
            $result[$field] = $this->{"get{$field}"}();
        }

        $result['owner'] = $this->getOwner()->getId();
        $result['location'] = $this->getLocation()->toArray();
        return $result;
    }

    public function toArrayDetailed()
    {
        $result = $this->toArray();
        $result['guests'] = $this->getGuests();

        return $result;
    }

    public function isValid()
    {
        try {

            Validator::create()->notEmpty()->assert($this->getTitle());
            Validator::create()->equals($this->getLocation()->isValid())->assert(true);

        } catch (\InvalidArgumentException $e) {
            return $e;
        }

        return true;
    }
}
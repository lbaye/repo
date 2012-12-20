<?php

namespace AdminUser\AdminUserBundle\Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as MongoDB;
use Symfony\Component\Validator\Constraints as Assert;
use Doctrine\Bundle\MongoDBBundle\Validator\Constraints\Unique as MongoDBUnique;

/**
 * @MongoDB\Document(collection="events")
 * @MongoDBUnique(fields="_id")
 */
class Event
{

    /**
     * @MongoDB\Id
     */
    protected $id;

    /** @MongoDB\String */
    protected $title;

    /** @MongoDB\String */
    protected $description;

    /** @MongoDB\String */
    protected $duration;

    /** @MongoDB\Date */
    protected $time;

    /** @MongoDB\String */
    protected $eventShortSummary;

    /** @MongoDB\Float */
    protected $eventDistance;

    /** @MongoDB\String */
    protected $eventImage;

    /** @MongoDB\Boolean */
    protected $guestsCanInvite;

    /** @MongoDB\String */
    protected $message;

    public function setDescription($description)
    {
        $this->description = $description;
    }

    public function getDescription()
    {
        return $this->description;
    }

    public function setDuration($duration)
    {
        $this->duration = $duration;
    }

    public function getDuration()
    {
        return $this->duration;
    }

    public function setEventDistance($eventDistance)
    {
        $this->eventDistance = $eventDistance;
    }

    public function getEventDistance()
    {
        return $this->eventDistance;
    }

    public function setEventImage($eventImage)
    {
        $this->eventImage = $eventImage;
    }

    public function getEventImage()
    {
        return $this->eventImage;
    }

    public function setEventShortSummary($eventShortSummary)
    {
        $this->eventShortSummary = $eventShortSummary;
    }

    public function getEventShortSummary()
    {
        return $this->eventShortSummary;
    }

    public function setGuestsCanInvite($guestsCanInvite)
    {
        $this->guestsCanInvite = $guestsCanInvite;
    }

    public function getGuestsCanInvite()
    {
        return $this->guestsCanInvite;
    }

    public function setMessage($message)
    {
        $this->message = $message;
    }

    public function getMessage()
    {
        return $this->message;
    }

    public function setTime($time)
    {
        $this->time = $time;
    }

    public function getTime()
    {
        return $this->time;
    }

    public function setTitle($title)
    {
        $this->title = $title;
    }

    public function getTitle()
    {
        return $this->title;
    }

    public function setId($id)
    {
        $this->id = $id;
    }

    public function getId()
    {
        return $this->id;
    }
}
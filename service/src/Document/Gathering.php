<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

use Document\User as User;
use Document\Location as Location;
use Helper\Location as LocationHelper;

/**
 * Base abstract class for all schedule related models (ie. events, plan and meetups)
 *
 * @abstract
 * @ODM\InheritanceType("COLLECTION_PER_CLASS")
 */
abstract class Gathering extends Content implements ParticipativeDoc
{


    /** @ODM\String */
    protected $title;

    /** @ODM\String */
    protected $description;

    /** @ODM\String */
    protected $duration;

    /** @ODM\Hash */
    protected $guests = array();

    /** @ODM\Hash */
    protected $invitedCircles = array();

    /**
     * @ODM\EmbedOne(targetDocument="Location")
     * @var Location
     */
    protected $location;

    /** @ODM\Date */
    protected $time;

    /** @ODM\String */
    protected $eventShortSummary;

    /** @ODM\Float */
    protected $eventDistance;

    /** @ODM\String */
    protected $eventImage;

    /** @ODM\Boolean */
    protected $guestsCanInvite;

     /** @ODM\String */
    protected $message;

    /** @ODM\Hash */
    protected $rsvp = array(
        'yes' => array(),
        'no' => array(),
        'maybe' => array(),
    );

    /** @ODM\Hash */
    protected $likes = array();

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
        $this->type = $type;
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
        $fieldsToExpose = array(
            'id', 'title', 'description', 'eventShortSummary','eventImage',
            'time', 'rsvp','guestsCanInvite', 'createDate', 'permission', 'permittedUsers', 'permittedCircles'
        );

        $result = array();

        foreach ($fieldsToExpose as $field) {
            $result[$field] = $this->{"get{$field}"}();
        }

        $userLocation = $this->getOwner()->getCurrentLocation();

        $distance = LocationHelper::distance(
            $userLocation['lat'],
            $userLocation['lng'],
            $this->getLocation()->getLat(),
            $this->getLocation()->getLng());

        $result['owner'] = $this->getOwner()->getId();
        $result['location'] = $this->getLocation()->toArray();
        $result['distance'] = $distance;

        return $result;
    }

    public function toArrayDetailed()
    {
        $result = $this->toArray();
        $guests['users']   = $this->getGuests();
        $guests['circles'] = $this->getInvitedCircles();
        $result['guests']  = $guests;

        return $result;
    }

    public function isValid()
    {
        try {

            Validator::create()->equals($this->getLocation()->isValid())->assert(true);

        } catch (\InvalidArgumentException $e) {
            return $e;
        }

        return true;
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

    public function setRsvp($whoWillAttend)
    {
        $this->rsvp = $whoWillAttend;
    }

    public function getRsvp()
    {
        return array(
            'yes' => array_values($this->rsvp['yes']),
            'no' => array_values($this->rsvp['no']),
            'maybe' => array_values($this->rsvp['maybe']),
        );

    }

    public function setGuestsCanInvite($guestsCanInvite)
    {
        $this->guestsCanInvite = (boolean) $guestsCanInvite;
    }

    public function getGuestsCanInvite()
    {
        return $this->guestsCanInvite;
    }


    public function setInvitedCircles($invitedCircles)
    {
        $this->invitedCircles = $invitedCircles;
    }

    public function getInvitedCircles()
    {
        return $this->invitedCircles;
    }

    public function setMessage($message)
    {
        $this->message = $message;
    }

    public function getMessage()
    {
        return $this->message;
    }


    public function getUserResponse($userId)
    {
        $rsvp = $this->getRsvp();

        if(in_array($userId, $rsvp['yes']))   return 'yes';
        if(in_array($userId, $rsvp['no']))    return 'no';
        if(in_array($userId, $rsvp['maybe'])) return 'maybe';
    }

    public function isPermittedFor(\Document\User $user)
    {
        if(in_array($user->getId(), $this->getGuests())){
            return true;
        } else {
            return parent::isPermittedFor($user);
        }
    }

    public function setLikes($likes) {
        $this->likes = $likes;
    }

    public function getLikes() {
        return $this->likes;
    }

    public function getCommentsCount() {
        return 0;
    }

    public function getLikesCount() {
        return count($this->likes);
    }
}
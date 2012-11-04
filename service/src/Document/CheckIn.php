<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

/**
 * @ODM\Document(collection="checkIns",repositoryClass="Repository\CheckInRepo")
 */
class CheckIn extends Content
{
    /** @ODM\Id */
    protected $id;

    /** @ODM\String */
    protected $uri;

    /** @ODM\String */
    protected $venue;

    /** @ODM\String */
    protected $venueType;

    /** @ODM\String */
    protected $message;

    /** @ODM\Hash */
    protected $taggedUsers = array();

    /** @ODM\Hash */
    protected $likedByUsers = array();

    public function setLikedByUsers($likedByUsers)
    {
        $this->likedByUsers = $likedByUsers;
    }

    public function getLikedByUsers()
    {
        return $this->likedByUsers;
    }

    public function setVenue($venue)
    {
        $this->venue = $venue;
    }

    public function getVenue()
    {
        return $this->venue;
    }

    public function setVenueType($venueType)
    {
        $this->venueType = $venueType;
    }

    public function getVenueType()
    {
        return $this->venueType;
    }


    public function setId($id)
    {
        $this->id = $id;
    }

    public function getId()
    {
        return $this->id;
    }

    public function setMessage($message)
    {
        $this->message = $message;
    }

    public function getMessage()
    {
        return $this->message;
    }

    public function setTaggedUsers($taggedUsers)
    {
        $this->taggedUsers = $taggedUsers;
    }

    public function getTaggedUsers()
    {
        return $this->taggedUsers;
    }

    public function setUri($uri)
    {
        $this->uri = $uri;
    }

    public function getUri()
    {
        return $this->uri;
    }

    public function addTaggedUsers($user_id)
    {
        foreach ($this->taggedUsers as $taggedUser) {
            if ($taggedUser == $user_id) {
                return false;
            }
        }

        $this->taggedUsers[] = $user_id;
    }

    public function addLikedByUsers($user_id)
    {
        foreach ($this->likedByUsers as $likedByUser) {
            if ($likedByUser == $user_id) {
                return false;
            }
        }

        $this->likedByUsers[] = $user_id;
    }

    public function isValid()
    {
        try {
            Validator::create()->notEmpty()->assert($this->getVenue());
            Validator::create()->notEmpty()->assert($this->getVenueType());
            Validator::create()->notEmpty()->assert($this->getMessage());

        } catch (\InvalidArgumentException $e) {
            return false;
        }

        return true;
    }

    public function toArray()
    {
        $hash = array();

        $fields = array('id', 'message', 'venue', 'venueType');
        foreach ($fields as $field) $hash[$field] = $this->{'get' . ucfirst($field)}();

        $hash['image'] = \Helper\Url::buildPhotoUrl(array('photo' => $this->getUri()));

        $owner = $this->getOwner();
        $hash['owner'] = array(
            'id' => $owner->getId(),
            'firstName' => $owner->getFirstName(),
            'lastName' => $owner->getLastName(),
            'avatar' => \Helper\Url::buildAvatarUrl(array('avatar' => $owner->getAvatar()))
        );

        $taggedUsers = $this->getTaggedUsers();
        if ($taggedUsers)
            $hash['taggedUsers'] = $taggedUsers;

        $likedByUsers = $this->getLikedByUsers();
        if ($likedByUsers)
            $hash['likedByUsers'] = $likedByUsers;

        return $hash;
    }
}
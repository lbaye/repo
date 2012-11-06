<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

/**
 * @ODM\Document(collection="reviews",repositoryClass="Repository\ReviewRepo")
 */
class Review extends Content
{
    /** @ODM\Id */
    protected $id;

    /** @ODM\String */
    protected $venue;

    /** @ODM\String */
    protected $venueType;

    /** @ODM\String */
    protected $review;

    /** @ODM\Int */
    protected $rating;

    public function setVenueType($venueType)
    {
        $this->venueType = $venueType;
    }

    public function getVenueType()
    {
        return $this->venueType;
    }

    public function setRating($rating)
    {
        $this->rating = $rating;
    }

    public function getRating()
    {
        return $this->rating;
    }

    public function setReview($review)
    {
        $this->review = $review;
    }

    public function getReview()
    {
        return $this->review;
    }

    public function setId($id)
    {
        $this->id = $id;
    }

    public function getId()
    {
        return $this->id;
    }

    public function setVenue($venue)
    {
        $this->venue = $venue;
    }

    public function getVenue()
    {
        return $this->venue;
    }

    public function isValid()
    {
        try {
            Validator::create()->notEmpty()->assert($this->getVenue());
            Validator::create()->notEmpty()->assert($this->getVenueType());
            Validator::create()->notEmpty()->assert($this->getReview());
            Validator::create()->notEmpty()->assert($this->getRating());

        } catch (\InvalidArgumentException $e) {
            return false;
        }

        return true;
    }

    public function toArray()
    {
        $hash = array();

        $fields = array('id', 'review', 'rating', 'venue', 'venueType');
        foreach ($fields as $field) $hash[$field] = $this->{'get' . ucfirst($field)}();

        $owner = $this->getOwner();
        $hash['owner'] = array(
            'id' => $owner->getId(),
            'firstName' => $owner->getFirstName(),
            'lastName' => $owner->getLastName(),
            'avatar' => \Helper\Url::buildAvatarUrl(array('avatar' => $owner->getAvatar()))
        );

        return $hash;
    }
}
<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

use Document\User as User;

/**
 * @ODM\Document(collection="user_activities",repositoryClass="Repository\UserActivityRepo")
 */
class UserActivity {

    const ACTIVITY_PHOTO = 'photo';
    const ACTIVITY_REVIEW = 'review';
    const ACTIVITY_CHECKIN = 'checkin';
    const ACTIVITY_GEOTAG = 'geotag';
    const ACTIVITY_FRIEND = 'friend';

    /** @ODM\Id */
    protected $id;

    /** @ODM\String */
    protected $objectId;

    /** @ODM\String */
    protected $objectType;

    /** @ODM\String */
    protected $title;

    /** @ODM\Hash */
    protected $likes = array();

    /** @ODM\Hash */
    protected $comments = array();

    /** @ODM\Date */
    protected $createdAt;

    # TODO: Add comments

    /**
     * @ODM\EmbedOne(targetDocument="Location")
     */
    protected $location;

    /**
     * @ODM\ReferenceOne(targetDocument="User", simple=true)
     */
    protected $owner;

    public function __construct() {
        $this->createdAt = new DateTime();
    }

    public function setId($id) {
        $this->id = $id;
    }

    public function getId() {
        return $this->id;
    }

    public function setLikes($likes) {
        $this->likes = $likes;
    }

    public function getLikes() {
        return $this->likes;
    }

    public function setLocation($location) {
        $this->location = $location;
    }

    public function getLocation() {
        return $this->location;
    }

    public function setObjectId($objectId) {
        $this->objectId = $objectId;
    }

    public function getObjectId() {
        return $this->objectId;
    }

    public function setObjectType($objectType) {
        $this->objectType = $objectType;
    }

    public function getObjectType() {
        return $this->objectType;
    }

    public function setOwner($owner) {
        $this->owner = $owner;
    }

    public function getOwner() {
        return $this->owner;
    }

    public function setTitle($title) {
        $this->title = $title;
    }

    public function getTitle() {
        return $this->title;
    }

    public function isValid() {
        return $this->getObjectId() &&
               $this->getObjectType() &&
               $this->getOwner();
    }

    public function setComments($comments) {
        $this->comments = $comments;
    }

    public function getComments() {
        return $this->comments;
    }

    public function setCreatedAt($createdAt) {
        $this->createdAt = $createdAt;
    }

    public function getCreatedAt() {
        return $this->createdAt;
    }

    public function toArray() {

        # Build hash object from the basic fields
        $exportableFields = array('id', 'objectId', 'objectType', 'title', 'likes', 'createdAt');
        $hash = array();
        foreach ($exportableFields as $field) $hash[$field] = $this->{'get' . ucfirst($field)}();

        # Add likes related fields
        $hash['likesCount'] = count($this->getLikes());

        return $hash;
    }
}
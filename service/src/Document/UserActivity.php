<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

use Document\User as User;

/**
 * @ODM\Document(collection="user_activities",repositoryClass="Repository\UserActivityRepo")
 */
class UserActivity implements ParticipativeDoc {

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

    /** @ODM\Int */
    protected $likesCount = 0;

    /** @ODM\Int */
    protected $commentsCount = 0;

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
        $this->createdAt = new \DateTime();
    }

    public function setId($id) {
        $this->id = $id;
    }

    public function getId() {
        return $this->id;
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

    public function setCreatedAt($createdAt) {
        $this->createdAt = $createdAt;
    }

    public function getCreatedAt() {
        return $this->createdAt;
    }

    public function setCommentsCount($commentsCount) {
        $this->commentsCount = $commentsCount;
    }

    public function getCommentsCount() {
        return $this->commentsCount;
    }

    public function setLikesCount($likesCount) {
        $this->likesCount = $likesCount;
    }

    public function getLikesCount() {
        if ($this->likesCount > 0)
            return $this->likesCount;
        else
            return count($this->likes);
    }

    public function setLikes($likes) {
        $this->likes = $likes;
    }

    public function getLikes() {
        return $this->likes;
    }

    public function toHumanizeDate() {
        $now = new \DateTime();
        return \Helper\Util::toHumanizeDate($now->getTimestamp(), $this->createdAt->getTimestamp());
    }

    public function toArray() {
        # Build hash object from the basic fields
        $exportableFields = array(
            'id', 'objectId', 'objectType', 'title', 'likesCount',
            'commentsCount', 'createdAt', 'likes'
        );
        $hash = array();
        foreach ($exportableFields as $field) $hash[$field] = $this->{ 'get' . ucfirst($field) }();

        return $hash;
    }
}
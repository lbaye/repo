<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

use Document\User as User;

/**
 * @ODM\Document(collection="photos",repositoryClass="Repository\PhotosRepo")
 */
class Photo extends Content
{
    /** @ODM\Id */
    protected $id;

    /** @ODM\Hash */
    protected $metadata = array(
        'original_file' => null,
        'mime_type' => null,
        'length' => 0
    );

    /** @ODM\String */
    protected $uriThumb;

    /** @ODM\String */
    protected $uriMedium;

    /** @ODM\String */
    protected $uriLarge;

    /** @ODM\String */
    protected $title;

    /** @ODM\String */
    protected $description;

    /** @ODM\Hash */
    protected $likes = array();

    /**
     * @ODM\EmbedOne(targetDocument="Location")
     * @var Location
     */
    protected $location;

     /**
     * @ODM\EmbedMany(targetDocument="PhotoComment")
     */
    protected $photoComment = array();

    public function setId($id)
    {
        $this->id = $id;
    }

    public function getId()
    {
        return $this->id;
    }

    /**
     * @param \Document\Location $location
     */
    public function setLocation($location)
    {
        $this->location = $location;
    }

    /**
     * @return \Document\Location
     */
    public function getLocation()
    {
        return $this->location;
    }

    public function setDescription($description) {
        $this->description = $description;
    }

    public function getDescription() {
        return $this->description;
    }

    public function setMetadata($metadata) {
        $this->metadata = $metadata;
    }

    public function getMetadata() {
        return $this->metadata;
    }

    public function setTitle($title) {
        $this->title = $title;
    }

    public function getTitle() {
        return $this->title;
    }

    public function isValid() {
        try {
            Validator::create()->notEmpty()->assert($this->getTitle());
            Validator::create()->notEmpty()->assert($this->getDescription());
            Validator::create()->notEmpty()->assert($this->getUriThumb());

        } catch (\InvalidArgumentException $e) {
            return false;
        }

        return true;
    }

    public function toArray() {
        $hash = array();

        $fields = array('id', 'description', 'title', 'permission', 'permittedUsers', 'permittedCircles');
        foreach ($fields as $field) $hash[$field] = $this->{'get' . ucfirst($field)}();

        $hash['imageThumb'] = \Helper\Url::buildPhotoUrl(array('photo' => $this->getUriThumb()));
        $hash['imageMedium'] = \Helper\Url::buildPhotoUrl(array('photo' => $this->getUriMedium()));
        $hash['imageLarge'] = \Helper\Url::buildPhotoUrl(array('photo' => $this->getUriLarge()));

        $location = $this->getLocation();
        if ($location)
            $hash['location'] = $location->toArray();

        $owner = $this->getOwner();
        $hash['owner'] = array(
            'id' => $owner->getId(),
            'firstName' => $owner->getFirstName(),
            'lastName' => $owner->getLastName(),
            'avatar' => \Helper\Url::buildAvatarUrl(array('avatar' => $owner->getAvatar()))
        );

        return $hash;
    }

    public function setUriLarge($uriLarge)
    {
        $this->uriLarge = $uriLarge;
    }

    public function getUriLarge()
    {
        return $this->uriLarge;
    }

    public function setUriMedium($uriMedium)
    {
        $this->uriMedium = $uriMedium;
    }

    public function getUriMedium()
    {
        return $this->uriMedium;
    }

    public function setUriThumb($uriThumb)
    {
        $this->uriThumb = $uriThumb;
    }

    public function getUriThumb()
    {
        return $this->uriThumb;
    }

    public function addLikesUser($userId) {
        $this->likes[] = $userId;
    }

    public function setLikesUser(array $users)
    {
        $this->likes = $users;
    }

    public function getLikes()
    {
        return $this->likes;
    }

    public function addPhotoComment($photoComment)
    {
        $this->photoComment[] = $photoComment;
    }

    public function setPhotoComment($photoComment)
    {
        $this->photoComment = $photoComment;
    }

    public function getPhotoComment()
    {
        return $this->photoComment;
    }
}
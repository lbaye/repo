<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

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
    protected $uri;

    /** @ODM\String */
    protected $title;

    /** @ODM\String */
    protected $description;

    /**
     * @ODM\EmbedOne(targetDocument="Location")
     * @var Location
     */
    protected $location;

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

    public function setUri($uri) {
        $this->uri = $uri;
    }

    public function getUri() {
        return $this->uri;
    }

    public function isValid() {
        try {
            Validator::create()->notEmpty()->assert($this->getTitle());
            Validator::create()->notEmpty()->assert($this->getDescription());
            Validator::create()->notEmpty()->assert($this->getUri());

        } catch (\InvalidArgumentException $e) {
            return false;
        }

        return true;
    }

    public function toArray() {
        $hash = array();

        $fields = array('id', 'description', 'title');
        foreach ($fields as $field) $hash[$field] = $this->{'get' . ucfirst($field)}();

        $hash['image'] = \Helper\Url::buildPhotoUrl(array('photo' => $this->getUri()));

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
}
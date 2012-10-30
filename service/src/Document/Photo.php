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

        return $hash;
    }
}
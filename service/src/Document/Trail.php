<?php
namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;
/**
 * Created by JetBrains PhpStorm.
 * User: zunaid
 * Date: 10/13/12
 * Time: 9:27 PM
 * To change this template use File | Settings | File Templates.
 */
/**
 * @ODM\Document(collection="trails",repositoryClass="Repository\TrailRepo")
 */
class Trail extends Content
{
    /** @ODM\Id */
    protected $id;

    /** @ODM\String */
    protected $description;

    /** @ODM\String */
    protected $name;

    /**
     * @ODM\EmbedMany(targetDocument="Marker")
     */
    protected $markers = array();


    /**
     * @return mixed
     */
    public function getId()
    {
        return $this->id;
    }

    /**
     * @param $id
     */
    public function setId($id)
    {
        $this->id = $id;
    }

    /**
     * @return mixed
     */
    public function getName()
    {
        return $this->name;
    }

    /**
     * @param $trailName
     */
    public function setName($trailName)
    {
        $this->name = $trailName;
    }

    /**
     * @return mixed
     */
    public function getTrailType()
    {
        return $this->trailType;
    }

    /**
     * @param $trailType
     */
    public function setTrailType($trailType)
    {
        $this->trailType = $trailType;
    }

    /**
     * @return mixed
     */
    public function getMarkers()
    {
        return $this->markers;
    }

    /**
     * @param $markers
     */
    public function setMarkers($markers)
    {
        $this->markers = $markers;
    }


    public function resetMarkers()
    {
        $this->markers = array();
    }

    /**
     * @return mixed
     */
    public function getCreatedDate()
    {
        return $this->createdDate;
    }

    /**
     * @param $createdDate
     */
    public function setCreatedDate($createdDate)
    {
        $this->createdDate = $createdDate;
    }

    /**
     * @return mixed
     */
    public function getUpdatedDate()
    {
        return $this->updatedDate;
    }

    /**
     * @param $updatedDate
     */
    public function setUpdatedDate($updatedDate)
    {
        $this->updatedDate = $updatedDate;
    }

    /**
     * @return mixed
     */
    public function getTitle()
    {
        return $this->title;
    }

    /**
     * @param $title
     */
    public function setTitle($title)
    {
        $this->title = $title;
    }

    /**
     * @return mixed
     */
    public function getDescription()
    {
        return $this->description;
    }

    /**
     * @param $description
     */
    public function setDescription($description)
    {
        $this->description = $description;
    }

    /**
     * @param $marker
     */
    public function addMarker($marker)
    {
        $this->markers[] = $marker;
    }

    /**
     * @return array
     */
    public function toArray() {
        return array(
            'id' => $this->getId(),
            'name' => $this->getName(),
            'description' => $this->getDescription()

        );
    }

    /**
     * @return bool
     */
    public function isValid()
    {
        try {
            Validator::create()->notEmpty()->assert($this->getName());

        } catch (\InvalidArgumentException $e) {
            return false;
        }

        return true;
    }
}

<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

use Document\User as User;
use Document\Location as Location;

/**
 * @ODM\Document(collection="deals",repositoryClass="Repository\Deal")
 * @ODM\Index(keys={"location"="2d"})
 */
class Deal
{
    /** @ODM\Id */
    protected $id;

    /** @ODM\String */
    protected $title;

    /** @ODM\String */
    protected $description;

    /** @ODM\String */
    protected $link;

    /** @ODM\String */
    protected $mapLink;

    /** @ODM\String */
    protected $category;

    /** @ODM\Hash */
    protected $location = array();

    /** @ODM\Distance */
    protected  $distance;

    /** @ODM\Date */
    protected $expiration;

    /** @ODM\Date */
    protected $createDate;

    /** @ODM\Date */
    protected $updateDate;

    //<editor-fold desc="Setters">
    public function setId($id)
    {
        $this->id = $id;
    }

    public function setTitle($title)
    {
        $this->title = $title;
    }

    public function setLocation(array $location)
    {
        $this->location = $location;
    }


    public function setCategory($category)
    {
        $this->category = $category;
    }

    public function setDescription($description)
    {
        $this->description = $description;
    }

    public function setLink($link)
    {
        $this->link = $link;
    }

    public function setMapLink($mapLink)
    {
        $this->mapLink = $mapLink;
    }

    public function setExpiration($expirationDate)
    {
        $this->expiration = new \DateTime($expirationDate);
    }

    public function setCreateDate(\DateTime $created)
    {
        $this->createDate = $created;
    }

    public function setUpdateDate(\DateTime $modified)
    {
        $this->updateDate = $modified;
    }
    //</editor-fold>

    //<editor-fold desc="Getters">
    public function getId()
    {
        return $this->id;
    }

    public function getTitle()
    {
        return $this->title;
    }

    public function getLocation()
    {
        return $this->location;
    }

    public function getExpiration()
    {
        return $this->expiration;
    }

    public function getCreateDate()
    {
        return $this->createDate;
    }

    public function getUpdateDate()
    {
        return $this->updateDate;
    }

    public function getDistance()
    {
        return $this->distance;
    }

    public function getCategory()
    {
        return $this->category;
    }

    public function getDescription()
    {
        return $this->description;
    }

    public function getLink()
    {
        return $this->link;
    }

    public function getMapLink()
    {
        return $this->mapLink;
    }
    //</editor-fold>

    public function toArray()
    {
        $fieldsToExpose = array('id', 'title', 'description', 'link', 'maplink', 'expiration', 'category', 'location', 'distance', 'createDate');
        $result = array();

        foreach($fieldsToExpose as $field) {
            $result[$field] = $this->{"get{$field}"}();
        }

        //$result['owner'] = $this->getOwner()->getId();

        return $result;
    }

    public function isValid()
    {
        try {
            $loc = $this->getLocation();
            Validator::create()->notEmpty()->assert($this->getTitle());

            if(! empty($this->link)) Validator::create()->domain()->assert(parse_url($this->link, PHP_URL_HOST));
            if(! empty($this->mapLink)) Validator::create()->domain()->assert(parse_url($this->mapLink, PHP_URL_HOST));

            if(isset($loc['lat']) && isset($loc['lng'])){
                Validator::create()->float()->assert($loc['lng']);
                Validator::create()->float()->assert($loc['lat']);
            } else {
                throw new \InvalidArgumentException("lat and lng is required params");
            }

        } catch (\InvalidArgumentException $e) {
            return false;
        }

        return true;
    }

}
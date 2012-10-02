<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

use Document\User as User;
use Document\Location as Location;

/**
 * @ODM\Document(collection="directions",repositoryClass="Repository\DirectionRepo")
 */
class Direction extends Content
{
    /** @ODM\Id */
    protected $id;
    
    /** @ODM\String */
    protected $title;
    
    /** @ODM\String */
    protected $type;

    /** @ODM\Float */
    protected $latFrom;

    /** @ODM\Float */
    protected $lngFrom;

    /** @ODM\Float */
    protected $latTo;

    /** @ODM\Float */
    protected $lngTo;

    /**
     * @ODM\EmbedOne(targetDocument="Location")
     * @var Location
     */
    protected $from;

    /**
     * @ODM\EmbedOne(targetDocument="Location")
     * @var Location
     */
    protected $to;


    /** @ODM\Date */
    protected $createDate;


    //<editor-fold desc="Setters">
    public function setId($id)
    {
        $this->id = $id;
    }
   
    public function setTitle($title)
    {
        $this->title = $title;
    }
    
    public function setType($type)
    {
        $this->type = $type;
    }

    //<editor-fold desc="Setters">
    public function setlatFrom($latFrom)
    {
        $this->latFrom = $latFrom;
    }
    //<editor-fold desc="Setters">
    public function setlngFrom($lngFrom)
    {
        $this->lngFrom = $lngFrom;
    }
    //<editor-fold desc="Setters">
    public function setlatTo($latTo)
    {
        $this->latTo = $latTo;
    }
    //<editor-fold desc="Setters">
    public function setlngTo($lngTo)
    {
        $this->lngTo = $lngTo;
    }

    public function setFrom($location)
    {
        $this->from = $location;
    }

    public function setTo($location)
    {
        $this->to = $location;
    }
    //</editor-fold>

    public function setCreateDate(\DateTime $created)
    {
        $this->createDate = $created;
    }

    //<editor-fold desc="Getters">
    public function getId()
    {
        return $this->id;
    }
    
    public function getTitle()
    {
        return $this->title;
    }
    
    public function getType()
    {
        return $this->type;
    }

    /**
     * @return Location
     */
    public function getFrom()
    {
        return $this->from;
    }

    /**
     * @return Location
     */
    public function getTo()
    {
        return $this->to;
    }



    public function getCreateDate()
    {
        return $this->createDate;
    }



    //</editor-fold>

    public function toArray()
    {
        $fieldsToExpose = array('id','title','type','createDate');
        $result = array();

        foreach($fieldsToExpose as $field) {
            $result[$field] = $this->{"get{$field}"}();
        }

        $result['owner'] = $this->getOwner()->getId();
        $result['from'] = $this->getFrom()->toArray();
        $result['to'] = $this->getTo()->toArray();
//        $result['location'] = $this->getLocation()->toArray();

        return $result;
    }

    public function isValid()
    {
        try {
            Validator::create()->equals($this->getFrom()->isValid())->assert(true);
            Validator::create()->equals($this->getTo()->isValid())->assert(true);

        } catch (\InvalidArgumentException $e) {
            return false;
        }

        return true;
    }

}

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

    public function setFrom($location)
    {
        $this->from = $location;
    }

    public function setTo($location)
    {
        $this->to = $location;
    }
    //</editor-fold>

    //<editor-fold desc="Getters">

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

    //</editor-fold>

    public function toArray()
    {
        $fieldsToExpose = array('id', 'from', 'to', 'createDate');
        $result = array();

        foreach($fieldsToExpose as $field) {
            $result[$field] = $this->{"get{$field}"}();
        }

        $result['owner'] = $this->getOwner()->getId();
        $result['location'] = $this->getLocation()->toArray();

        return $result;
    }

    public function isValid()
    {
        try {

            Validator::create()->alnum()->assert($this->getTitle());
            Validator::create()->equals($this->getLocation()->isValid())->assert(true);

        } catch (\InvalidArgumentException $e) {
            return false;
        }

        return true;
    }

}
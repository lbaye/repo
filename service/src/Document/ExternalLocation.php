<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

/**
 * @ODM\Document(collection="external_locations",repositoryClass="Repository\ExternalLocation")
 * @ODM\Index(keys={"coords"="2d"})
 * @ODM\UniqueIndex(keys={"refId"="asc", "source"="asc"})
 */
class ExternalLocation
{
    /** @ODM\Id */
    protected $id;

    /** @ODM\String */
    protected $refId;

    /** @ODM\String */
    protected $refUserId;

    /** @ODM\String */
    protected $refLocationId;

    /** @ODM\String */
    protected $refType;

    /** @ODM\Hash */
    protected $coords = array(
        'latitude' => 0,
        'longitude' => 0
    );

    /** @ODM\String */
    protected $refTimestamp;

    /** @ODM\Hash */
    protected $refTaggedUserIds;

    /** @ODM\String */
    protected $source;

    public function setCoords($coords)
    {
        $this->coords = $coords;
    }

    public function getCoords()
    {
        return $this->coords;
    }

    public function setId($id)
    {
        $this->id = $id;
    }

    public function getId()
    {
        return $this->id;
    }

    public function setRefId($refId)
    {
        $this->refId = $refId;
    }

    public function getRefId()
    {
        return $this->refId;
    }

    public function setRefLocationId($refLocationId)
    {
        $this->refLocationId = $refLocationId;
    }

    public function getRefLocationId()
    {
        return $this->refLocationId;
    }

    public function setRefTaggedUserIds($refTaggedUserIds)
    {
        $this->refTaggedUserIds = $refTaggedUserIds;
    }

    public function getRefTaggedUserIds()
    {
        return $this->refTaggedUserIds;
    }

    public function setRefTimestamp($refTimestamp)
    {
        $this->refTimestamp = $refTimestamp;
    }

    public function getRefTimestamp()
    {
        return $this->refTimestamp;
    }

    public function setRefType($refType)
    {
        $this->refType = $refType;
    }

    public function getRefType()
    {
        return $this->refType;
    }

    public function setRefUserId($refUserId)
    {
        $this->refUserId = $refUserId;
    }

    public function getRefUserId()
    {
        return $this->refUserId;
    }

    public function setSource($source)
    {
        $this->source = $source;
    }

    public function getSource()
    {
        return $this->source;
    }
}
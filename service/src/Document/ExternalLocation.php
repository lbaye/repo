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
    protected $userId = null;

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
        'longitude' => 0,
        'latitude' => 0
    );

    /** @ODM\String */
    protected $refTimestamp;

    /** @ODM\Hash */
    protected $refProfile;

    /** @ODM\Hash */
    protected $refTaggedUserIds;

    /** @ODM\String */
    protected $source;

    public function toArray()
    {
        $data = array(
            'id' => $this->getId(),
            'userId' => $this->getUserId(),
            'refId' => $this->getRefId(),
            'refUserId' => $this->getRefUserId(),
            'refLocationId' => $this->getRefLocationId(),
            'refType' => $this->getRefType(),
            'coords' => $this->getCoords(),
            'refTimestamp' => $this->getRefTimestamp(),
            'refProfile' => $this->getRefProfile(),
            'refTaggedUserIds' => $this->getRefTaggedUserIds(),
            'source' => $this->getSource()
        );

        return $data;
    }

    public function toArrayAsUser()
    {
        $data = array(
            'id' => $this->getId(),
            'email' => '',
            'source' => $this->getSource(),
            'userId' => $this->getUserId()
        );

        $coords = $this->getCoords();
        $data['currentLocation'] = array('lat' => $coords['latitude'], 'lng' => $coords['longitude']);

        $profile = $this->getRefProfile();

        if (isset($profile['first_name'])) {
            $data['firstName'] = $profile['first_name'];
        }

        if (isset($profile['last_name'])) {
            $data['lastName'] = $profile['last_name'];
        }

        if (isset($profile['gender'])) {
            $data['gender'] = $profile['gender'];
        }

        if (isset($profile['avatar'])) {
            $data['avatar'] = $profile['avatar'];
        }

        return $data;
    }

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

    public function setRefProfile($refProfile)
    {
        $this->refProfile = $refProfile;
    }

    public function getRefProfile()
    {
        return $this->refProfile;
    }

    public function setUserId($userId)
    {
        $this->userId = $userId;
        return $this;
    }

    public function getUserId()
    {
        return $this->userId;
    }
}
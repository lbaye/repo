<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

/**
 * @ODM\Document(collection="external_locations",repositoryClass="Repository\ExternalLocationRepo")
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
    protected $authId;

    /** @ODM\String */
    protected $refUserId;

    /** @ODM\String */
    protected $refFacebookId;

    /** @ODM\String */
    protected $name;

    /** @ODM\String */
    protected $gender;

    /** @ODM\String */
    protected $email;

    /** @ODM\String */
    protected $location;

    /** @ODM\String */
    protected $picSquare;

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

    /** @ODM\String */
    protected $refLocationId;

    /** @ODM\String */
    protected $refType;

    public function toArray()
    {
        $data = array(
            'id' => $this->getId(),
            'userId' => $this->getUserId(),
            'authId' => $this->getAuthId(),
            'refUserId' => $this->getRefUserId(),
            'refFacebookId' => $this->getRefFacebookId(),
            'name' => $this->getName(),
            'gender' => $this->getGender(),
            'email' => $this->getEmail(),
            'location' => $this->getLocation(),
            'picSquare' => $this->getPicSquare(),
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

    public function setAuthId($authId)
    {
        $this->authId = $authId;
    }

    public function getAuthId()
    {
        return $this->authId;
    }

    public function setRefUserId($refUserId)
    {
       $this->refUserId = $refUserId;
    }

    public function getRefUserId()
    {
        return $this->refUserId;
    }

    public function setRefFacebookId($refFacebookId)
    {
       $this->refFacebookId = $refFacebookId;
    }

    public function getRefFacebookId()
    {
        return $this->refFacebookId;
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

    public function setName($name)
    {
       return $this->name = $name;
    }

    public function getName()
    {
        return $this->name;
    }

    public function setGender($gender)
    {
       return $this->gender = $gender;
    }

    public function getGender()
    {
        return $this->gender;
    }

    public function setEmail($email)
    {
       return $this->email = $email;
    }

    public function getEmail()
    {
        return $this->email;
    }

    public function setLocation($location)
    {
       return $this->location = $location;
    }

    public function getLocation()
    {
        return $this->location;
    }

    public function setPicSquare($picSquare)
    {
       return $this->picSquare = $picSquare;
    }

    public function getPicSquare()
    {
        return $this->picSquare;
    }


    public function toArraySecondDegree()
    {
        $data = array(
            'id' => $this->getId(),
            'userId' => $this->getUserId(),
            'email' => '',
            'facebookAuthId' => $this->getAuthId(),
            'refFacebookId' => $this->getRefFacebookId(),
            'refUserId' => $this->getRefUserId(),
            'name' => $this->getName(),
            'avatar' => $this->getPicSquare(),
            'coords' => $this->getCoords(),
            'distance' => 0,
            'checkinTime' => $this->getRefTimestamp(),
            'source' => $this->getSource()
        );

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

        return $data;
    }
}
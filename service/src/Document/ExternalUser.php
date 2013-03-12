<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

/**
 * Domain model for storing external users information (such as facebook users), this model is linked with "external_users" collection
 *
 * @ODM\Document(collection="external_users",repositoryClass="Repository\ExternalUserRepo")
 * @ODM\Index(keys={"currentLocation"="2d"})
 * @ODM\Index(keys={"refId"="asc"})
 */
class ExternalUser {
    const SOURCE_FB = 'facebook';

    /** @ODM\Id */
    protected $id;

    /** @ODM\Hash */
    protected $smFriends;

    /** @ODM\String */
    protected $refId;

    /** @ODM\String */
    protected $firstName;

    /** @ODM\String */
    protected $lastName;

    /** @ODM\String */
    protected $refType;

    /** @ODM\String */
    protected $avatar;

    /** @ODM\String */
    protected $email;

    /** @ODM\String */
    protected $gender;

    /** @ODM\Date */
    protected $createdAt;

    /** @ODM\Hash */
    protected $currentLocation = array(
        'lat' => 0,
        'lng' => 0
    );

    /** @ODM\String */
    protected $lastSeenAt = null;

    public function toArray() {
        $exposed_fields = array('id', 'smFriends', 'refId', 'refType', 'avatar',
                                'firstName', 'lastName', 'currentLocation', 'gender');
        $values = array();

        foreach ($exposed_fields as $field)
            $values[$field] = $this->{'get' . ucfirst($field)}();

        return $values;
    }

    public function setAvatar($avatar) {
        $this->avatar = $avatar;
    }

    public function getAvatar() {
        return $this->avatar;
    }

    public function setCurrentLocation($currentLocation) {
        $this->currentLocation = $currentLocation;
    }

    public function getCurrentLocation() {
        return $this->currentLocation;
    }

    public function setFirstName($firstName) {
        $this->firstName = $firstName;
    }

    public function getFirstName() {
        return $this->firstName;
    }

    public function setId($id) {
        $this->id = $id;
    }

    public function getId() {
        return $this->id;
    }

    public function setLastName($lastName) {
        $this->lastName = $lastName;
    }

    public function getLastName() {
        return $this->lastName;
    }

    public function setLastSeenAt($lastSeenAt) {
        $this->lastSeenAt = $lastSeenAt;
    }

    public function getLastSeenAt() {
        return $this->lastSeenAt;
    }

    public function setRefId($refId) {
        $this->refId = $refId;
    }

    public function getRefId() {
        return $this->refId;
    }

    public function setRefType($refType) {
        $this->refType = $refType;
    }

    public function getRefType() {
        return $this->refType;
    }

    public function setSmFriends($smFriends) {
        $this->smFriends = $smFriends;
    }

    public function getSmFriends() {
        return $this->smFriends;
    }

    public function setEmail($email) {
        $this->email = $email;
    }

    public function getEmail() {
        return $this->email;
    }

    public function setCreatedAt($createdAt) {
        $this->createdAt = $createdAt;
    }

    public function getCreatedAt() {
        return $this->createdAt;
    }

    public function setGender($gender) {
        $this->gender = $gender;
    }

    public function getGender() {
        return $this->gender;
    }

}
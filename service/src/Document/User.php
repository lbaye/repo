<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

use Document\Circle;

/**
 * @ODM\Document(collection="users",repositoryClass="Repository\User")
 * @ODM\Index(keys={"currentLocation"="2d"})
 */
class User
{
    const SALT = 'socialmaps';

    /** @ODM\Id */
    protected $id;

    /** @ODM\String */
    protected $firstName;

    /** @ODM\String */
    protected $lastName;

    /** @ODM\String */
    protected $email;

    /** @ODM\String */
    protected $password;

    /** @ODM\String */
    protected $oldPassword;

    /** @ODM\String */
    protected $facebookId;

    /** @ODM\String */
    protected $facebookAuthToken;

    /** @ODM\String */
    protected $salt = self::SALT;

    /** @ODM\String */
    protected $confirmationToken;

    /** @ODM\String */
    protected $forgetPasswordToken;

    /** @ODM\String */
    protected $authToken;

    /** @ODM\String */
    protected $avatar;

    /** @ODM\String */
    protected $source;

    /** @ODM\Date */
    protected $dateOfBirth;

    /** @ODM\String */
    protected $bio;

    /** @ODM\String */
    protected $interests;

    /** @ODM\String */
    protected $workStatus;

    /** @ODM\String */
    protected $relationshipStatus;

    /**
     * @ODM\EmbedOne(targetDocument="Address")
     * @var Address
     */
    protected $address;

    /**
     * @ODM\EmbedOne(targetDocument="Connector")
     * @var Connector
     */
    protected $connector;

    /**
     * @ODM\EmbedMany(targetDocument="Notification")
     * @var Notification
     */
    protected $notification = array();

    /**
     * @ODM\EmbedMany(targetDocument="Circle")
     */
    protected $circles = array();

    /**
     * @ODM\EmbedMany(targetDocument="FriendRequest")
     */
    protected $friendRequest = array();

    /** @ODM\Hash */
    protected $currentLocation = array(
        'lng' => 0, 'lat' => 0
    );

    /** @ODM\Boolean */
    protected $visible = true;

    /** @ODM\Distance */
    protected $distance = 0;

    /** @ODM\Boolean */
    protected $enabled;

    /** @ODM\Hash */
    protected $blockedUsers = array();

    /** @ODM\Hash */
    protected $blockedBy = array();

    /** @ODM\Boolean */
    protected $deactivated;

    /** @ODM\Date */
    protected $lastLogin;

    /** @ODM\Int */
    protected $loginCount;

    /** @ODM\Date */
    protected $createDate;

    /** @ODM\Date */
    protected $updateDate;

    /** @ODM\Hash */
    protected $locationSettings = array(

        'status' => 'on',

        'friends' => array(
            'permitted_users' => array(),
            'permitted_circles' => array(),
            'duration' => 0,
            'radius' => 2
        ),

        'strangers' => array(
            'duration' => 0,
            'radius' => 2
        )

    );

    /** @ODM\Hash */
    protected $platformSettings = array(
        'fb'         => true,
        '4sq'        => true,
        'googlePlus' => true,
        'gmail'      => true,
        'twitter'    => true,
        'yahoo'      => true,
        'badoo'      => true,
    );

    /** @ODM\Hash */
    protected $layersSettings = array(
        'wikipedia' => true, 'tripadvisor' => true, 'foodspotting' => true
    );

    /** @ODM\Hash */
    protected $notificationSettings = array(
        'friend_requests'       => array('sm' => true, 'mail' => true),
        'posts_by_friends'      => array('sm' => true, 'mail' => true),
        'comments'              => array('sm' => true, 'mail' => true),
        'messages'              => array('sm' => true, 'mail' => true),
        'recommendations'       => array('sm' => true, 'mail' => true),
        'proximity_alerts'      => array('sm' => true, 'mail' => true),
        'offline_notifications' => array('sm' => true, 'mail' => true),
        'proximity_radius'      => 0
    );

    /** @ODM\Hash */
    protected $geoFence = array(
        'lat' => 0, 'lng' => 0, 'radius' => 0, //meters
    );

    /** @ODM\Hash */
    protected $settings;

    /** @ODM\String */
    protected $regMedia;

    /** @ODM\String */
    protected $gender;

    /** @ODM\String */
    protected $username;

    /** @var array */
    public $defaultSettings = array(
        'unit' => 'Metrics',
        'visible' => true
    );

    /**
     * @ODM\Hash
     *
     * Possible options: all, friends, none, circles, custom
     */
    protected $sharingPreferenceSettings = array(
        'firstName'          => 'all',
        'lastName'           => 'all',
        'email'              => 'all',
        'dateOfBirth'        => 'all',
        'bio'                => 'all',
        'interests'          => 'all',
        'workStatus'         => 'all',
        'relationshipStatus' => 'all',
        'address'            => 'all',
        'friendRequest'      => 'all',
        'circles'            => 'all',
        'newsfeed'           => 'all',
        'avatar'             => 'all',
        'username'           => 'all',
        'name'               => 'all',
        'gender'             => 'all'
    );

    public function isValid()
    {
        try {
            Validator::create()->email()->assert($this->getEmail());
            Validator::create()->notEmpty()->assert($this->getPassword());
            Validator::create()->notEmpty()->assert($this->getSalt());
            return true;
        } catch (\InvalidArgumentException $e) {
            return false;
        }
    }

    public function isValidForFb()
    {
        try {
            Validator::create()->notEmpty()->assert($this->getFacebookId());
            Validator::create()->notEmpty()->assert($this->getFacebookAuthToken());
            return true;
        } catch (\InvalidArgumentException $e) {
            return false;
        }
    }

    public function toArray($detail = true)
    {
        $shortFields = array(
            'id', 'email', 'firstName', 'lastName', 'avatar'
        );

        $detailFields = array(
            'id',
            'email',
            'firstName',
            'lastName',
            'avatar',
            'enabled',
            'lastLogin',
            'settings',
            'currentLocation',
            'createDate',
            'updateDate',
            'distance',
            'age',
            'gender',
            'address',
            'relationshipStatus',
            'workStatus',
            'dateOfBirth'
        );

        $items = array();
        $targetFields = null;

        if ($detail) {
            $targetFields = $detailFields;
        } else {
            $targetFields = $shortFields;
        }

        foreach ($targetFields as $field) {
            $items[$field] = $this->{"get{$field}"}();
        }

        return $items;
    }

    public function toArrayDetailed()
    {
        $data = array(
            'id'                 => $this->getId(),
            'email'              => $this->getEmail(),
            'firstName'          => $this->getFirstName(),
            'lastName'           => $this->getLastName(),
            'avatar'             => $this->getAvatar(),
            'deactivated'        => $this->getDeactivated(),
            'authToken'          => $this->getAuthToken(),
            'settings'           => $this->getSettings(),
            'source'             => $this->getSource(),
            'dateOfBirth'        => $this->getDateOfBirth(),
            'bio'                => $this->getBio(),
            'gender'             => $this->getGender(),
            'username'           => $this->getUsername(),
            'interests'          => $this->getInterests(),
            'workStatus'         => $this->getWorkStatus(),
            'relationshipStatus' => $this->getRelationshipStatus(),
            'currentLocation'    => $this->getCurrentLocation(),
            'enabled'            => $this->getEnabled(),
            'visible'            => $this->getVisible(),
            'regMedia'           => $this->getRegMedia(),
            'loginCount'         => $this->getLoginCount(),
            'lastLogin'          => $this->getLastLogin(),
            'createDate'         => $this->getCreateDate(),
            'updateDate'         => $this->getUpdateDate(),
            'blockedUsers'       => $this->getBlockedUsers(),
            'blockedBy'          => $this->getBlockedBy(),
            'distance'           => $this->getDistance(),
            'age'                => $this->getAge()
        );

        if ($this->getCircles()) {
            $circles = $this->getCircles();
            foreach ($circles as $circle) {
                $data['circles'][] = $circle->toArray();
            }
        }

        if ($this->getAddress()) {
            $data['address'] = $this->getAddress()->toArray();
        } else {
            $data['address'] = null;
        }

        return $data;
    }

    public function setConfirmationToken($confirmationToken)
    {
        $this->confirmationToken = $confirmationToken;
    }

    public function getConfirmationToken()
    {
        return $this->confirmationToken;
    }

    public function setEmail($email)
    {
        $this->email = $email;
    }

    public function getEmail()
    {
        return $this->email;
    }

    public function setEnabled($enabled)
    {
        $this->enabled = $enabled;
    }

    public function getEnabled()
    {
        return $this->enabled;
    }

    public function setId($id)
    {
        $this->id = $id;
    }

    public function getId()
    {
        return $this->id;
    }

    public function setLastLogin($lastLogin)
    {
        $this->lastLogin = $lastLogin;
    }

    public function getLastLogin()
    {
        return $this->lastLogin;
    }


    public function setPassword($password)
    {
        $this->password = $password;
    }

    public function getPassword()
    {
        return $this->password;
    }

    public function setSalt($salt)
    {
        $this->salt = $salt;
    }

    public function getSalt()
    {
        return $this->salt;
    }

    public function setAvatar($avatar)
    {
        $this->avatar = $avatar;
    }

    public function getAvatar()
    {
        return $this->avatar;
    }

    public function setFirstName($firstName)
    {
        $this->firstName = $firstName;
    }

    public function getFirstName()
    {
        return $this->firstName;
    }

    public function setLastName($lastName)
    {
        $this->lastName = $lastName;
    }

    public function getLastName()
    {
        return $this->lastName;
    }

    public function setAuthToken($authToken)
    {
        $this->authToken = $authToken;
    }

    public function getAuthToken()
    {
        return $this->authToken;
    }

    public function setSettings($settings)
    {
        if (empty($this->settings)) {
            $this->settings = $this->defaultSettings;
        } else {
            $this->settings = array_merge($this->settings, $settings);
        }
    }

    public function getSettings()
    {
        return $this->settings;
    }

    public function setCreateDate($createDate)
    {
        $this->createDate = $createDate;
    }

    public function getCreateDate()
    {
        return $this->createDate;
    }

    public function setUpdateDate($modifyDate)
    {
        $this->updateDate = $modifyDate;
    }

    public function getUpdateDate()
    {
        return $this->updateDate;
    }

    public function setDeactivated($deactivated)
    {
        $this->deactivated = $deactivated;
    }

    public function getDeactivated()
    {
        return $this->deactivated;
    }

    public function setSource($source)
    {
        $this->source = $source;
    }

    public function getSource()
    {
        return $this->source;
    }

    public function setDateOfBirth($dateOfBirth)
    {
        $this->dateOfBirth = new \DateTime($dateOfBirth);
    }

    public function getDateOfBirth()
    {

        return $this->dateOfBirth;
    }

    public function setBio($bio)
    {
        $this->bio = $bio;
    }

    public function getBio()
    {
        return $this->bio;
    }

    public function setInterests($interests)
    {
        $this->interests = $interests;
    }

    public function getInterests()
    {
        return $this->interests;
    }

    public function setWorkStatus($workStatus)
    {
        $this->workStatus = $workStatus;
    }

    public function getWorkStatus()
    {
        return $this->workStatus;
    }

    public function setRelationshipStatus($relationshipStatus)
    {
        $this->relationshipStatus = $relationshipStatus;
    }

    public function getRelationshipStatus()
    {
        return $this->relationshipStatus;
    }

    public function setAddress($address)
    {
        $this->address = $address;
    }

    public function getAddress()
    {
        return $this->address;
    }

    public function setConnector($connector)
    {
        $this->connector = $connector;
    }

    public function getConnector()
    {
        return $this->connector;
    }

    public function addNotification($notification)
    {
        $this->notification[] = $notification;
    }

    public function getNotification()
    {
        return $this->notification;
    }

    public function setCircles($circles)
    {
        $this->circles = $circles;
    }

    public function addCircle(Circle $circle)
    {
        $this->circles[] = $circle;
    }

    public function getCircles()
    {
        return $this->circles;
    }

    public function addFriendRequest($friendRequest)
    {
        $this->friendRequest[] = $friendRequest;
    }

    public function setFriendRequest($friendRequest)
    {
        $this->friendRequest = $friendRequest;
    }

    public function getFriendRequest()
    {
        return $this->friendRequest;
    }

    public function setGeoFence($geoFence)
    {
        $this->geoFence = $geoFence;
    }

    public function getGeoFence()
    {
        return $this->geoFence;
    }

    public function setLocationSettings($locationSettings)
    {
        $this->locationSettings = $locationSettings;
    }

    public function getLocationSettings()
    {
        return $this->locationSettings;
    }

    public function setFacebookId($facebookId)
    {
        $this->facebookId = $facebookId;
    }

    public function getFacebookId()
    {
        return $this->facebookId;
    }

    public function setFacebookAuthToken($facebookAuthToken)
    {
        $this->facebookAuthToken = $facebookAuthToken;
    }

    public function getFacebookAuthToken()
    {
        return $this->facebookAuthToken;
    }

    public function setNotificationSettings(array $notificationSettings)
    {
        $this->notificationSettings = $notificationSettings;
    }

    public function getNotificationSettings()
    {
        return $this->notificationSettings;
    }

    public function setPlatformSettings(array $platformSettings)
    {
        $this->platformSettings = $platformSettings;
    }

    public function getPlatformSettings()
    {
        return $this->platformSettings;
    }

    public function setLayersSettings($layerSettings)
    {
        $this->layersSettings = $layerSettings;
    }

    public function getLayersSettings()
    {
        return $this->layersSettings;
    }

    public function setSharingPreferenceSettings($sharingPreferenceSettings)
    {
        $this->sharingPreferenceSettings = $sharingPreferenceSettings;
    }

    public function getSharingPreferenceSettings()
    {
        return $this->sharingPreferenceSettings;
    }

    public function getAge()
    {
        $dob = $this->getDateOfBirth();

        if ($dob) {
            $age = $dob->diff(new \DateTime());
            return $age->y;
        }

        return 0;
    }

    public function setForgetPasswordToken($forgetPasswordToken)
    {
        $this->forgetPasswordToken = $forgetPasswordToken;
    }

    public function getForgetPasswordToken()
    {
        return $this->forgetPasswordToken;
    }

    public function setCurrentLocation($currentLocation)
    {
        $this->currentLocation = $currentLocation;
    }

    public function getCurrentLocation()
    {
        return $this->currentLocation;
    }

    public function setVisible($visible)
    {
        $this->visible = $visible;
    }

    public function getVisible()
    {
        return $this->visible;
    }

    public function setRegMedia($regMedia)
    {
        $this->regMedia = $regMedia;
    }

    public function getRegMedia()
    {
        return $this->regMedia;
    }

    public function setGender($gender)
    {
        $this->gender = $gender;
    }

    public function getGender()
    {
        return $this->gender;
    }

    public function setUsername($username)
    {
        $this->username = $username;
    }

    public function getUsername()
    {
        return $this->username;
    }

    public function addBlockedUser($user)
    {
        $this->blockedUsers[] = $user->getId();
    }

    public function getBlockedUsers()
    {
        return $this->blockedUsers;
    }

    public function addBlockedBy($userBy)
    {
        $this->blockedBy[] = $userBy->getId();
    }

    public function getBlockedBy()
    {
        return $this->blockedBy;
    }

    public function setLoginCount($loginCount)
    {
        $this->loginCount = $loginCount;
    }

    public function getLoginCount()
    {
        return $this->loginCount;
    }

    public function setOldPassword($oldPassword)
    {
        $this->oldPassword = $oldPassword;
    }

    public function getOldPassword()
    {
        return $this->oldPassword;
    }

    public function getDistance()
    {
        if (isset($this->distance)) {
            $metricValue = floatval($this->distance) * 111.12; // Convert to Km
        } else {
            return 0;
        }

        $unitName = $this->getSettings();
        $this->distance = $this->unitConvert($metricValue, @$unitName['unit']);

        return $this->distance;
    }

    private function unitConvert($value, $unitName = "Metrics")
    {
        if ($unitName != "") {
            if ($unitName == "Imperial") {
                if (isset($this->$value)) {
                    $value = $value * 0.6214;
                }
            }
        }

        return $value;
    }

    public function toArrayFiltered(User $viewer)
    {
        $info = $this->toArray();
        $shearing = $this->getSharingPreferenceSettings();

        foreach($shearing as $field => $value) {
            if($value == 'all') continue;
            else if($value == 'none') {
                if($this->getId() != $viewer->getId()) $info[$field] = null;
            } else if($value == 'friends') {
                if(!in_array($viewer->getId(), $this->getFriends())) $info[$field] = null;
            } else if($value == 'circles') {
                if(!in_array($viewer->getId(), $this->getCircleFriends())) $info[$field] = null;
            }
        }

        return $info;
    }

    public function getFriends()
    {
        $circles = $this->getCircles();
        foreach($circles as $circle) {
            if($circle->getName() == 'friends') {
                return $circle->getFriends();
            }
        }
    }

    public function getCircleFriends()
    {
        $circles = $this->getCircles();
        $friends = array();

        foreach($circles as $circle) {
           $friends = array_merge($friends, $circle->getFriends());
        }

        return $friends;
    }
}
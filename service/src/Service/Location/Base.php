<?php

namespace Service\Location;

/**
 * @ignore
 */
abstract class Base
{
    protected $facebookId;
    protected $facebookAuthToken;

    public function __construct($fbId = null, $fbAuthToken = null) {
        $this->setFacebookId($fbId);
        $this->setFacebookAuthToken($fbAuthToken);
    }

    abstract public function getFriendLocation($userId, $authToken);

    public function getFacebookId() {
        return $this->facebookId;
    }

    public function setFacebookId($facebookId) {
        $this->facebookId = $facebookId;
    }

    public function getFacebookAuthToken() {
        return $this->facebookAuthToken;
    }

    public function setFacebookAuthToken($facebookAuthToken) {
        $this->facebookAuthToken = $facebookAuthToken;
    }
}
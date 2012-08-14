<?php

namespace Mapper;

use Document\User as UserEntity;

class User
{
    /**
     * @var UserEntity
     */
    protected $userEntity;

    public function __construct(UserEntity $user)
    {
        $this->userEntity = $user;
    }

    public function map($data)
    {
        if ($this->userEntity->getId()) {
            $user = $this->userEntity;
        } else {
            $user = clone $this->userEntity;
        }

        if (isset($data['id']) && !is_null($data['id'])) {
            $user->setId($data['id']);
        }

        if (isset($data['email']) && !is_null($data['email'])) {
            $user->setEmail($data['email']);
        }

        if (isset($data['enabled']) && !empty($data['enabled'])) {
            $user->setEnabled((bool)$data['enabled']);
        }

        if (isset($data['salt']) && !is_null($data['salt'])) {
            $user->setSalt($data['salt']);
        }

        if (isset($data['password']) && !is_null($data['password'])) {
            $user->setPassword($data['password']);
        }

        if (isset($data['last_login']) && !is_null($data['last_login'])) {
            $user->setLastLogin($data['last_login']['date']);
        }

        if (isset($data['confirmation_token']) && !is_null($data['confirmation_token'])) {
            $user->setConfirmationToken($data['confirmation_token']);
        }

        if (isset($data['password_requested_at']) && !is_null($data['password_requested_at'])) {
            $user->setPasswordRequestedAt($data['password_requested_at']['date']);
        }

        if (isset($data['locked']) && !empty($data['locked'])) {
            $user->setLocked((bool)$data['locked']);
        }

        if (isset($data['first_name']) && !is_null($data['first_name'])) {
            $user->setFirstName($data['first_name']);
        }

        if (isset($data['middle_name']) && !is_null($data['middle_name'])) {
            $user->setMiddleName($data['middle_name']);
        }

        if (isset($data['last_name']) && !is_null($data['last_name'])) {
            $user->setLastName($data['last_name']);
        }

        if (isset($data['avatar']) && !is_null($data['avatar'])) {
            $user->setAvatar($data['avatar']);
        }

        if (isset($data['auth_token']) && !is_null($data['auth_token'])) {
            $user->setAuthToken($data['auth_token']);
        }

        if (isset($data['settings']) && !is_null($data['settings'])) {
            $user->setSettings($data['settings']);
        }

        if (isset($data['deactivated']) && !empty($data['deactivated'])) {
            $user->setDeactivated((bool)$data['deactivated']);
        }

        return $user;
    }

}
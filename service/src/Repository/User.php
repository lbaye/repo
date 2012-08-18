<?php

namespace Repository;

use Repository\Base as BaseRepository;
use Document\User as UserDocument;
use Document\FriendRequest;
use Helper\Security as SecurityHelper;
use Helper\Image as ImageHelper;

class User extends BaseRepository
{
    public function validateLogin($data)
    {
        if (empty($data)) {
            return false;
        }

        $user = $this->map($data);

        $user = $this->findOneBy(array(
            'email'    => $data['email'],
            'password' => SecurityHelper::hash($user->getPassword(), $user->getSalt())
        ));

        if (!is_null($user)) {
            return $user;
        }

        return false;
    }

    public function validateFbLogin($data)
    {
        if (empty($data)) {
            return false;
        }

        $user = $this->findOneBy(array('facebookId' => $data['facebookId']));

        if (!is_null($user)) {
            return $user;
        }

        return false;
    }

    public function getByEmail($email)
    {
        $user = $this->findOneBy(array('email' => $email));
        return is_null($user) ? false : $user;
    }

    public function getByAuthToken($authToken)
    {
        $user = $this->findOneBy(array('authToken' => $authToken));
        return is_null($user) ? false : $user;
    }

    public function getAll($start, $limit)
    {
        $results = $this->createQueryBuilder('Document\User')->limit($limit)->skip($start)->getQuery()->execute();

        if (count($results) == 0) {
            return false;
        }

        $users = array();
        foreach ($results as $user) {
            $users[] = $user->toArrayDetailed();
        }

        return $users;
    }

    public function getNearBy($lat, $lng, $limit = 20)
    {
        $users = $this->createQueryBuilder()
            ->field('currentLocation.lat')->near($lat)
            ->field('currentLocation.lng')->near($lng)
            ->field('id')->notIn($this->currentUser->getblockedBy())
            ->field('visible')->equals(true)
            ->limit($limit)
            ->getQuery()
            ->execute();

        return (count($users)) ? $this->_toArrayAll($users) : array();
    }

    public function getAllByIds(array $ids)
    {
        $users = $this->createQueryBuilder('Document\User')->field('id')->in(array($ids))->getQuery()->execute();
        return $users;
    }

    public function insert($data)
    {
        $user = $this->map($data);

        $isFacebookRegistration = !empty($data['facebookAuthToken']) AND (!empty($data['facebookId']));

        if ($isFacebookRegistration) {
            $valid = $user->isValidForFb();
        } else {
            $valid = $user->isValid();
        }

        if ($valid !== true) {
            throw new \InvalidArgumentException('Invalid request', 406);
        }

        if ($this->exists($data)) {
            throw new \Exception\ResourceAlreadyExistsException(($isFacebookRegistration) ? $data['facebookId'] : $data['email']);
        }

        if ($isFacebookRegistration) {
            $user->setRegMedia("fb");
        } else {
            $user->setRegMedia("sm");
        }

        if (is_null($user->getSettings())) {
            $user->setSettings($user->defaultSettings);
        } else {
            $user->setSettings(array_merge($user->defaultSettings, $user->getSettings()));
        }

        if (is_null($user->getEnabled())) {
            $user->setEnabled(true);
        }

        // For FB users, their ID is set as default password
        if ($isFacebookRegistration) {
            $user->setPassword(SecurityHelper::hash($data['facebookId'], $user->getSalt()));
        } else {
            $user->setPassword(SecurityHelper::hash($user->getPassword(), $user->getSalt()));
        }

        $user->setConfirmationToken(SecurityHelper::hash(time(), $user->getSalt()));
        $user->setAuthToken(SecurityHelper::hash($user->getEmail(), $user->getSalt()));
        $user->setCreateDate(new \DateTime());

        $this->dm->persist($user);
        $this->dm->flush($user);

        $this->addDefaultCircles($user->getId());

        return $user;
    }

    public function exists($data)
    {
        $qb = $this->createQueryBuilder('Document\User');

        if (isset($data['email'])) {
            $results = $qb->addOr($qb->expr()->field('email')->equals($data['email']))->getQuery()->execute();
        } else {
            $results = $qb->addOr($qb->expr()->field('facebookId')->equals($data['facebookId']))->getQuery()->execute();
        }

        if ($results->count() > 0) {
            return true;
        }

        return false;
    }

    public function update($data, $id)
    {
        if (isset($data['email']) && ($data['email'] != $this->currentUser->getEmail())) {
            if ($this->exists($data)) {
                throw new \Exception\ResourceAlreadyExistsException($data['email']);
            }
        }

        $userDetail = $this->find($id);

        if (false === $userDetail) {
            throw new \Exception\ResourceNotFoundException();
        }

        $user = $this->map($data, $userDetail);

        if ($user->getAuthToken() !== $this->currentUser->getAuthToken()) {
            throw new \Exception\UnauthorizedException();
        }

        if (!empty($data['email']) && $data['email'] != $user->getEmail()) {
            if ($this->exists($data)) {
                throw new \Exception\ResourceAlreadyExistsException($data['email']);
            }
        }

        if (!empty($data['password'])) {
            $user->setPassword(SecurityHelper::hash($user->getPassword(), $user->getSalt()));
        }

        $user->setUpdateDate(new \DateTime());

        if ($user->isValid() === false) {
            return false;
        }

        $this->dm->persist($user);
        $this->dm->flush();

        return $user;
    }

    public function delete($id)
    {
        $user = $this->find($id);

        if (false === $user) {
            throw new \InvalidArgumentException();
        }

        $this->dm->remove($user);
        $this->dm->flush();
    }

    public function addCircle(array $data)
    {
        $circle = new \Document\Circle($data);

        foreach ($data['friends'] as $friendId) {
            $friend = $this->find($friendId);
            if (!empty($friend)) {
                $circle->addFriend($friend);
            }
        }

        $this->currentUser->setUpdateDate(new \DateTime());
        $this->currentUser->addCircle($circle);

        $this->dm->persist($circle);
        $this->dm->persist($this->currentUser);
        $this->dm->flush();

        return $circle;
    }

    public function sendFriendRequests($data, $friendId)
    {
        $user = $this->find($friendId);

        if (false === $user) {
            throw new \InvalidArgumentException();
        }

        $data['userId']      = $this->currentUser->getId();
        $data['friendName']  = $this->currentUser->getFirstName() . " " . $this->currentUser->getLastName();
        $data['recipientId'] = $friendId;

        $friendRequest = new FriendRequest($data);
        $friendRequest->setRequestdate(new \DateTime);

        $user->addFriendRequest($friendRequest);

        $this->dm->persist($friendRequest);
        $this->dm->persist($user);

        $this->dm->flush();

        $data = array(
            'userId'     => $friendId,
            'objectId'   => $user->getId(),
            'objectType' => 'FriendRequest',
            'message'    => (!empty($data['message']) ? $data['message'] : $user->getLastName() . "is inviting you to use socialmaps, download the app and login.")
        );

        $this->addTask('new_friend_request', json_encode($data));
        $this->runTasks();

        return $friendRequest;
    }

    public function map(array $data, UserDocument $user = null)
    {
        if (is_null($user)) {
            $user = new UserDocument();
        }

        $setIfExistFields = array(
            'id',
            'firstName',
            'lastName',
            'gender',
            'username',
            'email',
            'authToken',
            'enabled',
            'salt',
            'password',
            'oldPassword',
            'settings',
            'confirmationToken',
            'forgetPasswordToken',
            'facebookId',
            'facebookAuthToken',
            'avatar',
            'source',
            'dateOfBirth',
            'bio',
            'age',
            'address',
            'interests',
            'workStatus',
            'circles',
            'relationshipStatus',
            'enabled',
            'regMedia',
            'lastLogin',
            'loginCount',
            'createDate',
            'updateDate'
        );

        foreach ($setIfExistFields as $field) {
            if (isset($data[$field]) && !is_null($data[$field])) {
                $user->{"set{$field}"}($data[$field]);
            }
        }

        $user->setAddress(new \Document\Address($data));
        $user->getAddress();

        return $user;
    }

    public function settingsMap(array $data, UserDocument $user = null)
    {
        $setIfExistFields = array(
            'id',
            'firstName',
            'lastName',
            'email',
            'avatar',
            'gender',
            'dateOfBirth',
            'username',
            'address',
            'workStatus',
            'relationshipStatus',
            'password',
            'settings',
            'bio',
            'interests',
            'updateDate'
        );

        foreach ($setIfExistFields as $field) {
            if (isset($data[$field]) && !is_null($data[$field])) {
                $user->{"set{$field}"}($data[$field]);
            }
        }

        $user->setAddress(new \Document\Address($data));
        $user->getAddress();

        return $user;
    }

    public function addNotification($userId, array $data)
    {
        $user = $this->find($userId);

        if (false === $user) {
            throw new \InvalidArgumentException();
        }

        $notification = new \Document\Notification($data);

        $user->addNotification($notification);

        $this->dm->persist($notification);
        $this->dm->persist($user);
        $this->dm->flush();

        return $notification;
    }

    public function acceptFriendRequest($userId)
    {
        $userDetail = $this->find($userId);

        if (false === $userDetail) {
            throw new \Exception\ResourceNotFoundException();
        }

        $this->updateFriendsCircleList($userId);
        $circles = $this->currentUser->getCircles();

        foreach ($circles as &$circle) {
            if ($circle->getName() == 'friends' && $circle->getType() == 'system') {
                $circle->addFriend($userDetail);
            }
        }

        $this->currentUser->setCircles($circles);

        $this->dm->persist($this->currentUser);
        $this->dm->flush();

        return $circle;
    }

    public function addDefaultCircles($id)
    {
        $user = $this->find($id);

        if (false === $user) {
            throw new \InvalidArgumentException();
        }

        $defaultCircles = array('friends', 'second_degree');

        foreach ($defaultCircles as $circle) {

            $data = array();

            $data['name'] = $circle;
            $data['type'] = "system";

            $circle = new \Document\Circle($data);

            $user->addCircle($circle);
            $this->dm->persist($circle);

        }

        $this->dm->persist($user);
        $this->dm->flush();
    }

    public function updateNotification($notificationId)
    {
        $notifications = $this->currentUser->getNotification();

        foreach ($notifications as &$notification) {
            if ($notification->getId() == $notificationId) {
                $notification->setViewed(true);
            }
        }

        $this->dm->persist($this->currentUser);
        $this->dm->flush();

        return true;
    }

    public function updateAccountSettings($data)
    {
        if (isset($data['email']) && ($data['email'] != $this->currentUser->getEmail())) {
            if ($this->exists($data)) {
                throw new \Exception\ResourceAlreadyExistsException($data['email']);
            }
        }

        $user = $this->settingsMap($data, $this->currentUser);

        if ($user->getAuthToken() !== $this->currentUser->getAuthToken()) {
            throw new \Exception\UnauthorizedException();
        }

        if (!empty($data['password'])) {
            $user->setPassword(SecurityHelper::hash($user->getPassword(), $user->getSalt()));
        }

        $user->setUpdateDate(new \DateTime());

        if ($user->isValid() === false) {
            return false;
        }

        $this->dm->persist($user);
        $this->dm->flush();

        return $user;
    }

    public function getPasswordToken($userId)
    {
        $user = $this->find($userId);

        if (false === $user) {
            throw new \Exception\ResourceNotFoundException();
        }

        $data = array();

        $user->setForgetPasswordToken(SecurityHelper::hash(time(), $user->getSalt()));
        $user = $this->map($data, $user);

        return $user->getForgetPasswordToken();
    }

    public function generatePassword($length = 8)
    {
        $password = "";
        $possible = "12346789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
        $maxlength = strlen($possible);

        if ($length > $maxlength) {
            $length = $maxlength;
        }

        $i = 0;

        while ($i < $length) {
            $char = substr($possible, mt_rand(0, $maxlength - 1), 1);
            if (!strstr($password, $char)) {
                $password .= $char;
                $i++;
            }
        }

        return $password;
    }

    public function updateFriendsCircleList($friendId)
    {
        $user = $this->find($friendId);

        if (false === $user) {
            throw new \Exception\ResourceNotFoundException();
        }

        $circles = $user->getCircles();

        foreach ($circles as &$circle) {
            if ($circle->getName() == 'friends' && $circle->getType() == 'system') {
                $circle->addFriend($this->currentUser);
            }
        }

        $user->setCircles($circles);

        $this->dm->persist($user);
        $this->dm->flush();

        return $circle;
    }

    private function _toArrayAll($results)
    {
        $users = array();
        foreach ($results as $user) {
            $users[] = $user->toArray();
        }

        return $users;
    }

    public function getByPasswordToken($passwordToken)
    {
        $user = $this->findOneBy(array('forgetPasswordToken' => $passwordToken));
        return is_null($user) ? false : $user;
    }

    public function resetPassword($data, $userId)
    {
        $userDetail = $this->find($userId);
        $user       = $this->map($data, $userDetail);

        if (false === $user) {
            throw new \Exception\ResourceNotFoundException();
        }

        if (!empty($data['password'])) {
            $user->setPassword(SecurityHelper::hash($user->getPassword(), $user->getSalt()));
        }

        $user->setUpdateDate(new \DateTime());

        $this->dm->persist($user);
        $this->dm->flush();

        return true;
    }

    public function changePassword($data)
    {
        $user = $this->map($data, $this->currentUser);

        $passWord = $this->findOneBy(array('password' => SecurityHelper::hash($user->getOldPassword(), $user->getSalt())));

        if (is_null($passWord)) {
            throw new \Exception\ResourceNotFoundException();
        }

        if (!empty($data['password'])) {
            $user->setPassword(SecurityHelper::hash($user->getPassword(), $user->getSalt()));
        }

        $user->setUpdateDate(new \DateTime());

        $this->dm->persist($user);
        $this->dm->flush();

        return true;
    }

    public function checkOldPassword($password)
    {
        if (empty($password)) {
            return false;
        }

        $user = $this->currentUser;

        if (SecurityHelper::hash($user->getPassword(), $user->getSalt()) != $user->getPassword()) {
            return false;
        }

        return true;
    }

    public function updateLoginCount($id)
    {
        $user = $this->find($id);

        if (false === $user) {
            throw new \Exception\ResourceNotFoundException();
        }

        $loginCount = $user->getLoginCount();
        $user->setLoginCount($loginCount + 1);
        $user->setLastLogin(new \DateTime());

        $this->dm->persist($user);
        $this->dm->flush();

        return $user;
    }

    public function updateFacebookAuthToken($id, $facebookAuthToken)
    {
        $userDetail = $this->find($id);

        if (false === $userDetail) {
            throw new \Exception\ResourceNotFoundException();
        }

        $data = array();

        $user = $this->map($data, $userDetail);

        $user->setFacebookAuthToken($facebookAuthToken);
        $user->setUpdateDate(new \DateTime());

        $this->dm->persist($user);
        $this->dm->flush();

        return $user;
    }

    public function saveAvatarImage($id, $avatar)
    {
        $user = $this->find($id);

        if (false === $user) {
            throw new \Exception\ResourceNotFoundException();
        }

        $filePath = "/images/avatar/" . $user->getId() . ".jpeg";
        $avatarUrl = filter_var($avatar, FILTER_VALIDATE_URL);

        if ($avatarUrl !== false) {
            $user->setAvatar($avatarUrl);
        } else {
            ImageHelper::saveImageFromBase64($avatar, ROOTDIR . $filePath);
            $user->setAvatar($this->config['web']['root'] . $filePath);
        }

        $user->setUpdateDate(new \DateTime());

        $this->dm->persist($user);
        $this->dm->flush();

        return $user;
    }

    public function updateForgetPasswordToken($userId, $passwordToken)
    {
        $userDetail = $this->find($userId);
        $data       = array();
        $user       = $this->map($data, $userDetail);

        $user->setForgetPasswordToken($passwordToken);
        $user->setUpdateDate(new \DateTime());

        if ($user->isValid() === false) {
            return false;
        }

        $this->dm->persist($user);
        $this->dm->flush();

        return $user;
    }

    public function search($keyword = null, $location = array(), $limit = 20)
    {
        $query = $this->createQueryBuilder()
            ->field('currentLocation')->withinCenter($location['lng'], $location['lat'], \Controller\Search::DEFAULT_RADIUS)
            ->field('id')->notIn($this->currentUser->getBlockedBy())
            ->field('visible')->equals(true)
            ->limit($limit);

        if (!is_null($keyword)) {
            $query->addOr($query->expr()->field('firstName')->equals(new \MongoRegex('/' . $keyword . '.*/i')));
            $query->addOr($query->expr()->field('lastName')->equals(new \MongoRegex('/' . $keyword . '.*/i')));
        }

        $users = $query->getQuery()->execute();

        return (count($users)) ? $this->_toArrayAll($users) : array();
    }

    public function getFacebookUsers($start = null, $limit = null)
    {
        $query = $this->createQueryBuilder()->field('facebookAuthToken')->exists(true);

        if ($start != null) {
            $query->skip($start);
        }

        if ($limit != null) {
            $query->limit($limit);
        }

        $users = $query->getQuery()->execute();
        return (count($users)) ? $users : array();
    }

}
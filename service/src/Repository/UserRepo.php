<?php

namespace Repository;

use Symfony\Component\HttpFoundation\Response;
use Document\User as UserDocument;
use Document\FriendRequest;
use Helper\Security as SecurityHelper;
use Helper\Image as ImageHelper;

class UserRepo extends Base
{
    public function validateLogin($data)
    {
        if (empty($data)) {
            return false;
        }

        $user = $this->map($data);

        $user = $this->findOneBy(array(
            'email' => $data['email'],
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
            ->field('currentLocation')->near($lat, $lng)
            ->field('id')->notIn($this->currentUser->getblockedBy())
            ->field('visible')->equals(true)
            ->limit($limit)
            ->getQuery()
            ->execute();

        return (count($users)) ? $this->_toArrayAll($users) : array();
    }

    public function getAllByIds(array $ids, $asArray = true)
    {
        $users = $this->createQueryBuilder('Document\User')->field('id')->in($ids)->getQuery()->execute();
        return $asArray ? $this->_toArrayAll($users) : $users;
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
            $user->setAuthToken(SecurityHelper::hash($data['facebookId'], $user->getSalt()));
        } else {
            $user->setPassword(SecurityHelper::hash($user->getPassword(), $user->getSalt()));
            $user->setAuthToken(SecurityHelper::hash($user->getEmail(), $user->getSalt()));
        }

        $user->setConfirmationToken(SecurityHelper::hash(time(), $user->getSalt()));
        $user->setCreateDate(new \DateTime());

        $this->dm->persist($user);
        $this->dm->flush($user);

        $this->addDefaultCircles($user->getId());

        return $user;
    }

    public function exists($data)
    {
        $qb = $this->createQueryBuilder('Document\User');

        if (isset($data['facebookId'])) {
            $result = $qb->field('facebookId')->equals($data['facebookId'])->getQuery()->execute();
        }

        if (isset($data['email'])) {

            $result = $qb->field('email')->equals($data['email'])->getQuery()->execute();
        }

        if ($result->count() > 0) {
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

    public function addCircle(array $data)
    {
        $circle = new \Document\Circle($data);

        if (!empty($data['friends'])) {
            $users = $this->_trimInvalidUsers($data['friends']);

            foreach ($users as $friendId) {
                $friend = $this->find($friendId);
                if (!empty($friend)) {
                    $circle->addFriend($friend);
                }
            }
        }


        $this->currentUser->setUpdateDate(new \DateTime());
        $this->currentUser->addCircle($circle);

        $this->dm->persist($circle);
        $this->dm->persist($this->currentUser);
        $this->dm->flush();

        return $circle;
    }

    public function updateCircle($id, array $data)
    {
        $circles = $this->currentUser->getCircles();


        $users = $this->_trimInvalidUsers($data['friends']);

        foreach ($circles as $circle) {
            if ($circle->getId() == $id) {

                if (!empty($data['name'])) {
                    $circle->setName($data['name']);
                }

                if (!empty($data['friends'])) {

                    $friends = (array_unique(array_merge($circle->getFriends(), $users)));

                    foreach ($friends as $friend) {
                        $friendId = $this->find($friend);
                        $circle->addFriend($friendId);
                    }

                }

            }
        }

        $this->currentUser->setCircles($circles);
        $this->dm->persist($this->currentUser);
        $this->dm->flush();

        return true;

    }

    public function sendFriendRequests($data, $friendId)
    {
        $recipient = $this->find($friendId);

        if (is_null($recipient)) {
            throw new \Exception\ResourceNotFoundException($friendId);
        }

        $existingFriendRequests = $recipient->getFriendRequest();

        foreach ($existingFriendRequests as $existingFriendRequest) {

            if ($existingFriendRequest->getUserId() == $this->currentUser->getId()) {
                throw new \Exception('Friend request previously sent to this recipient.');
            }
        }

        $data['userId'] = $this->currentUser->getId();
        $data['friendName'] = $this->currentUser->getFirstName() . " " . $this->currentUser->getLastName();
        $data['recipientId'] = $friendId;

        $friendRequest = new FriendRequest($data);
        $friendRequest->setRequestdate(new \DateTime);

        $recipient->addFriendRequest($friendRequest);

        $this->dm->persist($friendRequest);
        $this->dm->persist($recipient);

        $this->dm->flush();

        $data = array(
            'userId' => $friendId,
            'objectId' => $recipient->getId(),
            'objectType' => 'FriendRequest',
            'message' => (!empty($data['message']) ? $data['message'] : $recipient->getLastName() . "is inviting you to use socialmaps, download the app and login.")
        );

        $this->addTask('new_friend_request', json_encode($data));

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
            'coverPhoto',
            'status',
            'company',
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
            'coverPhoto',
            'status',
            'company',
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

        $user->setAddress(new \Document\Address(array_merge($user->getAddress()->toArray(), $data)));

        $user->getAddress();

        return $user;
    }

    public function addNotification($userId, array $data)
    {
        $user = $this->find($userId);

        if (is_null($user)) {
            throw new \InvalidArgumentException();
        }

        $notification = new \Document\Notification($data);

        $user->addNotification($notification);

        $this->dm->persist($notification);
        $this->dm->persist($user);
        $this->dm->flush();

        return $notification;
    }

    public function acceptFriendRequest($userId, $response)
    {
        $user = $this->find($userId);

        if (is_null($user)) {
            throw new \Exception\ResourceNotFoundException();
        }

        if ($response == 'accept') {

            $this->updateFriendsCircleList($userId);
            $circles = $this->currentUser->getCircles();

            foreach ($circles as &$circle) {
                if ($circle->getName() == 'friends' && $circle->getType() == 'system') {
                    $circle->addFriend($user);
                }
            }

            $this->currentUser->setCircles($circles);

        }

        $friendRequests = $this->currentUser->getFriendRequest();

        foreach ($friendRequests as &$friendRequest) {
            if ($friendRequest->getUserId() == $userId) {
                $friendRequest->setAccepted(($response == 'accept'));
            }
        }

        $this->currentUser->setFriendRequest($friendRequests);

        $this->dm->persist($this->currentUser);
        $this->dm->flush();
    }

    public function addDefaultCircles($id)
    {
        $user = $this->find($id);

        if (is_null($user)) {
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
//                $notification->setViewed(true);
            }
        }

        $this->currentUser->setNotification($notifications);

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
            $user->setPassword(SecurityHelper::hash($user->getPassword(), \Document\User::SALT));
        }

        $user->setUpdateDate(new \DateTime());

        $this->dm->persist($user);
        $this->dm->flush();

        return $user;
    }

    public function getPasswordToken($userId)
    {
        $user = $this->find($userId);

        if (is_null($user)) {
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

        if (is_null($user)) {
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

    protected function _toArrayAll($results, $filterFields = false)
    {
        $users = array();
        foreach ($results as $user) {
            $userArr = ($filterFields) ? $user->toArrayFiltered($this->currentUser) : $user->toArray();
            $userArr['friendship'] = $this->currentUser->getFriendship($user);

            $userArr['avatar'] = $this->_buildAvatarUrl($userArr);
            $userArr['coverPhoto'] = $this->_buildCoverPhotoUrl($userArr);
            $users[] = $userArr;

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
        $user = $this->find($userId);

        if (is_null($user)) {
            throw new \Exception\ResourceNotFoundException();
        }

        if (!empty($data['password'])) {
            $user->setPassword(SecurityHelper::hash($data['password'], \Document\User::SALT));
        }

        $user->setUpdateDate(new \DateTime());

        $this->dm->persist($user);
        $this->dm->flush();

        return true;
    }

    public function changePassword($data)
    {
        $user = $this->findOneBy(array('password' => SecurityHelper::hash($data['oldPassword'], \Document\User::SALT)));

        if (is_null($user)) {
            throw new \Exception\ResourceNotFoundException();
        }

        if (!empty($data['password'])) {
            $user->setPassword(SecurityHelper::hash($data['password'], \Document\User::SALT));
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
        $user = $this->find($id);

        if (is_null($user)) {
            throw new \Exception\ResourceNotFoundException();
        }

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

        $user->setUpdateDate(new \DateTime());

        $timeStamp = $user->getUpdateDate()->getTimestamp();

        $filePath = "/images/avatar/" . $user->getId();
        $avatarUrl = filter_var($avatar, FILTER_VALIDATE_URL);

        if ($avatarUrl !== false) {
            $user->setAvatar($avatarUrl);
        } else {
            @ImageHelper::saveImageFromBase64($avatar, ROOTDIR . $filePath);
            $user->setAvatar($filePath . "?" . $timeStamp);
        }


        $this->dm->persist($user);
        $this->dm->flush();

        return $user;
    }

    public function saveCoverPhoto($id, $coverPhoto)
    {
        $user = $this->find($id);

        if (false === $user) {
            throw new \Exception\ResourceNotFoundException();
        }

        $user->setUpdateDate(new \DateTime());
        $timeStamp = $user->getUpdateDate()->getTimestamp();
        $filePath = "/images/cover-photo/" . $user->getId();
        $coverPhotoUrl = filter_var($coverPhoto, FILTER_VALIDATE_URL);

        if ($coverPhotoUrl !== false) {
            $user->setCoverPhoto($coverPhotoUrl);
        } else {
            ImageHelper::saveImageFromBase64($coverPhoto, ROOTDIR .$filePath);
            $user->setCoverPhoto($filePath . "?" . $timeStamp);
        }


        $this->dm->persist($user);
        $this->dm->flush();

        return $user;
    }

    public function updateForgetPasswordToken($userId, $passwordToken)
    {
        $userDetail = $this->find($userId);
        $data = array();
        $user = $this->map($data, $userDetail);

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
        $exclude = array();
        $blockUserList = array();
        $exclude[] = $this->currentUser->getId();

        if ($this->currentUser->getBlockedBy()) {
            $exclude = array_merge($exclude, $this->currentUser->getBlockedBy());
        }

        $query = $this->createQueryBuilder()
            ->field('id')->notIn($exclude)
            ->field('visible')->equals(true)
            ->limit($limit);

//        if (!is_null($keyword)) {
//            $query->addOr($query->expr()->field('firstName')->equals(new \MongoRegex('/' . $keyword . '.*/i')));
//            $query->addOr($query->expr()->field('lastName')->equals(new \MongoRegex('/' . $keyword . '.*/i')));
//        } else {
//            // @TODO : Changing to near temporarily for testing with more users
//           // $query->field('currentLocation')->withinCenter($location['lng'], $location['lat'], \Controller\Search::DEFAULT_RADIUS);
//            $query->field('currentLocation')->near($location['lat'], $location['lng']);
//        }

        $result = $query->getQuery()->execute();

        if (count($result)) {

            $friends = $this->currentUser->getFriends();
            $users = $this->_toArrayAll($result, true);

            $blockUserList = $this->currentUser->getBlockedUsers();
            foreach ($users as &$user) {
                $user['distance'] = \Helper\Location::distance($location['lat'], $location['lng'], $user['currentLocation']['lat'], $user['currentLocation']['lng']);
                if (in_array($user['id'],$blockUserList)) {
                    $user['blockStatus'] = "blocked";
                } else {
                    $user['blockStatus'] = "unblocked";
                }
            }

            return $users;
        }

        return array();
    }

    public function searchWithPrivacyPreference($keyword = null, $location = array(), $limit = 20) {
        $people_around = $this->search($keyword, $location, $limit);
        $visible_people = array();

        # TODO: How to fix less than $limit items
        foreach ($people_around as $target_user_hash) {
            $target_user = $this->find($target_user_hash['id']);
            if ($target_user->isVisibleTo($this->currentUser)) {
                $visible_people[] = $target_user_hash;
            }
        }

        return $visible_people;
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

    public function removeFriendFromCircle($id, array $data)
    {
        $circles = $this->currentUser->getCircles();
        $friends = $this->_trimInvalidUsers($data['friends']);

        if (!empty($data['friends'])) {
            foreach ($circles as $circle) {
                if ($circle->getId() === $id) {
                    $circleFriends = $circle->getFriends();
                    $circle->setFriendIds(array_diff($circleFriends, $friends));
                }
            }
        }

        $this->currentUser->setCircles($circles);
        $this->dm->persist($this->currentUser);
        $this->dm->flush();

        return true;
    }

    public function addFriendToMultipleCircle($id, array $data)
    {
        $circles = $this->currentUser->getCircles();

        $user = $this->_trimInvalidUsers(array($id));
        if (!empty($data['circles'])) {

            foreach ($circles as $circle) {

                if ($circle->getType() == 'system' && in_array($circle->getId(), $data)) {

                    throw new \InvalidArgumentException('Invalid request', 406);
                }
                foreach ($data['circles'] AS $circleId) {

                    if ($circle->getId() == $circleId) {

                        $friends = (array_unique(array_merge($circle->getFriends(), $user)));

                        foreach ($friends as $friend) {
                            $friendId = $this->find($friend);
                            $circle->addFriend($friendId);
                        }

                    }

                }


            }

        }

        $this->currentUser->setCircles($circles);
        $this->dm->persist($this->currentUser);
        $this->dm->flush();

        return true;

    }

    public function getNotificationsCount($id)
    {
        $user = $this->find($id);
        $friendRequests = $user->getFriendRequest();

        $notifications = $user->getNotification();

        $friendResult = array();
        $notificationResult = array();

        foreach ($friendRequests as $friendRequest) {
            $friendResult[] = $friendRequest->toArray();
        }

        foreach ($notifications as $notification) {

            if ($notification->getViewed() != true) {
                $notificationResult[] = $notification->toArray();
            }

        }

        return $countTotal = count($notificationResult) . ":" . count($friendResult);
    }

    public function unBlockUsers($id, array $data)
    {

        if (empty($data['users'])) {
            throw new \InvalidArgumentException('Invalid request', 406);
        }

        $users = $this->_trimInvalidUsers($data['users']);
        $user = $this->find($id);
        $user->updateBlockedUser(array_diff($user->getBlockedUsers(), $users));


        $this->dm->persist($this->currentUser);
        $this->dm->flush();

        return true;
    }
}
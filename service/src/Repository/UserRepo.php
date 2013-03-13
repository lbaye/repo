<?php

namespace Repository;


use Symfony\Component\HttpFoundation\Response;
use Document\User as UserDocument;
use Document\FriendRequest;
use Helper\Security as SecurityHelper;
use Helper\Image as ImageHelper;
use Helper\Constants as Constants;
use Helper\Util as Util;

/**
 * Data access functionality for user model
 */
class UserRepo extends Base
{
    const MAX_NOTIFICATIONS = 20;
    const EVENT_ADDED_FRIEND = 'added_friend';
    static $DEFAULT_USER_FIELDS = array('_id', 'firstName', 'lastName', 'currentLocation', 'email',
        'status', 'avatar', 'coverPhoto', 'distance',
        'age', 'gender', 'lastSeenAt', 'relationshipStatus', 'username',
        'workStatus', 'dateOfBirth', 'regMedia', 'address', 'lastPulse');

    protected $loggerName = 'Repository::UserRepo';

    public function bindObservers()
    {
        $this->addObserver(new \Document\UsersObserver($this->dm, $this));
    }

    public function validateLogin($data)
    {
        if (empty($data)) {
            return false;
        }

        $user = $this->map($data);

        $user = $this->findOneBy(array(
            'email' => $data['email'],
            'password' => SecurityHelper::hash($user->getPassword(), $user->getSalt()),
            'enabled' => true
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

        $user = $this->findOneBy(array('facebookId' => $data['facebookId'], 'enabled' => true));

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

    public function getByUserId($id)
    {
        $user = $this->findOneBy(array('id' => $id));
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
            throw new \Exception\ResourceAlreadyExistsException(($isFacebookRegistration) ? $data['facebookId']
                : $data['email']);
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

    public function checkFbUser($data)
    {
        if (isset($data['facebookId'])) {
            $existFacebookId = $this->findOneBy(array('facebookId' => $data['facebookId']));
            return is_null($existFacebookId) ? false : true;
        }

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

        return $this->updateObject($user);
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
        $friend = $this->find($friendId);
        if (is_null($friend)) throw new \Exception\ResourceNotFoundException($friendId);

        $this->debug(sprintf('Sending friend request to - %s', $friend->getFirstName()));

        $existingRequests = $friend->getFriendRequest();

        foreach ($existingRequests as $request)
            if ($request->getUserId() == $this->currentUser->getId()) {
                $this->warn('Existing friend request found');
                throw new \Exception('Friend request previously sent to this recipient.');
            }

        $data['userId'] = $this->currentUser->getId();
        if ($this->currentUser->getFirstName() == null || $this->currentUser->getLastName() == null) {
            $data['friendName'] = $this->currentUser->getUsername();
        } else {
            $data['friendName'] = $this->currentUser->getFirstName() . " " . $this->currentUser->getLastName();
        }

        $data['recipientId'] = $friendId;

        $friendRequest = new FriendRequest($data);
        $friendRequest->setRequestdate(new \DateTime);

        $friend->addFriendRequest($friendRequest);

        $this->dm->persist($friendRequest);
        $this->dm->persist($friend);

        $this->dm->flush();
        $this->debug('Friend request stored');

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
        $frequest = null;

        foreach ($friendRequests as &$friendRequest) {
            if ($friendRequest->getUserId() == $userId) {
                $frequest = $friendRequest;
                $friendRequest->setAccepted(($response == 'accept'));
            }
        }

        $this->currentUser->setFriendRequest($friendRequests);

        $this->dm->persist($this->currentUser);
        $this->dm->flush();

        if ($frequest) {
            $this->announcement(self::EVENT_ADDED_FRIEND, array('object' => $frequest));
            return $frequest->getId();
        }
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
                $notification->setViewed(true);
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

    public function insertFacebookAuthInfo($id, $facebookAuthId, $facebookAuthToken)
    {
        $user = $this->find($id);

        if (is_null($user)) {
            throw new \Exception\ResourceNotFoundException();
        }

        $user->setFacebookId($facebookAuthId);
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

        $baseDir = ROOTDIR . "/images/avatar/";
        if (!file_exists($baseDir))
            mkdir($baseDir, 0777, true);

        $filePath = "/images/avatar/" . $user->getId();
        $avatarUrl = filter_var($avatar, FILTER_VALIDATE_URL);

        if ($avatarUrl !== false) {
            $avatarUrl = preg_replace("/\&type=normal/i", "?type=normal", $avatarUrl);
            $user->setAvatar($avatarUrl);
        } else {
            $thumbPath = $this->findOrCreateAvatarThumbnailPath();
            ImageHelper::saveResizeAvatarFromBase64(
                $avatar, ROOTDIR . $filePath,
                $thumbPath . DIRECTORY_SEPARATOR . $user->getId());
            $user->setAvatar($filePath . "?" . $timeStamp);
        }

        $this->dm->persist($user);
        $this->dm->flush();

        return $user;
    }

    public function findOrCreateAvatarThumbnailPath()
    {
        $fullThumbPath = ROOTDIR . '/images/avatar/thumb';

        if (!file_exists($fullThumbPath)) {
            mkdir($fullThumbPath, 0777, true);
            return $fullThumbPath;
        }

        return $fullThumbPath;
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
            ImageHelper::saveImageFromBase64($coverPhoto, ROOTDIR . $filePath);
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

    public function search($keyword = null, $location = array(),
                           $limit = Constants::PEOPLE_LIMIT, $key = null, $hour = null, $minute = null)
    {

        $users = $this->searchNearByPeople($keyword, $location, array('limit' => $limit, 'offset' => 0), $hour, $minute);
        $filteredUsers = array();

        if (!empty($users)) {
            foreach ($users as $userHash) {
                $this->prepareUserData($userHash, $location, $key, 1);
                $filteredUsers[] = $userHash;
            }

            return $filteredUsers;
        }

        return array();
    }

    public function searchNearByPeople($keywords, array $location, array $options = array(), $hour = null, $minute = null)
    {
        // Set all required parameters
        $limit = $options['limit'];
        $offset = $options['offset'];

        // Determine selectable fields based on options
        $selectableFields = isset($options['select']) ? $options['select'] : self::$DEFAULT_USER_FIELDS;

        // Include current user in excluded users list
        $excludedUserIds = array($this->currentUser->getId());

        // Include blocked users in excluded users list
        if ($this->currentUser->getBlockedBy())
            $excludedUserIds = array_merge($excludedUserIds, $this->currentUser->getBlockedBy());

        // Retrieve all users
        $query = $this->createQueryBuilder('Document\User');
        call_user_func_array(array($query, 'select'), $selectableFields);

//        $hour = date('H');
//        $minute = date('i');
        if (isset($hour) || isset($minute))
            $_dateTime = new \DateTime($hour . 'hours ' . $minute . ' minutes ago');
//         ->field('updateDate')->gte($_dateTime)
        if (!isset($_dateTime)) {
            $query->field('id')->notIn($excludedUserIds)
                ->field('visible')->equals(true)
                ->field('enabled')->equals(true)
                ->field('currentLocation.lat')->notEqual(0)
                ->field('currentLocation.lng')->notEqual(0)
                ->hydrate(false)
                ->limit($limit);
        } else {
            $query->field('id')->notIn($excludedUserIds)
                ->field('visible')->equals(true)
                ->field('enabled')->equals(true)
                ->field('currentLocation.lat')->notEqual(0)
                ->field('currentLocation.lng')->notEqual(0)
                ->field('updateDate')->gte($_dateTime)
                ->hydrate(false)
                ->limit($limit);
        }

        //$query->field('currentLocation')->withinCenter($location['lng'], $location['lat'], \Controller\Search::DEFAULT_RADIUS);

        if (isset($location['sw']) && isset($location['ne'])) {
            $query->field('currentLocation');
            $locationParams = array();
            foreach (array_merge($location['ne'], $location['sw']) as $position)
                $locationParams[] = (float)$position;
            call_user_func_array(array($query, 'withinBox'), $locationParams);
        }

        return $query->getQuery()->execute();
    }

    private function prepareUserData(&$userHash, &$location, &$key, $getAvatarForSearch = null)
    {
        # Set user database id to "id" field
        $id = $userHash['_id']->__toString();
        $userHash['id'] = &$id;
        unset($userHash['_id']);

        # unset address _id
        if (isset($userHash['address'])) {
            unset($userHash['address']['_id']);

            if (empty($userHash['address']))
                $userHash['address'] = null;
        }

        # Ensure null is set if no user name is set
        if (isset($userHash['username']) && empty($userHash['username']))
            $userHash['username'] = null;

        # Retrieve user object
        $userObj = $this->find($userHash['id']);

        # Pull authenticated user and visiting user's relationship
        $userHash['friendship'] = $this->currentUser->getFriendship($userObj);

        # Setting up absolute urls for user avatar and cover photo
        $userHash['avatar'] = $this->_buildAvatarUrl($userHash);
        $isFbAvatar = preg_match("/graph.facebook.com/i", $userHash['avatar']);

        if (($getAvatarForSearch) && empty($isFbAvatar)) {
            $userHash['avatar'] = preg_replace("/avatar/", "avatar/thumb", $userHash['avatar']);
        }
        $userHash['coverPhoto'] = $this->_buildCoverPhotoUrl($userHash);

        # Set Online/offline status
        $userHash['online'] = $userObj->isOnlineUser();

        # Set street view image if no cover photo is set
        $noCoverPhotoSet = !isset($userHash['coverPhoto']) || empty($userHash['coverPhoto']);
        $currentLocationFound = isset($userHash['currentLocation']) &&
            !empty($userHash['currentLocation']['lat']) &&
            !empty($userHash['currentLocation']['lng']) &&
            0 != $userHash['currentLocation']['lat'] &&
            0 != $userHash['currentLocation']['lng'];

        if ($currentLocationFound && $noCoverPhotoSet)
            $userHash['coverPhoto'] =
                \Helper\Url::buildStreetViewImage($key, $userHash['currentLocation']);


        # Calculate distance if current location is set
        if (!$currentLocationFound)
            $userHash['distance'] = Constants::DISTANCE_UPPER_LIMIT;

        else
            $userHash['distance'] = \Helper\Location::distance(
                $location['lat'], $location['lng'],
                $userHash['currentLocation']['lat'],
                $userHash['currentLocation']['lng']);

        # Flag as "Blocked" if user is in blocked users list
        $blockedUsers = $this->currentUser->getBlockedUsers();
        if (in_array($userHash['id'], $blockedUsers))
            $userHash['blockStatus'] = UserDocument::BLOCKED;
        else
            $userHash['blockStatus'] = UserDocument::UNBLOCKED;

        if (isset($userHash['dateOfBirth']) && !empty($userHash['dateOfBirth'])) {
            $newTime = new \DateTime();
            $newTime->setTimestamp($userHash['dateOfBirth']->sec);
            $userHash['dateOfBirth'] = $newTime;
        }
    }

    public function searchWithPrivacyPreference($keyword = null, $location = array(), $limit = 20, $key = null, $hour, $minute)
    {

        $people_around = $this->search($keyword, $location, $limit, $key, $hour, $minute);
        $visible_people = array();

        # TODO: How to fix less than $limit items
        foreach ($people_around as $target_user_hash) {
            if (isset($target_user_hash['lastSeenAt']) && !empty($target_user_hash['lastSeenAt'])) {
                $target_user_hash['lastSeenAt'] = "Last seen at " . \Helper\Util::formatAddress($target_user_hash['lastSeenAt']);
                if (!$target_user_hash['online'] && !empty($target_user_hash['lastPulse'])) {

                    $time = ((array)time());
                    $now = $time[0];
                    $then = (array)$target_user_hash['lastPulse'];
                    $then = (int)($then['sec']);
                    $diff = $now - $then;

                    $target_user_hash['lastSeenAt'] .= " about " . Util::humanizeTimeDiff($diff);
                }
            }

            $target_user = $this->find($target_user_hash['id']);
            if ($target_user->isVisibleTo($this->currentUser)) {
                $visible_people[] = $target_user_hash;
            }
        }

        return $visible_people;
    }

    public function getFbConnectedUsers($start = 0, $limit = 50)
    {
        $query = $this->createQueryBuilder()
            ->field('facebookAuthToken')->exists(true)
            ->hydrate(false);

        $users = $query->getQuery()->execute();
        return (!empty($users)) ? $users : array();
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

    public function unBlockAllUsers($id, array $data)
    {

        if (empty($data['users'])) {
            throw new \InvalidArgumentException('Invalid request', 406);
        }

        $users = $this->_trimInvalidUsers($data['users']);
        $user = $this->find($id);
        $user->updateBlockedUser($users);

        $this->dm->persist($this->currentUser);
        $this->dm->flush();

        return true;
    }

    public function deleteCustomCircle($id)
    {
        $circles = $this->currentUser->getCircles();

        $result = array();
        foreach ($circles as $circle) {
            if ($circle->getId() == $id) {
                $result = $circle->toArray();
            }
        }

        if ($result['type'] == 'system') {
            throw new \InvalidArgumentException('Invalid request', 406);
        }

        $counter = 0;
        foreach ($circles as $circle) {

            if ($circle->getId() === $id) {
                unset($circles[$counter]);
            }
            $counter++;
        }

        $this->currentUser->setCircles($circles);
        $this->dm->persist($this->currentUser);
        $this->dm->flush();

        return true;

    }

    public function renameCustomCircle($id, $data)
    {
        $circles = $this->currentUser->getCircles();

        foreach ($circles as $circle) {
            if ($circle->getId() == $id) {
                if (!empty($data['name'])) {
                    $circle->setName($data['name']);
                }
            }
        }

        $this->currentUser->setCircles($circles);
        $this->dm->persist($this->currentUser);
        $this->dm->flush();

        return true;
    }

    public function removeOldNotifications(UserDocument $user)
    {
        $notifications = $user->getNotification();

        if (count($notifications) > 0) {
            $user->setNotification(array_slice($notifications, 0, self::MAX_NOTIFICATIONS));
            $this->dm->persist($user);
            $this->dm->flush();
        }

        return true;
    }

    public function removeFriendFromMyCircle($id)
    {
        $circles = $this->currentUser->getCircles();
        $friendId = $this->_trimInvalidUsers($id);

        if (!empty($friendId)) {
            foreach ($circles as $circle) {
                $circleFriends = $circle->getFriends();
                $circle->setFriendIds(array_diff($circleFriends, $friendId));
            }
        }

        $this->currentUser->setCircles($circles);
        $this->dm->persist($this->currentUser);
        $this->dm->flush();

        return true;
    }

    public function generateNotificationCount($user_id)
    {

        $user = $this->find($user_id);
        $messageRepo = $this->dm->getRepository('Document\Message');

        $friend_requests = $user->getFriendRequest();
        $pending_friend_requests_count = 0;

        foreach ($friend_requests as $friend_request) {
            if ($friend_request->getAccepted() === null)
                $pending_friend_requests_count++;
        }

        $unread_messages = $messageRepo->getUnreadMessagesByRecipient($user);
        $unread_messages_count = count($unread_messages);

        return array(
            "badge" => $pending_friend_requests_count + $unread_messages_count,
            "tabCounts" => "{$unread_messages_count}|{$pending_friend_requests_count}|0",
            "sound" => "default"
        );
    }

    public function updateUserPulse(\Document\User $user)
    {
        if (!$user->isOnlineUser()) {
            $this->debug('Updating user pulse');
            $user->setLastPulse(new \DateTime());
            $this->updateObject($user);
        }
    }

    public function resetDuplicateDeviceId($deviceId)
    {
        $this->createQueryBuilder('Document\User')
            ->update()
            ->field('pushSettings.device_id')->equals($deviceId)
            ->field('pushSettings.device_id')->set(null)
            ->getQuery()->execute();
        $this->dm->flush();
    }
}
<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;
use Repository\UserRepo as UserRepository;

use Document\FriendRequest;
use Helper\Status;
use Helper\AppMessage as AppMessage;

/**
 * Manage SocialMaps system user
 */
class User extends Base
{
    public function init()
    {
        $this->response = new Response();
        $this->response->headers->set('Content-Type', 'application/json');

        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->_updatePulse();
        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);
        $this->createLogger('Controller::User');
    }

    /**
     * GET /users
     *
     * Retrieve all users from the system
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function get()
    {
        $this->_ensureLoggedIn();

        $start = $this->request->get('start', 0);
        $limit = $this->request->get('limit', 20);

        $location = $this->user->getCurrentLocation();

        if (!isset($location['lat']) || !isset($location['lng'])) {
            $this->response->setContent(json_encode(array('message' => 'Users Current location is not updated!')));
            $this->response->setStatusCode(Status::NOT_ACCEPTABLE);
        } else {
            $users = $this->userRepository->getNearBy($location['lat'], $location['lng'], $limit);

            if (!empty($users)) {
                $this->response->setContent(json_encode($users));
                $this->response->setStatusCode(Status::OK);
            } else {
                $this->response->setContent(json_encode(array('message' => 'No deals found')));
                $this->response->setStatusCode(Status::NO_CONTENT);
            }
        }

        return $this->response;
    }

    /**
     * GET /me/notifications
     *
     * Retrieve notifications from the current user
     *`
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getNotifications()
    {
        $this->_ensureLoggedIn();

        $notifications = $this->user->getNotification();

        $result = array();

        foreach ($notifications as $notification) {
            if ($notification->getViewed() != true) {
                $result[] = $notification;
                $this->updateNotification($notification->getId());
            }
        }

        $this->userRepository->removeOldNotifications($this->user);

        if (empty($result)) {
            $this->_generateResponse(array(), Status::OK);
        } else {
            $this->_generateResponse($this->_toArrayAll($result));
        }

        return $this->response;
    }

    /**
     * GET /request/friend
     *
     * Retrieve all pending friend requests from the current user
     *
     * @param string $status all | accepted | unaccepted
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getFriendRequest($status = 'all')
    {
        $friendRequests = $this->user->getFriendRequest();
        $result = array();

        foreach ($friendRequests as $friendRequest) {
            if ($status != 'all') {
                if ($status == 'accepted') {
                    if ($friendRequest->getAccepted() === true) {
                        $result[] = $friendRequest->toArray();
                    }
                } else {
                    if ($friendRequest->getAccepted() === null) {
                        $result[] = $friendRequest->toArray();
                    }
                }
            } else {
                $result[] = $friendRequest->toArray();
            }
        }

        if (empty($result)) {
            $this->response->setContent(json_encode(array('message' => 'There is no friend request for you.')));
        } else {
            $this->response->setContent(json_encode($result));
        }

        $this->response->setStatusCode(Status::OK);

        return $this->response;
    }

    /**
     * POST /request/friend/:friendId
     *
     * Send new friend request between current user and another SocialMaps user
     *
     * @param $friendId
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function sendFriendRequest($friendId)
    {
        $data = $this->request->request->all();

        try {
            $this->debug('Sending friend request');
            $friendRequest = $this->userRepository->sendFriendRequests($data, $friendId);

            $this->debug('Sending in app notification');
            $this->sendInAppNotification($this->user, $friendRequest);

            $this->debug('Sending push notification');
            $this->_sendPushNotification(
                array($friendId), $this->_createPushMessage(),
                AppMessage::FRIEND_REQUEST, $friendRequest->getId()
            );

            $this->requestForCacheUpdate($this->user);
            $this->response->setContent(json_encode($friendRequest->toArray()));
            $this->response->setStatusCode(Status::OK);
        } catch (\InvalidArgumentException $e) {
            $this->response->setContent(json_encode(array('result' => $e->getMessage())));
            $this->response->setStatusCode(Status::NOT_FOUND);
        } catch (\Exception $e) {
            $this->response->setContent(json_encode(array('result' => $e->getMessage())));
            $this->response->setStatusCode(Status::BAD_REQUEST);
        }

        return $this->response;
    }

    private function sendInAppNotification(\Document\User $user, \Document\FriendRequest $request)
    {
        $data = array(
            'objectId' => $request->getRecipientId(),
            'objectType' => \Helper\AppMessage::FRIEND_REQUEST,
            'message' => $this->_createPushMessage()
        );
        $this->debug(json_encode($data));

        $this->userRepository->addNotification($request->getRecipientId(), $data);
        $this->debug('In App notification is created.');
    }

    /**
     * GET /me
     *
     * Retrieve profile information for the current user
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getCurrentUser()
    {
        if ($this->user instanceof \Document\User) {

            $data = $this->user->toArrayDetailed();
            $data['avatar'] = \Helper\Url::buildAvatarUrl($data);
            $data['coverPhoto'] = \Helper\Url::buildCoverPhotoUrl($data);

            $notificationCounts = $this->userRepository->generateNotificationCount($this->user->getId());
            $notificationCounts = explode("|", $notificationCounts['tabCounts']);
            $data['notification_count'] = array('notifications' => $notificationCounts[2], 'friendRequest' => $notificationCounts[1], 'messageCount' => $notificationCounts[0]);
            $data['friends'] = $this->_getFriendList($this->user, array('id', 'firstName', 'lastName', 'avatar', 'status', 'coverPhoto', 'distance', 'address', 'regMedia'));

            $this->response->setContent(json_encode($data));
            $this->response->setStatusCode(Status::OK);
        } else {
            $this->response->setContent(json_encode(array('message' => 'Unauthorized acecss. Auth-Token not found or invalid')));
            $this->response->setStatusCode(Status::UNAUTHORIZED);
        }

        return $this->response;
    }

    /**
     * GET /users/{id}
     *
     * Retrieve profile information for the specific user
     *
     * @param $id
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getById($id)
    {
        $this->_ensureLoggedIn();
        $user = $this->userRepository->find($id);

        if (null !== $user) {

            $data = $user->toArrayDetailed();
            $data['avatar'] = \Helper\Url::buildAvatarUrl($data);
            $data['coverPhoto'] = \Helper\Url::buildCoverPhotoUrl($data);
            $data['friendship'] = $this->user->getFriendship($user);
            $data['friends'] = $this->_getFriendList($user);
            $this->response->setContent(json_encode($data));
            $this->response->setStatusCode(Status::OK);
        } else {
            $this->response->setContent(json_encode(array('result' => Response::$statusTexts[404])));
            $this->response->setStatusCode(Status::NOT_FOUND);
        }

        return $this->response;
    }

    /**
     * GET /users/{email}
     *
     * Retrieve user by email address
     *
     * @param $email
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getByEmail($email)
    {
        $this->_ensureLoggedIn();
        $user = $this->userRepository->getByEmail($email);

        if (false !== $user) {

            $data = $user->toArrayDetailed();
            $data['avatar'] = \Helper\Url::buildAvatarUrl($data);
            $data['coverPhoto'] = \Helper\Url::buildCoverPhotoUrl($data);

            $this->response->setContent(json_encode($data));
            $this->response->setStatusCode(Status::OK);
        } else {
            $this->response->setContent(json_encode(array('result' => Response::$statusTexts[404])));
            $this->response->setStatusCode(Status::NOT_FOUND);
        }

        return $this->response;
    }

    /**
     * POST /users
     *
     * Create new user
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function create()
    {
        $data = $this->request->request->all();
        $key = $this->config['googlePlace']['apiKey'];
        if (!isset($data['coverPhoto']) || empty($data['coverPhoto'])) {
            if (!empty($data['lat']) && !empty($data['lng'])) {
                $streetViewImage = \Helper\Url::buildStreetViewImage($key, $data, $size="320x130");
                $data['coverPhoto'] = $streetViewImage;
            }
        }

        try {

            $user = $this->userRepository->insert($data);
            $this->response->setContent(json_encode($user->toArrayDetailed()));
            $this->response->setStatusCode(Status::CREATED);
        } catch (\Exception\ResourceAlreadyExistsException $e) {
            $this->warn(sprintf('Failed to create new account %s', $e->getMessage()));
            $this->response->setContent(json_encode(array('result' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        } catch (\InvalidArgumentException $e) {
            $this->warn(sprintf('Failed to create new account %s', $e->getMessage()));
            $this->response->setContent(json_encode(array('result' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }

        return $this->response;
    }

    /**
     * PUT /users/{id}
     *
     * Update an existing user profile
     *
     * @param $id
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function update($id)
    {
        $this->_ensureLoggedIn();
        $data = $this->request->request->all();
        if (!empty($data['email'])) {
            $data['email'] = strtolower($data['email']);
        }

        try {
            $user = $this->userRepository->update($data, $id);

            if (!empty($data['avatar'])) {
                $this->userRepository->saveAvatarImage($user->getId(), $data['avatar']);
            }

            if (!empty($data['coverPhoto'])) {
                $user = $this->userRepository->saveCoverPhoto($user->getId(), $data['coverPhoto']);
            }

            $data = $user->toArrayDetailed();
            $data['avatar'] = \Helper\Url::buildAvatarUrl($data);
            $data['coverPhoto'] = \Helper\Url::buildCoverPhotoUrl($data);

            $this->response->setContent(json_encode($data));
            $this->response->setStatusCode(Status::OK);
        } catch (\Exception\ResourceNotFoundException $e) {

            $this->response->setContent(json_encode(array('result' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        } catch (\Exception\UnauthorizedException $e) {

            $this->response->setContent(json_encode(array('result' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        } catch (\Exception\ResourceAlreadyExistsException $e) {

            $this->response->setContent(json_encode(array('result' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }

        return $this->response;
    }

    /**
     * DELETE /users/{id}
     *
     * Delete an existing user
     *
     * @param $id
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function delete($id)
    {
        if ($id == $this->user->getId()) {
            try {
                $this->userRepository->delete($id);
                $this->response->setContent(json_encode(array('message' => Response::$statusTexts[200])));
                $this->response->setStatusCode(Status::OK);
            } catch (\InvalidArgumentException $e) {

                $this->response->setContent(json_encode(array('message' => Response::$statusTexts[404])));
                $this->response->setStatusCode(Status::NOT_FOUND);
            }
        } else {
            $this->response->setContent(json_encode(array('message' => Response::$statusTexts[404])));
            $this->response->setStatusCode(Status::UNAUTHORIZED);
        }

        return $this->response;
    }

    /**
     * POST /me/circles
     *
     * Create new circle for the current user
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function addCircle()
    {
        $circleData = $this->request->request->all();

        $this->userRepository->addCircle($circleData);

        $circles = $this->user->getCircles();

        $result = array();
        foreach ($circles as $circle) {

            $friends = $circle->toArray();
            $friends['friends'] = $this->_getUserSummaryList(
                $circle->getFriends(), array('id', 'firstName', 'lastName', 'avatar', 'status',
                                            'coverPhoto', 'distance', 'address', 'regMedia', 'username'));
            $result[] = $friends;
        }

        $this->response->setContent(json_encode($result));
        $this->response->setStatusCode(Status::CREATED);

        return $this->response;
    }

    /**
     * GET /me/circles
     *
     * Retrieve all circles from the current user
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getCircles()
    {
        $circles = $this->user->getCircles();

        $result = array();
        foreach ($circles as $circle) {

            $friends = $circle->toArray();
            $friends['friends'] = $this->_getUserSummaryList(
                $circle->getFriends(), array('id', 'firstName', 'lastName', 'avatar', 'status',
                                            'coverPhoto', 'distance', 'address', 'regMedia', 'username'));
            $result[] = $friends;

        }

        $this->response->setContent(json_encode($result));
        $this->response->setStatusCode(Status::OK);

        return $this->response;
    }

    /**
     * PUT /request/friend/:friendId/:response
     *
     * Accept friend request from the other SocialMaps user
     *
     * @param $friendId
     * @param $response
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function acceptFriendRequest($friendId, $response)
    {
        $this->_ensureLoggedIn();

        try {
            $this->userRepository->acceptFriendRequest($friendId, $response);
            $this->notifyUser($friendId);

            $user = $this->user;
            $data = $user->toArrayDetailed();
            $userData['circles'] = $data['circles'];
            $userData['friends'] = $this->_getFriendList(
                $user, array('id', 'firstName', 'lastName', 'avatar', 'distance',
                            'address', 'regMedia', 'username'));

            $this->requestForCacheUpdate($user);

            $this->response->setContent(json_encode($userData));
            $this->response->setStatusCode(Status::OK);

        } catch (\Exception $e) {
            $this->response->setContent(json_encode(array('result' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }

        return $this->response;
    }

    private function notifyUser($friendId)
    {
        $this->_sendPushNotification(
            array($friendId),
            AppMessage::getMessage(AppMessage::ACCEPTED_FRIEND_REQUEST, $this->user->getUsernameOrFirstName()),
            AppMessage::ACCEPTED_FRIEND_REQUEST, $this->user->getId()
        );
    }

    /**
     * PUT /me/notification/{notificationId}
     *
     * Update an existing notification
     *
     * @param $notificationId
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function updateNotification($notificationId)
    {
        try {
            $this->userRepository->updateNotification($notificationId);
            $this->response->setStatusCode(Status::OK);

        } catch (\Exception\ResourceNotFoundException $e) {

            $this->response->setContent(json_encode(array('result' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());

        } catch (\Exception\UnauthorizedException $e) {

            $this->response->setContent(json_encode(array('result' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());

        } catch (\Exception\ResourceAlreadyExistsException $e) {

            $this->response->setContent(json_encode(array('result' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }

        return $this->response;
    }

    /**
     * GET /request/notification
     *
     * Retrieve all user's notifications
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getUserNotifications()
    {
        $this->_ensureLoggedIn();

        $friendRequests = $this->user->getFriendRequest();
        $notifications = $this->user->getNotification();

        $friendResult = array();
        $notificationResult = array();

        foreach ($friendRequests as $friendRequest) {
            $friendResult[] = $friendRequest->toArray();
        }

        foreach ($notifications as $notification) {

            if ($notification->getViewed() != true) {
                $notificationResult[] = $notification->toArray();
                $this->updateNotification($notification->getId());
            }

        }

        if (empty($friendResult) AND (empty($notificationResult))) {
            $this->response->setContent(json_encode(array()));
        } else {
            $this->response->setContent(json_encode(array(
                'friend request' => $friendResult,
                'notifications' => $notificationResult
            )));
        }

        $this->response->setStatusCode(Status::OK);
        return $this->response;
    }

    /**
     * PUT /users/block
     *
     * Block a set of users for the current user
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function blockUser()
    {
        $this->_ensureLoggedIn();

        $postData = $this->request->request->all();
        if (!empty($postData['users'])) {
            foreach ($postData['users'] as $userId) {
                $blockingUser = $this->userRepository->find($userId);

                if ($blockingUser instanceof \Document\User) {

                    $blockedUsers = $this->user->getBlockedUsers();

                    if ($this->user != $blockingUser) {

                        if (!in_array($blockingUser->getId(), $blockedUsers)) {

                            $this->user->addBlockedUser($blockingUser);
                            $this->dm->persist($this->user);

                            $blockingUser->addBlockedBy($this->user);
                            $this->dm->persist($blockingUser);

                            $this->dm->flush();
                        }
                        $this->getBlockedUsers();

                    } else {

                        $this->response->setContent(json_encode(array('message' => 'You are trying to block yourself.')));
                        $this->response->setStatusCode(Status::BAD_REQUEST);

                    }

                } else {

                    $this->response->setContent(json_encode(array('message' => 'Invalid user Id')));
                    $this->response->setStatusCode(Status::BAD_REQUEST);

                }
            }
        }

        return $this->response;
    }

    /**
     * PUT /me/users/block/overwrite
     *
     * Update blocked users list for the current user
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function blockUserOverwrite()
    {
        $this->_ensureLoggedIn();

        $postData = $this->request->request->all();
        if (!empty($postData['users'])) {
            $unBlockUsers = $this->userRepository->unBlockAllUsers($this->user->getId(), $postData);
            foreach ($postData['users'] as $userId) {
                $blockingUser = $this->userRepository->find($userId);

                if ($blockingUser instanceof \Document\User) {

                    $blockedUsers = $this->user->getBlockedUsers();

                    if ($this->user != $blockingUser) {

                        if (!in_array($blockingUser->getId(), $blockedUsers)) {

                            $this->user->addBlockedUser($blockingUser);
                            $this->dm->persist($this->user);

                            $blockingUser->addBlockedBy($this->user);
                            $this->dm->persist($blockingUser);

                            $this->dm->flush();
                        }
                        $this->getBlockedUsers();

                    } else {

                        $this->response->setContent(json_encode(array('message' => 'You are trying to block yourself.')));
                        $this->response->setStatusCode(Status::BAD_REQUEST);

                    }

                } else {

                    $this->response->setContent(json_encode(array('message' => 'Invalid user Id')));
                    $this->response->setStatusCode(Status::BAD_REQUEST);

                }
            }
        }

        return $this->response;
    }

    /**
     * GET /me/circles/:id
     *
     * Retrieve detail information for a specific circle for the current user.
     *
     * @param $id
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getCircleDetail($id)
    {
        $circles = $this->user->getCircles();

        $result = array();
        foreach ($circles as $circle) {
            if ($circle->getId() == $id) {
                $friends = $circle->toArray();
                $friends['friends'] = $this->_getUserSummaryList(
                    $circle->getFriends(), array('id', 'firstName', 'lastName', 'avatar', 'status',
                                                'coverPhoto', 'distance', 'address', 'regMedia', 'username'));
                $result[] = $friends;
            }
        }

        $this->response->setContent(json_encode($result));
        $this->response->setStatusCode(Status::OK);

        return $this->response;
    }

    /**
     * PUT /me/circles/:id
     *
     * Update a specific circle for the current user
     *
     * @param $id
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */

    public function updateCustomCircle($id)
    {
        $this->_ensureLoggedIn();

        try {

            $circles = $this->user->getCircles();

            $result = array();
            foreach ($circles as $circle) {
                if ($circle->getId() == $id) {
                    $result = $circle->toArray();
                }
            }

            if ($result['type'] == 'system') {
                $this->response->setStatusCode(Status::NOT_ACCEPTABLE);
                return $this->response;
            }

            $circleData = $this->request->request->all();

            $this->userRepository->updateCircle($id, $circleData);

            $allCircles = $this->user->getCircles();

            $updateResult = array();
            foreach ($allCircles as $circle) {

                $friends = $circle->toArray();
                $friends['friends'] = $this->_getUserSummaryList(
                    $circle->getFriends(), array('id', 'firstName', 'lastName', 'avatar', 'status',
                                                'coverPhoto', 'distance', 'address', 'regMedia', 'username'));
                $updateResult[] = $friends;
            }

            $this->response->setContent(json_encode($updateResult));
            $this->response->setStatusCode(Status::OK);

        } catch (\Exception $e) {
            $this->response->setContent(json_encode(array('result' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }

        return $this->response;
    }

    /**
     * GET /me/friends
     * GET /{id}/friends
     *
     * Retrieve friends list from current or the specific user
     *
     * @param $id
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getFriends($id = null)
    {
        $this->_ensureLoggedIn();

        if (is_null($id)) $user = $this->user;
        else    $user = $this->userRepository->find($id);

        if ($user instanceof \Document\User) {
            $data = $user->toArrayDetailed();
            $userData['circles'] = $data['circles'];
            $userData['friends'] = $this->_getFriendList(
                $user, array('id', 'firstName', 'lastName', 'avatar', 'distance',
                            'address', 'regMedia', 'coverPhoto', 'username'));

            $this->response->setContent(json_encode($userData));
            $this->response->setStatusCode(Status::OK);
        } else {
            $this->response->setContent(json_encode(array('result' => Response::$statusTexts[404])));
            $this->response->setStatusCode(Status::NOT_FOUND);
        }

        return $this->response;
    }

    private function _createPushMessage()
    {
        return AppMessage::getMessage(AppMessage::FRIEND_REQUEST, $this->user->getUsernameOrFirstName());
    }

    /**
     * DELETE /me/circles/{id}
     *
     * Delete a specific circle from the current user
     *
     * @param $id
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function deleteCustomCircle($id)
    {
        $this->_ensureLoggedIn();

        try {

            $this->userRepository->deleteCustomCircle($id);

            $this->response->setContent(json_encode(array('message' => Response::$statusTexts[200])));
            $this->response->setStatusCode(Status::OK);
        } catch (\InvalidArgumentException $e) {

            $this->response->setContent(json_encode(array('result' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());

        } catch (\Exception $e) {
            $this->response->setContent(json_encode(array('message' => Response::$statusTexts[404])));
            $this->response->setStatusCode(Status::NOT_FOUND);
        }

        return $this->response;
    }

    /**
     * PUT /circles/:id/remove
     *
     * Remove friend from a specific circle
     *
     * @param $id
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function removeFriendFromCircle($id)
    {
        $this->_ensureLoggedIn();

        try {
            $circles = $this->user->getCircles();

            $result = array();
            foreach ($circles as $circle) {
                if ($circle->getId() == $id) {
                    $result = $circle->toArray();
                }
            }

            if ($result['type'] == 'system') {
                $this->response->setStatusCode(Status::NOT_ACCEPTABLE);
                return $this->response;
            }

            $circleData = $this->request->request->all();

            $this->userRepository->removeFriendFromCircle($id, $circleData);

            $updateResult = array();
            foreach ($circles as $circle) {
                if ($circle->getId() == $id) {
                    $updateFriends = $circle->toArray();
                    $updateFriends['friends'] = $this->_getUserSummaryList(
                        $circle->getFriends(), array('id', 'firstName', 'lastName', 'avatar', 'status',
                                                    'coverPhoto', 'distance', 'address', 'regMedia', 'username'));
                    $updateResult[] = $updateFriends;
                }
            }

            $this->response->setContent(json_encode($updateResult));
            $this->response->setStatusCode(Status::OK);
        } catch (\InvalidArgumentException $e) {

            $this->response->setContent(json_encode(array('message' => Response::$statusTexts[404])));
            $this->response->setStatusCode(Status::NOT_FOUND);
        }


        return $this->response;
    }

    /**
     * PUT  /me/circles/friends/:id
     *
     * Add friend to multiple circles
     *
     * @param $id
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function addFriendToMultipleCircle($id)
    {
        $this->_ensureLoggedIn();

        try {

            $circleData = $this->request->request->all();
            $this->userRepository->removeFriendFromMyCircle($id);

            $this->userRepository->addFriendToMultipleCircle($id, $circleData);

            $allCircles = $this->user->getCircles();

            $updateResult = array();
            foreach ($allCircles as $circle) {

                $friends = $circle->toArray();
                $friends['friends'] = $this->_getUserSummaryList(
                    $circle->getFriends(), array('id', 'firstName', 'lastName', 'avatar', 'status',
                                                'coverPhoto', 'distance', 'address', 'regMedia', 'username'));
                $updateResult[] = $friends;
            }

            $this->response->setContent(json_encode($updateResult));
            $this->response->setStatusCode(Status::OK);

        } catch (\Exception $e) {
            $this->response->setContent(json_encode(array('result' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }

        return $this->response;
    }

    /**
     * PUT /me/users/un-block
     *
     * Unblock set of users from the current user
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function unblockUsers()
    {
        $this->_ensureLoggedIn();

        try {

            $postData = $this->request->request->all();

            $unBlockUsers = $this->userRepository->unBlockUsers($this->user->getId(), $postData);
            if ($unBlockUsers == true) {
                $this->getBlockedUsers();
            }
        } catch (\Exception\ResourceNotFoundException $e) {

            $this->response->setContent(json_encode(array('message' => Response::$statusTexts[404])));
            $this->response->setStatusCode(Status::NOT_FOUND);

        } catch (\InvalidArgumentException $e) {

            $this->response->setContent(json_encode(array('result' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());

        }


        return $this->response;
    }

    /**
     * GET /me/blockes-users
     *
     * Retrieve list of blocked users from the current user
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getBlockedUsers()
    {

        if ($this->user instanceof \Document\User) {

            $user = $this->user->getBlockedUsers();

            $userDetail = $this->_getUserSummaryList(
                $user, array('id', 'firstName', 'lastName', 'avatar', 'status',
                            'coverPhoto', 'distance', 'address', 'regMedia', 'username'));

            $this->response->setContent(json_encode($userDetail));
            $this->response->setStatusCode(Status::OK);
        } else {
            $this->response->setContent(json_encode(array('message' => 'Unauthorized acecss. Auth-Token not found or invalid')));
            $this->response->setStatusCode(Status::UNAUTHORIZED);
        }

        return $this->response;
    }

    /**
     * RENAME /me/circles/{id}/rename
     *
     * Rename a specific circle from the current user
     *
     * @param $id
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function renameCustomCircle($id)
    {
        $this->_ensureLoggedIn();
        $postData = $this->request->request->all();

        try {

            $this->userRepository->renameCustomCircle($id, $postData);

            $this->response->setContent(json_encode(array('message' => Response::$statusTexts[200])));
            $this->response->setStatusCode(Status::OK);
        } catch (\InvalidArgumentException $e) {

            $this->response->setContent(json_encode(array('result' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());

        } catch (\Exception $e) {
            $this->response->setContent(json_encode(array('message' => Response::$statusTexts[404])));
            $this->response->setStatusCode(Status::NOT_FOUND);
        }

        return $this->response;
    }


}
<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;
use Repository\UserRepo as UserRepository;

use Document\FriendRequest;
use Helper\Status;


class User extends Base
{
    /**
     * Initialize the controller.
     */
    public function init()
    {
        $this->response = new Response();
        $this->response->headers->set('Content-Type', 'application/json');

        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);
    }

    /**
     * GET /users
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

        if (empty($result)) {
            $this->response->setStatusCode(Status::NO_CONTENT);
        } else {

            $this->response->setContent(json_encode($this->_toArrayAll($result)));
            $this->response->setStatusCode(Status::OK);
        }

        return $this->response;
    }

    /**
     * GET /request/friend
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
     * @param $friendId
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function sendFriendRequest($friendId)
    {
        $data = $this->request->request->all();

        try {
            $frequest = $this->userRepository->sendFriendRequests($data, $friendId);

            $this->_sendPushNotification(array($friendId), $this->_createPushMessage(), 'friend_request');

            $this->response->setContent(json_encode($frequest->toArray()));
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

    /**
     * GET /me
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getCurrentUser()
    {
        if ($this->user instanceof \Document\User) {

            $data = $this->user->toArrayDetailed();

            $data['avatar'] = \Helper\Url::buildAvatarUrl($data);
            $data['coverPhoto'] = \Helper\Url::buildCoverPhotoUrl($data);

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
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function create()
    {
        $data = $this->request->request->all();

        try {

            $user = $this->userRepository->insert($data);
            $this->response->setContent(json_encode($user->toArrayDetailed()));
            $this->response->setStatusCode(Status::CREATED);
        } catch (\Exception\ResourceAlreadyExistsException $e) {
            $this->response->setContent(json_encode(array('result' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        } catch (\InvalidArgumentException $e) {
            $this->response->setContent(json_encode(array('result' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }

        return $this->response;
    }

    /**
     * PUT /users/{id}
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
            $friends['friends'] = $this->_getUserSummaryList($circle->getFriends(), array('id', 'firstName', 'lastName', 'avatar', 'status', 'coverPhoto', 'distance', 'address', 'regMedia'));
            $result[] = $friends;
        }

        $this->response->setContent(json_encode($result));
        $this->response->setStatusCode(Status::CREATED);

        return $this->response;
    }

    /**
     * GET /me/circles
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getCircles()
    {
        $circles = $this->user->getCircles();

        $result = array();
        foreach ($circles as $circle) {

            $friends = $circle->toArray();
            $friends['friends'] = $this->_getUserSummaryList($circle->getFriends(), array('id', 'firstName', 'lastName', 'avatar', 'status', 'coverPhoto', 'distance', 'address', 'regMedia'));
            $result[] = $friends;

        }

        $this->response->setContent(json_encode($result));
        $this->response->setStatusCode(Status::OK);

        return $this->response;
    }

    /**
     * PUT /request/friend/:friendId/:response
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
            $circles = $this->user->getCircles();

            $result = array();
            foreach ($circles as $circle) {
                $result[] = $circle->toArray();
            }

            $this->response->setContent(json_encode($result));
            $this->response->setStatusCode(Status::OK);

        } catch (\Exception $e) {
            $this->response->setContent(json_encode(array('result' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }


        return $this->response;
    }

    /**
     * PUT /me/notification/{notificationId}
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
     * GET /me/circles/:id
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
                $friends['friends'] = $this->_getUserSummaryList($circle->getFriends(), array('id', 'firstName', 'lastName', 'avatar', 'status', 'coverPhoto', 'distance', 'address', 'regMedia'));
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
                $friends['friends'] = $this->_getUserSummaryList($circle->getFriends(), array('id', 'firstName', 'lastName', 'avatar', 'status', 'coverPhoto', 'distance', 'address', 'regMedia'));
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
     * PUT /me/friends
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */

    public function getFriendList()
    {
        $user = $this->user;

        if ($user instanceof \Document\User) {

            $data = $user->toArrayDetailed();
            $userData['circles'] = $data['circles'];
            $userData['friends'] = $this->_getFriendList($user, array('id', 'firstName', 'lastName', 'avatar', 'distance', 'address', 'regMedia'));

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
        return $this->user->getFirstName() . " added you as a friend.";
    }

    /**
     * DELETE /me/circles/{id}
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

        }catch (\Exception $e) {
            $this->response->setContent(json_encode(array('message' => Response::$statusTexts[404])));
            $this->response->setStatusCode(Status::NOT_FOUND);
        }

        return $this->response;
    }

    /**
     * PUT /circles/:id/remove
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
                    $updateFriends['friends'] = $this->_getUserSummaryList($circle->getFriends(), array('id', 'firstName', 'lastName', 'avatar', 'status', 'coverPhoto', 'distance', 'address', 'regMedia'));
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
     * @param $id
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function addFriendToMultipleCircle($id)
    {
        $this->_ensureLoggedIn();

        try {

            $circleData = $this->request->request->all();

            $this->userRepository->addFriendToMultipleCircle($id, $circleData);

            $allCircles = $this->user->getCircles();

            $updateResult = array();
            foreach ($allCircles as $circle) {

                $friends = $circle->toArray();
                $friends['friends'] = $this->_getUserSummaryList($circle->getFriends(), array('id', 'firstName', 'lastName', 'avatar', 'status', 'coverPhoto', 'distance', 'address', 'regMedia'));
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

     /*
     * PUT /me/users/un-block
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

    /*
     * GET /me/blockes-users
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */

    public function getBlockedUsers(){

        if ($this->user instanceof \Document\User) {

            $user = $this->user->getBlockedUsers();

            $userDetail = $this->_getUserSummaryList($user,array('id', 'firstName', 'lastName', 'avatar','status','coverPhoto', 'distance','address','regMedia'));

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
     * @param $id
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function renameCustomCircle($id)
    {
        $this->_ensureLoggedIn();
        $postData = $this->request->request->all();

        try {

            $this->userRepository->renameCustomCircle($id,$postData);

            $this->response->setContent(json_encode(array('message' => Response::$statusTexts[200])));
            $this->response->setStatusCode(Status::OK);
        } catch (\InvalidArgumentException $e) {

            $this->response->setContent(json_encode(array('result' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());

        }catch (\Exception $e) {
            $this->response->setContent(json_encode(array('message' => Response::$statusTexts[404])));
            $this->response->setStatusCode(Status::NOT_FOUND);
        }

        return $this->response;
    }


}
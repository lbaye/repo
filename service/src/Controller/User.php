<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;
use Repository\User as UserRepository;

use Document\FriendRequest;

class User extends Base
{
    /**
     * @var UserRepository
     */
    private $userRepository;

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
            $this->response->setStatusCode(406);
        } else {
            $users = $this->userRepository->getNearBy($location['lat'], $location['lng'], $limit);

            if (!empty($users)) {
                $this->response->setContent(json_encode($users));
                $this->response->setStatusCode(200);
            } else {
                $this->response->setContent(json_encode(array('message' => 'No deals found')));
                $this->response->setStatusCode(204);
            }
        }

        return $this->response;
    }

    /**
     * GET /me/notifications
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getNotifications()
    {
        $this->_ensureLoggedIn();

        $notifications = $this->user->getNotification();

        $result = array();

        foreach ($notifications as $notification) {
            $result[] = $notification->toArray();
        }

        if (empty($result)) {
            $this->response->setContent(json_encode(array('message' => 'There is no notification for you.')));
        } else {
            $this->response->setContent(json_encode($result));
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
        $result         = array();

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

        $this->response->setStatusCode(200);

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
            $this->response->setContent(json_encode($frequest->toArray()));
            $this->response->setStatusCode(200);
        } catch (\InvalidArgumentException $e) {
            $this->response->setContent(json_encode(array('result' => $e->getMessage())));
            $this->response->setStatusCode(404);
        } catch (\Exception $e) {
            $this->response->setContent(json_encode(array('result' => $e->getMessage())));
            $this->response->setStatusCode(400);
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
            $this->response->setContent(json_encode($this->user->toArrayDetailed()));
            $this->response->setStatusCode(200);
        } else {
            $this->response->setContent(json_encode(array('message' => 'Unauthorized acecss. Auth-Token not found or invalid')));
            $this->response->setStatusCode(401);
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
            $this->response->setContent(json_encode($user->toArrayDetailed()));
            $this->response->setStatusCode(200);
        } else {
            $this->response->setContent(json_encode(array('result' => Response::$statusTexts[404])));
            $this->response->setStatusCode(404);
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
            $this->response->setContent(json_encode($user->toArrayDetailed()));
            $this->response->setStatusCode(200);
        } else {
            $this->response->setContent(json_encode(array('result' => Response::$statusTexts[404])));
            $this->response->setStatusCode(404);
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
            $this->response->setStatusCode(201);
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

        try {
            $user = $this->userRepository->update($data, $id);
            if (!empty($data['avatar'])) {
                $this->userRepository->saveAvatarImage($user->getId(), $data['avatar']);
            }
            $this->response->setContent(json_encode($user->toArrayDetailed()));
            $this->response->setStatusCode(200);
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
                $this->response->setStatusCode(200);
            } catch (\InvalidArgumentException $e) {

                $this->response->setContent(json_encode(array('message' => Response::$statusTexts[404])));
                $this->response->setStatusCode(404);
            }
        } else {
            $this->response->setContent(json_encode(array('message' => Response::$statusTexts[404])));
            $this->response->setStatusCode(401);
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

        $circle = $this->userRepository->addCircle($circleData);

        $this->response->setContent(json_encode($circle->toArray()));
        $this->response->setStatusCode(201);

        return $this->response;
    }

    /**
     * GET /me/circles
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getCircles()
    {
        $this->userRepository->setCurrentUser($this->user);
        $circles = $this->user->getCircles();

        $result = array();
        foreach ($circles as $circle) {
            $result[] = $circle->toArray();
        }

        $this->response->setContent(json_encode($result));
        $this->response->setStatusCode(200);

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
            $this->response->setStatusCode(200);

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
        $data = $this->request->request->all();

        try {

            $user = $this->userRepository->updateNotification($notificationId);
            $this->response->setContent(json_encode($user->toArray()));
            $this->response->setStatusCode(200);

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
        $notifications  = $this->user->getNotification();

        $friendResult   = array();
        $notificationResult = array();

        foreach ($friendRequests as $friendRequest) {
            $friendResult[] = $friendRequest->toArray();
        }

        foreach ($notifications as $notification) {
            $notificationResult[] = $notification->toArray();
        }

        if (empty($friendResult) or (empty($notificationResult))) {
            $this->response->setContent(json_encode(array('message' => 'There is no notification for you.')));
        } else {
            $this->response->setContent(json_encode(array(
                'friend request' => $friendResult,
                'notifications'  => $notificationResult
            )));
        }

        $this->response->setStatusCode(200);
        return $this->response;
    }

    /**
     * PUT /user/block/:id
     *
     * @param $id
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function blockUser($id)
    {
        $this->_ensureLoggedIn();
        $blockingUser = $this->userRepository->find($id);

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

                $this->response->setContent(json_encode(array('result' => 'User blocked')));
                $this->response->setStatusCode(200);

            } else {

                $this->response->setContent(json_encode(array('message' => 'You are trying to block yourself.')));
                $this->response->setStatusCode(400);

            }

        } else {

            $this->response->setContent(json_encode(array('message' => 'Invalid user Id')));
            $this->response->setStatusCode(400);

        }

        return $this->response;
    }
}
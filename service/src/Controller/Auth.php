<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;
use Repository\UserRepo as UserRepository;
use Document\FriendRequest;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Helper\Email as EmailHelper;
use Helper\Status;

class Auth extends Base
{

    /**
     * Initialize the controller.
     */
    public function init()
    {
        parent::init();
        $this->createLogger('Controller::Auth');

        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->messageRepository = $this->dm->getRepository('Document\Message');
        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);

        $this->info('Completed controller initialization');
    }

    /**
     * POST /users
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function create()
    {
        $data = $this->request->request->all();


        if (!empty($data['email'])) {
            $data['email'] = strtolower($data['email']);
        }

        try {
            $required_fields = array('email', 'firstName', 'lastName', 'password', 'avatar');
            foreach ($required_fields as $key) {
                if (empty($data[$key])) {
                    $this->response->setContent(json_encode(array('message' => "`$key` is required field.")));
                    $this->response->setStatusCode(Status::NOT_ACCEPTABLE);
                    return $this->response;
                }
            }
            $streetViewImageAdded = false;
            $key = $this->config['googlePlace']['apiKey'];
            if (!isset($data['coverPhoto']) || empty($data['coverPhoto'])) {
                if (!empty($data['lat']) && !empty($data['lng'])) {
                    $streetViewImage = "http://maps.googleapis.com/maps/api/streetview?size=320x165&location=" . $data['lat'] . "," . $data['lng'] . "&fov=90&heading=235&pitch=10&sensor=false&key={$key}";
                    $data['coverPhoto'] = $streetViewImage;
                    $streetViewImageAdded = true;
                }
            }

            $user = $this->userRepository->insert($data);

            if (!empty($data['avatar'])) {
                $user = $this->userRepository->saveAvatarImage($user->getId(), $data['avatar']);
            }

            if ($streetViewImageAdded == false) {
                if (!empty($data['coverPhoto'])) {
                    $user = $this->userRepository->saveCoverPhoto($user->getId(), $data['coverPhoto']);
                }
            }

            $data = $user->toArrayDetailed();

            $data['avatar'] = \Helper\Url::buildAvatarUrl($data);
            if ($streetViewImageAdded == false) {
                $data['coverPhoto'] = \Helper\Url::buildCoverPhotoUrl($data);
            }

            $notifications = 0;
            $friendRequest = 0;
            $messageCount = 0;
            $userData['notification_count'] = array('notifications' => $notifications, 'friendRequest' => $friendRequest, 'messageCount' => $messageCount);

            $this->response->setContent(json_encode($data));
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
     * POST /auth/login
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function login()
    {
        $data = $this->request->request->all();

        if (!empty($data['email'])) {
            $data['email'] = strtolower($data['email']);
        }
        $user = $this->userRepository->validateLogin($data);

        $this->userRepository->setCurrentUser($user);

        if ($user instanceof \Document\User) {
            $this->userRepository->updateLoginCount($user->getId());
            $this->user = $user;
            $userData = $user->toArrayDetailed();

            $userData['avatar'] = \Helper\Url::buildAvatarUrl($userData);
            $userData['coverPhoto'] = \Helper\Url::buildCoverPhotoUrl($userData);

            $userData['friends'] = $this->_getFriendList($user, array('id', 'firstName', 'lastName', 'avatar', 'status', 'coverPhoto', 'distance', 'address', 'regMedia'));

            $notificationCounts = $this->userRepository->generateNotificationCount($user->getId());
            $notificationCounts = explode("|", $notificationCounts['tabCounts']);
            $userData['notification_count'] = array('notifications' => $notificationCounts[2], 'friendRequest' => $notificationCounts[1], 'messageCount' => $notificationCounts[0]);

            $this->response->setContent(json_encode($userData));
            $this->response->setStatusCode(Status::OK);
        } else {
            $this->response->setContent(json_encode(array('result' => Response::$statusTexts[404])));
            $this->response->setStatusCode(Status::NOT_FOUND);
        }

        return $this->response;
    }

    /**
     * POST /auth/login/fb
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function fbLogin()
    {
        $this->info('Executing action fbLogin');
        $data = $this->request->request->all();

        $this->debug('Request parameters - ' . json_encode(array_keys($data)));

        if (!empty($data['email'])) {
            $data['email'] = strtolower($data['email']);
            $this->debug('Email is set with the parameter.');
        }

        if (empty($data['facebookAuthToken']) OR (empty($data['facebookId']))) {
            $this->warn('Invalid facebook login attempt.');
            $this->response->setContent(json_encode(array('message' => "Required field 'facebookId' and/or 'facebookAuthToken' not found.")));
            $this->response->setStatusCode(Status::NOT_ACCEPTABLE);
            return $this->response;
        }

        try {

            $user = $this->userRepository->validateFbLogin($data);

            if ($user instanceof \Document\User) {
                $this->debug(sprintf('Found existing fb user - %s', $user->getFirstName()));

                $this->userRepository->setCurrentUser($user);

                if (!empty($data['avatar'])) {
                    $this->userRepository->saveAvatarImage($user->getId(), $data['avatar']);
                }

                if (!empty($data['coverPhoto'])) {
                    $user = $this->userRepository->saveCoverPhoto($user->getId(), $data['coverPhoto']);
                }

                $this->userRepository->updateLoginCount($user->getId());
                $this->userRepository->updateFacebookAuthToken($user->getId(), $data['facebookAuthToken']);

            } else {
                $this->debug('Not found existing facebook user, creating now.');
                $user = $this->userRepository->insert($data);

                $this->debug('New facebook user - ' . $user->getId());
            }

            $notifications_friendrequest = $this->userRepository->getNotificationsCount($user->getId());
            $notifications_friendrequest_extract = explode(":", $notifications_friendrequest);
            $message = count($this->messageRepository->getByRecipientCount($user));

            $userData = $user->toArrayDetailed();
            $userData['avatar'] = \Helper\Url::buildAvatarUrl($userData);
            $userData['coverPhoto'] = \Helper\Url::buildCoverPhotoUrl($userData);
            $userData['friends'] = $this->_getFriendList($user);

            $notifications = (int)$notifications_friendrequest_extract[0];
            $friendRequest = (int)$notifications_friendrequest_extract[1];
            $messageCount = $message;
            $userData['notification_count'] = array('notifications' => $notifications, 'friendRequest' => $friendRequest, 'messageCount' => $messageCount);

            $this->response->setContent(json_encode($userData));
            $this->response->setStatusCode(Status::OK);

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
     * POST /auth/fb_connect
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function fbConnect()
    {
        $this->_ensureLoggedIn();
        $data = $this->request->request->all();

        if (empty($data['facebookAuthToken']) OR (empty($data['facebookId']))) {
            $this->response->setContent(json_encode(array('message' => "Required field 'facebookId' and/or 'facebookAuthToken' not found.")));
            $this->response->setStatusCode(Status::NOT_ACCEPTABLE);
            return $this->response;
        }

        if ($this->userRepository->checkFbUser($data)) {
            $this->response->setContent(json_encode(array('message' => "You already registered using your Facebook account.")));
            $this->response->setStatusCode(Status::NOT_ACCEPTABLE);
            return $this->response;
        }

        try {

            $this->userRepository->insertFacebookAuthInfo($this->user->getId(), $data['facebookId'], $data['facebookAuthToken']);

            $this->response->setContent(json_encode(array('message' => 'Facebook Connected Successfully.')));
            $this->response->setStatusCode(Status::OK);

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
     * GET /auth/forgot_pass/:email
     *
     * @param $email
     *
     * @throws \Exception\ResourceNotFoundException
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getPassword($email)
    {
        $user = $this->userRepository->getByEmail($email);


        if (false === $user) {
            $this->response->setContent(json_encode(array('message' => "No user found with this email.")));
            $this->response->setStatusCode(400);
        } else {
            $userId = $user->getId();
            $passwordToken = $this->userRepository->getPasswordToken($userId);

            $url = $this->config['web']['root'] . "/auth/pass/token/" . $passwordToken;
            $this->userRepository->updateForgetPasswordToken($userId, $passwordToken);
            $message = "Please click the link to reset your password {$url} ";

            EmailHelper::sendMail($email, $message);

            $this->response->setContent(json_encode(array('message' => "Please check your email for instruction.")));
            $this->response->setStatusCode(Status::OK);

            return $this->response;

        }


        return $this->response;
    }

    /**
     * GET /auth/pass/token/:passwordToken
     *
     * @param $passwordToken
     *
     * @throws \Exception\ResourceNotFoundException
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function confirmPassToken($passwordToken)
    {
        $user = $this->userRepository->getByPasswordToken($passwordToken);

        if (false === $user) {
            throw new \Exception\ResourceNotFoundException();
        } else {

            return new RedirectResponse($this->config['web']['root'] . "/pass_socialmaps/index.php");

        }
    }

    /**
     * POST /auth/reset_pass
     *
     * @throws \Exception\ResourceNotFoundException
     * @return \Symfony\Component\HttpFoundation\Response
     */

    public function resetPassword()
    {
        $data = $this->request->request->all();
        $user = $this->userRepository->getByEmail($data['email']);


        if (false === $user) {
            $this->response->setContent(json_encode(array('message' => "No user found with this email.")));
            $this->response->setStatusCode(Status::OK);
        }

        if ($data['password'] != $data['retypePassword']) {

            $this->response->setContent(json_encode(array('message' => "password and retype password didn't match")));
            $this->response->setStatusCode(Status::OK);
        }

        $userId = $user->getId();
        $password = $this->userRepository->resetPassword($data, $userId);
        $this->response->setContent(json_encode(array('password' => $password)));
        $this->response->setStatusCode(Status::OK);

        return $this->response;
    }

    /**
     * POST /auth/change_pass
     *
     * @throws \Exception\ResourceNotFoundException
     * @return \Symfony\Component\HttpFoundation\Response
     */

    public function  changePassword()
    {
        $data = $this->request->request->all();

        try {
            $this->userRepository->changePassword($data);
            $this->response->setContent(json_encode(array('password' => true)));
            $this->response->setStatusCode(Status::OK);

        } catch (\Exception\ResourceNotFoundException $e) {

            $this->response->setContent(json_encode(array('result' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }


        return $this->response;
    }

}

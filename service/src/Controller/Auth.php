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
     * @var UserRepository
     */
    protected $userRepository;

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
     * POST /users
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function create()
    {
        $data = $this->request->request->all();

        try {

            $user = $this->userRepository->insert($data);

            if (!empty($data['avatar'])) {
                $user = $this->userRepository->saveAvatarImage($user->getId(), $data['avatar']);
            }

            if (!empty($data['coverPhoto'])) {
                $user = $this->userRepository->saveCoverPhoto($user->getId(), $data['coverPhoto']);
            }

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
     * POST /auth/login
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function login()
    {
        $data = $this->request->request->all();
        $user = $this->userRepository->validateLogin($data);

        $this->userRepository->setCurrentUser($user);

        if ($user instanceof \Document\User) {
            $this->userRepository->updateLoginCount($user->getId());

            $userData = $user->toArrayDetailed();
            $userData['friends'] = $this->_getFriendList($user);

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
        $data = $this->request->request->all();

        if (empty($data['facebookAuthToken']) OR (empty($data['facebookId']))) {
            $this->response->setContent(json_encode(array('message' => "Required field 'facebookId' and/or 'facebookAuthToken' not found.")));
            $this->response->setStatusCode(Status::NOT_ACCEPTABLE);
            return $this->response;
        }

        try {

            $user = $this->userRepository->validateFbLogin($data);

            if ($user instanceof \Document\User) {

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

                $user = $this->userRepository->insert($data);

            }

            $userData = $user->toArrayDetailed();
            $$userData['friends'] = $this->_getFriendList($user);

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
            $userId        = $user->getId();
            $passwordToken = $this->userRepository->getPasswordToken($userId);
            $url           = "http://203.76.126.69/social_maps/web/auth/pass/token/" . $passwordToken;
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

            return new RedirectResponse("http://203.76.126.69/social_maps/web/pass_socialmaps/index.php");

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

        $userId   = $user->getId();
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

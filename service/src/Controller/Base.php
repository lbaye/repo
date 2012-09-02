<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Doctrine\ODM\MongoDB\DocumentManager;
use Repository\UserRepo as userRepository;

use Helper\Status;

abstract class Base
{
    /**
     * @var \Symfony\Component\HttpFoundation\Request
     */
    protected $request;

    /**
     * @var \Doctrine\ODM\MongoDB\DocumentManager
     */
    protected $dm;

    /**
     * @var \Symfony\Component\HttpFoundation\Response;
     */
    protected $response;

    /**
     * @var array
     */
    protected $config;

    /**
     * @var \Document\User
     */
    protected $user;

    /**
     * @var UserRepository
     */
    protected $userRepository;


    /**
     * @var \Service\Serializer\Serializable
     */
    protected $serializer;

    /**
     * Inject the Request object for further use.
     *
     * @param \Symfony\Component\HttpFoundation\Request $request
     */
    public function setRequest($request)
    {
        $this->request = $request;
    }

    /**
     * Inject the DocumentManager for further communication with MongoDB.
     *
     * @param \Doctrine\ODM\MongoDB\DocumentManager $dm
     */
    public function setDocumentManager($dm)
    {
        $this->dm = $dm;
    }

    /**
     * Load the requesting user's object if provided in the header.
     */
    public function setSessionUser()
    {
        if ($this->request->headers->has('Auth-Token')) {
            $authToken  = $this->request->headers->get('Auth-Token');
            $this->user = $this->dm->getRepository('Document\User')->getByAuthToken($authToken);
        }
    }

    /**
     * Inject the configuration.
     *
     * @param $config array
     */
    public function setConfiguration($config)
    {
        $this->config = $config;
    }

    /**
     * Initializer function to be used by child classes.
     */
    public function init()
    {
        $this->response = new Response();
        $this->response->headers->set('Content-Type', 'application/json');

        $this->serializer = \Service\Serializer\Factory::getSerializer('json');
    }

    /**
     * Ensure if a User has been set as currentUser.
     */
    protected function _ensureLoggedIn()
    {
        if (!$this->user instanceof \Document\User) {
            $this->response->setContent(json_encode(array('message' => 'Unauthorized (Wrong or no Auth-Token provided!)')));
            $this->response->setStatusCode(Status::UNAUTHORIZED);
            $this->response->send();
            exit;
        }
    }

    protected function _filterByPermission($documents)
    {
        $permittedDocs = array();

        foreach($documents as $doc) {
            if($doc->isPermittedFor($this->user)) {
                $permittedDocs[] = $doc;
            }
        }

        return $permittedDocs;
    }

    protected function _toArrayAll(array $results)
    {
        $gatheringItems = array();
        foreach ($results as $place) {
            $gatheringItems[] = $place->toArray();
        }

        return $gatheringItems;
    }

    protected function _generateResponse($hash, $code = Status::OK, $options = array())
    {
        if (!empty($hash)) {
            $this->response->setContent(
                $this->serializer->serialize($hash, $options)
            );
            $this->response->setStatusCode($code);
        } else {
            $this->response->setContent('[]'); // No content
            $this->response->setStatusCode($code);
        }

        return $this->response;
    }

    protected function _generateErrorResponse($message, $code = Status::NOT_ACCEPTABLE)
    {
        return $this->_generateResponse(array(
            'message' => $message
        ), $code);
    }

    protected function _generate404()
    {
        return $this->_generateErrorResponse('Object not found', Status::NOT_FOUND);
    }

    protected function _generate500($message = 'Failed to update object')
    {
        return $this->_generateErrorResponse($message, Status::INTERNAL_SERVER_ERR);
    }

    protected function _generateUnauthorized($message = 'Unauthorized!')
    {
        return $this->_generateErrorResponse($message, Status::UNAUTHORIZED);
    }

    protected function _generateForbidden($message = 'Forbidden!')
    {
        return $this->_generateErrorResponse($message, Status::FORBIDDEN);
    }

    protected function _generateException(\Exception $e)
    {
        return $this->_generateErrorResponse($e->getMessage(), $e->getCode());
    }

    protected function _getFriendList($user) {
        $friends = $user->getFriends();
        return $this->_getUserSummaryList($friends);
    }

    protected function _getUserSummaryList(array $userIds, array $fields = array('id', 'firstName', 'lastName', 'avatar'))
    {
        $userData = $this->userRepository->getAllByIds($userIds);

        array_walk($userData, function(&$friend, $k, $fields) {
           $friend = array_intersect_key($friend, array_flip($fields));
        }, $fields);

        return $userData;
    }
}
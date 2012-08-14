<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;

use Repository\User as userRepository;
//use Repository\resource as resourceRepository;

/**
 * Template class for all content serving controllers
 */
class Tmpl extends Base
{
    /**
     * @var  resourceRepository
     */
    private $resourceRepository;

    /**
     * @var userRepository
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
        //$this->resourceRepository = $this->dm->getRepository('Document\resource');

        $this->userRepository->setCurrentUser($this->user);
        $this->_ensureLoggedIn();
    }

    /**
     * GET /resources
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function index()
    {
        $this->response->setContent(json_encode(array('message' => 'Not implemented')));
        $this->response->setStatusCode(501);

        return $this->response;
    }

    /**
     * GET /resources/{id}
     *
     * @param $id  place id
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getById($id)
    {
        $this->response->setContent(json_encode(array('message' => 'Not implemented')));
        $this->response->setStatusCode(501);

        return $this->response;
    }

     /**
     * GET /me/resources
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getByCurrentUser()
    {
        $this->response->setContent(json_encode(array('message' => 'Not implemented')));
        $this->response->setStatusCode(501);

        return $this->response;
    }

    /**
     * GET /user/{userId}/resources
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getByUser()
    {
        $this->response->setContent(json_encode(array('message' => 'Not implemented')));
        $this->response->setStatusCode(501);

        return $this->response;
    }

     /**
     * POST /resources
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function create()
    {
        $this->response->setContent(json_encode(array('message' => 'Not implemented')));
        $this->response->setStatusCode(501);

        return $this->response;
    }

     /**
     * PUT /resources/{id}
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function update()
    {
        $this->response->setContent(json_encode(array('message' => 'Not implemented')));
        $this->response->setStatusCode(501);

        return $this->response;
    }

     /**
     * DELETE /resources/{id}
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function delete()
    {
        $this->response->setContent(json_encode(array('message' => 'Not implemented')));
        $this->response->setStatusCode(501);

        return $this->response;
    }

}
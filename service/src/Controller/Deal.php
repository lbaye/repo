<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;

use Repository\User as userRepository;
use Repository\Deal as DealRepository;

/**
 * Template class for all content serving controllers
 */
class Deal extends Base
{
    /**
     * @var  dealRepository
     */
    private $dealRepository;

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
        $this->dealRepository = $this->dm->getRepository('Document\Deal');

        $this->userRepository->setCurrentUser($this->user);
        $this->_ensureLoggedIn();
    }

    /**
     * GET /deals
     *
     * List deals order by distance
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function index()
    {
        //$deals = $query->where('{ "location" : { $near : [81,91] } }')->getQuery()->execute();
        $location = $this->user->getCurrentLocation();

        if(!isset($location['lat']) || !isset($location['lng'])){
            $this->response->setContent(json_encode(array('message' => 'Users Current location is not updated!')));
            $this->response->setStatusCode(406);

        } else {
            $deals = $this->dealRepository->getNearBy($location['lat'], $location['lng']);

            if (!empty($deals)) {
                $this->response->setContent(json_encode($deals));
                $this->response->setStatusCode(200);
            } else {
                $this->response->setContent(json_encode(array('message' => 'No deals found')));
                $this->response->setStatusCode(204);
            }
        }

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
     * POST /deals
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function create()
    {
           $postData = $this->request->request->all();

        try {
            $deal = $this->dealRepository->map($postData);
            $this->dealRepository->insert($deal);

            $this->response->setContent(json_encode($deal->toArray()));
            $this->response->setStatusCode(201);

        } catch (\Exception $e) {
            $this->response->setContent(json_encode(array('message' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }

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
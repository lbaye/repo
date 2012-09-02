<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;

use Repository\UserRepo as userRepository;
use Repository\DealRepo as DealRepository;
use Helper\Status;

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
     * Initialize the controller.
     */
    public function init()
    {
        parent::init();

        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->dealRepository = $this->dm->getRepository('Document\Deal');

        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);
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
            return $this->_generateErrorResponse('Users Current location is not updated!');
        } else {
            $deals = $this->dealRepository->getNearBy($location['lat'], $location['lng']);

            if (!empty($deals)) {
                return $this->_generateResponse($deals);
            } else {
                return $this->_generateResponse(null, Status::NO_CONTENT);
            }
        }
    }

    /**
     * GET /resources/{id}
     *
     * @param $id  place id
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getById($id)
    {
        return $this->_generateErrorResponse('Not implemented', Status::NOT_IMPLEMENTED);
    }

     /**
     * GET /me/resources
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getByCurrentUser()
    {
        return $this->_generateErrorResponse('Not implemented', Status::NOT_IMPLEMENTED);
    }

    /**
     * GET /user/{userId}/resources
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getByUser()
    {
        return $this->_generateErrorResponse('Not implemented', Status::NOT_IMPLEMENTED);;
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

        } catch (\Exception $e) {
            return $this->_generateException($e);
        }

        return $this->_generateResponse($deal->toArray(), Status::CREATED);
    }

     /**
     * PUT /resources/{id}
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function update()
    {
        return $this->_generateErrorResponse('Not implemented', Status::NOT_IMPLEMENTED);
    }

     /**
     * DELETE /resources/{id}
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function delete()
    {
        return $this->_generateErrorResponse('Not implemented', Status::NOT_IMPLEMENTED);
    }

}
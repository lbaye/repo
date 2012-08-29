<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;

use Repository\UserRepo as userRepository;
use Repository\PlaceRepo as placeRepository;
use Helper\Status;

class Place extends Base
{
    /**
     * This can be object of place repository or geotag repository
     * @var placeRepository
     */
    private $LocationMarkRepository;

    /**
     * @var userRepository
     */
    private $userRepository;

    /**
     * Initialize the controller.
     */
    public function init()
    {
        parent::init();

        $this->userRepository  = $this->dm->getRepository('Document\User');
        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);

        $this->_ensureLoggedIn();
    }

    /**
     * GET /places
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function index($type = 'place')
    {
        $start = $this->request->get('start', 0);
        $limit = $this->request->get('limit', 20);

        $this->_initRepository($type);

        $places = $this->LocationMarkRepository->getAll($limit, $start);

        if (!empty($places)) {
            $permittedDocs = $this->_filterByPermission($places);

            return $this->_generateResponse($this->_toArrayAll($permittedDocs));
        } else {
            return $this->_generateResponse(array('message' => 'No places found'), Status::NO_CONTENT);
        }
    }

    /**
     * GET /places/{id}
     *
     * @param $id  place id
     * @param $type
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getById($id, $type = 'place')
    {
        $this->_initRepository($type);
        $place = $this->LocationMarkRepository->find($id);

        if (null !== $place) {
            if($place->isPermittedFor($this->user)){
                return $this->_generateResponse($place->toArray());
            } else {
                return $this->_generateForbidden('Not permitted for you');
            }
        } else {
            return $this->_generate404();
        }
    }

    /**
     * GET /me/places
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getByCurrentUser($type = 'place')
    {
        $this->_initRepository($type);
        $places = $this->LocationMarkRepository->getByUser($this->user);

        if ($places) {
            return $this->_generateResponse($places);
        } else {
            return $this->_generateResponse(null, Status::NO_CONTENT);
        }
    }

    /**
     * GET /user/{userId}/places
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getByUser($type = 'place')
    {
        return $this->_generateErrorResponse('Not implemented', Status::NOT_IMPLEMENTED);
    }

    /**
     * POST /places
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function create($type = 'place')
    {
        $postData = $this->request->request->all();
        $this->_initRepository($type);

        try {
            $place = $this->LocationMarkRepository->map($postData, $this->user);
            $this->LocationMarkRepository->insert($place);

        } catch (\Exception $e) {
            return $this->_generateException($e);
        }

        return $this->_generateResponse($place->toArray(), Status::CREATED);
    }

    /**
     * PUT /places/{id}
     *
     * @param $id
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function update($id, $type = 'place')
    {
        $postData = $this->request->request->all();
        $this->_initRepository($type);

        $place = $this->LocationMarkRepository->find($id);

        if(empty($place) || $place->getOwner() != $this->user){
            return $this->_generateUnauthorized();
        }

        try {
            $place = $this->LocationMarkRepository->update($postData, $id);

            if($place) {
                return $this->_generateResponse(json_encode($place->toArray()));
            } else {
                return $this->_generateErrorResponse('Invalid request params');
            }

        } catch (\Exception $e) {
            return $this->_generateException($e);
        }
    }

    /**
     * DELETE /places/{id}
     *
     * @param $id
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function delete($id, $type = 'place')
    {
        $this->_initRepository($type);

        try {
            $this->LocationMarkRepository->delete($id);
        } catch (\Exception $e) {
            $this->_generateException($e);
        }

        return $this->_generateResponse(array('message'=>'Deleted Successfully'));
    }

    private function _initRepository($type)
    {
        if($type == 'geotag') {
            $this->LocationMarkRepository = $this->dm->getRepository('Document\Geotag');
        } else {
            $this->LocationMarkRepository = $this->dm->getRepository('Document\Place');
        }

    }

}
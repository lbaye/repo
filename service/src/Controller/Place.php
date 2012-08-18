<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;

use Repository\User as userRepository;
use Repository\Place as placeRepository;
use Repository\Deal as DealRepository;

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
        $this->response = new Response();
        $this->response->headers->set('Content-Type', 'application/json');

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

            $this->response->setContent(json_encode($this->_toArrayAll($permittedDocs)));
            $this->response->setStatusCode(200);
        } else {
            $this->response->setContent(json_encode(array('message' => 'No places found')));
            $this->response->setStatusCode(204);
        }

        return $this->response;
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
                $this->response->setContent(json_encode($place->toArray()));
                $this->response->setStatusCode(200);
            } else {
                $this->response->setContent(json_encode(array('message' => 'Not permitted for you')));
                $this->response->setStatusCode(403);
            }
        } else {
            $this->response->setContent(json_encode(array('result' => Response::$statusTexts[404])));
            $this->response->setStatusCode(404);
        }

        return $this->response;
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
            $this->response->setContent(json_encode($places));
            $this->response->setStatusCode(200);
        } else {
            $this->response->setContent('[]'); // No content
            $this->response->setStatusCode(200);
        }

        return $this->response;
    }

    /**
     * GET /user/{userId}/places
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getByUser($type = 'place')
    {
        $this->response->setContent(json_encode(array('message' => 'Not implemented')));
        $this->response->setStatusCode(501);

        return $this->response;
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

            $this->response->setContent(json_encode($place->toArray()));
            $this->response->setStatusCode(201);

        } catch (\Exception $e) {
            $this->response->setContent(json_encode(array('message' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }

        return $this->response;
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
            $this->response->setContent(json_encode(array('message' => 'You are not permitted to update this resource')));
            $this->response->setStatusCode(401);
            return $this->response;
        }

        try {
            $place = $this->LocationMarkRepository->update($postData, $id);

            if($place) {
                $this->response->setContent(json_encode($place->toArray()));
                $this->response->setStatusCode(200);
            } else {
                $this->response->setContent(json_encode(array('message' => 'Invalid request params')));
                $this->response->setStatusCode(406);
            }

        } catch (\Exception $e) {
            $this->response->setContent(json_encode(array('message' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }

        return $this->response;
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

            $this->response->setContent(json_encode(array('message' => 'Deleted Successfully')));
            $this->response->setStatusCode(200);

        } catch (\Exception $e) {
            $this->response->setContent(json_encode(array('message' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }

        return $this->response;
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
<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;

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
        $limit = $this->request->get('limit', 200);

        $this->_initRepository($type);

        $places = $this->LocationMarkRepository->getAll($limit, $start);

        if (!empty($places)) {
            $permittedDocs = $this->_filterByPermission($places);
            $data = $this->_toArrayAll($permittedDocs);
            $i = 0;
            foreach ($data as $photoUrl) {
                $data[$i]['photo'] = \Helper\Url::buildPlacePhotoUrl($photoUrl);
                $i++;
            }

            return $this->_generateResponse($data);
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
     * GET /geotags/all
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function search($type)
    {
        $this->_initRepository($type);
        $lng = $this->request->get('lng');
        $lat = $this->request->get('lat');
        $geoTags = $this->LocationMarkRepository->search($this->user, $lng, $lat);

        if ($geoTags) {
            return $this->_generateResponse($geoTags);
        } else {
            return $this->_generateResponse(null, Status::NO_CONTENT);
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
            if (empty($postData['title'])) {
                $this->response->setContent(json_encode(array('message' => 'Place title can not be empty.')));
                $this->response->setStatusCode(Status::BAD_REQUEST);
                return $this->response;
            }
            $place = $this->LocationMarkRepository->map($postData, $this->user);
            $this->LocationMarkRepository->insert($place);

            if (!empty($postData['photo'])) {
                $this->LocationMarkRepository->savePlacePhoto($place->getId(), $postData['photo']);
            }
            $postData = $place->toArray();
            $postData['photo'] = \Helper\Url::buildPlacePhotoUrl($postData);

        } catch (\Exception $e) {
            return $this->_generateException($e);
        }

        return $this->_generateResponse($postData, Status::CREATED);
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
            if (!empty($postData['photo'])) {
                $this->LocationMarkRepository->savePlacePhoto($place->getId(), $postData['photo']);
            }

            $postData = $place->toArray();
            $postData['photo'] = \Helper\Url::buildPlacePhotoUrl($postData);

            if($place) {
                return $this->_generateResponse($postData);
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
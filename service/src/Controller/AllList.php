<?php
namespace Controller;

use Symfony\Component\HttpFoundation\Response;

use Repository\UserRepo as userRepository;
use Repository\PlaceRepo as placeRepository;
use Repository\DealRepo as DealRepository;
use Helper\Status;

class AllList extends Base
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
     * @var  dealRepository
     */
    private $dealRepository;

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
        $this->userRepository->setConfig($this->config);
        $this->_ensureLoggedIn();
    }

    /**
     * GET /list
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function index($type = 'place')
    {
        $this->response->setContent(json_encode(array('message' => 'Please use the search route.')));
        $this->response->setStatusCode(Status::NOT_IMPLEMENTED);

        return $this->response;

        /*if ($this->request->getMethod() == 'PUT') {

            $data = $this->request->request->all();
            $location = $this->user->getCurrentLocation();

            if (array_key_exists('lat', $data) && array_key_exists('lng', $data)) {

                $location['lat'] = floatval($data['lat']);
                $location['lng'] = floatval($data['lng']);

                $this->user->setCurrentLocation($location);
                $this->_updateVisibility($this->user);

                $this->dm->persist($this->user);
                $this->dm->flush();

            } else {

                $this->response->setContent(json_encode(array('message' => 'Invalid location (lat and lng required)')));
                $this->response->setStatusCode(417);

                return $this->response;
            }

        }

        $start = $this->request->get('start', 0);
        $limit = $this->request->get('limit', 20);

        $this->_initRepository($type);

        $places = $this->LocationMarkRepository->getAll($limit, $start);
        $location = $this->user->getCurrentLocation();
        $users = $this->userRepository->getNearBy($location['lat'], $location['lng'], $limit);

        $deals = $this->dealRepository->getNearBy($location['lat'], $location['lng']);

        $this->response->setContent(json_encode(array('places' => $places, 'users' => $users, 'deals' => $deals)));
        $this->response->setStatusCode(Status::OK);

        return $this->response;*/
    }


    public function getUsers()
    {
        $this->response->setContent(json_encode(array('message' => 'Please use the search route.')));
        $this->response->setStatusCode(Status::NOT_IMPLEMENTED);

        return $this->response;

        /*$this->_ensureLoggedIn();

        $start = $this->request->get('start', 0);
        $limit = $this->request->get('limit', 20);

        if (!isset($location['lat']) || !isset($location['lng'])) {
            $this->response->setContent(json_encode(array('message' => 'Users Current location is not updated!')));
            $this->response->setStatusCode(Status::NOT_ACCEPTABLE);
        } else {
            $users = $this->userRepository->getNearBy($location['lat'], $location['lng'], $limit);

            if (!empty($users)) {
                $this->response->setContent(json_encode($users));
                $this->response->setStatusCode(Status::OK);
            } else {
                $this->response->setContent(json_encode(array('message' => 'No user found')));
                $this->response->setStatusCode(Status::NO_CONTENT);
            }
        }

        return $this->response;*/
    }


    public function getDeals()
    {
        $this->response->setContent(json_encode(array('message' => 'Please use the search route.')));
        $this->response->setStatusCode(Status::NOT_IMPLEMENTED);

        return $this->response;

        //$deals = $query->where('{ "location" : { $near : [81,91] } }')->getQuery()->execute();
        /*$location = $this->user->getCurrentLocation();

        if (!isset($location['lat']) || !isset($location['lng'])) {
            $this->response->setContent(json_encode(array('message' => 'Users Current location is not updated!')));
            $this->response->setStatusCode(Status::NOT_ACCEPTABLE);

        } else {
            $deals = $this->dealRepository->getNearBy($location['lat'], $location['lng']);

            if (!empty($deals)) {
                $this->response->setContent(json_encode($deals));
                $this->response->setStatusCode(Status::OK);
            } else {
                $this->response->setContent(json_encode(array('message' => 'No deals found')));
                $this->response->setStatusCode(Status::NO_CONTENT);
            }
        }

        return $this->response;*/
    }

    private function _initRepository($type)
    {
        if ($type == 'geotag') {
            $this->LocationMarkRepository = $this->dm->getRepository('Document\Geotag');
        } else {
            $this->LocationMarkRepository = $this->dm->getRepository('Document\Place');
        }
    }

    /**
     * Update users visibility based on geo-fence settings and current location
     *
     * @param \Document\User $user
     *
     */
    private function _updateVisibility(\Document\User $user)
    {
        $fnc = $user->getGeoFence();

        if ($fnc['radius'] > 0) {
            $loc = $user->getCurrentLocation();

            $distance = \Helper\Location::distance($loc['lat'], $loc['lng'], $fnc['lat'], $fnc['lng']);
            $user->setVisible(($distance > $fnc['radius']));
        }

    }

    private function persistAndReturn($result)
    {
        $this->dm->persist($this->user);
        $this->dm->flush();

        return $this->returnResponse($result);
    }

    private function returnResponse($result)
    {
        $this->response->setContent(json_encode(array('result' => $result)));
        $this->response->setStatusCode(Status::OK);

        return $this->response;
    }
}

<?php
namespace Controller;

use Symfony\Component\HttpFoundation\Response;

use Repository\User as userRepository;
use Repository\Place as placeRepository;
use Repository\Deal as DealRepository;

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
        $start = $this->request->get('start', 0);
        $limit = $this->request->get('limit', 20);

        $this->_initRepository($type);

        $places = $this->LocationMarkRepository->getAll($limit, $start);
        $location = $this->user->getCurrentLocation();
        $users = $this->userRepository->getNearBy($location['lat'], $location['lng'], $limit);

        $deals = $this->dealRepository->getNearBy($location['lat'], $location['lng']);

        $this->response->setContent(json_encode(array('places' => $places , 'users' => $users , 'deals' => $deals)));
        $this->response->setStatusCode(200);

        return $this->response;

    }


    public function getUsers()
    {
        $this->_ensureLoggedIn();

        $start = $this->request->get('start', 0);
        $limit = $this->request->get('limit', 20);



        if (!isset($location['lat']) || !isset($location['lng'])) {
            $this->response->setContent(json_encode(array('message' => 'Users Current location is not updated!')));
            $this->response->setStatusCode(406);
        } else {
            $users = $this->userRepository->getNearBy($location['lat'], $location['lng'], $limit);

            if (!empty($users)) {
                $this->response->setContent(json_encode($users));
                $this->response->setStatusCode(200);
            } else {
                $this->response->setContent(json_encode(array('message' => 'No deals found')));
                $this->response->setStatusCode(204);
            }
        }

        return $this->response;
    }


    public function getDeals()
    {
        //$deals = $query->where('{ "location" : { $near : [81,91] } }')->getQuery()->execute();
        $location = $this->user->getCurrentLocation();

        if (!isset($location['lat']) || !isset($location['lng'])) {
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


    private function _initRepository($type)
    {
        if ($type == 'geotag') {
            $this->LocationMarkRepository = $this->dm->getRepository('Document\Geotag');
        } else {
            $this->LocationMarkRepository = $this->dm->getRepository('Document\Place');
        }

    }
}

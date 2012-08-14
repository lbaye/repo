<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;

use Repository\User as userRepository;
use Helper\Location;
//use Repository\resource as resourceRepository;

/**
 * Template class for all content serving controllers
 */
class Venue extends Base
{
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

        $this->userRepository->setCurrentUser($this->user);
        $this->_ensureLoggedIn();
    }

    /**
     * GET /venues
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function index()
    {
        $location = $this->user->getCurrentLocation();

        if(empty($location['lat'])){
            $this->response->setContent(json_encode(array('message' => 'Users Current location is not updated!')));
            $this->response->setStatusCode(406);

        } else {
            $venues = \Helper\Location::getNearbyVenues($location['lat'], $location['lng']);

            if (!empty($venues)) {
                $venues = $this->_formatGoogleVenues($venues);
                $this->response->setContent(json_encode($venues));
                $this->response->setStatusCode(200);
            } else {
                $this->response->setContent(json_encode(array('message' => 'No deals found')));
                $this->response->setStatusCode(204);
            }
        }

        return $this->response;
    }

    /**
     * GET /venues/{id}
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

    private function _formatGoogleVenues(array $venues)
    {
        $formattedVenues = array();
        foreach( $venues as $venue) {
            $formatted = new \stdClass();

            $formatted->id          = $venue->id;
            $formatted->name        = $venue->name;
            $formatted->icon        = $venue->icon;
            $formatted->location    = $venue->geometry->location;
            $formatted->reference   = $venue->reference;
            $formatted->types       = $venue->types;

            $formattedVenues[] = $formatted;
        }

        return $formattedVenues;
    }
}
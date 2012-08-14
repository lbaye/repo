<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;

use Repository\User as userRepository;
use Helper\Location;

class Search extends Base
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

    public function all()
    {
        $data = $this->request->request->all();
        $results = array();

        $results['people'] = $this->people($data);
        $results['places'] = $this->places($data);
        $results['deals']  = $this->deals($data);

        $this->response->setContent(json_encode($results));
        $this->response->setStatusCode(200);

        return $this->response;
    }

    /** TODO: Finalize people search */
    protected function people($data)
    {
        $location = array('lat' => $data['lat'], 'lng' => $data['lng']);
        $keywords = $data['keyword'];

        $people = $this->userRepository->search($keywords, $location);

        return $people;
    }

    protected function places($data)
    {
        $location = array('lat' => $data['lat'], 'lng' => $data['lng']);
        $keywords = $data['keyword'];

        $googlePlaces = new \Service\Venue\GooglePlaces('AIzaSyAblaI77qQF6DDi5wbhWKePxK00zdFzg-w');
        $places = $googlePlaces->search($keywords, $location);

        return $places;
    }

    /** TODO: Finalize deals search */
    protected function deals($data)
    {
        return array();
    }
}
<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;

use Repository\User as UserRepository;
use Repository\ExternalLocation as ExternalLocationRepository;
use Helper\Location;

class Search extends Base
{
    /**
     * Total number of users to return
     */
    const PEOPLE_THRESHOLD = 100;

    /**
     * Km to radius (km / 111.2)
     */
    const DEFAULT_RADIUS = .017985612;

    /**
     * @var UserRepository
     */
    private $userRepository;

    /**
     * @var ExternalLocationRepository
     */
    private $externalLocationRepository;

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

        $this->response->setContent(json_encode($results));
        $this->response->setStatusCode(200);

        return $this->response;
    }

    protected function people($data)
    {
        $location = array('lat' => (float) $data['lat'], 'lng' => (float) $data['lng']);
        $keywords = isset($data['keyword']) ? $data['keyword'] : null;

        $people = $this->userRepository->search($keywords, $location, self::PEOPLE_THRESHOLD);
        array_walk($people, function(&$person){
            $person['external'] = false;
        });

        if (is_null($keywords) && count($people) < self::PEOPLE_THRESHOLD) {

            $difference = self::PEOPLE_THRESHOLD - count($people);

            $this->externalLocationRepository = $this->dm->getRepository('Document\ExternalLocation');
            $externalPeople = $this->externalLocationRepository->getNearBy($location, $difference);

            array_walk($externalPeople, function(&$person){
                $person['external'] = true;
            });

            if ($externalPeople) {
                $people = array_merge($people, $externalPeople);
            }

        }

        return $people;
    }

    protected function places($data)
    {
        $location = array('lat' => $data['lat'], 'lng' => $data['lng']);
        $keywords = isset($data['keyword']) ? $data['keyword'] : null;

        $googlePlaces = new \Service\Venue\GooglePlaces($this->config['googlePlace']['apiKey']);

        try {
            $places = $googlePlaces->search($keywords, $location);
            return $places;
        } catch (\Exception $e) {
            return array();
        }
    }

    /** TODO: Finalize deals search */
    protected function deals($data)
    {
        return array();
    }
}
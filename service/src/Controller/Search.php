<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;

use Repository\UserRepo as UserRepository;
use Repository\ExternalLocationRepo as ExternalLocationRepository;
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
        parent::init();

        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);

        $this->externalLocationRepository = $this->dm->getRepository('Document\ExternalLocation');
        $this->externalLocationRepository->setCurrentUser($this->user);
        $this->externalLocationRepository->setConfig($this->config);

        $this->_ensureLoggedIn();
    }

    public function all()
    {
        $data = $this->request->request->all();
        $results = array();

        $results['people'] = $this->people($data);
        $results['places'] = $this->places($data);

        return $this->_generateResponse($results);
    }

    protected function people($data)
    {
        $location = array('lat' => (float) $data['lat'], 'lng' => (float) $data['lng']);
        $keywords = isset($data['keyword']) ? $data['keyword'] : null;

        $people = $this->userRepository->search($keywords, $location, self::PEOPLE_THRESHOLD);
        $friends = $this->user->getFriends();

        array_walk($people, function(&$person) use ($friends, $data) {
            $person['external'] = false;
        });

        if (is_null($keywords) && count($people) < self::PEOPLE_THRESHOLD) {

            $difference = self::PEOPLE_THRESHOLD - count($people);
            $externalPeople = $this->externalLocationRepository->getNearBy($location, $difference);

            array_walk($externalPeople, function(&$person) use ($friends) {
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
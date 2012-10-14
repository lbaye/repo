<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;

use Repository\UserRepo as UserRepository;
use Repository\ExternalLocationRepo as ExternalLocationRepository;
use Helper\Location;
use Helper\Status;

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

        if ($this->_isRequiredFieldsFound(array('lat', 'lng'), $data)) {
            $results = array();
            $results['people'] = $this->people($data);
            $results['places'] = $this->places($data);
            $results['facebookFriends'] = $this->secondDegreeFriends($data);

            return $this->_generateResponse($results);
        } else {
            return $this->_generateMissingFieldsError();
        }
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

        try {
            return $this->findPlaces($keywords, $location);
        } catch (\Exception $e) {
            return array("message" => $e->getMessage());
        }
    }

    protected function findPlaces($keywords, $location) {
        return \Service\Location\PlacesServiceFactory::
                getInstance($this->dm, $this->config, \Service\Location\PlacesServiceFactory::CACHED_GOOGLE_PLACES)
                ->search($location, $keywords);
    }

    /** TODO: Finalize deals search */
    protected function deals($data)
    {
        return array();
    }

    

    public function allPeopleList()
    {
        $data = $this->request->request->all();
        $results = $this->people($data);

        return $this->_generateResponse($results);
    }

    protected function secondDegreeFriends($data)
    {
        $location = array('lat' => $data['lat'], 'lng' => $data['lng']);
        $keywords = isset($data['keyword']) ? $data['keyword'] : null;

        return $this->externalLocationRepository->getExternalUsers($this->user->getId(), $limit = 200);
    }
}
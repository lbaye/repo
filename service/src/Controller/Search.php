<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;

use Repository\UserRepo as UserRepository;
use Repository\ExternalUserRepo as ExtUserRepo;
use Helper\Location;
use Helper\Status;

class Search extends Base {
    /**
     * Total number of users to return
     */
    const PEOPLE_THRESHOLD = 100;

    /**
     * Km to radius (km / 111.2)
     */
    const DEFAULT_RADIUS = .017985612;

    private $extUserRepo;

    /**
     * Initialize the controller.
     */
    public function init() {
        parent::init();

        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);

        $this->extUserRepo = $this->dm->getRepository('Document\ExternalUser');

        $this->_ensureLoggedIn();
    }

    public function all() {
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

    protected function people($data) {
        $location = array('lat' => (float)$data['lat'], 'lng' => (float)$data['lng']);
        $keywords = isset($data['keyword']) ? $data['keyword'] : null;

        $people = $this->userRepository->searchWithPrivacyPreference($keywords, $location, self::PEOPLE_THRESHOLD);
        $friends = $this->user->getFriends();

        array_walk($people, function(&$person) use ($friends, $data) {
                $person['external'] = false;

            });

        return $people;
    }

    protected function places($data) {
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
    protected function deals($data) {
        return array();
    }


    public function allPeopleList() {
        $data = $this->request->request->all();
        $results = $this->people($data);

        return $this->_generateResponse($results);
    }

    protected function secondDegreeFriends($data) {
        $location = array('lat' => $data['lat'], 'lng' => $data['lng']);
        $keywords = isset($data['keyword']) ? $data['keyword'] : null;

        $users = array_values(
            $this->dm->createQueryBuilder('Document\ExternalUser')
                    ->field('smFriends')->equals($this->user->getId())
                    ->hydrate(false)
                    ->skip(0)
                    ->limit(200)
                    ->getQuery()->execute()->toArray());
        
        foreach ($users as &$user) {
            $user['distance'] = \Helper\Location::distance(
                $location['lat'], $location['lng'],
                $user['currentLocation']['lat'], $user['currentLocation']['lng']);
        }

        return $users;
    }
}
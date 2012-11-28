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
    const PEOPLE_THRESHOLD = 2000;

    /**
     * Km to radius (km / 111.2)
     */
    const DEFAULT_RADIUS = .017985612;

    /**
     * Maximum allowed older checkins to show in the list.
     */
    const MAX_ALLOWED_OLDER_CHECKINS = '12 hours ago';

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

        $this->createLogger('Controller::Search');
        $this->_ensureLoggedIn();
    }

    public function all() {
        $this->debug('Preparing search result');
        $data = $this->request->request->all();

        if ($this->_isRequiredFieldsFound(array('lat', 'lng'), $data)) {
            $that = &$this;
            return $this->cacheAndReturn($this->buildCacheKey($data),
                function() use($that, $data) {
                    $results = array();
                    $results['people'] = $that->people($data);
                    $results['places'] = $that->places($data);
                    $results['facebookFriends'] = $that->secondDegreeFriends($data);

                    return $that->_generateResponse($results);
                }
            );

        } else {
            $this->warn('Invalid request with missing required fields');
            return $this->_generateMissingFieldsError();
        }
    }

    private function buildCacheKey($data) {
        $lat = round((float) $data['lat'], 3);
        $lng = round((float) $data['lng'], 3);

        $key = $this->user->getId() . DIRECTORY_SEPARATOR . $lat . '_' . $lng;
        return 'search' . DIRECTORY_SEPARATOR . $key;
    }

    public function people($data) {
        $this->debug('Retrieving all people');
        $location = array('lat' => (float)$data['lat'], 'lng' => (float)$data['lng']);
        $keywords = isset($data['keyword']) ? $data['keyword'] : null;
        $key = $this->config['googlePlace']['apiKey'];
        $people = $this->userRepository->searchWithPrivacyPreference($keywords, $location, self::PEOPLE_THRESHOLD, $key);

        return $people;
    }

    public function places($data) {
        $this->debug('Retrieving all places');
        $location = array('lat' => $data['lat'], 'lng' => $data['lng']);
        $keywords = isset($data['keyword']) ? $data['keyword'] : null;

        try {
            return $this->findPlaces($keywords, $location);
        } catch (\Exception $e) {
            return array("message" => $e->getMessage());
        }
    }

    protected function findPlaces($keywords, $location) {
        $this->debug('Finding places with CachedGooglePlaces API');
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

    public function secondDegreeFriends($data) {
        $location = array('lat' => $data['lat'], 'lng' => $data['lng']);
        $keywords = isset($data['keyword']) ? $data['keyword'] : null;

        $users = array_values(
            $this->dm->createQueryBuilder('Document\ExternalUser')
                    ->field('smFriends')->equals($this->user->getId())
            #->field('createdAt')->gte(new \DateTime(self::MAX_ALLOWED_OLDER_CHECKINS))
                    ->hydrate(false)
                    ->skip(0)
                    ->limit(200)
                    ->getQuery()->execute()->toArray());

        foreach ($users as &$user) {
            $user['distance'] = \Helper\Location::distance(
                $location['lat'], $location['lng'],
                $user['currentLocation']['lat'], $user['currentLocation']['lng']);

            $mongoDate = $user['createdAt'];
            $now = new \DateTime();
            $now->setTimestamp($mongoDate->sec);

            $user['createdAt'] = array(
                'date' => $now
            );

            $user['coverPhoto'] = "http://maps.googleapis.com/maps/api/streetview?size=320x130&location="
                                  . $user['currentLocation']['lat'] . ","
                                  . $user['currentLocation']['lng'] . "&fov=90&heading=235&pitch=10&sensor=false"
                                  . "&key={$this->config['googlePlace']['apiKey']}";
        }

        return $users;
    }
}
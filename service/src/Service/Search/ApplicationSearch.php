<?php

namespace Service\Search;

/**
 * Application search implementation
 */
class ApplicationSearch implements ApplicationSearchInterface
{

    private $dm;
    private $config;
    private $user;

    public function __construct(\Document\User $user, \Doctrine\ODM\MongoDB\DocumentManager &$dm, array &$config)
    {
        $this->user = $user;
        $this->dm = &$dm;
        $this->config = &$config;

        $this->userRepository = $dm->getRepository('Document\User');
    }

    public function searchAll(array $params, $options = array())
    {
        $user = isset($options['user']) ? $options['user'] : null;
        if (!is_null($user)) $this->user = $user;

        $results = array();
        $results['people'] = $this->searchPeople($params, $options);
        $results['places'] = $this->searchPlaces($params, $options);
        $results['facebookFriends'] = $this->searchSecondDegreeFriends($params, $options);

        return $results;
    }

    public function searchPeople(array $params, $options = array())
    {
        $limit = isset($options['limit']) ? $options['limit'] : 2000;
        $location = array();

        if (isset($params['ne-position']) && isset($params['sw-position']))
            $location = array(
                'ne' => explode(',', $params['ne-position']),
                'sw' => explode(',', $params['sw-position'])
            );

        if (isset($params['hour'])) {
            $hour = (int)$params['hour'];
        } else {
            $hour = null;
        }
        if (isset($params['minute'])) {
            $minute = (int)$params['minute'];
        } else {
            $minute = null;
        }

        if (isset($params['lat']) && isset($params['lng']))
            $location = array_merge(
                $location, array('lat' => (float)$params['lat'],
                'lng' => (float)$params['lng']));

        $keywords = isset($params['keyword']) ? $params['keyword'] : null;
        $key = $this->config['googlePlace']['apiKey'];
        return $this->userRepository->searchWithPrivacyPreference($keywords, $location, $limit, $key, $hour, $minute);
    }

    public function searchPlaces(array $params, $options = array())
    {
        $location = array('lat' => $params['lat'], 'lng' => $params['lng']);
        $keywords = isset($params['keyword']) ? $params['keyword'] : null;

        try {
            return $this->findPlaces($keywords, $location);
        } catch (\Exception $e) {
            return array();
        }
    }

    public function searchSecondDegreeFriends(array $data, $options = array())
    {
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

            $user['createdAt'] = array('date' => $now);

            $user['coverPhoto'] = \Helper\Url::buildStreetViewImage(
                $this->config['googlePlace']['apiKey'], $user['currentLocation'], '320x130');

            if (isset($user['lastSeenAt']) && !empty($user['lastSeenAt']))
                $user['lastSeenAt'] = \Helper\Util::formatAddress($user['lastSeenAt']);
        }

        return $users;
    }

    private function findPlaces($keywords, $location)
    {
        $googlePlaces = \Service\Location\PlacesServiceFactory::
            getInstance($this->dm, $this->config, \Service\Location\PlacesServiceFactory::CACHED_GOOGLE_PLACES)
            ->search($location, $keywords);

        $customPlaces = array();
        $customPlaces = $this->findCustomPlaces($location);

        return array_merge($googlePlaces, $customPlaces);
    }

    private function findCustomPlaces($location)
    {
        $customPlaces = $this->dm->createQueryBuilder('Document\CustomPlace')
            ->field('type')->equals('custom_place')
            ->getQuery()->execute();

        $result = array();
        foreach ($customPlaces as $customPlace) {
            $customPlaceStore['id'] = $customPlace->getId();
            $customPlaceStore['name'] = $customPlace->getTitle();

            $placeIcon['icon'] = $customPlace->getIcon();
            if (!empty($placeIcon)) {
                $customPlaceStore['icon'] = \Helper\Url::buildPlaceIconUrl($placeIcon);
            }

            $placePhoto['photo'] = $customPlace->getPhoto();
            if (!empty($placePhoto)) {
                $customPlaceStore['streetViewImage'] = \Helper\Url::buildPlacePhotoUrl($placePhoto);
            }

            $customPlaceStore['types'] = array($customPlace->getCategory());

            $placeLocation = $customPlace->getLocation();
            if (!empty($placeLocation)) {
                $customPlaceStore['geometry']['location'] = $placeLocation->toArray();
                if (!empty($customPlaceStore['geometry']['location'])) {
                    $customPlaceStore['distance'] = \Helper\Location::distance(
                        $customPlaceStore['geometry']['location']['lat'], $customPlaceStore['geometry']['location']['lng'],
                        $location['lat'],
                        $location['lng']);
                    $customPlaceStore['vicinity'] = $customPlaceStore['geometry']['location']['address'];
                }
            }

            $customPlaceStore['reference'] = "custom_place";
            $result[] = $customPlaceStore;
        }

        return $result;
    }
}

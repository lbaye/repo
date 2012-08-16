<?php

namespace Repository;

use Doctrine\ODM\MongoDB\DocumentRepository;
use Document\ExternalLocation as ExternalLocationDocument;

class ExternalLocation extends DocumentRepository
{
    public function insertFromFacebook($data)
    {
        $externalLocation = $this->map($data);

        try {
            $this->dm->persist($externalLocation);
            $this->dm->flush();
            return $externalLocation;
        } catch (\MongoCursorException $e) {
            return false;
        }

    }

    public function getNearBy($location = array(), $limit = 20)
    {
        $query = $this->createQueryBuilder()
            //->field('currentLocation.latitude')->near($location['lat'])
            //->field('currentLocation.longitude')->near($location['lng'])
            ->field('coords')->withinCenter($location['lng'], $location['lat'], \Controller\Search::DEFAULT_RADIUS)
            ->limit($limit);

        $result = $query->getQuery()->execute();

        if (count($result)) {

            $externalUsers = $this->_toArrayAll($result);

            foreach ($externalUsers as &$externalUser) {
                $externalUser['distance'] = \Helper\Location::distance($location['lat'], $location['lng'], $externalUser['currentLocation']['lat'], $externalUser['currentLocation']['lng']);
            }

            return $externalUsers;
        }

        return array();
    }

    public function map(array $data, ExternalLocationDocument $externalLocation = null)
    {
        if (is_null($externalLocation)) {
            $externalLocation = new ExternalLocationDocument();
        }

        $setIfExistFields = array(
            'id'          => 'refId',
            'author_uid'  => 'refUserId',
            'page_id'     => 'refLocationId',
            'type'        => 'refType',
            'coords'      => 'coords',
            'timestamp'   => 'refTimestamp',
            'tagged_uids' => 'refTaggedUserIds',
            'source'      => 'source',
            'profile'     => 'refProfile'
        );

        foreach ($setIfExistFields as $externalField => $field) {
            if (isset($data[$externalField]) && !is_null($data[$externalField])) {
                $method = "set" . ucfirst($field);
                $externalLocation->$method($data[$externalField]);
            }
        }

        return $externalLocation;
    }

    private function _toArrayAll($results)
    {
        $users = array();
        foreach ($results as $user) {
            $users[] = $user->toArrayAsUser();
        }

        return $users;
    }
}
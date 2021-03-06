<?php

namespace Repository;

use Repository\Base as BaseRepository;
use Document\ExternalLocation as ExternalLocationDocument;

/**
 * Data access functionality for external location model
 */
class ExternalLocation extends BaseRepository
{
    public function exists($refId)
    {
        $externalLocation = $this->findOneBy(array('refId' => $refId));
        return is_null($externalLocation) ? false : true;
    }

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
            ->field('coords')->withinCenter($location['lng'], $location['lat'], \Helper\Constants::DEFAULT_RADIUS)
            ->limit($limit);

        $result = $query->getQuery()->execute();

        if (count($result)) {

            $friends = $this->currentUser->getFriends();
            $externalUsers = $this->_toArrayAll($result);

            foreach ($externalUsers as &$externalUser) {
                $externalUser['isFriend'] = in_array($externalUser['userId'], $friends);
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

        $userRepo = $this->dm->getRepository('Document\User');
        $user = $userRepo->findOneBy(array('facebookId' => $data['author_uid']));

        if ($user instanceof \Document\User) {
            $externalLocation->setUserId($user->getId());
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
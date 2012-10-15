<?php

namespace Repository;

use Document\ExternalLocation as ExternalLocationDocument;

class ExternalLocationRepo extends Base
{
    public function exists($authId)
    {
        $externalLocation = $this->findOneBy(array('authId' => $authId));
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

    public function updateFromFacebook($data,$locationId)
    {
       $externalLocation = $this->find($locationId);

        if (false === $externalLocation) {
            throw new \Exception\ResourceNotFoundException();
        }
        $externalLocation = $this->map($data,$externalLocation);

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
            ->field('coords')->withinCenter($location['lng'], $location['lat'], \Controller\Search::DEFAULT_RADIUS)
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
            'userId'             => 'userId',
            'uid'                => 'authId',
            'refUserId'          => 'refUserId',
            'ownerFacebookId'    => 'refFacebookId',
            'name'               => 'name',
            'gender'             => 'gender',
            'email'              => 'email',
            'location'           => 'location',
            'picSquare'          => 'picSquare',
            'refType'            => 'refType',
            'refLocationId'      => 'refLocationId',
            'coords'             => 'coords',
            'refTimestamp'       => 'refTimestamp',
            'refProfile'         => 'refProfile',
            'source'             => 'source',
            'refTaggedUserIds'   => 'refTaggedUserIds'
        );

        foreach ($setIfExistFields as $externalField => $field) {
            if (isset($data[$externalField]) && !is_null($data[$externalField])) {
                $method = "set" . ucfirst($field);
                $externalLocation->$method($data[$externalField]);
            }
        }

        $userRepo = $this->dm->getRepository('Document\User');
        $user = $userRepo->findOneBy(array('facebookId' => $data['ownerFacebookId']));

        if ($user instanceof \Document\User) {
            $externalLocation->setRefUserId($user->getId());
        }

        return $externalLocation;
    }

    protected function _toArrayAll($results)
    {
        $users = array();
        foreach ($results as $user) {
            $users[] = $user->toArrayAsUser();
        }

        return $users;
    }

    protected function _toArraySecondDegreeAll($results)
    {
        $users = array();
        foreach ($results as $user) {
            $users[] = $user->toArraySecondDegree();
        }

        return $users;
    }

    public function getExternalUsers($userId, $limit = 200)
    {
            $query = $this->createQueryBuilder()
            ->field('refUserId')->equals($userId)
            ->limit($limit);

        $result = $query->getQuery()->execute();

        if (!empty($result)) {

            $facebookFriends = $this->_toArraySecondDegreeAll($result);
            return $facebookFriends;
        }
        return array();
    }
}
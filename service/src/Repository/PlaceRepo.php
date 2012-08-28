<?php

namespace Repository;

use Doctrine\ODM\MongoDB\DocumentRepository;
use Document\Place as PlaceDocument;
use Document\Geotag as GeotagDocument;
use Document\User as UserDocument;
use Helper\Security as SecurityHelper;

class PlaceRepo extends DocumentRepository
{

    public function getByUser(UserDocument $user)
    {
        $places = $this->findBy(array('owner' => $user->getId()));
        return $this->_toArrayAll($places);
    }

    public function getAll($limit = 20, $offset = 0)
    {
        return $this->findBy(array(), null, $limit, $offset);
    }

    public function insert($place)
    {
        $valid  = $place->isValid();

        if ($valid !== true) {
            throw new \InvalidArgumentException('Invalid Location data', 406);
        }

        $this->dm->persist($place);
        $this->dm->flush($place);

        return $place;
    }

    public function update($data, $id)
    {
        $place = $this->find($id);

        if (false === $place) {
            throw new \Exception\ResourceNotFoundException();
        }

        $place = $this->map($data, $place->getOwner(), $place);

        if ($place->isValid() === false) {
            return false;
        }

        $this->dm->persist($place);
        $this->dm->flush();

        return $place;
    }

    public function delete($id)
    {
        $place = $this->find($id);

        if (is_null($place)) {
            throw new \Exception("Not found", 404);
        }

        $this->dm->remove($place);
        $this->dm->flush();
    }

    public function map(array $data, UserDocument $owner, \Document\Landmark $placeTypeDoc = null)
    {
        if(is_null($placeTypeDoc)){
            if('Document\Geotag' == $this->documentName) {
                $placeTypeDoc = new GeotagDocument();
            } else {
                $placeTypeDoc = new PlaceDocument();
            }

            $placeTypeDoc->setCreateDate(new \DateTime());
        } else {
            $placeTypeDoc->setUpdateDate(new \DateTime());
        }

        $setIfExistFields = array('title');

        foreach($setIfExistFields as $field) {
            if (isset($data[$field]) && !is_null($data[$field])) {
                $placeTypeDoc->{"set{$field}"}($data[$field]);
            }
        }

        $placeTypeDoc->setOwner($owner);
        if(isset($data['lat'])) {
            $placeTypeDoc->setLocation(new \Document\Location($data));
        }

        if(isset($data['permission'])){
            $placeTypeDoc->share($data['permission'], @$data['permittedUsers'], @$data['permittedCircles']);
        }

        return $placeTypeDoc;
    }

    private function _toArrayAll($results)
    {
        $places = array();
        foreach ($results as $place) {
            $places[] = $place->toArray();
        }

        return $places;
    }
}
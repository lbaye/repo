<?php

namespace Repository;

use Doctrine\ODM\MongoDB\DocumentRepository;
use Document\Place as PlaceDocument;
use Document\Geotag as GeotagDocument;
use Document\User as UserDocument;
use Helper\Security as SecurityHelper;
use Helper\Image as ImageHelper;

class PlaceRepo extends Base
{

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

        $setIfExistFields = array('title','category', 'description', 'photo');

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


    public function savePlacePhoto($id, $placePhoto)
    {
        $place = $this->find($id);

        if (false === $place) {
            throw new \Exception\ResourceNotFoundException();
        }

        $place->setUpdateDate(new \DateTime());

        $timeStamp = $place->getUpdateDate()->getTimestamp();

        $filePath = "/images/place-photo/" . $place->getId();
        $photoUrl = filter_var($placePhoto, FILTER_VALIDATE_URL);

        if ($photoUrl !== false) {
            $place->setPhoto($photoUrl);
        } else {
            @ImageHelper::saveImageFromBase64($placePhoto, ROOTDIR . $filePath);
            $place->setPhoto($filePath . "?" . $timeStamp);
        }


        $this->dm->persist($place);
        $this->dm->flush();

        return $place;
    }
}
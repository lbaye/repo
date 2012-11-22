<?php

namespace Repository;

use Doctrine\ODM\MongoDB\DocumentRepository;
use Document\Place as PlaceDocument;
use Document\Geotag as GeotagDocument;
use Document\User as UserDocument;
use Helper\Security as SecurityHelper;
use Helper\Image as ImageHelper;

class PlaceRepo extends Base implements Likable
{
    protected function bindObservers() {
        $this->addObserver(new \Document\PlacesObserver($this->dm));
    }

    public function update($data, $id)
    {
        $place = $this->find($id);
        if (false === $place) throw new \Exception\ResourceNotFoundException();

        $place = $this->map($data, $place->getOwner(), $place);
        return $this->updateObject($place);
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

        $dirPath = "/images/place-photo/";
        $filePath = "/images/place-photo/" . $place->getId() . '.jpg';
        $photoUrl = filter_var($placePhoto, FILTER_VALIDATE_URL);

        if ($photoUrl !== false) {
            $place->setPhoto($photoUrl);
        } else {
            if (!file_exists(ROOTDIR . "/" . $dirPath)) {
                mkdir(ROOTDIR . "/" . $dirPath, 0777, true);
            }
            
            ImageHelper::saveImageFromBase64($placePhoto, ROOTDIR . $filePath);
            $place->setPhoto($filePath . "?" . $timeStamp);
        }


        $this->dm->persist($place);
        $this->dm->flush();

        return $place;
    }

    public function getAll($limit = 20, $offset = 0)
    {
        return $this->findBy(array(), array('createDate' => 'DESC'), $limit, $offset);
    }

    public function getOwnerByPlaceId($id)
    {
        $place = $this->find($id);
        return $place->getOwner();
    }

    public function getByUser(UserDocument $user) {
        $docs = $this->findBy(array('owner' => $user->getId()), array('createDate' => 'DESC'));
        return $this->_toArrayAll($docs);
    }

    public function search(UserDocument $user,$lng,$lat)
    {
        $circles = $user->getCircles();
        foreach ($circles as $circle) {
            $circleId[] = $circle->getId();
        }
        $qb = $this->dm->createQueryBuilder('Document\Geotag');
        if (!empty($lat) && !empty($lng))
            $qb->field('location')->near($lat, $lng);
        $qb->addOr($qb->expr()->field('owner')->equals($user->getId()));
        $qb->addOr($qb->expr()->field('permittedUsers')->equals($user->getId()));
        $qb->addOr($qb->expr()->field('permittedCircles')->in($circleId));
        $qb->addOr($qb->expr()->field('permission')->equals('public'));

        $docs = $qb->getQuery()->execute();

        return $this->_toArrayAll($docs);
    }

    public function like($place, $user) {
        $docName = $this->determineDocName($place);
        return $this->dm->createQueryBuilder("Document\\$docName")
                ->update()
                ->field('likes')->addToSet($user->getId())
                ->field('id')->equals($place->getId())
                ->getQuery()
                ->execute();
    }

    public function unlike($place, $user) {
        $docName = $this->determineDocName($place);
        return $this->dm->createQueryBuilder("Document\\$docName")
                ->update()
                ->field('likes')->pull($user->getId())
                ->field('id')->equals($place->getId())
                ->getQuery()
                ->execute();
    }

    public function hasLiked($place, $user) {
        if ($place->getLikesCount() > 0)
            return in_array($user->getId(), $place->getLikes());

        return false;
    }

    public function getLikes($place) {
        return $place->getLikes();
    }

    protected function determineDocName($place) {
        if ($place->getObjectType() == 'geotag')
            return 'Geotag';
        else
            return 'Place';
    }
}
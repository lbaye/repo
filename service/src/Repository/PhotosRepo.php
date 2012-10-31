<?php

namespace Repository;

use Symfony\Component\HttpFoundation\Response;
use Doctrine\ODM\MongoDB\DocumentRepository;
use Document\User as UserDocument;
use Repository\UserRepo as UserRepository;
use Document\Photo as Photo;
use Helper\Security as SecurityHelper;
use Helper\Image as ImageHelper;

class PhotosRepo extends Base
{
    public function map(array $data, UserDocument $owner, Photo $photo = null)
    {
        if (is_null($photo)) $photo = new Photo();

        $setIfExistFields = array('title', 'description', 'uri');

        foreach($setIfExistFields as $field) {
            if (isset($data[$field]) && !is_null($data[$field])) {
                $photo->{"set{$field}"}($data[$field]);
            }
        }

        if(isset($data['lat']) && isset($data['lng'])){
            $photo->setLocation(new \Document\Location($data));
        }

        $photo->setOwner($owner);

        return $photo;
    }

    public function setPhoto($owner, $title, $description, $uri, $lat, $lng, $photo = null) {
        if (is_null($photo)) $photo = new Photo();

        if(isset($lat) && isset($lng)){
            $data = array(
               'lat' => $lat,
               'lng' => $lng
            );
            $photo->setLocation(new \Document\Location($data));
        }

        $photo->setOwner($owner);
        $photo->setDescription($description);
        $photo->setTitle($title);
        $photo->setUri($uri);

        return $photo;

    }

    public function getByUser(UserDocument $user)
    {
        return $this->dm->createQueryBuilder()
            ->find('Document\Photo')
            ->field('owner')
            ->equals($user->getId())
            ->sort('createDate', 'desc')
            ->getQuery()
            ->execute();
    }

    public function update($data, $id) {
        $photo = $this->find($id);

        if (false === $photo) {
            throw new \Exception\ResourceNotFoundException();
        }

        $photo = $this->map($data, $photo->getOwner(), $photo);

        if ($photo->isValid() === false) {
            return false;
        }

        $this->dm->persist($photo);
        $this->dm->flush();

        return $photo;
    }

}
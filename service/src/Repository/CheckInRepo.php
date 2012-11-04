<?php

namespace Repository;

use Symfony\Component\HttpFoundation\Response;
use Doctrine\ODM\MongoDB\DocumentRepository;
use Document\User as UserDocument;
use Repository\UserRepo as UserRepository;
use Document\CheckIn as CheckIn;
use Helper\Security as SecurityHelper;
use Helper\Image as ImageHelper;

class CheckInRepo extends Base
{
    public function map(array $data, UserDocument $owner, CheckIn $checkIn = null)
    {


        if (is_null($checkIn)) $checkIn = new CheckIn();

        $setIfExistFields = array('uri', 'message', "venue", "venueType");

        foreach($setIfExistFields as $field) {
            if (isset($data[$field]) && !is_null($data[$field])) {
                $f = ucfirst($field);
                $checkIn->{"set{$f}"}($data[$field]);
            }
        }

        if (isset($data['taggedUsers']))
        {
            $taggedUsers = $data["taggedUsers"];
            foreach($taggedUsers as $taggedUser) {
                $checkIn->AddtaggedUsers($taggedUser);
            }
        }

        if (isset($data['likedByUsers']))
        {
            $likedByUsers = $data["likedByUsers"];
            foreach($likedByUsers as $likedByUser) {
                $checkIn->addLikedByUsers($likedByUser);
            }
        }

        $checkIn->setOwner($owner);

        return $checkIn;
    }

    public function getByUser(UserDocument $user)
    {
        return $this->dm->createQueryBuilder()
            ->find('Document\CheckIn')
            ->field('owner')
            ->equals($user->getId())
            ->sort('createDate', 'desc')
            ->getQuery()
            ->execute();
    }



    public function update($data, $id) {
        $checkIn = $this->find($id);

        if (false === $checkIn) {
            throw new \Exception\ResourceNotFoundException();
        }

        $checkIn = $this->map($data, $checkIn->getOwner(), $checkIn);

        if ($checkIn->isValid() === false) {
            return false;
        }

        $this->dm->persist($checkIn);
        $this->dm->flush();

        return $checkIn;
    }

}
<?php

namespace Repository;

use Symfony\Component\HttpFoundation\Response;
use Doctrine\ODM\MongoDB\DocumentRepository;
use Document\User as UserDocument;
use Repository\UserRepo as UserRepository;
use Document\Review as Review;
use Helper\Security as SecurityHelper;


class ReviewRepo extends Base
{
    public function map(array $data, UserDocument $owner, Review $review = null)
    {


        if (is_null($review)) $review = new Review();

        $setIfExistFields = array('review', 'rating', "venue", "venueType");

        foreach($setIfExistFields as $field) {
            if (isset($data[$field]) && !is_null($data[$field])) {
                $f = ucfirst($field);
                $review->{"set{$f}"}($data[$field]);
            }
        }

        $review->setOwner($owner);
        return $review;
    }

    public function getByUser(UserDocument $user)
    {
        return $this->dm->createQueryBuilder()
            ->find('Document\Review')
            ->field('owner')
            ->equals($user->getId())
            ->sort('createDate', 'desc')
            ->getQuery()
            ->execute();
    }

    public function getByVenue($venue)
    {
        return $this->dm->createQueryBuilder()
            ->find('Document\Review')
            ->field('venue')
            ->equals($venue)
            ->sort('createDate', 'desc')
            ->getQuery()
            ->execute();
    }

    public function GetByVenueType($venue_type)
    {
        return $this->dm->createQueryBuilder()
            ->find('Document\Review')
            ->field('venueType')
            ->equals($venue_type)
            ->sort('createDate', 'desc')
            ->getQuery()
            ->execute();
    }

    public function update($data, $id) {
        $review = $this->find($id);

        if (false === $review) {
            throw new \Exception\ResourceNotFoundException();
        }

        $review = $this->map($data, $review->getOwner(), $review);

        if ($review->isValid() === false) {
            return false;
        }

        $this->dm->persist($review);
        $this->dm->flush();

        return $review;
    }

}



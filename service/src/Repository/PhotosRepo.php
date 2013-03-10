<?php

namespace Repository;

use Symfony\Component\HttpFoundation\Response;
use Doctrine\ODM\MongoDB\DocumentRepository;
use Document\User as UserDocument;
use Repository\UserRepo as UserRepository;
use Document\Photo as Photo;
use Helper\Security as SecurityHelper;
use Helper\Image as ImageHelper;
use Document\PhotosObserver;
use Repository\Likable;

/**
 * Data access functionality for photo model
 */
class PhotosRepo extends Base implements Likable
{

    protected function bindObservers()
    {
        $this->addObserver(new \Document\PhotosObserver($this->dm));
    }

    public function map(array $data, UserDocument $owner, Photo $photo = null)
    {
        if (is_null($photo)) $photo = new Photo();

        $setIfExistFields = array('title', 'description', 'uriThumb', 'uriMedium', 'uriLarge');

        foreach ($setIfExistFields as $field) {
            if (isset($data[$field]) && !is_null($data[$field])) {
                $photo->{
                "set{$field}"
                }($data[$field]);
            }
        }

        if (isset($data['lat']) && isset($data['lng'])) {
            $photo->setLocation(new \Document\Location($data));
        }

        $photo->setOwner($owner);
        if (isset($data['permission'])) {
            $photo->share($data['permission'], @$data['permittedUsers'], @$data['permittedCircles']);
        }

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

    public function getByPermittedUser(UserDocument $user)
    {
        return $this->dm->createQueryBuilder()
            ->find('Document\Photo')
            ->field('owner')
            ->equals($user->getId())
            ->sort('createDate', 'desc')
            ->getQuery()
            ->execute();
    }

    public function getByPhotoId(UserDocument $user, $photoId)
    {
        return $this->dm->createQueryBuilder()
            ->find('Document\Photo')
            ->field('_id')
            ->equals($photoId)
            ->field('owner')
            ->equals($user->getId())
            ->sort('createDate', 'desc')
            ->getQuery()
            ->execute();
    }

    public function update($data, $id)
    {
        $photo = $this->find($id);
        if (false === $photo) throw new \Exception\ResourceNotFoundException();

        $photo = $this->map($data, $photo->getOwner(), $photo);
        return $this->updateObject($photo);
    }

    public function addComments($photoId, array $data)
    {
        $photo = $this->find($photoId);

        if (is_null($photo)) {
            throw new \InvalidArgumentException();
        }

        $comment = new \Document\PhotoComment($data);

        $photo->addPhotoComment($comment);

        $this->dm->persist($comment);
        $this->dm->persist($photo);
        $this->dm->flush();

        return $comment;
    }

    public function getAllByUser(UserDocument $user, $limit = 20, $offset = 0)
    {
        return $this->findBy(array('owner' => $user->getId()), array('_id' => 'DESC'));
    }

    public function like($photo, $user)
    {
        return $this->dm->createQueryBuilder('Document\Photo')
            ->update()
            ->field('likes')->addToSet($user->getId())
            ->field('id')->equals($photo->getId())
            ->getQuery()
            ->execute();
    }

    public function unlike($photo, $user)
    {
        return $this->dm->createQueryBuilder('Document\Photo')
            ->update()
            ->field('likes')->pull($user->getId())
            ->field('id')->equals($photo->getId())
            ->getQuery()
            ->execute();
    }

    public function hasLiked($photo, $user)
    {
        if ($photo->getLikesCount() > 0)
            return in_array($user->getId(), $photo->getLikes());

        return false;
    }

    public function getLikes($photo)
    {
        return $photo->getLikes();
    }
}
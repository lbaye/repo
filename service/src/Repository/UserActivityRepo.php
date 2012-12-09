<?php

namespace Repository;

use Symfony\Component\HttpFoundation\Response;
use Doctrine\ODM\MongoDB\DocumentRepository;
use Document\User as User;
use Document\UserActivity as UserActivity;
use Repository\UserRepo as UserRepo;
use Repository\PhotosRepo as PhotoRepo;
use Repository\Likable;

class UserActivityRepo extends Base implements Likable
{

    public function getByNetwork(User $user, $offset = 0, $limit = 20)
    {

        $ids = $user->getFriends();
        $ids[] = $user->getId();
        foreach ($ids as &$id) {
            $id = new \MongoId($id);
        }

        return $this->dm->createQueryBuilder()
            ->find('Document\UserActivity')
            ->field('owner')
            ->in($ids)
            ->sort('createdAt', 'desc')
            ->limit($limit)
            ->skip($offset)
            ->getQuery()
            ->execute();
    }

    public function getByUser(User $user, $offset = 0, $limit = 20)
    {

        return $this->dm->createQueryBuilder()
            ->find('Document\UserActivity')
            ->field('owner')
            ->equals($user->getId())
            ->sort('createdAt', 'desc')
            ->limit($limit)
            ->skip($offset)
            ->getQuery()
            ->execute();
    }

    public function logActivity(UserActivity $activity)
    {
        return $this->insert($activity);
    }

    public function hasLiked($object, $user)
    {
        if ($this->canLikeRemotely($object))
            return $this->hasLikedRemotely($object, $user);
        else
            return $this->hasLikedLocally($object, $user);
    }

    public function like($activity, $user)
    {
        if ($this->canLikeRemotely($activity))
            return $this->likeRemotely($activity, $user);
        else
            return $this->likeLocally($activity, $user);
    }

    public function unlike($activity, $user)
    {
        if ($this->canLikeRemotely($activity))
            return $this->unlikeRemotely($activity, $user);
        else
            return $this->unlikeLocally($activity, $user);
    }

    public function getLikes($activity)
    {
        if ($this->canLikeRemotely($activity))
            return $this->getLikesRemotely($activity);
        else
            return $activity->getLikes();
    }

    public function map(array $data, User $owner, UserActivity $activity = null)
    {

        if (is_null($activity))
            $activity = new UserActivity();

        $this->populateIfExists($activity, $data);
        $activity->setOwner($owner);

        return $activity;
    }

    private function getObjectRepo(UserActivity $activity)
    {
        switch ($activity->getObjectType()) {
            case UserActivity::ACTIVITY_PHOTO:
                return $this->dm->getRepository('Document\Photo');

            case \Document\UserActivity::ACTIVITY_GEOTAG:
                return $this->dm->getRepository('Document\Geotag');

            default:
                return null;
        }
    }

    private function canLikeRemotely(\Document\UserActivity $activity)
    {
        $objectRepo = $this->getObjectRepo($activity);
        return !is_null($objectRepo);
    }

    private function likeRemotely(
        \Document\UserActivity $activity,
        \Document\User $user)
    {

        $objectRepo = $this->getObjectRepo($activity);
        $object = $objectRepo->find($activity->getObjectId());
        if ($objectRepo->like($object, $user)) {
            $this->refresh($object);
            $activity->setLikesCount($object->getLikesCount());
            $this->updateObject($activity);

            return true;
        }

        return false;
    }

    private function unlikeRemotely(
        \Document\UserActivity $activity,
        \Document\User $user)
    {

        $objectRepo = $this->getObjectRepo($activity);
        $object = $objectRepo->find($activity->getObjectId());
        if ($objectRepo->unlike($object, $user)) {
            $this->refresh($object);
            $activity->setLikesCount($object->getLikesCount());
            $this->updateObject($activity);

            return true;
        }

        return false;
    }

    private function hasLikedRemotely(\Document\UserActivity $activity, \Document\User $user)
    {
        $objectRepo = $this->getObjectRepo($activity);
        return $objectRepo->hasLiked(
            $objectRepo->find($activity->getObjectId()), $user);
    }

    private function likeLocally(\Document\UserActivity $activity, \Document\User $user)
    {
        return $this->dm->createQueryBuilder('Document\UserActivity')
            ->update()
            ->field('likes')->addToSet($user->getId())
            ->field('id')->equals($activity->getId())
            ->getQuery()
            ->execute();
    }

    private function unlikeLocally(\Document\UserActivity $activity, \Document\User $user)
    {
        return $this->dm->createQueryBuilder('Document\UserActivity')
            ->update()
            ->field('likes')->pull($user->getId())
            ->field('id')->equals($activity->getId())
            ->getQuery()
            ->execute();
    }

    private function hasLikedLocally(\Document\UserActivity $activity, \Document\User $user)
    {
        if ($activity->getLikesCount() > 0)
            return in_array($user->getId(), $activity->getLikes());

        return false;
    }

    private function getLikesRemotely($activity)
    {
        $objectRepo = $this->getObjectRepo($activity);
        return $objectRepo->find($activity->getObjectId())->getLikes();
    }
}
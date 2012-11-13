<?php

namespace Repository;

use Symfony\Component\HttpFoundation\Response;
use Doctrine\ODM\MongoDB\DocumentRepository;
use Document\User as User;
use Document\UserActivity as UserActivity;
use Repository\UserRepo as UserRepo;

class UserActivityRepo extends Base {

    public function getByUser(User $user, $limit = 20) {
        return $this->dm->createQueryBuilder()
                ->find('Document\UserActivity')
                ->field('owner')
                ->equals($user->getId())
                ->sort('createDate', 'desc')
                ->limit($limit)
                ->getQuery()
                ->execute();
    }

    public function logActivity(UserActivity $activity) {
        return $this->insert($activity);
    }

    public function map( array $data, User $owner, UserActivity $activity = null) {

        if (is_null($activity)) $activity = new UserActivity();

        $this->populateIfExists($activity, $data);
        $activity->setOwner( $owner );

        return $activity;
    }

}
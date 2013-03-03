<?php

namespace Document;

use Repository\UserActivityRepo as ActivityRepo;

/**
 * Observer for create user activity based on new photo creation
 */
class PhotosObserver extends AbstractObserver {

    private $activityRepo;
    private $dm;

    public function __construct(\Doctrine\ODM\MongoDB\DocumentManager $dm) {
        $this->dm = $dm;
        $this->activityRepo = $this->dm->getRepository('Document\UserActivity');
    }

    public function getName() {
        return 'PhotosObserver';
    }

    public function afterDestroy(&$object) {
        $this->activityRepo->deleteBy(array('objectId' => $object->getId()));
    }

    public function afterCreate(&$object) {
        $activity = new UserActivity();
        $activity->setTitle($object->getDescription());
        $activity->setObjectType(UserActivity::ACTIVITY_PHOTO);
        $activity->setOwner($object->getOwner());
        $activity->setObjectId($object->getId());

        $this->activityRepo->logActivity($activity);
    }
}

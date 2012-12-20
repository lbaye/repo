<?php

namespace Document;

use Repository\UserActivityRepo as ActivityRepo;

/**
 * Observer for storing user activity based on new place creation
 */
class PlacesObserver extends AbstractObserver {

    private $activityRepo;
    private $dm;

    public function __construct(\Doctrine\ODM\MongoDB\DocumentManager $dm) {
        $this->dm = $dm;
        $this->activityRepo = $this->dm->getRepository('Document\UserActivity');
    }

    public function getName() {
        return 'GeotagObserver';
    }

    public function afterDestroy(&$object) {
        if ($object->getType() !== 'geotag') return false;
        $this->activityRepo->deleteBy(array('objectId' => $object->getId()));
    }

    public function afterUpdate(&$object) {
        if ($object->getType() !== 'geotag') return false;
        $activity = $this->activityRepo->findOneBy(array('objectId' => $object->getId()));

        if ($activity) {
            $activity->setTitle($object->getTitle());
            $this->activityRepo->updateObject($activity);
        }
    }

    public function afterCreate(&$object) {
        if ($object->getType() !== 'geotag') return false;

        $activity = new UserActivity();
        $activity->setTitle($object->getTitle());
        $activity->setObjectType(UserActivity::ACTIVITY_GEOTAG);
        $activity->setOwner($object->getOwner());
        $activity->setObjectId($object->getId());

        $this->activityRepo->logActivity($activity);
    }

}

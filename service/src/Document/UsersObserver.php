<?php

namespace Document;

use Repository\UserActivityRepo as ActivityRepo;

/**
 * Observer for creating user activity based on friend request accepted
 */
class UsersObserver extends AbstractObserver {

    private $activityRepo;
    private $userRepo;
    private $dm;

    public function __construct(
        \Doctrine\ODM\MongoDB\DocumentManager $dm, \Repository\UserRepo $userRepo) {

        $this->dm = $dm;
        $this->activityRepo = $this->dm->getRepository('Document\UserActivity');
        $this->userRepo = $userRepo;
    }

    public function getName() {
        return 'UsersObserver';
    }

    public function afterDestroy(&$object) {
        $this->activityRepo->deleteBy(array('objectId' => $object->getId()));
        $this->activityRepo->deleteBy(array('owner' => $object->getId()));
    }

    public function announcement($type, array $array) {
        if (isset($array['object']) && isset($array['type'])) {
            $object = $array['object'];
            $type = $array['type'];

            if ($type === \Repository\UserRepo::EVENT_ADDED_FRIEND)
                $this->logEventIfNotYetExists($object);

        }
    }

    private function logEventIfNotYetExists(\Document\FriendRequest $request) {
        $criteria = array(
            'objectId' => $request->getUserId(),
            'objectType' => UserActivity::ACTIVITY_FRIEND,
            'owner' => $request->getRecipientId()
        );

        if (!$this->activityRepo->findOneBy($criteria)) {
            $activity = new UserActivity();
            $activity->setTitle(
                \Helper\AppMessage::getMessage(\Helper\AppMessage::FRIEND_REQUEST, $request->getFriendName()));
            $activity->setObjectId($request->getUserId());
            $activity->setObjectType(UserActivity::ACTIVITY_FRIEND);
            $activity->setOwner($this->userRepo->find($request->getRecipientId()));

            $this->activityRepo->logActivity($activity);
        }
    }


}

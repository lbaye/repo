<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;
use Repository\UserRepo as UserRepository;
use Document\FriendRequest;
use Symfony\Component\HttpFoundation\RedirectResponse;
use MtHaml\Environment;
use Helper\Email as EmailHelper;
use Helper\Status;
use \Helper\Dependencies as Dependencies;

class UserActivities extends Base {

    private $userActivitiesRepo;
    private $photoRepository;

    public function init() {
        parent::init();

        $this->createLogger('Controller::UserActivities');

        $this->userActivitiesRepo = $this->dm->getRepository('Document\UserActivity');
        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->photoRepository = $this->dm->getRepository('Document\Photo');
        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);

        $this->_ensureLoggedIn();
    }

    public function getActivities($type) {
        return $this->getActivitiesByUser($this->user, $type);
    }

    public function getActivitiesByUserId($type) {
        $userId = $this->request->get('userId');
        return $this->getActivitiesByUser($this->userRepository->find($userId), $type);
    }

    public function getActivitiesByUser(
        \Document\User $user, $type = self::DEFAULT_CONTENT_TYPE) {

        $activities = $this->userActivitiesRepo->getByUser($user);

        if (count($activities) == 0)
            return $this->_generateResponse(array());
        else {
            $items = array();
            foreach ($activities as $activity) $items[] = $activity->toArray();

            if (self::DEFAULT_CONTENT_TYPE === $type)
                return $this->_generateResponse($items);
            else {
                return $this->render(
                    array(
                        'baseUrl' => Dependencies::$rootUrl,
                        'activities' => $activities,
                        'userRepo' => $this->userRepository,
                        'photoRepo' => $this->photoRepository
                    ));
            }
        }
    }
    
}

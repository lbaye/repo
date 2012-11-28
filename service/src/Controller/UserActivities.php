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
    private $geotagRepository;

    public function init() {
        parent::init();

        $this->createLogger('Controller::UserActivities');

        $this->userActivitiesRepo = $this->dm->getRepository('Document\UserActivity');
        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->photoRepository = $this->dm->getRepository('Document\Photo');
        $this->geotagRepository = $this->dm->getRepository('Document\Geotag');
        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);
    }

    public function getActivities($type) {
        $this->_ensureLoggedIn();
        return $this->getActivitiesByUser($this->user, $type);
    }

    public function getMiniFeed($type){
        $this->_ensureLoggedIn();
        return $this->getMiniFeedByUser($this->user, $type);
    }

    public function getMiniFeedByUserId($type) {
        $userId = $this->request->get('userId');
        return $this->getMiniFeedByUser($this->userRepository->find($userId), $type);
    }

    public function getActivitiesByUserId($type) {
        $userId = $this->request->get('userId');
        return $this->getActivitiesByUser($this->userRepository->find($userId), $type);
    }

    public function getMiniFeedByUser(
        \Document\User $user, $type = self::DEFAULT_CONTENT_TYPE) {

        $activities = $this->userActivitiesRepo->getByUser($user);

        if (count($activities) == 0) {
            $this->response->setContent('');
            $this->response->headers->set('Content-Type', 'text/html');
            return $this->response;
        } else {
            $items = array();
            foreach ($activities as $activity) $items[] = $activity->toArray();

            if (self::DEFAULT_CONTENT_TYPE === $type)
                return $this->_generateResponse($items);
            else {
                return $this->render(
                    array(
                        'activities' => $activities,
                        'userRepo' => $this->userRepository,
                        'photoRepo' => $this->photoRepository,
                        'geotagRepo' => $this->geotagRepository,
                        'activityRepo' => $this->userActivitiesRepo,
                        'currentUser' => $user,
                        'authToken' => $user->getAuthToken()
                    ));
            }
        }

    }

    public function getActivitiesByUser(
        \Document\User $user, $type = self::DEFAULT_CONTENT_TYPE) {

        $activities = $this->userActivitiesRepo->getByUser($user);

        if (count($activities) == 0) {
            $this->response->setContent('');
            $this->response->headers->set('Content-Type', 'text/html');
            return $this->response;
        } else {
            $items = array();
            foreach ($activities as $activity) $items[] = $activity->toArray();

            if (self::DEFAULT_CONTENT_TYPE === $type)
                return $this->_generateResponse($items);
            else {
                return $this->render(
                    array(
                         'activities' => $activities,
                         'userRepo' => $this->userRepository,
                         'photoRepo' => $this->photoRepository,
                         'geotagRepo' => $this->geotagRepository,
                         'activityRepo' => $this->userActivitiesRepo,
                         'currentUser' => $user,
                         'authToken' => $user->getAuthToken()
                    ));
            }
        }
    }

    public function likeById($id, $type = self::DEFAULT_CONTENT_TYPE) {
        $this->_ensureLoggedIn();

        $activity = $this->userActivitiesRepo->find($id);
        if (is_null($activity)) return $this->_generate404();

        if ($this->userActivitiesRepo->like($activity, $this->user))
            return $this->_generateResponse(
                array('status' => 'true', 'message' => 'You have liked it'));
        else
            return $this->_generateResponse(
                array('status' => 'false', 'message' => 'You have failed to like it'));
    }

    public function getLikesById($id, $type = self::DEFAULT_CONTENT_TYPE) {
        $this->_ensureLoggedIn();

        $activity = $this->userActivitiesRepo->find($id);
        if (is_null($activity)) return $this->_generate404();

        if ($type === self::DEFAULT_CONTENT_TYPE) {
            return $this->_generateErrorResponse($activity->toArray());
        } else {
            return $this->render(
                array(
                    'activity' => $activity,
                    'activityRepo' => $this->userActivitiesRepo,
                    'currentUser' => $this->user
                ));
        }

    }
}

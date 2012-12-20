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

/**
 * Manage user activities related logs
 */
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

    /**
     * GET /me/newsfeed
     * GET /me/newsfeed.html
     *
     * Generate current user's activities as newsfeed for the current user.
     *
     * @param  $type JSON or HTML
     * @param bool $networkFeed Set true if you want to include all friend's activities
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getActivities($type, $networkFeed = false) {
        $this->_ensureLoggedIn();
        return $this->getActivitiesByUser($this->user, $type, $networkFeed);
    }

    /**
     * GET /me/minifeed
     * GET /me/minifeed.html
     *
     * Generate current user's activities as newsfeed for the current user. This version of newsfeed is compact
     * and suitable for small view area.
     *
     * @param  $type JSON or HTML
     * @param bool $networkFeed Set true if you want to include all friend's activities
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getMiniFeed($type, $networkFeed = false){
        $this->_ensureLoggedIn();
        return $this->getMiniFeedByUser($this->user, $type, $networkFeed);
    }

    /**
     * GET /{userId}/minifeed
     * GET /{userId}/minifeed.html
     *
     * Generate specific user's activities as newsfeed for the current user. This version of newsfeed is compact
     * and suitable for small view area.
     *
     * @param  $type JSON or HTML
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getMiniFeedByUserId($type) {
        $userId = $this->request->get('userId');
        return $this->getMiniFeedByUser($this->userRepository->find($userId), $type);
    }

    /**
     * GET /{userId}/newsfeed
     * GET /{userId}/newsfeed.html
     *
     * Generate specific user's activities as newsfeed for the current user.
     *
     * @param  $type JSON or HTML
     * @param bool $networkFeed Set true if you want to include all friend's activities
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getActivitiesByUserId($type, $networkFeed = false) {
        $userId = $this->request->get('userId');
        return $this->getActivitiesByUser($this->userRepository->find($userId), $type, $networkFeed);
    }

    public function getMiniFeedByUser(
        \Document\User $user, $type = self::DEFAULT_CONTENT_TYPE, $networkFeed = false) {

        if($networkFeed)
            $activities = $this->userActivitiesRepo->getByNetwork($user);
        else
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
        \Document\User $user, $type = self::DEFAULT_CONTENT_TYPE, $networkFeed = false) {

        $offset = $this->request->get('offset', 0);

        if ($networkFeed)
            $activities = $this->userActivitiesRepo->getByNetwork($user, $offset, 5);
        else
            $activities = $this->userActivitiesRepo->getByUser($user, $offset, 5);

        $partialView = $offset > 0;

        if (self::DEFAULT_CONTENT_TYPE === $type) {
            $items = array();
            if (count($activities) > 0)
                foreach ($activities as $activity) $items[] = $activity->toArray();

            return $this->_generateResponse($items);
        } else {
            return $this->render(
                array(
                     'activities' => $activities,
                     'userRepo' => $this->userRepository,
                     'photoRepo' => $this->photoRepository,
                     'geotagRepo' => $this->geotagRepository,
                     'activityRepo' => $this->userActivitiesRepo,
                     'contextUser' => $user,
                     'currentUser' => $this->user,
                     'partialView' => $partialView,
                     'networkFeed' => $networkFeed,
                     'authToken' => $this->user->getAuthToken()
                ));
        }
    }

    /**
     * PUT /newsfeed/{id}/like
     *
     * Like a specific newsfeed from the stream
     *
     * @param  $id
     * @param string $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
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

    /**
     * PUT /newsfeed/{id}/unlike
     *
     * Unlike a specific newsfeed from the stream
     *
     * @param  $id
     * @param string $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function unlikeById($id, $type = self::DEFAULT_CONTENT_TYPE) {
        $this->_ensureLoggedIn();

        $activity = $this->userActivitiesRepo->find($id);
        if (is_null($activity)) return $this->_generate404();

        if ($this->userActivitiesRepo->unlike($activity, $this->user))
            return $this->_generateResponse(
                array('status' => 'true', 'message' => 'You have unliked it'));
        else
            return $this->_generateResponse(
                array('status' => 'false', 'message' => 'You have failed to unlike it'));
    }

    /**
     * GET /newsfeed/{id}/likes.html
     *
     * Retrieve list of likes from a specific newsfeed
     *
     * @param  $id
     * @param string $type HTML or JSON format
     * @return \Symfony\Component\HttpFoundation\Response
     */
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

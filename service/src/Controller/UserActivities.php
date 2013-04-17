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
class UserActivities extends Base
{

    private $userActivitiesRepo;
    private $photoRepository;
    private $geotagRepository;
    private $placeRepository;

    public function init()
    {
        parent::init();

        $this->createLogger('Controller::UserActivities');

        $this->userActivitiesRepo = $this->dm->getRepository('Document\UserActivity');
        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->photoRepository = $this->dm->getRepository('Document\Photo');
        $this->geotagRepository = $this->dm->getRepository('Document\Geotag');
        $this->placeRepository = $this->dm->getRepository('Document\Place');
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
    public function getActivities($type, $networkFeed = false)
    {
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
    public function getMiniFeed($type, $networkFeed = false)
    {
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
    public function getMiniFeedByUserId($type)
    {
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
    public function getActivitiesByUserId($type, $networkFeed = false)
    {
        $userId = $this->request->get('userId');
        return $this->getActivitiesByUser($this->userRepository->find($userId), $type, $networkFeed);
    }

    public function getMiniFeedByUser(
        \Document\User $user, $type = self::DEFAULT_CONTENT_TYPE, $networkFeed = false)
    {

        if ($networkFeed)
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
        \Document\User $user, $type = self::DEFAULT_CONTENT_TYPE, $networkFeed = false)
    {

        $offset = $this->request->get('offset', 0);

        $userId = $this->request->get('userId', 0);
        $ownProfile = 1;
        if ($userId == $this->user->getId()) {
            $ownProfile = 1;
        } else {
            $ownProfile = 0;
        }

        $partialView = $offset > 0;

        $allowItems = array();

        while ($requiredItems = (5 - count($allowItems))) {
            if ($networkFeed)
                $activities = $this->userActivitiesRepo->getByNetwork($user, $offset, 5);
            else
                $activities = $this->userActivitiesRepo->getByUser($user, $offset, 5);

            $recNo = 0;
            foreach ($activities as $activity) {
                $recNo++;
            }


//            if (empty($activities)) {
//                echo "RRRRRRRRRRRRR";
//                break;
//            }
            if ($networkFeed) {
                $items = $this->expectedNetworkActivities($activities, $user, $offset);
            } else {
                $items = $this->expectedActivities($activities, $user, $offset, $ownProfile);
            }

            if (($removeItems = (count($items) - $requiredItems)) > 0) {
                while ($removeItems > 0) {
                    array_pop($items);
                    --$removeItems;
                }
                $offset += count($items);
            } else {
                $offset += 5;
            }

            $allowItems = array_merge($allowItems, $items);

            // TRICKS
            if ($recNo < 5) {
                break;
            }
        }


//        if (count($activities) > 0) {
//            $allowItems = $this->expectedActivities($activities, $user, $offset);
//            if ($requiredItems = (5 - count($allowItems))) {
//                if ($networkFeed)
//                    $activities = $this->userActivitiesRepo->getByNetwork($user, $offset, 5);
//                else
//                    $activities = $this->userActivitiesRepo->getByUser($user, $offset, 5);
//            }
//        }

        if (self::DEFAULT_CONTENT_TYPE === $type) {
            $items = array();
            if (count($activities) > 0)
                foreach ($activities as $activity) $items[] = $activity->toArray();

            return $this->_generateResponse($items);
        } else {
            return $this->render(
                array(
                    'activities' => $allowItems,
                    'offset' => $offset,
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

    private function expectedActivities($activities, $user, $offset = 0, $ownProfile)
    {
        $allowItems = array();
        foreach ($activities as $activity) {
            if ($activity->getObjectType() == "photo") {
                $photo = $this->photoRepository->getByPhotoId($user, $activity->getObjectId());
                $permittedDocs = $this->_filterByPermissionForDetails($photo, $this->user);

                if (empty($permittedDocs))
                    unset($activity);
                else
                    $allowItems[] = $activity;
            } else if ($activity->getObjectType() == "geotag") {
                if ($ownProfile) {
                    $geotag = $this->placeRepository->getOwnActivityById($activity->getObjectId(), $this->user);
                    if (!empty($geotag)) {
                        $allowItems[] = $activity;
                    }
                } else {
                    $geotag = $this->placeRepository->getUserActivityById($activity->getObjectId());
                    if (($geotag->getPermission() == "custom")) {
                        if ($this->isPermittedGeoTag($geotag, $ownProfile)) {
                            $allowItems[] = $activity;
                        }
                    } else {
                        $allowItems[] = $activity;
                    }
                }

            } elseif ($activity->getObjectType() == "friend") {
                if (in_array($activity->getObjectId(), $this->user->getFriends())) {
                    $allowItems[] = $activity;
                }
            } else {
                $allowItems[] = $activity;
            }
        }
        return $allowItems;
    }

    private function expectedNetworkActivities($activities, $user, $offset = 0)
    {
        $allowItems = array();
        foreach ($activities as $activity) {
            if ($activity->getObjectType() == "photo") {
                $photo = $this->photoRepository->getByPhotoIdWithoutAuth($user, $activity->getObjectId());
                $permittedDocs = $this->_filterByPermissionForDetails($photo, $this->user);

                if (empty($permittedDocs))
                    unset($activity);
                else
                    $allowItems[] = $activity;
            } else if ($activity->getObjectType() == "geotag") {
                $geotag = $this->placeRepository->getUserActivityById($activity->getObjectId());

                if (($geotag->getPermission() == "custom")) {
                    if ($this->isPermittedGeoTag($geotag)) {
                        $allowItems[] = $activity;
                    }
                } else {
                    $allowItems[] = $activity;
                }

            } elseif ($activity->getObjectType() == "friend") {
                if (in_array($activity->getObjectId(), $this->user->getFriends())) {
                    $allowItems[] = $activity;
                }
            } else {
                $allowItems[] = $activity;
            }
        }
        return $allowItems;
    }

    private function isPermittedGeoTag($geotag)
    {
        $ownerId = $geotag->getOwner()->getId();
        if ($ownerId == null) {
            return false;
        }

        if ($this->user->getId() == $ownerId) {
            return true;
        }

        $ownerObj = $this->userRepository->find($ownerId);

        if (in_array($this->user->getId(), $geotag->getPermittedUsers())) {
            return true;
        }
        $permittedCircleIds = $geotag->getPermittedCircles();

        foreach ($ownerObj->getCircles() as $circle) {

            if (in_array($circle->getId(), $permittedCircleIds)) {

                if (in_array($this->user->getId(), $circle->getFriends())) {
                    return true;
                }
            }
        }
        return false;
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
    public function likeById($id, $type = self::DEFAULT_CONTENT_TYPE)
    {
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
    public function unlikeById($id, $type = self::DEFAULT_CONTENT_TYPE)
    {
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
    public function getLikesById($id, $type = self::DEFAULT_CONTENT_TYPE)
    {
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

    /**
     * POST /report
     *
     * @throws \Exception\ResourceNotFoundException
     * @return \Symfony\Component\HttpFoundation\Response
     */

    public function sentReport()
    {

        $data = $this->request->request->all();
        $message = "objectType: " . $data['objectType'] . " objectId: " . $data['objectId'];
        EmailHelper::sendMail("islam.rafiqul@genweb2.com", $message);

        $this->response->setContent(json_encode(array('message' => "Report sent!")));
        $this->response->setStatusCode(Status::OK);

        return $this->response;
    }
}

<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;

use Repository\PlaceRepo as placeRepository;
use Helper\Status;
use Helper\AppMessage as AppMessage;

/**
 * Manage geo position related resources. ie - places and geotags
 */
class Place extends Base
{
    /**
     * This can be object of place repository or geotag repository
     * @var placeRepository
     */
    private $LocationMarkRepository;

    public function init()
    {
        parent::init();

        $this->messageRepository = $this->dm->getRepository('Document\Message');
        $this->messageRepository->setConfig($this->config);

        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->_updatePulse();

        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);

        $this->_ensureLoggedIn();
    }

    /**
     * GET /places
     *
     * Retrieve all places from current user. Using "start" and "limit"
     * parameters this list could be controlled.
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function index($type = 'place')
    {
        $start = $this->request->get('start', 0);
        $limit = $this->request->get('limit', 200);
        $location = $this->user->getCurrentLocation();

        $this->_initRepository($type);

        $places = $this->LocationMarkRepository->getAll($limit, $start);

        if (!empty($places)) {
            $permittedDocs = $this->_filterByPermission($places);
            $data = $this->_toArrayAll($permittedDocs);
            $i = 0;
            foreach ($data as $photoUrl) {
                $this->addOwnerInfo($data[$i]);
                $data[$i]['photo'] = \Helper\Url::buildPlacePhotoUrl($photoUrl);
                if (is_null($data[$i]['photo'])) {
                    $data[$i]['photo'] = $this->addStreetViewPhotoIfNoPhotoPresent($data[$i]);
                }

                if (!empty($location['lat']) && !empty($location['lng'])) {
                    $data[$i]['distance'] = \Helper\Location::distance($location['lat'], $location['lng'], $data[$i]['location']['lat'], $data[$i]['location']['lng']);
                }

                $i++;
            }

            return $this->_generateResponse($data);
        } else {
            return $this->_generateResponse(array('message' => 'No places found'), Status::NO_CONTENT);
        }
    }

    /**
     * GET /places/{id}
     *
     * Retrieve a specific place by it's id
     *
     * @param $id  place id
     * @param $type
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getById($id, $type = 'place')
    {
        $this->_initRepository($type);
        $place = $this->LocationMarkRepository->find($id);

        if (null !== $place) {
            if ($place->isPermittedFor($this->user)) {
                $place = $place->toArray();
                $place['photo'] = \Helper\Url::buildPlacePhotoUrl($place);
                if (is_null($place['photo'])) {
                    $place['photo'] = $this->addStreetViewPhotoIfNoPhotoPresent($place);
                }
                $this->addOwnerInfo($place);
                return $this->_generateResponse($place);
            } else {
                return $this->_generateForbidden('Not permitted for you');
            }
        } else {
            return $this->_generate404();
        }
    }

    /**
     * GET /geotags/all
     *
     * Retrieve all places with in a specific geo radius.
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function search($type)
    {
        $this->_initRepository($type);
        $lng = $this->request->get('lng');
        $lat = $this->request->get('lat');
        $geoTags = $this->LocationMarkRepository->search($this->user, $lng, $lat);

        if ($geoTags) {
            return $this->_generateResponse($geoTags);
        } else {
            return $this->_generateResponse(null, Status::NO_CONTENT);
        }
    }

    /**
     * GET /me/places
     *
     * Retrieve all places from current user
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getByCurrentUser($type = 'place')
    {
        $this->_initRepository($type);
        $places = $this->LocationMarkRepository->getByUser($this->user);
        $this->addPhoto($places);

        foreach ($places as &$place) {
            $this->addOwnerInfo($place);
        }

        if ($places) {
            return $this->_generateResponse($places);
        } else {
            return $this->_generateResponse(null, Status::NO_CONTENT);
        }
    }

    /**
     * GET /users/{userId}/places
     *
     * Retrieve all places by the given user id
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getByUser($userId, $type = 'place')
    {
        $user = $this->userRepository->find($userId);

        if (is_null($user) || empty($user))
            return $this->_generateResponse(null, Status::NO_CONTENT);

        $this->_initRepository($type);
        $places = $this->LocationMarkRepository->getByUser($user);
        $this->addPhoto($places);

        foreach ($places as &$place) {
            $this->addOwnerInfo($place);
        }

        if ($places) {
            return $this->_generateResponse($places);
        } else {
            return $this->_generateResponse(null, Status::NO_CONTENT);
        }
    }


    private function addStreetViewPhotoIfNoPhotoPresent($place)
    {
        $key = $this->config['googlePlace']['apiKey'];
        $photoUrl =  \Helper\Url::buildStreetViewImage($key, $place['location'], $size= "320x130");
        return $photoUrl;
    }

    private function addPhoto(array &$places)
    {
        foreach ($places as &$place) {
            $place['photo'] = \Helper\Url::buildPlacePhotoUrl($place);
            if (is_null($place['photo'])) {
                $place['photo'] = $this->addStreetViewPhotoIfNoPhotoPresent($place);
            }
        }
    }

    private function addOwnerInfo(&$data)
    {
        $owner = $this->LocationMarkRepository->getOwnerByPlaceId($data['id']);
        $username = $owner->getUsername();
        if (empty($username)) $username = null;

        $data['owner'] = array(
            'id' => $owner->getId(),
            'firstName' => $owner->getFirstName(),
            'lastName' => $owner->getLastName(),
            'username' => $username,
            'avatar' => \Helper\Url::buildAvatarUrl(array('avatar' => $owner->getAvatar()))
        );
    }

    /**
     * POST /places
     *
     * Create new place
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function create($type = 'place')
    {
        $postData = $this->request->request->all();
        $this->_initRepository($type);

        try {
            if (empty($postData['title'])) {
                $this->response->setContent(json_encode(array('message' => 'Place title can not be empty.')));
                $this->response->setStatusCode(Status::BAD_REQUEST);
                return $this->response;
            }
            $place = $this->LocationMarkRepository->map($postData, $this->user);
            $this->LocationMarkRepository->insert($place);

            if (!empty($postData['photo'])) {
                $this->LocationMarkRepository->savePlacePhoto($place->getId(), $postData['photo']);
            }
            $postData = $place->toArray();
            $postData['photo'] = \Helper\Url::buildPlacePhotoUrl($postData);

        } catch (\Exception $e) {
            return $this->_generateException($e);
        }

        return $this->_generateResponse($postData, Status::CREATED);
    }

    /**
     * PUT /places/{id}
     *
     * Update an existing place
     *
     * @param $id
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function update($id, $type = 'place')
    {
        $postData = $this->request->request->all();
        $this->_initRepository($type);

        $place = $this->LocationMarkRepository->find($id);

        if (empty($place) || $place->getOwner() != $this->user) {
            return $this->_generateUnauthorized();
        }

        try {
            $place = $this->LocationMarkRepository->update($postData, $id);
            if (!empty($postData['photo'])) {
                $this->LocationMarkRepository->savePlacePhoto($place->getId(), $postData['photo']);
            }

            $postData = $place->toArray();
            $postData['photo'] = \Helper\Url::buildPlacePhotoUrl($postData);

            if ($place) {
                return $this->_generateResponse($postData);
            } else {
                return $this->_generateErrorResponse('Invalid request params');
            }

        } catch (\Exception $e) {
            return $this->_generateException($e);
        }
    }

    /**
     * DELETE /places/{id}
     *
     * Delete an existing place
     *
     * @param $id
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function delete($id, $type = 'place')
    {
        $this->_initRepository($type);

        try {
            $this->LocationMarkRepository->delete($id);
        } catch (\Exception $e) {
            $this->_generateException($e);
        }

        return $this->_generateResponse(array('message' => 'Deleted Successfully'));
    }

    private function _initRepository($type)
    {
        if ($type == 'geotag') {
            $this->LocationMarkRepository = $this->dm->getRepository('Document\Geotag');
        } else {
            $this->LocationMarkRepository = $this->dm->getRepository('Document\Place');
        }
    }

    /**
     * POST /recommend/{recommendType}/{id}
     *
     * Recommend a specific place
     *
     * @param $id
     * @param $recommendType
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function recommend($id, $recommendType, $type = 'place')
    {
        try {
            $this->_initRepository($type);
            $place = $this->LocationMarkRepository->find($id);
            $postData = $this->request->request->all();
            if (empty($postData['recipients'])) {
                $this->response->setContent(json_encode(array('message' => "Recipient is empty.")));
                $this->response->setStatusCode(Status::NOT_ACCEPTABLE);
                return $this->response;
            }

            if ($recommendType == "venue") {
                $metaType = "venue";
                $staticMsg = appMessage::RECOMMEND_VENUE_MESSAGE;
                if (empty($postData['metaTitle']) OR empty($postData['metaContent'])) {
                    $this->response->setContent(json_encode(array('message' => "Required field is empty.")));
                    $this->response->setStatusCode(Status::NOT_ACCEPTABLE);
                    return $this->response;
                }

                if (empty($postData['subject'])) {
                    $postData['subject'] = $postData['metaTitle'];
                }

                if (empty($postData['content'])) {
                    $postData['content'] = $this->_createPushMessage($postData['subject'], $staticMsg);
                }

                if (!empty($postData['metaContent']['note'])) {
                    $postData['content'] .= ". " . $postData['metaContent']['note'];
                }
            } elseif ($recommendType == "place") {
                $metaType = "place";
                $staticMsg = appMessage::RECOMMEND_PLACE_MESSAGE;

            } elseif ($recommendType == "geotag") {
                $metaType = "geotag";
                $staticMsg = appMessage::RECOMMEND_GEOTAG_MESSAGE;

            }
            else {
                $this->response->setContent(json_encode(array('message' => "Required field is empty.")));
                $this->response->setStatusCode(Status::NOT_ACCEPTABLE);
                return $this->response;
            }

            $recipients = $postData['recipients'];
            if (!empty($place)) {
                $createMetaData = array("id" => $place->getId(), "category" => $place->getCategory(), "title" => $place->getTitle(), "address" => $place->getLocation()->toArray());
                $postData['subject'] = $place->getTitle();
                $postData['content'] = $this->_createPushMessage($postData['subject'], $staticMsg);

                if (!empty($postData['metaContent']['note'])) {
                    $postData['content'] .= ". " . $postData['metaContent']['note'];
                }
            } else {
                $createMetaData = array("id" => $id, "content" => $postData['metaContent']);
            }

            $message = $this->messageRepository->map($postData, $this->user);
            $message->addReadStatusFor($this->user);
            $message->setMetaType($metaType);
            $message->setMetaTitle($postData['subject']);
            $message->setMetaContent($createMetaData);
            $getResponse = $this->messageRepository->insert($message);

            // Don't put it before insert operation. this is intentional
            $message->setStatus('read');

            if (!empty($recipients)) {
                $this->_sendPushNotification(
                    array($recipients), $this->_createPushMessage($postData['subject'], $staticMsg),
                    $staticMsg, $id
                );

            }

            $this->response->setContent(json_encode(array("message" => "Message Sent Successfully.")));
            $this->response->setStatusCode(Status::CREATED);

        } catch (\Exception $e) {
            $this->_generate500($e->getMessage());
        }

        return $this->response;
    }

    /**
     * POST  /places/recommend/fbcheckin/{id}
     *
     * Recommend a specific place and share over facebook
     *
     * @param $id
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function recommendPlaceFbCheckin($id, $type = 'place')
    {
        try {
            $this->_initRepository($type);
            $place = $this->LocationMarkRepository->find($id);
            $postData = $this->request->request->all();
            if (empty($data['facebookAuthToken']) OR (empty($data['facebookId']))) {
                $this->response->setContent(json_encode(array('message' => "Required field 'facebookId' and/or 'facebookAuthToken' not found.")));
                $this->response->setStatusCode(Status::NOT_ACCEPTABLE);
                return $this->response;
            }
            $recipients = $postData['recipients'];
            $createMetaData = array("id" => $place->getId(), "category" => $place->getCategory(), "title" => $place->getTitle(), "address" => $place->getLocation()->toArray());

            $message = $this->messageRepository->map($postData, $this->user);
            $message->addReadStatusFor($this->user);
            $message->setPlaceRecommend($createMetaData);
            $getResponse = $this->messageRepository->insert($message);

            // Don't put it before insert operation. this is intentional
            $message->setStatus('read');

            if (!empty($recipients)) {
                $this->_sendPushNotification(
                    array($recipients), $this->_createPushMessage($place->getTitle(), 'test'),
                    AppMessage::RECOMMEND_VENUE_MESSAGE, $place->getId()
                );

            }

            $this->response->setContent(json_encode(array("message" => "Message Sent Successfully.")));
            $this->response->setStatusCode(Status::CREATED);

        } catch (\Exception $e) {
            $this->_generate500($e->getMessage());
        }

        return $this->response;
    }

    private function _createPushMessage($metaTitle, $staticMsg)
    {
        return AppMessage::getMessage($staticMsg, $this->user->getUsernameOrFirstName(), $metaTitle);

    }
}
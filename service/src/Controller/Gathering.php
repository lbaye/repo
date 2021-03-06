<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;

use Document\User;
use Repository\GatheringRepo as gatheringRepository;
use Helper\Status;
use Helper\ShareConstant;

/**
 * Base class for 'meetup', 'event' and 'place' resources.
 */
class Gathering extends Base
{

    const TYPE_MEETUP = 'meetup';
    const TYPE_EVENT = 'event';
    const TYPE_PLAN = 'plan';

    /**
     * @var gatheringRepository
     */
    private $gatheringRepository;

    public function init()
    {
        parent::init();

        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->_updatePulse();
        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);

        $this->_ensureLoggedIn();
        $this->createLogger('Controller::Gathering');
    }

    /**
     * GET /meetups
     * GET /events
     * GET /plans
     *
     * Retrieve all objects
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */

    public function index($type)
    {
        $start = (int)$this->request->get('start', 0);
        $limit = (int)$this->request->get('limit', 20);
        $this->_initRepository($type);
        $gatheringObjs = $this->gatheringRepository->getAll($limit, $start);
        $key = $this->config['googlePlace']['apiKey'];

        if (!empty($gatheringObjs)) {
            $permittedDocs = $this->_filterByPermission($gatheringObjs);
            $data = $this->_toArrayAll($permittedDocs);

            if ($type == self::TYPE_PLAN) {
                foreach ($data as &$plan_data) {
                    $plan_data = $this->gatheringRepository->planToArray($plan_data, $key);
                }
            }

            return $this->_generateResponse($data);
        } else {
            return $this->_generateResponse(array('message' => 'No meetups found'), Status::NO_CONTENT);
        }
    }

    /**
     * GET /meetups
     *
     * Retrieve all active gatherings
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */

    public function getActiveEvent($type)
    {
        $start = (int)$this->request->get('start', 0);
        $limit = (int)$this->request->get('limit', 20);
        $this->_initRepository($type);
        $gatheringObjs = $this->gatheringRepository->getAllActiveEvent($limit, $start);

        if (!empty($gatheringObjs)) {
            $permittedDocs = $this->_filterByPermission($gatheringObjs);
            return $this->_generateResponse($this->_toArrayAll($permittedDocs));
        } else {
            return $this->_generateResponse(array('message' => 'No active meetups found'), Status::NO_CONTENT);
        }
    }

    /**
     * GET /meetups/{id}
     * GET /events/{id}
     * GET /plans/{id}
     *
     * Retrieve gathering by the specific id
     *
     * @param $id
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getById($id, $type)
    {
        $this->_initRepository($type);
        $gathering = $this->gatheringRepository->find($id);
        $key = $this->config['googlePlace']['apiKey'];

        if (null !== $gathering) {
            if ($gathering->isPermittedFor($this->user)) {

                $data = $gathering->toArrayDetailed();

                $data['my_response'] = $gathering->getUserResponse($this->user->getId());
                $data['is_invited'] = in_array($this->user->getId(), $gathering->getGuests());

                $guests['users'] = $this->_getUserSummaryList($data['guests']['users']);
                $guests['circles'] = $data['guests']['circles'];
                $data['guests'] = $guests;

                if (!empty($data['eventImage'])) {
                    $data['eventImage'] = \Helper\Url::buildEventPhotoUrl($data);
                } else {
                    $data['eventImage'] = \Helper\Url::buildStreetViewImage($key, $data['location']);
                }

                $ownerDetail = $this->_getUserSummaryList(array($gathering->getOwner()->getId()));
                $data['ownerDetail'] = $ownerDetail[0];

                if ($type == self::TYPE_PLAN)
                    $data = $this->gatheringRepository->planToArray($data, $key);

                return $this->_generateResponse($data);

            } else {
                return $this->_generateForbidden('Not permitted for you');
            }
        } else {
            return $this->_generate404();
        }
    }

    /**
     * GET /me/meetups
     * GET /me/events
     *
     * Retrieve gatherings from the current user
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getByCurrentUser($type)
    {
        return $this->getByUser($this->user, $type);
    }

    /**
     * GET /user/{userId}/meetups
     *
     * Retrieve gatherings by specific user
     *
     * @param $user  String|Object
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getByUser($user, $type)
    {
        $key = $this->config['googlePlace']['apiKey'];
        $this->_initRepository($type);

        if (is_string($user)) {
            $user = $this->userRepository->find($user);
        }

        if ($user instanceof \Document\User) {
            $gatherings = $this->gatheringRepository->getByUser($user);

            if ($gatherings) {
                foreach ($gatherings as &$gathering) {
                    if ($type == self::TYPE_PLAN) {
                        $gathering = $this->gatheringRepository->planToArray($gathering, $key);
                    } else {
                        if (!empty($gathering['eventImage'])) {
                            $gathering['eventImage'] = \Helper\Url::buildEventPhotoUrl($gathering);
                        } else {
                            $gathering['eventImage'] = \Helper\Url::buildStreetViewImage($key, $gathering['location']);

                        }
                    }
                }
                return $this->_generateResponse($gatherings);
            } else {
                return $this->_generateResponse(null, Status::NO_CONTENT);
            }
        }

        return $this->_generateErrorResponse('Invalid user');
    }

    /**
     * POST /events
     * POST /meetups
     *
     * Create new gathering
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function create($type)
    {
        $key = $this->config['googlePlace']['apiKey'];
        $formData = $this->request->request->all();
        $this->_initRepository($type);

        # Check valid date format
        if (!$this->isValidDateFormat($type, $formData))
            return $this->_generateErrorResponse('Date format must be in GMT format!');

        try {
            # Set formatted time if meetup request
            if ($type === self::TYPE_MEETUP)
                $formData['time'] = date('Y-m-d h:i:s a', time());

            # Store gathering object
            $gathering = $this->storeGathering($formData, $this->user, $type);

        } catch (\Exception $e) {
            return $this->_generateException($e);
        }

        # Send push or in app notifications
        if (!empty($formData['guests'])) $this->sendNotification($type, $gathering, $formData['guests']);

        # Build absolute event image url
        $data = $gathering->toArrayDetailed();
        if (!empty($data['eventImage'])) $data['eventImage'] = \Helper\Url::buildEventPhotoUrl($data);

        if ($type == self::TYPE_PLAN)
            $data = $this->gatheringRepository->planToArray($data, $key);

        return $this->_generateResponse($data, Status::CREATED);
    }

    private function isValidDateFormat($type, $formData)
    {
        if ($type === self::TYPE_EVENT && isset($formData['time']))
            if (count(preg_split('/\s+|\t/', $formData['time'])) < 3) return false;

        return true;
    }

    private function storeGathering(array $postData, \Document\User $user, $type = null)
    {
        $gathering = $this->gatheringRepository->map($postData, $user, null, $type);
        $this->gatheringRepository->insert($gathering);

        if (!empty($postData['eventImage']))
            $this->gatheringRepository->saveEventImage($gathering->getId(), $postData['eventImage']);

        if (empty($postData['guestsCanInvite'])) $gathering->setGuestsCanInvite(0);

        return $gathering;
    }

    private function sendNotification($type, $gathering, $guestsIds)
    {
        $eventGuests = $this->userRepository->getAllByIds($guestsIds, false);
        $pushMessageType = $this->decidePushMessageType($type);
        $pushNotificationText = $this->createInvitationText($type, $this->user, $gathering);

        # Build notification data
        $notificationData = array(
            'title' => $pushNotificationText,
            'message' => $pushNotificationText,
            'objectId' => $gathering->getId(),
            'objectType' => $pushMessageType,
        );

        $this->debug(sprintf('Sending push 111 notification with - %s', json_encode($notificationData)));
        $this->debug(sprintf('Sending push 111 notification: %s', $pushNotificationText));

        # Send in app push notification
        \Helper\Notification::send($notificationData, $eventGuests);

        # Send device push notification
        $this->_sendPushNotification($guestsIds, $pushNotificationText, $pushMessageType, $gathering->getId());
    }

    private function decidePushMessageType($type)
    {
        switch ($type) {
            case self::TYPE_EVENT :
                return \Helper\AppMessage::EVENT_GUEST_REQUEST;

            case self::TYPE_MEETUP :
                return \Helper\AppMessage::MEETUP_REQUEST;
        }
    }

    /**
     * PUT /events/{id}
     * PUT /meetups/{id}
     *
     * Update an existing gathering object
     *
     * @param $id
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function update($id, $type)
    {
        $key = $this->config['googlePlace']['apiKey'];
        $this->_initRepository($type);

        $postData = $this->request->request->all();
        $gathering = $this->gatheringRepository->find($id);

        if ($gathering === null) {
            return $this->_generate404();
        }

        $this->debug(sprintf('Updating gathering - %s', $gathering->getTitle()));

        if ($gathering->getOwner() != $this->user) {

            if ($gathering->getGuestsCanInvite() && in_array($this->user->getId(), $gathering->getGuests())) {
                $this->debug('`Guest can invite` option is enabled.');

                if (!empty($postData['guests'])) {
                    $this->debug('Inviting new guests if found');
                    $this->inviteNewGuests($type, $gathering, $postData['guests']);

                    # Persist new change
                    $this->gatheringRepository->addGuests($postData['guests'], $gathering);
                }

                return $this->_generateResponse(array('message' => 'New guests has been added'));
            } else {
                $this->warn('Unauthorized access attempt.');
                return $this->_generateUnauthorized('You do not have permission to edit this ' . $type);
            }
        }

        if (!empty($postData['invitedCircles'])) {
            $this->debug('Inviting more circles');
            $this->gatheringRepository->addCircles($postData['invitedCircles'], $gathering);
        }

        try {

            if (count(@$postData['guests']) > 0) {
                $this->debug('Inviting new guests if found');
                $this->inviteNewGuests($type, $gathering, $postData['guests']);
            }

            $place = $this->gatheringRepository->update($postData, $gathering, $type);

            if (!empty($postData['eventImage'])) {
                $this->debug('Updating event image');
                $this->gatheringRepository->saveEventImage($place->getId(), $postData['eventImage']);
            }


        } catch (\Exception $e) {
            $this->error(sprintf('Failed to update gathering - %s', $e->getMessage()));
            return $this->_generateException($e);
        }

        $data = $place->toArrayDetailed();

        $guests['users'] = $this->_getUserSummaryList($data['guests']['users']);
        $guests['circles'] = $data['guests']['circles'];
        $data['guests'] = $guests;

        if (!empty($data['eventImage'])) {
            $data['eventImage'] = \Helper\Url::buildEventPhotoUrl($data);
        }
        if ($type == self::TYPE_PLAN)
            $data = $this->gatheringRepository->planToArray($data, $key);

        return $this->_generateResponse($data);
    }

    private function inviteNewGuests($type, \Document\Gathering $gathering, $guestsIds)
    {
        $this->debug(sprintf('Checking new guest for - %s', $gathering->getTitle()));
        $newGuestsIds = $this->determineNewGuests($gathering, $guestsIds);

        if (count($newGuestsIds) > 0) {
            $this->debug(sprintf('New guests found - %s', json_encode($newGuestsIds)));
            $this->sendNotification($type, $gathering, $newGuestsIds);
        } else
            $this->debug('No new guest found');

    }

    private function determineNewGuests(\Document\Gathering $gathering, $guestsIds)
    {
        return array_diff($guestsIds, $gathering->getGuests());
    }

    /**
     * DELETE /events/{id}
     * DELETE /meetups/{id}
     *
     * Delete an existing gathering object
     *
     * @param $id
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function delete($id, $type)
    {
        $this->_initRepository($type);

        $gathering = $this->gatheringRepository->find($id);

        if ($gathering === null) {
            return $this->_generate404();
        }

        if ($gathering->getOwner() != $this->user) {
            return $this->_generateUnauthorized('You do not have permission to edit this ' . $type);
        }

        try {
            $this->gatheringRepository->delete($id);

        } catch (\Exception $e) {
            return $this->_generateException($e);
        }

        return $this->_generateResponse(array('message' => 'Deleted Successfully'));
    }

    private function _initRepository($type)
    {
        if ($type == 'event') {
            $this->gatheringRepository = $this->dm->getRepository('Document\Event');
        } else if ($type == 'meetup') {
            $this->gatheringRepository = $this->dm->getRepository('Document\Meetup');
        } else if ($type == 'plan') {
            $this->gatheringRepository = $this->dm->getRepository('Document\Plan');
        }
    }

    /**
     * PUT /events/{id}/rsvp
     * PUT /meetups/{id}/rsvp
     *
     * Store user's RSVP for the specific gathering
     *
     * @param $id
     * @param $type
     *
     * @internal param $response
     * @return \Symfony\Component\HttpFoundation\Response
     */

    public function setRsvp($id, $type)
    {
        $this->_initRepository($type);

        $gathering = $this->gatheringRepository->find($id);

        $userRsvp = $gathering->getUserResponse($this->user->getId());
        $rsvp = $gathering->getRsvp();

        if (!empty($userRsvp)) {
            $key = array_search($this->user->getId(), $rsvp[$userRsvp]);
            unset($rsvp[$userRsvp][$key]);
        }
        $response = $this->request->get('response');
        array_push($rsvp[$response], $this->user->getId());

        $gathering->setRsvp($rsvp);
        $this->dm->persist($gathering);
        $this->dm->flush();

        return $this->_generateResponse($gathering->toArray());
    }

    /**
     * POST /events/{id}/share
     * POST /meetups/{id}/share
     * POST /plans/{id}/share
     *
     * Share gathering with the specific friends
     *
     * @param $id
     * @param $type
     *
     * @internal param $response
     * @return \Symfony\Component\HttpFoundation\Response
     */

    public function share($id, $type)
    {
        $this->_initRepository($type);

        $postData = $this->request->request->all();
        $gathering = $this->gatheringRepository->find($id);

        $users = $this->userRepository->getAllByIds($postData['users'], false);

        $notification = new \Document\Notification();
        $notificationData = array(
            'title' => $this->user->getName() . " shared an {$type} Request",
            'message' => "{$this->user->getName()} has created {$gathering->getTitle()}. He wants you to check it out!",
            'objectId' => $gathering->getId(),
            'objectType' => $type,
        );

        \Helper\Notification::send($notificationData, $users);

        return $this->_generateResponse(array('message' => 'Shared successfully!'));
    }

    protected function _toArrayAll(array $results)
    {
        $key = $this->config['googlePlace']['apiKey'];
        $gatheringItems = array();
        foreach ($results as $gathering) {
            $gatheringItem = $gathering->toArray();
            $gatheringItem['event_type'] = $this->_checkGatheringType($gathering->getOwner());

            if ($this->user == $gathering->getOwner()) {
                $gatheringItem['my_response'] = 'yes';
            } else {
                $gatheringItem['my_response'] = $gathering->getUserResponse($this->user->getId());
            }

            if (in_array($this->user->getId(), $gathering->getGuests()))
                $gatheringItem['is_invited'] = true;

            if (!empty($gatheringItem['eventImage'])) {
                $gatheringItem['eventImage'] = \Helper\Url::buildEventPhotoUrl($gatheringItem);
            } else {
                $gatheringItem['eventImage'] = \Helper\Url::buildStreetViewImage($key, $gatheringItem['location']);
            }
            $ownerDetail = $this->_getUserSummaryList(array($gathering->getOwner()->getId()));
            $gatheringItem['ownerDetail'] = $ownerDetail[0];

            $gatheringItems[] = $gatheringItem;
        }

        return $gatheringItems;
    }

    protected function _checkGatheringType($owner)
    {
        $friends = $this->_getFriendList($this->user);
        if ($owner->getId() == $this->user->getId()) {
            return "my_event";
        } elseif (in_array($this->user->getId(), $owner->getFriends())) {
            return "friends_event";
        } else {
            return "public_event";
        }
    }

    /**
     * GET /meetups/invited
     *
     * Retrieve list of invited members from the specific gathering
     *
     * @param $type
     * @internal param $response
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getInvitedMeetups($type)
    {
        $this->_initRepository($type);
        $gatheringObjs = $this->gatheringRepository->getInvitedMeetups($this->user->getId());
        $gatheringIMNotOwner = array();

        if (!empty($gatheringObjs)) {
            foreach ($gatheringObjs as $gathering) {

                if ($gathering->getOwner()->getId() != $this->user->getId()) {
                    $gatheringIMNotOwner[] = $gathering;
                }
            }

            return $this->_generateResponse($this->_toArrayAll($gatheringIMNotOwner));
        } else {
            return $this->_generateResponse(array('message' => 'No meetups found'), Status::NO_CONTENT);
        }

    }

    private function createInvitationText($type, \Document\User $user, \Document\Gathering $gathering)
    {
        if ($type == self::TYPE_EVENT)
            return \Helper\AppMessage::getMessage(
                \Helper\AppMessage::EVENT_GUEST_REQUEST,
                $user->getName(), $gathering->getTitle());
        else {
            $address = $gathering->getLocation()->getAddress();
            $addressTag = !empty($address) ? "at $address" : '';

            return \Helper\AppMessage::getMessage(
                \Helper\AppMessage::MEETUP_REQUEST,
                $user->getName(), $addressTag);
        }

    }


    /**
     * PUT /events/{id}/guests/
     *
     * Add new guest to the gathering
     *
     * @param $id
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function addGuests($id, $type)
    {
        $this->_initRepository($type);

        $postData = $this->request->request->all();
        $gathering = $this->gatheringRepository->find($id);

        if ($gathering === null) {
            return $this->_generate404();
        }

        if ($gathering->getOwner() != $this->user) {

            if ($gathering->getGuestsCanInvite() && in_array($this->user->getId(), $gathering->getGuests())) {
                if (!empty($postData['guests']))
                    $this->gatheringRepository->addGuests($postData['guests'], $gathering);

                if (!empty($postData['invitedCircles'])) {
                    $this->gatheringRepository->addGuestsFromCircleIds($this->user, $postData['invitedCircles'], $gathering);
                    $this->gatheringRepository->addCircles($postData['invitedCircles'], $gathering);
                }
                return $this->_generateResponse(array('message' => 'New guests has been added'));
            } else {
                return $this->_generateUnauthorized('You do not have permission to edit this ' . $type);
            }
        } else {

            if (!empty($postData['guests'])) {
                $this->gatheringRepository->addGuests($postData['guests'], $gathering);
            }

            if (!empty($postData['circleIds'])) {
                $this->gatheringRepository->addGuestsFromCircleIds($this->user, $postData['invitedCircles'], $gathering);
                $this->gatheringRepository->addCircles($postData['invitedCircles'], $gathering);
            }
            $data = $gathering->toArrayDetailed();
            $guests['users'] = $this->_getUserSummaryList($data['guests']['users']);
            $guests['circles'] = $data['guests']['circles'];
            $data['guests'] = $guests;
        }

        return $this->_generateResponse($data);
    }

    /**
     * GET //users/{user}/events
     *
     * Retrieve all active gatherings
     * @param $user  String|Object
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */

    public function getPermittedEvents($user, $type)
    {
        $getUserObjs = $this->userRepository->getByUserId($user);

        $start = (int)$this->request->get('start', 0);
        $limit = (int)$this->request->get('limit', 20);
        $this->_initRepository($type);
        $gatheringObjs = $this->gatheringRepository->getAllPermittedEvent($limit, $start);

        if (!empty($gatheringObjs)) {
            $permittedDocs = $this->_filterByPermissionForBothUsers($gatheringObjs,$getUserObjs);
            return $this->_generateResponse($this->_toArrayAll($permittedDocs));
        } else {
            return $this->_generateResponse(array('message' => 'No active Events found'), Status::NO_CONTENT);
        }
    }
}


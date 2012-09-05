<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;

use Document\User;
use Repository\GatheringRepo as gatheringRepository;
use Helper\Status;

class Gathering extends Base
{
    /**
     * @var gatheringRepository
     */
    private $gatheringRepository;

    /**
     * Initialize the controller.
     */
    public function init()
    {
        parent::init();

        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);

        $this->_ensureLoggedIn();
    }

    /**
     * GET /meetups
     * GET /events
     * GET /plans
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function index($type)
    {
        $start = (int)$this->request->get('start', 0);
        $limit = (int)$this->request->get('limit', 80);
        $this->_initRepository($type);
        $gatheringObjs = $this->gatheringRepository->getAll($limit, $start);

        if (!empty($gatheringObjs)) {
            $permittedDocs = $this->_filterByPermission($gatheringObjs);

            return $this->_generateResponse($this->_toArrayAll($permittedDocs));
        } else {
            return $this->_generateResponse(array('message' => 'No meetups found'), Status::NO_CONTENT);
        }
    }

    /**
     * GET /meetups/{id}
     * GET /events/{id}
     * GET /plans/{id}
     *
     * @param $id
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getById($id, $type)
    {
        $this->_initRepository($type);
        $gathering = $this->gatheringRepository->find($id);

        if (null !== $gathering) {
            if ($gathering->isPermittedFor($this->user)) {

                $data = $gathering->toArrayDetailed();
                $data['my_response'] = $gathering->getUserResponse($this->user->getId());
                $data['is_invited'] = in_array($this->user->getId(),$data['guests']);
                $data['guests'] = $this->_getUserSummaryList($data['guests']);
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
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getByCurrentUser($type)
    {
        return $this->getByUser($this->user, $type);
    }

    /**
     * GET /user/{userId}/places
     *
     * @param $user  String|Object
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getByUser($user, $type)
    {
        $this->_initRepository($type);

        if (is_string($user)) {
            $user = $this->userRepository->find($user);
        }

        if ($user instanceof \Document\User) {
            $gatherings = $this->gatheringRepository->getByUser($user);

            if ($gatherings) {
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
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function create($type)
    {
        $postData = $this->request->request->all();
        $this->_initRepository($type);

        try {
            $meetup = $this->gatheringRepository->map($postData, $this->user);
            $this->gatheringRepository->insert($meetup);

            if (!empty($postData['eventImage'])) {
                $this->gatheringRepository->saveEventImage($meetup->getId(), $postData['eventImage']);
            }

            if (empty($postData['guestsCanInvite'])) {
               $meetup->setGuestsCanInvite(0);
            }

        } catch (\Exception $e) {
            return $this->_generateException($e);
        }

        return $this->_generateResponse($meetup->toArrayDetailed(), Status::CREATED);
    }

    /**
     * PUT /places/{id}
     *
     * @param $id
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function update($id, $type)
    {
        $this->_initRepository($type);

        $postData = $this->request->request->all();
        $gathering = $this->gatheringRepository->find($id);

        if ($gathering === null) {
            return $this->_generate404();
        }

        if ($gathering->getOwner() != $this->user) {

            if($gathering->getGuestsCanInvite() && in_array($this->user->getId(), $gathering->getGuests())){
                if(! empty($postData['guests']))
                    $this->gatheringRepository->addGuests($postData['guests'], $gathering);

                return $this->_generateResponse(array('message' => 'New guests has been added'));
            } else {
                return $this->_generateUnauthorized('You do not have permission to edit this ' . $type);
            }
        }

        try {
            $place = $this->gatheringRepository->update($postData, $gathering);

        } catch (\Exception $e) {
            return $this->_generateException($e);
        }

        return $this->_generateResponse($place->toArray());
    }

    /**
     * DELETE /places/{id}
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

        if (!empty($userRsvp)){
            $key = array_search($this->user->getId(), $rsvp[$userRsvp]);
            unset($rsvp[$userRsvp][$key]);
        }
        $response = $this->request->get('response');
        array_push($rsvp[$response],$this->user->getId());

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

        $notification  = new \Document\Notification();
        $notification->setTitle($this->user->getName() .' shared an Event.');
        $notification->setMessage("{$this->user->getName()} has created an event {$gathering->getTitle()}. He wants you to check it out!");
        $notification->setObjectId($id);
        $notification->setObjectType('event');
        $notification->setPhotoUrl($this->user->getAvatar());

        foreach($postData['users'] as $user) {
            $receiver = $this->userRepository->find($user);
            if($receiver) {
                $receiver->addNotification(clone $notification);
                $this->dm->persist($receiver);
            }
        }

        $this->dm->flush();

        return $this->_generateResponse(array('message' => 'Shared successfully!'));
    }

    protected function _toArrayAll(array $results)
    {
        $gatheringItems = array();
        foreach ($results as $place) {
            $gatheringItem = $place->toArray();
            $gatheringItem['event_type']  = $this->_checkGatheringType($place->getOwner());
            $gatheringItem['my_response'] = $place->getUserResponse($this->user->getId());
            $gatheringItem['is_invited']  = in_array($this->user->getId(), $place->getGuests());

            $gatheringItems[] = $gatheringItem;
        }

        return $gatheringItems;
    }

    protected function _checkGatheringType($owner)
    {
        $friends = $this->_getFriendList($this->user);

        if($owner == $this->user){
            return "my_event";
        }elseif(!empty($friends)){
            return "friends_event";
        }else{
            return "public_event";
        }

    }


}
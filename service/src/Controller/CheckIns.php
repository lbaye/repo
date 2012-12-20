<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;
use Helper\Status;
use Repository\UserRepo as userRepository;
use Repository\CheckInRepo as CheckInRepository;
use Document\CheckIn as CheckInDocument;
use Helper\Image as ImageHelper;

/**
 * Manage venue checkins related resources
 */
class CheckIns extends Base
{
    private $checkInRepo;

    public function init()
    {
        parent::init();

        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->checkInRepo = $this->dm->getRepository('Document\CheckIn');
        $this->_updatePulse();
        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);
        $this->_ensureLoggedIn();
    }

    /**
     * POST /checkins
     *
     * Create new checkin
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function create()
    {

        $postData = $this->request->request->all();
        $imageData = $postData['image'];

        $user = $this->user;
        $user->setUpdateDate(new \DateTime());
        $timeStamp = $user->getUpdateDate()->getTimestamp();

        # Ensure directory is created
        $dirPath = '/images/photos/checkins/' . $user->getId();

        if (!file_exists(ROOTDIR . "/" . $dirPath)) {
            mkdir(ROOTDIR . "/" . $dirPath, 0777, true);
        }

        $filePath = $dirPath . '/' . (time() * rand(100, 1000)) . '.jpg';
        $photoUrl = filter_var($imageData, FILTER_VALIDATE_URL);

        if ($photoUrl !== false) {
            $uri = $photoUrl;
        } else {
            ImageHelper::saveImageFromBase64($imageData, ROOTDIR . $filePath);
            $uri = $filePath . "?" . $timeStamp;
        }

        $postData['uri'] = $uri;

        $checkIn = $this->checkInRepo->map($postData, $this->user);
        $this->checkInRepo->insert($checkIn);

        return $this->_generateResponse($checkIn->toArray(), Status::CREATED);
    }

    /**
     * GET /checkins/{id}
     *
     * Retrieve checkin by the given id
     *
     * @param  $id
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function show($id)
    {
        $checkIn = $this->checkInRepo->find($id);
        if (empty($checkIn))
            return $this->_generateResponse(null, Status::NOT_FOUND);

        return $this->_generateResponse($checkIn->toArray(), Status::OK);
    }

    /**
     * PUT /checkins/{id}
     *
     * Update a specific checkin
     *
     * @param  $id
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function update($id)
    {
        $data = $this->request->request->all();
        $checkIn = $this->checkInRepo->find($id);

        if (empty($checkIn) || $checkIn->getOwner() != $this->user) {
            return $this->_generateUnauthorized();
        }
        try {
            $checkIn = $this->checkInRepo->update($data, $id);
        } catch (\Exception $e) {
            $this->_generateException($e);
        }

        return $this->_generateResponse($checkIn->toArray(), Status::OK);
    }

    /**
     * DELETE /checkins/{id}
     *
     * Delete a specific checkin
     *
     * @param  $id
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function delete($id)
    {
        $checkIn = $this->checkInRepo->find($id);

        if (empty($checkIn) || $checkIn->getOwner() != $this->user) {
            return $this->_generateUnauthorized();
        }

        try {
            $this->checkInRepo->delete($id);
        } catch (\Exception $e) {
            $this->_generateException($e);
        }
        return $this->_generateResponse(array('message' => 'Deleted Successfully'));
    }

    /**
     * GET /checkins/venue/{venue}
     * 
     * Retrieve checkins by the given venue
     *
     * @param  $venue
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getByVenue($venue)
    {
        $checkIns = $this->checkInRepo->getByVenue($venue);

        if (count($checkIns) > 0) {
            return $this->_generateResponse($this->_toArrayAll($checkIns->toArray()));
        } else {
            return $this->_generateResponse(null, Status::NO_CONTENT);
        }
    }

    /**
     * GET /checkins/venue_type/{venue_type}
     *
     * Retrieve checkins by specific venue type
     *
     * @param  $venue_type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getByVenueType($venue_type)
    {
        $checkIns = $this->checkInRepo->GetByVenueType($venue_type);

        if (count($checkIns) > 0) {
            return $this->_generateResponse($this->_toArrayAll($checkIns->toArray()));
        } else {
            return $this->_generateResponse(null, Status::NO_CONTENT);
        }
    }
}
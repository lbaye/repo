<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;
use Helper\Status;
use Repository\UserRepo as userRepository;
use Repository\ReviewRepo as ReviewRepository;
use Document\Review as Review;

class Reviews extends Base
{
    private $reviewRepo;

    public function init()
    {
        parent::init();

        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->reviewRepo = $this->dm->getRepository('Document\Review');
        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);
        $this->_ensureLoggedIn();
    }


    public function index()
    {
        echo "hi++++++++++++++++";
    }
    public function create()
    {
        $postData = $this->request->request->all();

        $review = $this->reviewRepo->map($postData, $this->user);
        $this->reviewRepo->insert($review);

        return $this->_generateResponse($review->toArray(), Status::CREATED);
    }

    public function show($id)
    {
        $review = $this->reviewRepo->find($id);
        if (empty($review))
            return $this->_generateResponse(null, Status::NOT_FOUND);

        return $this->_generateResponse($review->toArray(), Status::OK);
    }

    public function update($id)
    {
        $data = $this->request->request->all();
        $review = $this->reviewRepo->find($id);

        if (empty($review) || $review->getOwner() != $this->user) {
            return $this->_generateUnauthorized();
        }
        try {
            $review = $this->reviewRepo->update($data, $id);
        } catch (\Exception $e) {
            $this->_generateException($e);
        }

        return $this->_generateResponse($review->toArray(), Status::OK);
    }

    public function delete($id)
    {
        $review = $this->reviewRepo->find($id);

        if (empty($review) || $review->getOwner() != $this->user) {
            return $this->_generateUnauthorized();
        }

        try {
            $this->reviewRepo->delete($id);
        } catch (\Exception $e) {
            $this->_generateException($e);
        }
        return $this->_generateResponse(array('message' => 'Deleted Successfully'));
    }

    public function getByVenue($venue)
    {
        $review = $this->reviewRepo->getByVenue($venue);

        if (count($review) > 0) {
            return $this->_generateResponse($this->_toArrayAll($review->toArray()));
        } else {
            return $this->_generateResponse(null, Status::NO_CONTENT);
        }
    }

    public function getByVenueType($venue_type)
    {
        $review = $this->reviewRepo->get_by_venue_type($venue_type);

        if (count($review) > 0) {
            return $this->_generateResponse($this->_toArrayAll($review->toArray()));
        } else {
            return $this->_generateResponse(null, Status::NO_CONTENT);
        }
    }
}
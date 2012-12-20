<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;
use Helper\Status;
use Repository\UserRepo as userRepository;
use Repository\ReviewRepo as ReviewRepository;
use Document\Review as Review;

/**
 * Manage reviews on different venues
 */
class Reviews extends Base
{
    private $reviewRepo;

    public function init()
    {
        parent::init();

        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->reviewRepo = $this->dm->getRepository('Document\Review');
        $this->_updatePulse();
        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);
        $this->_ensureLoggedIn();
    }

    /**
     * POST /reviews
     *
     * Create new review on a specific venue
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function create()
    {
        $postData = $this->request->request->all();
        $review = $this->reviewRepo->map($postData, $this->user);
        try {
        $this->reviewRepo->insert($review);
        } catch (\Exception $e){
            $this->response->setContent(json_encode(array('message' => 'Invalid request. Set all the required parameters.')));
            $this->response->setStatusCode(Status::NOT_ACCEPTABLE);
            return $this->response;
        }
        return $this->_generateResponse($review->toArray(), Status::CREATED);
    }

    /**
     * GET /reviews/{id}
     *
     * Retrieve an existing review
     *
     * @param  $id
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function show($id)
    {
        $review = $this->reviewRepo->find($id);
        if (empty($review))
            return $this->_generateResponse(null, Status::NOT_FOUND);

        return $this->_generateResponse($review->toArray(), Status::OK);
    }

    /**
     * PUT /reviews/{id}
     *
     * Update an existing review
     *
     * @param  $id
     * @return \Symfony\Component\HttpFoundation\Response
     */
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

    /**
     * DELETE /reviews/{id}
     *
     * Delete a specific review
     *
     * @param  $id
     * @return \Symfony\Component\HttpFoundation\Response
     */
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

    /**
     * GET /reviews/venue/{venue}
     *
     * Retrieve list of reviews from a specific venue
     *
     * @param  $venue
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getByVenue($venue)
    {
        $review = $this->reviewRepo->getByVenue($venue);

        if (count($review) > 0) {
            return $this->_generateResponse($this->_toArrayAll($review->toArray()));
        } else {
            return $this->_generateResponse(null, Status::NO_CONTENT);
        }
    }

    /**
     * GET /reviews/venue_type/{venue_type}
     *
     * Retrieve reviews by the specific venue type
     *
     * @param  $venue_type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getByVenueType($venue_type)
    {
        $review = $this->reviewRepo->GetByVenueType($venue_type);

        if (count($review) > 0) {
            return $this->_generateResponse($this->_toArrayAll($review->toArray()));
        } else {
            return $this->_generateResponse(null, Status::NO_CONTENT);
        }
    }
}
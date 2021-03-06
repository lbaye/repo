<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;
use Helper\Status;
use Repository\TrailRepo;


/**
 * Manage breadcrumbs and mapix related resources
 */
class TrailController extends \Controller\Base
{
    /**
     * @var $trailRepository
     */
    private $trailRepository;


    public function init()
    {
        $this->response = new Response();
        $this->response->headers->set('Content-Type', 'application/json');

        $this->userRepository = $this->dm->getRepository('Document\User');
        //$this->trailRepository = $this->dm->getRepository('Document\Trail');

        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);
        $this->_ensureLoggedIn();
    }

    private function _initRepository($type)
    {
        if ($type == 'mapix') {
            $this->trailRepository = $this->dm->getRepository('Document\MapixTrail');
        } else if ('breadcrumb') {
            $this->trailRepository = $this->dm->getRepository('Document\BreadcrumbTrail');
        }
    }


    /**
     * GET /mapixTrails/{id}
     * GET /breadcrumbs/{id}
     *
     * Retrieve trail by a specific id
     *
     * @param $id
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getById($id, $type)
    {
        $this->_initRepository($type);
        $trail = $this->trailRepository->find($id);

        if (null !== $trail) {
            $this->response->setContent(json_encode($trail->toArray()));
            $this->response->setStatusCode(Status::OK);
        } else {
            $this->response->setContent(json_encode(array('result' => Response::$statusTexts[404])));
            $this->response->setStatusCode(Status::NOT_FOUND);
        }

        return $this->response;
    }


    /**
     * POST /breadcrumbs
     * POST /mapixTrails
     *
     * Create new trail
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function create($type)
    {
        $this->_initRepository($type);
        $postData = $this->request->request->all();

        try {
            $trail = $this->trailRepository->map($postData, $this->user);
            $this->trailRepository->insert($trail);

            $this->response->setContent(json_encode($trail->toArray()));
            $this->response->setStatusCode(Status::CREATED);

        } catch (\Exception $e) {
            $this->response->setContent(json_encode(array('message' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }

        return $this->response;
    }


    /**
     * PUT /mapixTrails
     * PUT /breadcrumbs
     *
     * Update an existing trail
     *
     * @param $id
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function update($id, $type)
    {
        $this->_initRepository($type);
        $postData = $this->request->request->all();

        try {
            $trail = $this->trailRepository->update($postData, $id);

            $this->response->setContent(json_encode($trail->toArray()));
            $this->response->setStatusCode(Status::OK);

        } catch (\Exception $e) {
            $this->response->setContent(json_encode(array('message' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }

        return $this->response;
    }


    /**
     * DELETE /mapixTrails/{id}
     * DELETE /breadcrumbs/{id}
     *
     * Delete an existing trail
     *
     * @param $id
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function delete($id, $type)
    {
        $this->_initRepository($type);

        $trail = $this->trailRepository->find($id);

        if ($trail === null) {
            $this->response->setContent(json_encode(array('message' => $type . 'Trail not found')));
            $this->response->setStatusCode(Status::NOT_FOUND);
            return $this->response;
        }

        if ($trail->getOwner() != $this->user) {
            return $this->_generateUnauthorized('You do not have permission to edit this ' . $type);
        }


        try {
            $this->trailRepository->delete($id);

            $this->response->setContent(json_encode(array('message' => 'Deleted Successfully')));
            $this->response->setStatusCode(Status::OK);

        } catch (\Exception $e) {
            $this->response->setContent(json_encode(array('message' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }

        return $this->response;
    }


    /**
     * GET /mapixTrails
     * GET /breadcrumbs
     *
     * Retrieve all breadcrumbs
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function index($type)
    {
        $start = $this->request->get('start', 0);
        $limit = $this->request->get('limit', 20);
        $this->_initRepository($type);

        $trails = $this->trailRepository->getAll($limit, $start);

        if (!empty($trails)) {
            $this->response->setContent(json_encode($trails));
            $this->response->setStatusCode(Status::OK);
        } else {
            $this->response->setContent(json_encode(array('message' => 'No trails found')));
            $this->response->setStatusCode(Status::NO_CONTENT);
        }

        return $this->response;
    }


    /**
     * GET /mapixTrails
     * GET /breadcrumbs
     *
     * Retrieve all trails by current user
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getByCurrentUser($type)
    {
        $this->_initRepository($type);
        $trail = $this->trailRepository->getByUser($this->user);

        if ($trail) {
            $this->response->setContent(json_encode($trail));
            $this->response->setStatusCode(Status::OK);
        } else {
            $this->response->setContent(json_encode(array('result' => Response::$statusTexts[404])));
            $this->response->setStatusCode(Status::NOT_FOUND);
        }

        return $this->response;
    }

    /**
     * GET /mapixTrails
     * GET /breadcrumbs
     *
     * Retrieve all trails by the specific user
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getByUser($type)
    {
        $this->_initRepository($type);
        $this->response->setContent(json_encode(array('message' => 'Not implemented')));
        $this->response->setStatusCode(Status::NOT_IMPLEMENTED);

        return $this->response;
    }


    /**
     * POST /mapixTrails/share/{id}
     * POST /breadcrumbs/share/{id}
     *
     * Share a specific trail with friends and circles
     *
     * @param $id
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function share($id, $type)
    {
        $this->_initRepository($type);
        $postData = $this->request->request->all();
        $trail = $this->trailRepository->find($id);

        $users = $this->userRepository->getAllByIds($postData['users'], false);

        $notificationData = array(
            'title' => $this->user->getName() . " shared a trail",
            'message' => "{$this->user->getName()} has created {$trail->getTitle()}. Please check it out!",
            'objectId' => $trail->getId(),

        );

        \Helper\Notification::send($notificationData, $users);

        $this->response->setContent(json_encode(array('Trail' => 'Shared successfully!')));

        return $this->response;
    }

    /**
     * PUT /breadcrumbs/marker/{id}
     * PUT /mapixTrails/marker/{id}
     *
     * Add new marker to an existing trail
     *
     * @param $id
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function addMarker($id, $type)
    {

        $this->_initRepository($type);

        $postData = $this->request->request->all();
        $trail = $this->trailRepository->find($id);

        if ($trail === null) {
            return $this->_generate404();
        }

        $this->trailRepository->addMarker($postData, $id);

        $this->response->setContent(json_encode(array('Trail' => 'Marker added successfully!')));

        return $this->response;
    }

    /**
     * DELETE /breadcrumbs/marker/delete/{id}
     * DELETE /mapixTrails/marker/delete/{id}
     *
     * Delete an existing marker from a specific trail
     *
     * @param $id
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function deleteMarker($id, $type)
    {

        $this->_initRepository($type);
        $postData = $this->request->request->all();
        $trail = $this->trailRepository->find($id);

        if ($trail === null) {
            return $this->_generate404();
        }

        $this->trailRepository->deleteMarker($postData, $id);

        $this->response->setContent(json_encode(array('Trail' => 'Marker deleted successfully!')));

        return $this->response;
    }

    /**
     * PUT /breadcrumbs/photo/{id}
     * PUT /mapixTrails/photo/{id}
     *
     * Add new photo to a specific marker
     *
     * @param $id
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function addPhotoToMarker($id, $type)
    {
        $this->_initRepository($type);
        $postData = $this->request->request->all();
        $trail = $this->trailRepository->find($id);

        if ($trail === null) {
            return $this->_generate404();
        }

        $this->trailRepository->addPhotoToMarker($postData, $id);

        $this->response->setContent(json_encode(array('Trail' => 'Photo added successfully!')));

        return $this->response;
    }

    /**
     * PUT /breadcrumbs/photo/delete/{id}
     * PUT /mapixTrails/photo/delete/{id}
     *
     * Delete a specific photo from a specific marker
     *
     * @param $id
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function deletePhotoFromMarker($id, $type)
    {

        $this->_initRepository($type);
        $postData = $this->request->request->all();
        $trail = $this->trailRepository->find($id);

        if ($trail === null) {
            return $this->_generate404();
        }

        $this->trailRepository->deletePhotoFromMarker($postData, $id);

        $this->response->setContent(json_encode(array('Trail' => 'Photo deleted successfully!')));

        return $this->response;
    }

}

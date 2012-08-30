<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;

use Document\User;
use Repository\User as userRepository;
use Repository\Gathering as gatheringRepository;

class Gathering extends Base
{
    /**
     * @var gatheringRepository
     */
    private $gatheringRepository;

    /**
     * @var userRepository
     */
    private $userRepository;

    /**
     * Initialize the controller.
     */
    public function init()
    {
        $this->response = new Response();
        $this->response->headers->set('Content-Type', 'application/json');

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
        $start = $this->request->get('start', 0);
        $limit = $this->request->get('limit', 20);

        $this->_initRepository($type);
        $gatheringObjs = $this->gatheringRepository->getAll($limit, $start);

        if (!empty($gatheringObjs)) {
            $permittedDocs = $this->_filterByPermission($gatheringObjs);

            $this->response->setContent(json_encode($this->_toArrayAll($permittedDocs)));
            $this->response->setStatusCode(200);
        } else {
            $this->response->setContent(json_encode(array('message' => 'No meetups found')));
            $this->response->setStatusCode(204);
        }

        return $this->response;
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
                $this->response->setContent(json_encode($gathering->toArrayDetailed()));
                $this->response->setStatusCode(200);
            } else {
                $this->response->setContent(json_encode(array('message' => 'Not permitted for you')));
                $this->response->setStatusCode(403);
            }
        } else {
            $this->response->setContent(json_encode(array('result' => Response::$statusTexts[404])));
            $this->response->setStatusCode(404);
        }

        return $this->response;
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
                $this->response->setContent(json_encode($gatherings));
                $this->response->setStatusCode(200);
            } else {
                $this->response->setContent('[]'); // No content
                $this->response->setStatusCode(204);
            }
        } else {
            $this->response->setContent(json_encode(array('message' => 'Invalid user')));
            $this->response->setStatusCode(406);
        }

        return $this->response;
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

            $this->response->setContent(json_encode($meetup->toArrayDetailed()));
            $this->response->setStatusCode(201);

        } catch (\Exception $e) {
            $this->response->setContent(json_encode(array('message' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }

        return $this->response;
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

        if ($gathering === false) {
            $this->response->setContent(json_encode(array('message' => ucfirst($type) . ' not found')));
            $this->response->setStatusCode(404);

            return $this->response;
        }

        if ($gathering->getOwner() != $this->user) {
            $this->response->setContent(json_encode(array('message' => 'You do not have permission to edit this ' . $type)));
            $this->response->setStatusCode(401);

            return $this->response;
        }

        try {
            $place = $this->gatheringRepository->update($postData, $gathering);

            $this->response->setContent(json_encode($place->toArray()));
            $this->response->setStatusCode(200);

        } catch (\Exception $e) {
            $this->response->setContent(json_encode(array('message' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }

        return $this->response;
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

        if ($gathering === false) {
            $this->response->setContent(json_encode(array('message' => ucfirst($type) . ' not found')));
            $this->response->setStatusCode(404);

            return $this->response;
        }

        if ($gathering->getOwner() != $this->user) {
            $this->response->setContent(json_encode(array('message' => 'You do not have permission to edit this ' . $type)));
            $this->response->setStatusCode(401);

            return $this->response;
        }

        try {
            $this->gatheringRepository->delete($id);

            $this->response->setContent(json_encode(array('message' => 'Deleted Successfully')));
            $this->response->setStatusCode(200);

        } catch (\Exception $e) {
            $this->response->setContent(json_encode(array('message' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }

        return $this->response;
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
     * PUT /events/{id}/user/{user}/attend/
     *
     * @param $id
     * @param $user
     *
     * @param $type
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function willAttend($id, $user, $type)
    {
        $this->_initRepository($type);

        $gathering = $this->gatheringRepository->find($id);
        $postData = $this->request->request->all();

        if ($gathering === false) {
            $this->response->setContent(json_encode(array('message' => ucfirst($type) . ' not found')));
            $this->response->setStatusCode(404);

            return $this->response;
        }

        try {

            var_dump($gathering);die;

            $attend = $gathering->getWhoWillAttend();

            if ($this->request->getMethod() == 'GET') {
                return $this->returnResponse($attend);
            }

            $attendUser = array_merge($attend, $postData);
            $gathering->setWhoWillAttend($attendUser);

            return $this->persistAndReturn($attendUser);

        } catch (\Exception $e) {
            $this->response->setContent(json_encode(array('message' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }

        return $this->response;

    }

    private function persistAndReturn($result)
    {
        $this->dm->persist($this->user);
        $this->dm->flush();

        return $this->returnResponse($result);
    }

    private function returnResponse($result)
    {
        $this->response->setContent(json_encode(array('result' => $result)));
        $this->response->setStatusCode(200);

        return $this->response;
    }
}
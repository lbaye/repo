<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;

use Repository\User as userRepository;
use Repository\Breadcrumb as breadcrumbRepository;

class Breadcrumb extends Base
{
    /**
     * @var breadcrumbRepository
     */
    private $breadcrumbRepository;

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

        $this->userRepository  = $this->dm->getRepository('Document\User');
        $this->breadcrumbRepository = $this->dm->getRepository('Document\Breadcrumb');

        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);
        $this->_ensureLoggedIn();
    }

    /**
     * GET /breadcrumbs
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function index()
    {
        $start = $this->request->get('start', 0);
        $limit = $this->request->get('limit', 20);

        $breadcrumbs = $this->breadcrumbRepository->getAll($limit, $start);

        if (!empty($breadcrumbs)) {
            $this->response->setContent(json_encode($breadcrumbs));
            $this->response->setStatusCode(200);
        } else {
            $this->response->setContent(json_encode(array('message' => 'No breadcrumb found')));
            $this->response->setStatusCode(204);
        }

        return $this->response;
    }

    /**
     * GET /breadcrumbs/{id}
     *
     * @param $id  breadcrumb id
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getById($id)
    {

        $breadcrumb = $this->breadcrumbRepository->find($id);

        if (null !== $breadcrumb) {
            $this->response->setContent(json_encode($breadcrumb->toArray()));
            $this->response->setStatusCode(200);
        } else {
            $this->response->setContent(json_encode(array('result' => Response::$statusTexts[404])));
            $this->response->setStatusCode(404);
        }

        return $this->response;
    }

    /**
     * GET /me/breadcrumbs
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getByCurrentUser()
    {
        $breadcrumb = $this->breadcrumbRepository->getByUser($this->user);

        if ($breadcrumb) {
            $this->response->setContent(json_encode($breadcrumb));
            $this->response->setStatusCode(200);
        } else {
            $this->response->setContent(json_encode(array('result' => Response::$statusTexts[404])));
            $this->response->setStatusCode(404);
        }

        return $this->response;
    }

    /**
     * GET /user/{userId}/breadcrumbs
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getByUser()
    {
        $this->response->setContent(json_encode(array('message' => 'Not implemented')));
        $this->response->setStatusCode(501);

        return $this->response;
    }

    /**
     * POST /breadcrumbs
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function create()
    {
        $postData = $this->request->request->all();

        try {
            $breadcrumb = $this->breadcrumbRepository->map($postData, $this->user);
            $this->breadcrumbRepository->insert($breadcrumb);

            $this->response->setContent(json_encode($breadcrumb->toArray()));
            $this->response->setStatusCode(201);

        } catch (\Exception $e) {
            $this->response->setContent(json_encode(array('message' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }

        return $this->response;
    }

    /**
     * PUT /breadcrumbs/{id}
     *
     * @param $id
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function update($id)
    {
        $postData = $this->request->request->all();

        try {
            $breadcrumb = $this->breadcrumbRepository->update($postData, $id);

            $this->response->setContent(json_encode($breadcrumb->toArray()));
            $this->response->setStatusCode(200);

        } catch (\Exception $e) {
            $this->response->setContent(json_encode(array('message' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }

        return $this->response;
    }

     /**
     * PUT /breadcrumbs/{id}
     *
     * @param $id
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function addPhoto($id)
    {
        $postData = $this->request->request->all();

        try {
            $breadcrumb = $this->breadcrumbRepository->addPhoto($postData, $id);

            $this->response->setContent(json_encode($breadcrumb->toArray()));
            $this->response->setStatusCode(200);

        } catch (\Exception $e) {
            $this->response->setContent(json_encode(array('message' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }

        return $this->response;
    }

    /**
     * DELETE /breadcrumbs/{id}
     *
     * @param $id
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function delete($id)
    {
        try {
            $this->breadcrumbRepository->delete($id);

            $this->response->setContent(json_encode(array('message' => 'Deleted Successfully')));
            $this->response->setStatusCode(200);

        } catch (\Exception $e) {
            $this->response->setContent(json_encode(array('message' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }

        return $this->response;
    }

}
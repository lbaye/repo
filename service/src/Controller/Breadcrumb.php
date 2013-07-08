<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;

use Repository\UserRepo as userRepository;
use Repository\BreadcrumbRepo as breadcrumbRepository;
use Helper\Status;

/**
 * Manage breadcrumbs
 * @ignore
 */
class Breadcrumb extends Base
{
    /**
     * @var breadcrumbRepository
     */
    private $breadcrumbRepository;


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
     * Generate list of breadcrumbs, Specify 'start' or 'limit' parameters to limit number of rows.
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
            $this->response->setStatusCode(Status::OK);
        } else {
            $this->response->setContent(json_encode(array('message' => 'No breadcrumb found')));
            $this->response->setStatusCode(Status::NO_CONTENT);
        }

        return $this->response;
    }

    /**
     * GET /breadcrumbs/{id}
     *
     * Retrieve breadcrumb by given id
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
            $this->response->setStatusCode(Status::OK);
        } else {
            $this->response->setContent(json_encode(array('result' => Response::$statusTexts[404])));
            $this->response->setStatusCode(Status::NOT_FOUND);
        }

        return $this->response;
    }

    /**
     * GET /me/breadcrumbs
     *
     * Retrieve list of current user owned breadcrumbs
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getByCurrentUser()
    {
        $breadcrumb = $this->breadcrumbRepository->getByUser($this->user);

        if ($breadcrumb) {
            $this->response->setContent(json_encode($breadcrumb));
            $this->response->setStatusCode(Status::OK);
        } else {
            $this->response->setContent(json_encode(array('result' => Response::$statusTexts[404])));
            $this->response->setStatusCode(Status::NOT_FOUND);
        }

        return $this->response;
    }

    /**
     * GET /user/{userId}/breadcrumbs
     *
     * Retrieve breadcrumbs from the specified user
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getByUser()
    {
        $this->response->setContent(json_encode(array('message' => 'Not implemented')));
        $this->response->setStatusCode(Status::NOT_IMPLEMENTED);

        return $this->response;
    }

    /**
     * POST /breadcrumbs
     *
     * Create new breadcrumb
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
            $this->response->setStatusCode(Status::CREATED);

        } catch (\Exception $e) {
            $this->response->setContent(json_encode(array('message' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }

        return $this->response;
    }

    /**
     * PUT /breadcrumbs/{id}
     *
     * Update an existing breadcrumb
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
            $this->response->setStatusCode(Status::OK);

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
            $this->response->setStatusCode(Status::OK);

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
            $this->response->setStatusCode(Status::OK);

        } catch (\Exception $e) {
            $this->response->setContent(json_encode(array('message' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }

        return $this->response;
    }

}
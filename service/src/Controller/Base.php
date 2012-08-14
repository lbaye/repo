<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Doctrine\ODM\MongoDB\DocumentManager;

abstract class Base
{
    /**
     * @var \Symfony\Component\HttpFoundation\Request
     */
    protected $request;

    /**
     * @var \Doctrine\ODM\MongoDB\DocumentManager
     */
    protected $dm;

    /**
     * @var \Symfony\Component\HttpFoundation\Response;
     */
    protected $response;

    /**
     * @var array
     */
    protected $config;

    /**
     * @var \Document\User
     */
    protected $user;

    /**
     * Inject the Request object for further use.
     *
     * @param \Symfony\Component\HttpFoundation\Request $request
     */
    public function setRequest($request)
    {
        $this->request = $request;
    }

    /**
     * Inject the DocumentManager for further communication with MongoDB.
     *
     * @param \Doctrine\ODM\MongoDB\DocumentManager $dm
     */
    public function setDocumentManager($dm)
    {
        $this->dm = $dm;
    }

    /**
     * Load the requesting user's object if provided in the header.
     */
    public function setSessionUser()
    {
        if ($this->request->headers->has('Auth-Token')) {
            $authToken  = $this->request->headers->get('Auth-Token');
            $this->user = $this->dm->getRepository('Document\User')->getByAuthToken($authToken);
        }
    }

    /**
     * Inject the configuration.
     *
     * @param $config array
     */
    public function setConfiguration($config)
    {
        $this->config = $config;
    }

    /**
     * Initializer function to be used by child classes.
     */
    public function init()
    {
    }

    /**
     * Ensure if a User has been set as currentUser.
     */
    protected function _ensureLoggedIn()
    {
        if (!$this->user instanceof \Document\User) {
            $this->response->setContent(json_encode(array('message' => 'Unauthorized (Wrong or no Auth-Token provided!)')));
            $this->response->setStatusCode(401);
            $this->response->send();
            exit;
        }
    }

    protected function _filterByPermission($documents)
    {
        $permittedDocs = array();

        foreach($documents as $doc) {
            if($doc->isPermittedFor($this->user)) {
                $permittedDocs[] = $doc;
            }
        }

        return $permittedDocs;
    }

    protected function _toArrayAll(array $results)
    {
        $gatheringItems = array();
        foreach ($results as $place) {
            $gatheringItems[] = $place->toArray();
        }

        return $gatheringItems;
    }
}
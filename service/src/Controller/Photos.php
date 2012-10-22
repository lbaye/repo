<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;
use Helper\Status;
use Repository\UserRepo as userRepository;
use Repository\PhotosRepo as photoRepository;
use Document\Photo as  photoDocument;

class Photos extends Base
{
    private $photoRepo;

    public function init()
    {
        $this->response = new Response();
        $this->response->headers->set('Content-Type', 'application/json');

        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->photoRepo = $this->dm->getRepository('Document\Photo');
        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);

        $this->_ensureLoggedIn();
    }

    # TODO Check authentication
    public function create() {
        $postData = $this->request->request->all();
        $photo = $this->photoRepo->map($postData);

        $this->photoRepo->insert($photo);
    }


}
<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;
use Helper\Status;
use Repository\UserRepo as userRepository;
use Repository\PhotoRepo as photoRepository;
use Document\Photo as  photoDocument;

/**
 * Template class for all content serving controllers
 */
class Photo extends Base
{
    /**
     * @var photoRepository
     */
    private $photoRepository;

    /**
     * Initialize the controller.
     */
    public function init()
    {
        $this->response = new Response();
        $this->response->headers->set('Content-Type', 'application/json');

        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->photoRepository = $this->dm->getRepository('Document\Photo');
        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);

        $this->_ensureLoggedIn();
    }

    /**
     * GET /photos
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function index()
    {
        $postData = $this->request->request->all();

        if (!empty($postData['photo'])) {

            $photo = $this->photoRepository->savePhoto($this->user->getId(), $postData['photo']);
        }
        $postData['photo'] = \Helper\Url::buildPhotoUrl($postData);

        if(empty($postData['photo'])){
            $this->response->setContent(json_encode(array('message' => 'Please select photo!')));
            $this->response->setStatusCode(Status::NOT_ACCEPTABLE);

        } else {
            $photos = $this->photoRepository->insert($postData);

            if (!empty($photos)) {

            } else {
                $this->response->setContent(json_encode(array('message' => 'Photos uploaded successfully.')));
                $this->response->setStatusCode(Status::NO_CONTENT);
            }
        }

        return $this->response;
    }

    /**
     * GET /photos/{id}
     *
     * @param $id  user id
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getById($id)
    {
        $this->response->setContent(json_encode(array('message' => 'Not implemented')));
        $this->response->setStatusCode(Status::NOT_IMPLEMENTED);

        return $this->response;
    }


}
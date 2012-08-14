<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;

class Messages extends Base {
    private $messageRepository;
    private $userRepository;

    public function init() {
        $this->response = new Response();
        $this->response->headers->set('Content-Type', 'application/json');

        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->messageRepository = $this->dm->getRepository('Document\Message');

        $this->userRepository->setCurrentUser($this->user);
        $this->_ensureLoggedIn();
    }

    public function create() {
        $postData = $this->request->request->all();

        try {
            $message = $this->messageRepository->map($postData, $this->user);
            $this->messageRepository->insert($message);

            $this->response->setContent(json_encode($message->toArray()));
            $this->response->setStatusCode(201);

        } catch (\Exception $e) {
            $this->response->setContent(
                json_encode(array('message' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }

        return $this->response;
    }

    public function getByCurrentUser() {
        return $this->generateResponse(
            $this->messageRepository->getByUser($this->user));
    }

    public function getInbox() {
        return $this->generateResponse(
            $this->messageRepository->getByRecipient($this->user));
    }

    public function delete($id) {
        try {
            $this->messageRepository->delete($id);

            $this->response->setContent(json_encode(array('message' => 'Removed Successfully')));
            $this->response->setStatusCode(200);

        } catch (\Exception $e) {
            $this->response->setContent(json_encode(array('message' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }

        return $this->response;
    }

    private function generateResponse($messages) {
        if (!empty($messages)) {
            $this->response->setContent(json_encode($messages));
            $this->response->setStatusCode(200);
        } else {
            $this->response->setContent('[]'); // No content
            $this->response->setStatusCode(200);
        }

        return $this->response;
    }
}
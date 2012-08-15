<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;

class Messages extends Base
{
    private $messageRepository;
    private $userRepository;
    private $serializer;

    public function init()
    {
        $this->response = new Response();
        $this->response->headers->set('Content-Type', 'application/json');

        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->messageRepository = $this->dm->getRepository('Document\Message');
        $this->serializer = \Service\Serializer\Factory::getSerializer('json');

        $this->userRepository->setCurrentUser($this->user);
        $this->_ensureLoggedIn();
    }

    public function getById($id)
    {
        $message = $this->messageRepository->find($id);
        if (empty($message)) {
            $this->generate404();
        } else {
            $this->generateResponse($message->toArray());
        }

        return $this->response;
    }

    public function create()
    {
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

    public function getByCurrentUser()
    {
        return $this->generateResponse(
            $this->messageRepository->getByUser($this->user));
    }

    public function getInbox()
    {
        return $this->generateResponse(
            $this->messageRepository->getByRecipient($this->user));
    }

    /**
     * Flag a message as READ or UNREAD
     * @param $status Accepts only READ or UNREAD
     */
    public function updateStatus($id, $status)
    {
        try {
            $message = $this->messageRepository->find($id);
            if (empty($message))
                return $this->generate404();

            if ($this->messageRepository->updateStatus($message, $status)) {
                $this->generateResponse($message->toArray(), 200);
            } else {
                $this->generate500();
            }
        } catch (\Exception $e) {
            $this->generate500();
        }

        return $this->response;
    }

    public function updateRecipients($id)
    {
        # Find existing object
        $message = $this->messageRepository->find($id);

        # Return if object is not found
        if (empty($message))
            return $this->generate404();

        # Load recipients list
        $recipients = $this->request->request->get('recipients');

        if (empty($recipients))
            return $this->generate500('No recipients[] is set over parameter.');

        try {
            # Update recipients list
            if ($this->messageRepository->updateRecipients($message, $recipients)) {
                $this->generateResponse($message->toArray(), 200);
            } else {
                $this->generate500();
            }
        } catch (\Exception $e) {
            $this->generate500($e->getMessage());
        }

        return $this->response;
    }

    public function getRepliesByLastVisitedSince($id)
    {
        try {
            $message = $this->messageRepository->find($id);

            if (empty($message))
                return $this->generate404();

            # Set replies `since` date parameter otherwise
            # set message's createDate as replies since date.
            $timestamp = $this->request->get('since');

            if (empty($timestamp)) {
                $since = $message->getCreateDate();
            } else {
                $since = new \DateTime();
                $since->setTimestamp($timestamp);
            }

            # Find all replies since <specific date> and order them by create date
            $this->generateResponse(
                $this->messageRepository->
                        getRepliesSince($message, $since),
                200,
                array(
                    'except' => array('replies', 'thread', 'recipients')
                ));

        } catch (\Exception $e) {
            $this->generate500($e->getMessage());
        }

        return $this->response;
    }

    public function delete($id)
    {
        try {
            $this->messageRepository->delete($id);
            $this->generateResponse(
                array('message' => 'Removed successfully'), 200
            );

        } catch (\Exception $e) {
            $this->generate500($e->getMessage());
        }

        return $this->response;
    }

    private function generateResponse($hash, $code = 200, $options = array())
    {
        if (!empty($hash)) {
            $this->response->setContent(
                $this->serializer->serialize($hash, $options)
            );
            $this->response->setStatusCode($code);
        } else {
            $this->response->setContent('[]'); // No content
            $this->response->setStatusCode($code);
        }

        return $this->response;
    }

    private function generateErrorResponse($message, $code = 406)
    {
        return $this->generateResponse(array(
            'message' => $message
        ), $code);
    }

    private function generate404()
    {
        return $this->generateErrorResponse('Object not found', 404);
    }

    private function generate500($message = 'Failed to update object')
    {
        return $this->generateResponse($message, 500);
    }
}
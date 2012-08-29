<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;

class Messages extends Base
{
    private $messageRepository;
    private $userRepository;

    public function init()
    {
        parent::init();

        $this->messageRepository = $this->dm->getRepository('Document\Message');

        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);

        $this->_ensureLoggedIn();
    }

    public function getById($id)
    {
        $message = $this->messageRepository->find($id);
        if (empty($message)) {
            $this->_generate404();
        } else {
            $this->_generateResponse($message->toArray());
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
            $this->response->setStatusCode(Status::CREATED);

        } catch (\Exception $e) {
            $this->_generate500($e->getMessage());
        }

        return $this->response;
    }

    public function getByCurrentUser()
    {
        return $this->_generateResponse(
            $this->messageRepository->getByUser($this->user));
    }

    public function getInbox()
    {
        return $this->_generateResponse(
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
                return $this->_generate404();

            if ($this->messageRepository->updateStatus($message, $status)) {
                $this->_generateResponse($message->toArray(), Status::OK);
            } else {
                $this->_generate500();
            }
        } catch (\Exception $e) {
            $this->_generate500();
        }

        return $this->response;
    }

    public function updateRecipients($id)
    {
        # Find existing object
        $message = $this->messageRepository->find($id);

        # Return if object is not found
        if (empty($message))
            return $this->_generate404();

        # Load recipients list
        $recipients = $this->request->request->get('recipients');

        if (empty($recipients))
            return $this->_generate500('No recipients[] is set over parameter.');

        try {
            # Update recipients list
            if ($this->messageRepository->updateRecipients($message, $recipients)) {
                $this->_generateResponse($message->toArray(), Status::OK);
            } else {
                $this->_generate500();
            }
        } catch (\Exception $e) {
            $this->_generate500($e->getMessage());
        }

        return $this->response;
    }

    public function getRepliesByLastVisitedSince($id)
    {
        try {
            $message = $this->messageRepository->find($id);

            if (empty($message))
                return $this->_generate404();

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
            $this->_generateResponse(
                $this->messageRepository->
                        getRepliesSince($message, $since),
                Status::OK,
                array(
                    'except' => array('replies', 'thread', 'recipients')
                ));

        } catch (\Exception $e) {
            $this->_generate500($e->getMessage());
        }

        return $this->response;
    }

    public function delete($id)
    {
        try {
            $this->messageRepository->delete($id);
            $this->_generateResponse(
                array('message' => 'Removed successfully'), Status::OK
            );

        } catch (\Exception $e) {
            $this->_generate500($e->getMessage());
        }

        return $this->response;
    }
}
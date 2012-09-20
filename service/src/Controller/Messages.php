<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;
use Helper\Status;

class Messages extends Base
{
    /**
     * @var \Repository\MessageRepo
     */
    private $messageRepository;

    public function init()
    {
        parent::init();

        $this->messageRepository = $this->dm->getRepository('Document\Message');
        $this->messageRepository->setConfig($this->config);

        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);

        $this->_ensureLoggedIn();
    }

    public function getById($id)
    {
        $data = $this->messageRepository->find($id);
        if (empty($data)) {
            $this->_generate404();
        } else {

            $messageDetail = array();

                $messageArr = $data->toArray(true);

                $messageArr['sender']['avatar'] = \Helper\Url::buildAvatarUrl($messageArr['sender']);

                foreach ($messageArr['recipients'] AS &$recipient) {
                    $recipient['avatar'] = \Helper\Url::buildAvatarUrl($recipient);
                }

                foreach ($messageArr['replies'] AS &$avatar) {

                    $avatar['sender']['avatar'] = \Helper\Url::buildAvatarUrl($avatar['sender']);
                }

                $messageDetail = $messageArr;

            $this->_generateResponse($messageDetail);
        }

        return $this->response;
    }

    public function create()
    {
        $postData = $this->request->request->all();

        try {
            $message = $this->messageRepository->map($postData, $this->user);
            $this->messageRepository->insert($message);

            $this->response->setContent(json_encode($message->toArray(true)));
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
        $showLastReply = (boolean) $this->request->get('show_last_reply');

        $messages = $this->messageRepository->getByRecipient($this->user);

        $docsAsArr = array();
        foreach ($messages as $message) {
            $messageArr = $message->toArray(true);
            $messageArr['sender']['avatar'] = \Helper\Url::buildAvatarUrl($messageArr['sender']);

            foreach($messageArr['recipients'] AS &$recipient){
                $recipient['avatar'] = \Helper\Url::buildAvatarUrl($recipient);
            }

            if($showLastReply == true){
                if(!empty($messageArr['replies'])){
                $messageArr['replies'] = end($messageArr['replies']);
                }else{
                $messageArr['replies'] = null;
                }
            }else{
                unset($messageArr['replies']);
            }

            $docsAsArr[] = $messageArr;
        }

        $this->_generateResponse($docsAsArr);

        return $this->response;
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
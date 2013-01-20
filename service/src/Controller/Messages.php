<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;
use Helper\Status;

/**
 * Manage user's generated messages
 */
class Messages extends Base {
    /**
     * @var \Repository\MessageRepo
     */
    private $messageRepository;

    public function init() {
        parent::init();

        $this->messageRepository = $this->dm->getRepository('Document\Message');
        $this->messageRepository->setConfig($this->config);

        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->_updatePulse();
        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);

        $this->_ensureLoggedIn();
    }

    /**
     * GET /messages/{id}
     *
     * Retrieve message by the specific id
     *
     * @param  $id
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getById($id) {
        $message = $this->messageRepository->find($id);
        if (empty($message)) {
            $this->_generate404();
        } else {

            $messageDetail = array();

            $messageArr = $message->toArray(true);

            $messageArr['sender']['avatar'] = \Helper\Url::buildAvatarUrl($messageArr['sender']);

            foreach ($messageArr['recipients'] AS &$recipient) {
                $recipient['avatar'] = \Helper\Url::buildAvatarUrl($recipient);
            }

            foreach ($messageArr['replies'] AS &$avatar) {

                $avatar['sender']['avatar'] = \Helper\Url::buildAvatarUrl($avatar['sender']);
            }

            $messageDetail = $messageArr;

            if (!in_array($this->user->getId(), $messageDetail['readBy'])) {
                $this->messageRepository->updateStatus($message, $this->user->getId());
                $messageDetail['status'] = 'unread';
            } else {
                $messageDetail['status'] = 'read';
            }

            $this->_generateResponse($messageDetail);
        }

        return $this->response;
    }

    /**
     * POST /messages
     *
     * Create new message with required paramters
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function create() {
        $postData = $this->request->request->all();

        try {
            $message = $this->messageRepository->map($postData, $this->user);
            $message->addReadStatusFor($this->user);
            $this->messageRepository->insert($message, $this->user);

            // Don't put it before insert operation. this is intentional
            $message->setStatus('read');
            $this->_sendNotification($postData, $message);

            $messageOrThread = $message->getThread() != null ? $message->getThread() : $message;
            $this->messageRepository->refresh($messageOrThread);

            $this->response->setContent(json_encode($messageOrThread->toArray(true)));
            $this->response->setStatusCode(Status::CREATED);

        } catch (\Exception $e) {
            $this->_generate500($e->getMessage());
        }

        return $this->response;
    }

    /**
     * Retrieve an existing thread for the given recipients list.
     * If not found an existing thread create new one.
     *
     * @return void
     */
    public function createOrGetMessageThread() {
        $postData = $this->request->request->all();

        if (!isset($postData['recipients']))
            return $this->_generateErrorResponse('"recipients[]" is required parameter');

        try {
            # Find or create new message thread
            $message = $this->messageRepository->findOrCreateMessageThread($this->user, $postData);

            if ($message->hasContent()) {
                # Send notification if content is set
                $this->_sendNotification($postData, $message);
            }

            $this->messageRepository->refresh($message);

            $this->response->setContent(json_encode($message->toArray(true)));
            $this->response->setStatusCode(Status::OK);

        } catch (\Exception $e) {
            $this->_generate500($e->getMessage());
        }

        return $this->response;
    }

    private function _sendNotification($postData, \Document\Message $message) {
        if ($message->getThread())
            $this->notifyNewReplyRecipients($postData, $message);
        else
            $this->notifyNewMessageRecipients($postData, $message);
    }

    private function notifyNewReplyRecipients(array $postData, \Document\Message $message) {
        $thread = $message->getThread();
        $recipients[] = $thread->getSender()->getId();

        foreach ($thread->getRecipients() as $recipient) $recipients[] = $recipient->getId();
        $recipients = array_diff($recipients, array($this->user->getId()));

        if (!empty($recipients)) {
            $this->_sendPushNotification(
                $recipients,
                \Helper\AppMessage::getMessage(\Helper\AppMessage::REPLY_MESSAGE, $this->user->getFirstName()),
                \Helper\AppMessage::REPLY_MESSAGE,
                $thread->getId());
        }
    }

    private function notifyNewMessageRecipients(array $postData, \Document\Message $message) {
        $recipients = $postData['recipients'];
        $filteredRecipientsIds = array_diff($recipients, array($this->user->getId()));

        if (!empty($filteredRecipientsIds)) {
            $this->_sendPushNotification(
                $filteredRecipientsIds,
                \Helper\AppMessage::getMessage(\Helper\AppMessage::NEW_MESSAGE, $this->user->getFirstName()),
                \Helper\AppMessage::NEW_MESSAGE,
                $message->getId());
        }
    }

    /**
     * GET /messages/sent
     *
     * Retrieve messages by current user
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getByCurrentUser() {
        return $this->_generateResponse(
            $this->messageRepository->getByUser($this->user));
    }

    /**
     * GET /messages/inbox
     *
     * Retrieve message inbox by current user
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getInbox() {
        $showLastReply = (boolean)$this->request->get('show_last_reply');

        $messages = $this->messageRepository->getByRecipient($this->user);

        $docsAsArr = array();
        foreach ($messages as $message) {
            if (count($message->getReplies()) > 0 || $message->hasContent()) {
                $messageArr = $message->toArray(true);

                $messageArr['sender']['avatar'] = \Helper\Url::buildAvatarUrl($messageArr['sender']);

                foreach ($messageArr['recipients'] AS &$recipient) {
                    $recipient['avatar'] = \Helper\Url::buildAvatarUrl($recipient);
                }

                if ($showLastReply == true) {

                    if (!empty($messageArr['replies'])) {

                        $messageArr['replies'] = array(end($messageArr['replies']));
                        $messageArr['replies'][0]['sender']['avatar'] = \Helper\Url::buildAvatarUrl($messageArr['replies'][0]['sender']);
                    } else {
                        $messageArr['replies'] = null;
                    }
                } else {
                    unset($messageArr['replies']);
                }

                if (!in_array($this->user->getId(), $messageArr['readBy'])) {
                    $messageArr['status'] = 'unread';
                } else {
                    $messageArr['status'] = 'read';
                }

                $docsAsArr[] = $messageArr;
            }
        }

        $this->_generateResponse($docsAsArr);

        return $this->response;
    }

    /**
     * PUT /messages/{id}/status/{status}
     *
     * Flag a specific message as READ or UNREAD
     *
     * @param $status Accepts only READ or UNREAD
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function updateStatus($id, $status) {
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

    /**
     * PUT /messages/{id}/recipients
     *
     * Modify recipients list from the specific message
     *
     * @param  $id
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function updateRecipients($id) {
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

    /**
     * GET /messages/{id}/replies
     *
     * Retrieve replies which were created after a specific timestamp from a specific message.
     *
     * @param  $id
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getRepliesByLastVisitedSince($id) {
        try {
            $message = $this->messageRepository->find($id);

            if (!in_array($this->user->getId(), $message->getReadBy())) {
                $this->messageRepository->updateStatus($message, $this->user->getId());
                $messageDetail['status'] = 'unread';
            } else {
                $messageDetail['status'] = 'read';
            }

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

    /**
     * DELETE /messsages/{id}
     *
     * Delete a specific message
     *
     * @param  $id
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function delete($id) {
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

    private function _createPushMessage($msgText) {
        return $this->user->getFirstName() . $msgText;
    }

    /**
     * PUT /messages/{id}/recipients/add
     *
     * Add new recipient to a specific message
     *
     * @param  $id
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function addRecipients($id) {
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
            $messageArray = $message->toArray();

            foreach ($messageArray['recipients'] as $recipient) {
                $previousRecipients[] = $recipient['id'];
            }

            $mergedRecipients = array_unique(array_merge($previousRecipients, $recipients));

            if ($this->messageRepository->updateRecipients($message, $mergedRecipients)) {

                $this->_generateResponse($message->toArray(), Status::OK);
            } else {
                $this->_generate500();
            }
        } catch (\Exception $e) {
            $this->_generate500($e->getMessage());
        }

        return $this->response;
    }

    /**
     * GET /messages/{id}/unread
     *
     * Retrieve a specific messages and keep it's status "unread"
     *
     * @param  $id
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getUnreadMessagesById($id) {
        $message = $this->messageRepository->find($id);
        if (empty($message)) {
            $this->_generate404();
        } else {

            $messageDetail = array();

            $messageArr = $message->toArray(true);

            $messageArr['sender']['avatar'] = \Helper\Url::buildAvatarUrl($messageArr['sender']);

            foreach ($messageArr['recipients'] AS &$recipient) {
                $recipient['avatar'] = \Helper\Url::buildAvatarUrl($recipient);
            }

            foreach ($messageArr['replies'] AS &$avatar) {

                $avatar['sender']['avatar'] = \Helper\Url::buildAvatarUrl($avatar['sender']);
            }

            $messageDetail = $messageArr;

            if (!in_array($this->user->getId(), $messageDetail['readBy'])) {
                $messageDetail['status'] = 'unread';
            } else {
                $messageDetail['status'] = 'read';
            }

            $this->_generateResponse($messageDetail);
        }

        return $this->response;
    }

}

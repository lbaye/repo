<?php

namespace Repository;

use Doctrine\ODM\MongoDB\DocumentRepository;
use Document\User as UserDocument;
use Repository\UserRepo as UserRepository;
use Document\Message as MessageDocument;
use Helper\Security as SecurityHelper;

/**
 * Data access functionality for message model
 */
class MessageRepo extends Base {

    private $userRepository;

    private function getUserRepository() {
        if ($this->userRepository === null) {
            $this->userRepository = $this->dm->getRepository('Document\User');
        }

        return $this->userRepository;
    }

    public function getByUser(UserDocument $user) {
        $messages = $this->dm->createQueryBuilder()
                ->find('Document\Message')
                ->field('sender')
                ->equals($user->getId())
                ->sort('createDate', 'desc')
                ->getQuery()
                ->execute();

        return $this->_toArrayAll($messages);
    }

    public function getByRecipient(UserDocument $user) {
        $messages = $this->dm->createQueryBuilder()
                ->find('Document\Message')
                ->field('recipients')
                ->equals($user->getId())
                ->sort('updateDate', 'desc')
                ->getQuery()
                ->execute();

        return $messages;
    }

    public function getUnreadMessagesByRecipient(UserDocument $user) {
        $messages = $this->dm->createQueryBuilder()
                ->find('Document\Message')
                ->field('recipients')->equals($user->getId())
                ->field('readBy')->notIn($user->getId())
                ->sort('updateDate', 'desc')
                ->getQuery()
                ->execute();

        return $messages;
    }

    public function getRepliesSince($thread, $since) {
        $replies = $this->dm->createQueryBuilder()
                ->find('Document\Message')

                ->field('createDate')
                ->gte($since)

                ->field('thread')
                ->equals($thread->getId())

                ->sort('createDate', 'asc')
                ->getQuery()
                ->execute();
        return $this->_toArrayAll($replies);
    }

    public function insert(MessageDocument $message, UserDocument $user = null) {
        if (!$message->isValid()) {
            throw new \InvalidArgumentException('Invalid Message data', 406);
        }

        # Store message
        $this->dm->persist($message);
        $this->dm->flush();

        # Add to parent message
        try {
            $thread = $message->getThread();
            if (!empty($thread)) {
                $this->addToThread($message);
                if(!is_null($user))
                    $this->clearReadBy($thread, $user);
            }

        } catch (\Exception $e) {
            die($e);
        }

        return $message;
    }


    private function addToThread(MessageDocument $message) {
        $message->getThread()->getReplies()->add($message);
        $this->dm->persist($message->getThread());
        $this->dm->flush();
    }

    private function clearReadBy(MessageDocument $message, UserDocument $user) {
        $message->resetReadStatusFor($user);
        $message->setUpdateDate(new \DateTime());
        $this->dm->persist($message);
        $this->dm->flush();
    }

    public function updateStatus(MessageDocument $message, $userId) {
        $users = $message->getReadBy();

        $message->setReadBy(array_unique(array_merge($users, array($userId))));
        $this->dm->persist($message);
        $this->dm->flush();

        return true;
    }

    public function updateRecipients(MessageDocument $message, array $recipients) {
        $this->setRecipients(array('recipients' => $recipients), $message);
        $this->dm->persist($message);
        $this->dm->flush();

        return true;
    }

    public function map(array $data, UserDocument $sender, MessageDocument $message = null) {
        $now = new \DateTime();

        if (is_null($message)) {
            $message = new MessageDocument();
            $message->setCreateDate($now);
            $message->setUpdateDate($now);
        } else {
            $message->setUpdateDate($now);
        }

        $formFields = array('subject', 'content');

        # Set recipients object's reference
        $this->setRecipients($data, $message, $sender);

        # Set thread object
        $message = $this->setThreadDependentProperties($formFields, $data, $message, $sender);

        foreach ($formFields as $field) {
            if (isset($data[$field]) && !is_null($data[$field])) {
                $message->{"set{$field}"}($data[$field]);
            }
        }

        $message->setSender($sender);

        return $message;
    }

    private function setThreadDependentProperties(
        array &$formFields, array $data, MessageDocument $message, UserDocument $sender = null) {


        if (!empty($data['thread'])) {
            $thread = $this->find($data['thread']);
            $message->setThread($thread);
            $message->setRecipients($thread->getRecipients());

            if (!array_key_exists('subject', $data) || empty($data['subject'])) {
                $message->setSubject($thread->getSubject());
                unset($formFields[0]);
            }

            $message->setUpdateDate(new \DateTime());
        }

        else {
            $recipientList = $data['recipients'];
            $recipientList[] = $sender->getId();
            $recipientIds = array();


            foreach ($recipientList as $recipientId) $recipientIds[] = new \MongoId($recipientId);

            $threadArray = $this->findThreadByRecipientList($recipientIds);

            if(!empty($threadArray)) {

                $thread = $this->find($threadArray['_id']);

                $message->setThread($thread);
                $message->setRecipients($thread->getRecipients());
                $message->setUpdateDate(new \DateTime());
            }
        }

        return $message;
    }


    private function findThreadByRecipientList($recipientList){

        $query = $this->createQueryBuilder('Document\Message')
            ->field('recipients')->all($recipientList)->hydrate(false);
        $message = $query->getQuery()->getSingleResult();

        return $message;

    }

    private function setRecipients(array $data, MessageDocument &$message, $sender = null) {
        if (!empty($data['recipients'])) {
            $recipients = $data['recipients'];
            $recipientsObjects = array($sender);

            foreach ($recipients as $recipient)
                $recipientsObjects[] = $this->getUserRepository()->find($recipient);
            $message->setRecipients(array_filter($recipientsObjects));
        }
    }

    protected function _toArrayAll($results) {
        $docsAsArr = array();
        foreach ($results as $message) {
            $messageArr = $message->toArray();
            $messageArr['sender']['avatar'] = \Helper\Url::buildAvatarUrl($messageArr['sender']);

            foreach ($messageArr['recipients'] AS &$recipient) {
                $recipient['avatar'] = \Helper\Url::buildAvatarUrl($recipient);
            }

            $docsAsArr[] = $messageArr;
        }

        return $docsAsArr;
    }

    public function getByRecipientCount(UserDocument $user) {
        $messages = $this->dm->createQueryBuilder()
                ->find('Document\Message')
                ->field('recipients')
                ->equals($user->getId())
                ->field('readBy')
                ->notEqual($user->getId())
                ->sort('updateDate', 'desc')
                ->getQuery()
                ->execute();

        return $messages;
    }

}
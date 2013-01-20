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
class MessageRepo extends Base
{

    private $userRepository;

    private function getUserRepository()
    {
        if ($this->userRepository === null) {
            $this->userRepository = $this->dm->getRepository('Document\User');
        }

        return $this->userRepository;
    }

    public function getByUser(UserDocument $user)
    {
        $messages = $this->dm->createQueryBuilder()
            ->find('Document\Message')
            ->field('sender')
            ->equals($user->getId())
            ->sort('createDate', 'desc')
            ->getQuery()
            ->execute();

        return $this->_toArrayAll($messages);
    }

    public function getByRecipient(UserDocument $user)
    {
        $messages = $this->dm->createQueryBuilder()
            ->find('Document\Message')
            ->field('recipients')
            ->equals($user->getId())
            ->sort('updateDate', 'desc')
            ->getQuery()
            ->execute();

        return $messages;
    }

    public function getUnreadMessagesByRecipient(UserDocument $user)
    {
        $messages = $this->dm->createQueryBuilder()
            ->find('Document\Message')
            ->field('recipients')->equals($user->getId())
            ->field('readBy')->notIn($user->getId())
            ->sort('updateDate', 'desc')
            ->getQuery()
            ->execute();

        return $messages;
    }

    public function getRepliesSince($thread, $since)
    {
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

    public function insert(MessageDocument $message, UserDocument $user = null)
    {
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
                $this->updateThreadContent($message);
                $this->persistThread($message);
                if (!is_null($user))
                    $this->clearReadBy($thread, $user);
            }

        } catch (\Exception $e) {
            die($e);
        }

        return $message;
    }

    private function updateThreadContent(MessageDocument $message) {
        $message->getThread()->setLastMessage($message->getContent());
    }

    private function persistThread(MessageDocument $message) {
        $this->dm->persist($message->getThread());
        $this->dm->flush();
    }

    private function addToThread(MessageDocument $message)
    {
        $message->getThread()->getReplies()->add($message);
    }

    private function clearReadBy(MessageDocument $message, UserDocument $user)
    {
        $message->resetReadStatusFor($user);
        $message->setUpdateDate(new \DateTime());
        $this->dm->persist($message);
        $this->dm->flush();
    }

    public function updateStatus(MessageDocument $message, $userId)
    {
        $users = $message->getReadBy();

        $message->setReadBy(array_unique(array_merge($users, array($userId))));
        $this->dm->persist($message);
        $this->dm->flush();

        return true;
    }

    public function updateRecipients(MessageDocument $message, array $recipients)
    {
        $this->setRecipients(array('recipients' => $recipients), $message);
        $this->dm->persist($message);
        $this->dm->flush();

        return true;
    }

    public function map(array $data, UserDocument $sender, MessageDocument $message = null)
    {
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
        $this->setThreadDependentProperties($formFields, $data, $message, $sender);

        foreach ($formFields as $field)
            if (isset($data[$field]) && !is_null($data[$field]))
                $message->{"set{$field}"}($data[$field]);

        $message->setLastMessage($message->getContent());
        $message->setSender($sender);

        return $message;
    }

    public function findOrCreateMessageThread(\Document\User $user, array $postData) {
        $recipients = array_unique(array_merge($postData['recipients'], array($user->getId())));
        $thread = $this->findThreadByRecipients($recipients);
        
        if (empty($thread))
            return $this->createThread($user, $postData);
        else
            return $thread;
    }

    private function createThread(\Document\User $user, array $postData) {
        $message = $this->map($postData, $user);
        $message->setRunValidation(false);
        $message->addReadStatusFor($user);
        $this->insert($message, $user);

        // Don't put it before insert operation. this is intentional
        $message->setStatus('read');

        return $message;
    }

    private function setThreadDependentProperties(
        array &$formFields, array $data, MessageDocument $message, UserDocument $sender = null)
    {


        if (!empty($data['thread'])) {
            $thread = $this->find($data['thread']);
            $message->setThread($thread);
            $message->setRecipients($thread->getRecipients());

            if (!array_key_exists('subject', $data) || empty($data['subject'])) {
                $message->setSubject($thread->getSubject());
                unset($formFields[0]);
            }

            $message->setUpdateDate(new \DateTime());
        } else {
            $recipientList = $data['recipients'];
            $recipientList[] = $sender->getId();
            $recipientList = array_unique($recipientList);

            $thread = $this->findThreadByRecipients($recipientList);

            if (!empty($thread)) {
                $message->setThread($thread);
                $message->setRecipients($thread->getRecipients());
                $message->setUpdateDate(new \DateTime());
            }
        }

    }

    private function findThreadByRecipients($recipients)
    {
        $recipientIds = array();
        foreach ($recipients as $recipientId) $recipientIds[] = new \MongoId($recipientId);

        return $this->createQueryBuilder('Document\Message')
            ->field('recipients')->all($recipientIds)->size(count($recipientIds))
            ->getQuery()->getSingleResult();
    }

    private function setRecipients(array $data, MessageDocument &$message, $sender = null)
    {
        if (!empty($data['recipients'])) {
            $recipients = $data['recipients'];
            $recipientsObjects = array($sender->getId() => $sender);

            foreach ($recipients as $recipient) {
                $obj = $this->getUserRepository()->find($recipient);
                $recipientsObjects[$obj->getId()] = $obj;
            }

            $message->setRecipients(array_values($recipientsObjects));
        }
    }

    protected function _toArrayAll($results)
    {
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

    public function getByRecipientCount(UserDocument $user)
    {
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
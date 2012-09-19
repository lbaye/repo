<?php

namespace Repository;

use Doctrine\ODM\MongoDB\DocumentRepository;
use Document\User as UserDocument;
use Repository\UserRepo as UserRepository;
use Document\Message as MessageDocument;
use Helper\Security as SecurityHelper;

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
        return $this->_toArrayAll($messages);
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

    public function insert(MessageDocument $message)
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
            if (!empty($thread))
                $this->addToThread($message);
        } catch (\Exception $e) {
            die($e);
        }

        return $message;
    }

    private function addToThread(MessageDocument $message)
    {
        $message->getThread()->getReplies()->add($message);
        $this->dm->persist($message->getThread());
        $this->dm->flush();
    }

    public function updateStatus(MessageDocument $message, $status)
    {
        $message->setStatus($status);

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
        $this->setThreadDependentProperties($formFields, $data, $message);

        foreach ($formFields as $field) {
            if (isset($data[$field]) && !is_null($data[$field])) {
                $message->{"set{$field}"}($data[$field]);
            }
        }

        $message->setSender($sender);

        return $message;
    }

    private function setThreadDependentProperties(
        array &$formFields, array $data, MessageDocument $message)
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
        }
    }

    private function setRecipients(array $data, MessageDocument &$message, $sender = null)
    {
        if (!empty($data['recipients'])) {
            $recipients = $data['recipients'];
            $recipientsObjects = array($sender);

            foreach ($recipients as $recipient)
                $recipientsObjects[] = $this->getUserRepository()->find($recipient);

            $message->setRecipients($recipientsObjects);
        }
    }

    protected function _toArrayAll($results)
    {
        $docsAsArr = array();
        foreach ($results as $place) {
            $placeArr = $place->toArray();

            $placeArr['sender']['avatar'] = $this->_buildAvatarUrl($placeArr['sender']['avatar']);
            $docsAsArr[] = $placeArr;
        }

        return $docsAsArr;
    }
}
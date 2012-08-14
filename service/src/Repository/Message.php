<?php

namespace Repository;

use Doctrine\ODM\MongoDB\DocumentRepository;
use Document\User as UserDocument;
use Repository\User as UserRepository;
use Document\Message as MessageDocument;
use Helper\Security as SecurityHelper;

class Message extends DocumentRepository
{

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

    public function insert(MessageDocument $message)
    {
        if (!$message->isValid()) {
            throw new \InvalidArgumentException('Invalid Message data', 406);
        }

        $this->dm->persist($message);
        $this->dm->flush();

        return $message;
    }


    public function delete($id)
    {
        $message = $this->find($id);

        if (is_null($message)) {
            throw new \Exception("Not found", 404);
        }

        $this->dm->remove($message);
        $this->dm->flush();
    }

    public function map(array $data, UserDocument $sender, MessageDocument $message = null)
    {
        if (is_null($message)) {
            $message = new MessageDocument();
            $now = new \DateTime();
            $message->setCreateDate($now);
            $message->setUpdateDate($now);
        } else {
            $message->setUpdateDate(new \DateTime());
        }

        $formFields = array('subject', 'content', 'recipients');

        // Set thread object
        $this->setThreadDependentProperties($formFields, $data, $message);

        foreach ($formFields as $field) {
            if (isset($data[$field]) && !is_null($data[$field])) {
                $message->{"set{$field}"}($data[$field]);
            }
        }

        $message->setSender($sender);

        return $message;
    }

    protected function _toArrayAll($results)
    {
        $messages = array();
        foreach ($results as $place) {
            $messages[] = $place->toArray();
        }

        return $messages;
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
}
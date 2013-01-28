<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

/**
 * Domain model for storing message related data, this model is linked to "messages" collection
 *
 * @ODM\Document(collection="messages",repositoryClass="Repository\MessageRepo")
 */
class Message
{
    # Define status constants
    const STATUS_READ = 'read';
    const STATUS_UNREAD = 'unread';

    const DETAILS_ARRAY = 'details';
    const SHORT_ARRAY = 'short';


    /** @ODM\Id */
    protected $id;

    /** @ODM\String */
    protected $subject;

    /** @ODM\String */
    protected $content;

    /** @ODM\ReferenceOne(targetDocument="User", simple=true) */
    protected $sender;

    /** @ODM\ReferenceOne(targetDocument="User", simple=true) */
    protected $lastSender;

    /** @ODM\ReferenceOne(targetDocument="Message", simple=true) */
    protected $thread;

    /** @ODM\ReferenceMany(targetDocument="Message", simple=true, cascade={"remove"}) */
    protected $replies = array();

    /** @ODM\ReferenceMany(targetDocument="User", simple=true, cascade={"persist"}) */
    protected $recipients;

    /** @ODM\Date */
    protected $createDate;

    /** @ODM\Date */
    protected $updateDate;

    /** @ODM\String */
    protected $status = self::STATUS_UNREAD;

    /** @ODM\Hash */
    protected $readBy = array();

    /** @ODM\String */
    protected $metaType;

    /** @ODM\String */
    protected $metaTitle;

    /** @ODM\Hash */
    protected $metaContent = array(
        'content' => null,
        'address' => null,
        'note' => array(),
        'lng' => 0,
        'lat' => 0
    );

    /** @ODM\String */
    protected $lastMessage;

    private $runValidation = true;

    public function setRunValidation($state) {
        $this->runValidation = $state;
    }

    public function hasContent() {
        return !empty($this->content);
    }

    public function isValid()
    {
        if (!$this->runValidation)
            return true;

        try {
            if (empty($this->thread)) {
                Validator::create()->notEmpty()->assert($this->getRecipients());
            }

            Validator::create()->notEmpty()->assert($this->getContent());
            Validator::create()->notEmpty()->assert($this->getSender());
        } catch (\InvalidArgumentException $e) {
            return false;
        }

        return true;
    }

    public function setContent($content)
    {
        $this->content = $content;
    }

    public function getContent()
    {
        return $this->content;
    }

    public function setCreateDate($createDate)
    {
        $this->createDate = $createDate;
    }

    public function getCreateDate()
    {
        return $this->createDate;
    }

    public function setId($id)
    {
        $this->id = $id;
    }

    public function getId()
    {
        return $this->id;
    }

    public function setRecipients($recipients)
    {
        $this->recipients = $recipients;
    }

    public function getRecipients()
    {
        return $this->recipients;
    }

    public function setSender($sender)
    {
        $this->sender = $sender;
    }

    public function getSender()
    {
        return $this->sender;
    }

    public function setLastSender($lastSender)
    {
        $this->lastSender = $lastSender;
    }

    public function getLastSender()
    {
        return $this->lastSender;
    }

    public function setSubject($subject)
    {
        $this->subject = $subject;
    }

    public function getSubject()
    {
        return $this->subject;
    }

    public function setUpdateDate($updateDate)
    {
        $this->updateDate = $updateDate;
    }

    public function getUpdateDate()
    {
        return $this->updateDate;
    }

    public function setThread($thread)
    {
        $this->thread = $thread;
    }

    public function getThread()
    {
        return $this->thread;
    }

    public function setStatus($status)
    {
        $this->status = $status;
    }

    public function getStatus()
    {
        return $this->status;
    }

    public function setReplies($replies)
    {
        $this->replies = $replies;
    }

    public function getReplies()
    {
        return $this->replies;
    }

    public function toArray($detail = self::SHORT_ARRAY)
    {
        $items = $this->buildSerializableFields();

        # Add sender information
        if ($this->getSender() != null)
            $items['sender'] = $this->getSender()->toArray(false);
        # Add last sender information
        if ($this->getSender() != null)
            $items['lastSender'] = $this->getLastSender()->toArray(false);

        # Add recipients
        $items['recipients'] = $this->toArrayOfUsers($this->getRecipients());

        # Add object and list of objects
        if (!empty($this->thread)) {
            $items['thread'] = $this->thread->toArray(false);
        } else {
            $items['thread'] = null;
        }

        if ($detail == self::DETAILS_ARRAY) {
            if ($this->replies->count() > 0) {
                $items['replies'] = $this->toArrayOfMessages($this->getReplies());
            } else {
                $items['replies'] = array();
            }
        } else {
            $items['reply_count'] = $this->replies->count();
        }

        return $items;
    }

    private function toArrayOfMessages(\Doctrine\ODM\MongoDB\PersistentCollection $collection)
    {
        $replies = array();
        $iterator = $collection->getIterator();
        foreach ($iterator as $key => $value) {
            try {
                $reply = array(
                    'id' => $value->getId(),
                    'subject' => $value->getSubject(),
                    'content' => $value->getContent(),
                    'sender' => $value->getSender()->toArray(false),
                    'createDate' => $value->getCreateDate(),
                    'updateDate' => $value->getUpdateDate()
                );
                $replies[] = $reply;
            } catch (\Exception $e) {
            }
        }

        return $replies;
    }

    private function toArrayOfUsers(\Doctrine\ODM\MongoDB\PersistentCollection $collection)
    {
        $users = array();
        $iterator = $collection->getIterator();
        foreach ($iterator as $key => $value) {
            try {
                $user = $value->toArray(false);
                $users[] = $user;
            } catch (\Exception $e) {
            }
        }

        return $users;
    }

    private function buildSerializableFields()
    {
        $serializableFields = array(
            'id', 'subject', 'content', 'metaType', 'metaContent', 'createDate',
            'updateDate', 'status', 'readBy', 'lastMessage'
        );

        $result = array();

        foreach ($serializableFields as $field)
            $result[$field] = $this->{"get{$field}"}();

        return $result;
    }

    public function setReadBy($readBy)
    {
        $this->readBy = $readBy;
    }

    public function getReadBy()
    {
        return $this->readBy;
    }

    public function addReadStatusFor(\Document\User $user)
    {
        if (empty($this->readBy)) {
            $this->resetReadStatusFor($user);
        } else {
            $this->readBy[] = $user->getId();
        }
    }

    public function resetReadStatusFor(\Document\User $user)
    {
       $this->readBy = array($user->getId());
    }

    public function setMetaContent($metaContent)
    {
        $this->metaContent = $metaContent;
    }

    public function getMetaContent()
    {
        return $this->metaContent;
    }

    public function setMetaTitle($metaTitle)
    {
        $this->metaTitle = $metaTitle;
    }

    public function getMetaTitle()
    {
        return $this->metaTitle;
    }

    public function setMetaType($metaType)
    {
        $this->metaType = $metaType;
    }

    public function getMetaType()
    {
        return $this->metaType;
    }

    public function setLastMessage($lastMessage) {
        $this->lastMessage = $lastMessage;
    }

    public function getLastMessage() {
        return $this->lastMessage;
    }

}
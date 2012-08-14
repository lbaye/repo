<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

/**
 * @ODM\Document(collection="messages",repositoryClass="Repository\Message")
 */
class Message
{
    # Define status constants
    const STATUS_READ = 'read';
    const STATUS_UNREAD = 'unread';

    /** @ODM\Id */
    protected $id;

    /** @ODM\String */
    protected $subject;

    /** @ODM\String */
    protected $content;

    /** @ODM\ReferenceOne(targetDocument="User", simple=true) */
    protected $sender;

    /** @ODM\ReferenceOne(targetDocument="Message", simple=true) */
    protected $thread;

    /** @ODM\ReferenceMany(targetDocument="Message", simple=true) */
    protected $replies = array();

    /** @ODM\Hash */
    protected $recipients;

    /** @ODM\Date */
    protected $createDate;

    /** @ODM\Date */
    protected $updateDate;

    /** @ODM\String */
    protected $status = self::STATUS_UNREAD;

    public function toArray()
    {
        $fieldsToExpose = array(
            'id', 'subject', 'content', 'sender', 'recipients', 'createDate',
            'updateDate', 'status'
        );

        $result = array();

        foreach ($fieldsToExpose as $field) {
            $result[$field] = $this->{"get{$field}"}();
        }

        # Add object and list of objects
        if (!empty($this->thread))
            $result['thread'] = $this->thread->toArray();
        else
            $result['thread'] = null;

        if ($this->replies->count() > 0) {
            $result['replies'] = $this->toArrayOfArrays($this->getReplies());
        } else {
            $result['replies'] = array();
        }

        return $result;
    }

    public function isValid()
    {
        try {
            if (empty($this->thread)) {
                Validator::create()->notEmpty()->assert($this->getSubject());
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

    private function toArrayOfArrays(\Doctrine\ODM\MongoDB\PersistentCollection $collection)
    {
        $replies = array();
        $iterator = $collection->getIterator();
        foreach ($iterator as $key => $value) {
            $reply = array(
                'id' => $value->getId(),
                'subject' => $value->getSubject(),
                'content' => $value->getContent(),
                'sender' => $value->getSender(),
                'createDate' => $value->getCreateDate(),
                'updateDate' => $value->getUpdateDate()
            );
            $replies[] = $reply;
        }

        return $replies;
    }

}
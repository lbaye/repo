<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

use Document\User;
use Repository\UserRepo as userRepository;
/**
 * @ODM\EmbeddedDocument
 */
class FriendRequest
{
    /** @ODM\Id */
    protected $id;

    /** @ODM\String */
    protected $userId;

    /** @ODM\String */
    protected $friendName;

    /** @ODM\String */
    protected $recipientId;

    /** @ODM\String */
    protected $message;

    /** @ODM\Date */
    protected $createDate;

    /** @ODM\Boolean */
    protected $accepted;


    function __construct(array $data = null)
    {
        if(!is_null($data)){
            $this->map($data);
        }

        return $this;
    }

    public function setId($id)
    {
        $this->id = $id;
    }

    public function getId()
    {
        return $this->id;
    }

    public function setUserId($userId)
    {
        $this->userId = $userId;
    }

    public function getUserId()
    {
        return $this->userId;
    }

    public function setMessage($message)
    {
       $this->message = $message;
    }

   public function getMessage()
    {
       return $this->message;
    }

    public function setRequestdate($requestDate)
    {
        $this->createDate = $requestDate;
    }

    public function getCreateDate()
    {
        return $this->createDate ;
    }

    public function setRecipientId($recipientId)
    {
        $this->recipientId = $recipientId;
    }

    public function getRecipientId()
    {
        return $this->recipientId;
    }

    public function setAccepted($accepted)
    {
        $this->accepted = $accepted;
    }

    public function getAccepted()
    {
        return $this->accepted;
    }


    public function setFriendName($friendName)
    {
        $this->friendName = $friendName;
    }

    public function getFriendName()
    {
        return $this->friendName;
    }

    public function toArray()
    {
        $fieldsToExpose = array('id', 'userId', 'message','friendName','recipientId' ,'createDate','accepted');
        $result = array();

        foreach($fieldsToExpose as $field) {
            $result[$field] = $this->{"get{$field}"}();
        }

        return $result;
    }

    public function map(array $data)
    {
        $setIfExistFields = array('id', 'userId', 'message','friendName','recipientId' ,'createDate','accepted');

        foreach($setIfExistFields as $field) {
            if (isset($data[$field]) && !is_null($data[$field])) {
                $this->{"set{$field}"}($data[$field]);
            }
        }

        return $this;
    }

    public function isValid()
    {
        try {
            Validator::create()->alnum()->assert($this->getMessage());
            Validator::create()->bool()->assert($this->getAccepted());

        } catch (\InvalidArgumentException $e) {
            return false;
        }

        return true;
    }


}
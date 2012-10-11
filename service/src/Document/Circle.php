<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

use Document\User;
use Repository\UserRepo as userRepository;
/**
 * @ODM\EmbeddedDocument
 */
class Circle
{
    /** @ODM\Id */
    protected $id;

    /** @ODM\String */
    protected $name;

    /** @ODM\String */
    protected $type;

    /** @ODM\Hash */
    protected $friends = array();


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

    public function setName($name)
    {
        $this->name = $name;
    }

    public function getName()
    {
        return $this->name;
    }

    public function setType($type)
    {
       $this->type = $type;
    }

   public function getType()
    {
       return $this->type;
    }

    /**
     * @param User $user
     */
    public function addFriend(\Document\User $user)
    {
        foreach ($this->friends as $friend) {
            if ($friend == $user->getId()) {
                return false;
            }
        }

        $this->friends[] = $user->getId();
    }

    public function setFriendIds($ids) {
        $this->friends = $ids;
    }

    public function getFriends()
    {
        return $this->friends;
    }

    public function toArray()
    {
        $fieldsToExpose = array('id', 'name', 'type', 'friends');
        $result = array();

        foreach($fieldsToExpose as $field) {
            $result[$field] = $this->{"get{$field}"}();
        }

        return $result;
    }

    public function map(array $data)
    {
        $setIfExistFields = array('name', 'type');

        foreach($setIfExistFields as $field) {
            if (isset($data[$field]) && !is_null($data[$field])) {
                $this->{"set{$field}"}($data[$field]);
            }
        }

        if(empty($data['type'])) {
            $this->setType('custom');
        }

        // NOTE : friends should be added from Repository\User

        return $this;
    }

    public function isValid()
    {
        try {
            Validator::create()->alnum()->assert($this->getName());
            Validator::create()->notEmpty()->assert($this->getType());
            Validator::create()->notEmpty()->assert($this->getFriends());

        } catch (\InvalidArgumentException $e) {
            return false;
        }

        return true;
    }
}
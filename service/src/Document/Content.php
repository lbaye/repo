<?php
namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

/**
 * Abstract Base domain model for providing reusable methods and attributes.
 *
 * @ODM\MappedSuperclass
 */
abstract class Content
{
    /** @ODM\Id */
    protected $id;

    /**
     * @ODM\ReferenceOne(targetDocument="User", simple=true)
     * @var User
     */
    protected $owner;

    /** @ODM\String */
    protected $permission;

    /** @ODM\Hash */
    protected $permittedUsers = array();

    /** @ODM\Hash */
    protected $permittedCircles = array();

    /** @ODM\Date */
    protected $createDate;

    /** @ODM\Date */
    protected $updateDate;


    //<editor-fold desc="Setters">

    public function setId($id)
    {
        $this->id = $id;
    }

    /**
     * @param \Document\User $owner
     */
    public function setOwner($owner)
    {
        $this->owner = $owner;
    }

    public function setPermission($permission)
    {
        $this->permission = $permission;
    }

    public function setPermittedUsers(array $users)
    {
        $this->permittedUsers = $users;
    }

    public function setPermittedCircles(array $circles)
    {
        $this->permittedCircles = $circles;
    }

    public function setCreateDate(\DateTime $created)
    {
        $this->createDate = $created;
    }

    public function setUpdateDate(\DateTime $modified)
    {
        $this->updateDate = $modified;
    }

    //</editor-fold>

    //<editor-fold desc="Getters">

    public function getId()
    {
        return $this->id;
    }

    /**
     * @return \Document\User
     */
    public function getOwner()
    {
        return $this->owner;
    }

    public function getPermission()
    {
        return $this->permission;
    }

    public function getPermittedCircles()
    {
        return $this->permittedCircles;
    }

    public function getPermittedUsers()
    {
        return $this->permittedUsers;
    }

    public function getCreateDate()
    {
        return $this->createDate;
    }

    public function getUpdateDate()
    {
        return $this->updateDate;
    }

    //</editor-fold>

    public function isPermittedFor(\Document\User $user)
    {
        if($this->getPermission() == 'public' || $this->getOwner() == $user) {
            return true;
        } else if($this->getPermission() == 'private') {
            return false;
        } else if($this->getPermittedUsers() && in_array($user->getId(), $this->getPermittedUsers())) {
            return true;
        } else if($permittedCircles = $this->getPermittedCircles()) {
            $circleUsers = array();

            foreach($this->getOwner()->getCircles() as $circle) {
                if(in_array($circle->getId(), $permittedCircles)){
                    $circleUsers = array_merge($circleUsers, $circle->getFriends());
                }
            }
            return in_array($user->getId(), $circleUsers);
        }

        return false;
    }

    public function share($type, array $users = null, array $circles = null)
    {
        $this->setPermission($type);
        if($type == 'private' || $type == 'public') {
            $this->permittedUsers = array();
            $this->permittedCircles = array();
        } else {
            if(is_array($users))   { $this->setPermittedUsers($users); }
            if(is_array($circles)) { $this->setPermittedCircles($circles); }
        }

        return true;
    }
}

<?php
// src/Acme/AdminUserBundle/Form/Model/Registration.php
namespace AdminUser\AdminUserBundle\Form\Model;

use Symfony\Component\Validator\Constraints as Assert;

use AdminUser\AdminUserBundle\Document\User;

class Registration extends User
{
    /**
     * @Assert\Type(type="AdminUser\AdminUserBundle\Document\User")
     */
    protected $user;

    public function setUser(User $user)
    {
        $this->user = $user;
    }

    public function getUser()
    {
        return $this->user;
    }

}
<?php

namespace AdminUser\AdminUserBundle\Form;

use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;

class LoginType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder->add('email', 'email', array('label' => '', 'attr' => array('placeholder' => 'Email address', 'class' => 'input-block-level')));
        $builder->add('password', 'password', array('label' => '', 'attr' => array('placeholder' => 'Password', 'class' => 'input-block-level')));
    }

    public function getName()
    {
        return 'login';
    }
}

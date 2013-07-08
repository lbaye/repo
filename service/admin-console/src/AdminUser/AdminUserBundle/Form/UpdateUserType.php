<?php

namespace AdminUser\AdminUserBundle\Form;

use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;

class UpdateUserType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder->add('email', 'email');
        $builder->add('firstName', 'text', array(
            'label' => 'First Name'
        ));
        $builder->add('lastName', 'text', array(
            'label' => 'Last Name'
        ));
        $builder->add('enabled', 'choice', array(
            'choices' => array(false => 'Block', true => 'Unblock'),
            'required' => true,
        ));
        $builder->add('gender', 'choice', array(
            'choices' => array('Male' => 'Male', 'Female' => 'Female'),
            'required' => false,
        ));
        $builder->add('regMedia', 'choice', array(
            'choices' => array('sm' => 'Social Maps', 'fb' => 'Facebook'),
            'required' => true,'label' => 'Reg Media'
        ));

    }

    public function getName()
    {
        return 'userupdate';
    }
}

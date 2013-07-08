<?php

namespace AdminUser\AdminUserBundle\Form;

use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;

class EmailType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder->add('subject', 'text', array('label' => '', 'required' => false, 'attr' => array('placeholder' => 'Email Subject', 'class' => 'input-block-level')));
        $builder->add('message', 'textarea', array('label' => '', 'required' => false,'attr' => array('placeholder' => 'Email Message', 'class' => 'input-block-level')));
    }

    public function getName()
    {
        return 'email';
    }
}

<?php

namespace AdminUser\AdminUserBundle\Form;
use Symfony\Component\HttpFoundation\File\File;

use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;

class UpdatePlaceType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder->add('category', 'choice', array(
            'choices' => array('bar' => 'bar', 'café' => 'café'
            , 'food' => 'food', 'lodging' => 'lodging'
            , 'museum' => 'museum', 'store' => 'store'),
            'required' => true,
        ));
        $builder->add('title', 'text');
        $builder->add('description', 'textarea');
        $builder->add('photo', 'file', array('required' => false));
        $builder->add('icon', 'file', array('required' => false));

        $builder->add('type', 'hidden', array('attr' => array('value' => 'custom_place')));
        $builder->add('lat', 'text');
        $builder->add('lng', 'text');
        $builder->add('address', 'textarea');
        $builder->add('note', 'textarea');

    }

    public function getName()
    {
        return 'updateplace';
    }
}

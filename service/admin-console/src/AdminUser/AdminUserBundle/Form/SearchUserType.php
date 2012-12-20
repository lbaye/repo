<?php

namespace AdminUser\AdminUserBundle\Form;

use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;

class SearchUserType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options)
    {

        $builder->add('keyword', 'search');

    }

    public function getName()
    {
        return 'searchuser';
    }
}

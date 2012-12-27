<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

use Document\User as User;
use Document\Location as Location;

/**
 * Domain model for storing place related data, this model is linked with "places" collection
 *
 * @ODM\Document(collection="places",repositoryClass="Repository\PlaceRepo")
 */
class CustomPlace extends Landmark
{

    /** @ODM\String */
    protected $icon;

    function __construct() {
        $this->setType('custom_place');
    }

    public function toArray()
    {
        $result = parent::toArray();
        $result['type'] = 'custom_place';

        return $result;
    }

    public function setIcon($icon)
    {
        $this->icon = $icon;
    }

    public function getIcon()
    {
        return $this->icon;
    }

}
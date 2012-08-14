<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

use Document\User as User;
use Document\Location as Location;

/**
 * @ODM\Document(collection="places",repositoryClass="Repository\Place")
 */
class Place extends Landmark
{
    function __construct() {
        $this->setType('place');
    }

    public function toArray()
    {
        $result = parent::toArray();
        $result['type'] = 'place';

        return $result;
    }
}
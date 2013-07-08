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
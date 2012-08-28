<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

use Document\User as User;
use Document\Place as Place;
use Document\Location as Location;

/**
 * @ODM\Document(collection="places", repositoryClass="Repository\PlaceRepo")
 */
class Geotag extends Landmark
{
    function __construct() {
        $this->setType('geotag');
    }

    public function toArray()
    {
        $result = parent::toArray();
        $result['type'] = 'geotag';

        return $result;
    }
}
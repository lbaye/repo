<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

use Document\User as User;
use Document\Location as Location;

/**
 * @ODM\Document(collection="mapixTrails",repositoryClass="Repository\TrailRepo")
 */
class MapixTrail extends Trail
{

    /**
     * @return bool
     */
    public function isValid()
    {
        try {
            Validator::create()->notEmpty()->assert($this->getName());

        } catch (\InvalidArgumentException $e) {
            return false;
        }

        return true;
    }

}
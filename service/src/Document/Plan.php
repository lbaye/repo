<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

use Document\User as User;
use Document\Location as Location;

/**
 * @ODM\Document(collection="plans",repositoryClass="Repository\GatheringRepo")
 */
class Plan extends Gathering
{
    /** @ODM\String */
    protected $type = 'plan';

    public function isValid() {

        $parentValidity = parent::isValid();
        if($parentValidity instanceof \Exception) {
            return $parentValidity;
        }

        try {
            Validator::create()->date()->assert($this->getTime());

        } catch (\InvalidArgumentException $e) {
            return $e;
        }

        return true;
    }

    public function toArray()
    {
        $result = parent::toArray();
        unset($result['description'], $result['guests']);

        return $result;
    }
}
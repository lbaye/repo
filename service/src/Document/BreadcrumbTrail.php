<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

use Document\User as User;
use Document\Location as Location;

/**
 * Domain model for storing breadcrumb trail related data, this model is liked with "breadcrumbTrails" collection
 *
 * @ODM\Document(collection="breadcrumbTrails",repositoryClass="Repository\TrailRepo")
 */
class BreadcrumbTrail extends Trail
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
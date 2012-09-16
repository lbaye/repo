<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

use Document\User as User;
use Document\Location as Location;

/**
 * @ODM\Document(collection="meetups",repositoryClass="Repository\GatheringRepo")
 */
class Meetup extends Gathering
{
    public function isValid() {

        $parentValidity = parent::isValid();

        if($parentValidity !== true) {
            return $parentValidity;
        }
        try {
            Validator::create()->positive()->assert(count($this->getGuests()));

        } catch (\InvalidArgumentException $e) {
            return $e;
        }

        return true;
    }


    public function toArray()
    {
        $result = parent::toArray();
        unset($result['description'], $result['guests'],$result['title'],$result['eventShortSummary'],$result['eventImage'],$result['guestsCanInvite'],$result['distance']);
        $result['duration'] = $this->getDuration();
        $result['message'] = $this->getMessage();

        return $result;
    }
}
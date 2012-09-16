<?php

namespace Repository;

use Doctrine\ODM\MongoDB\DocumentRepository;
use Document\Direction as DirectionDocument;
use Document\User as UserDocument;
use Helper\Security as SecurityHelper;

class DirectionRepo extends Base
{
    public function update($data, $id)
    {
        $place = $this->find($id);

        if (false === $place) {
            throw new \Exception\ResourceNotFoundException();
        }

        $place = $this->map($data, $place->getOwner(), $place);

        if ($place->isValid() === false) {
            return false;
        }

        $this->dm->persist($place);
        $this->dm->flush();

        return $place;
    }

    public function map(array $data, UserDocument $owner, \Document\Direction $directionDoc = null)
    {
        if(is_null($directionDoc)){
            $directionDoc = new DirectionDocument();
        } else {
            $directionDoc->setUpdateDate(new \DateTime());
        }

        $directionDoc->setOwner($owner);
        $directionDoc->setFrom(new \Document\Location($data['from']));
        $directionDoc->setTo(new \Document\Location($data['to']));

        if(isset($data['permission'])){
            $directionDoc->share($data['permission'], @$data['permittedUsers'], @$data['permittedCircles']);
        }

        return $directionDoc;
    }
}
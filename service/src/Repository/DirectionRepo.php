<?php

namespace Repository;

use Doctrine\ODM\MongoDB\DocumentRepository;
use Document\Direction as DirectionDocument;
use Document\User as UserDocument;
use Helper\Security as SecurityHelper;

class DirectionRepo extends Base
{
    public function update($data,$id)
    {
        $data = $this->map($data,$id);

        if ($data->isValid() === false) {
            return false;
        }

        $this->dm->persist($data);
        $this->dm->flush();

        return $data;
    }


    public function map(array $data, UserDocument $owner, \Document\Direction $directionDoc = null)
    {

        if(is_null($directionDoc)){
            $directionDoc = new DirectionDocument();
            $directionDoc->setCreateDate(new \DateTime());
        } else {
            $directionDoc->setUpdateDate(new \DateTime());
        }

        $directionDoc->setOwner($owner);
        $directionDoc->setFrom(new \Document\Location(array('lat' => $data['latFrom'], 'lng' => $data['lngFrom'])));
        $directionDoc->setTo(new \Document\Location(array('lat' => $data['latTo'], 'lng' => $data['lngTo'])));

        if(isset($data['permission'])){
            $directionDoc->share($data['permission'], @$data['permittedUsers'], @$data['permittedCircles']);
        }

        return $directionDoc;
    }


    protected function trimInvalidUsers($data)
    {
        $userRepo = $this->dm->getRepository('Document\User');
        $users = array();

        foreach ($data as $permissionUserId) {
            $user = $userRepo->find($permissionUserId);
            if ($user) array_push($users, $user->getId());
        }
        return $users;
    }
}
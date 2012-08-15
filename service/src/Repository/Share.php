<?php

namespace Repository;

use Doctrine\ODM\MongoDB\DocumentRepository;
use Document\Share as ShareDocument;
use Document\User as UserDocument;
use Repository\User as UserRepository;


class Share extends DocumentRepository
{
    public function getByUser(UserDocument $user)
    {
        $share = $this->findBy(array('owner' => $user->getId()));
        return $this->_toArrayAll($share);
    }

    public function getAll($limit = 20, $offset = 0)
    {

        $results = $this->findBy(array(), null, $limit, $offset);
        return $this->_toArrayAll($results);

    }

    public function insert(ShareDocument $share)
    {
        $valid = $share->isValid();

        if ($valid !== true) {
            throw new \InvalidArgumentException('Invalid share data', 406);
        }

        $this->dm->persist($share);
        $this->dm->flush($share);

        return $share;
    }

    public function update($data, $id)
    {
        $share = $this->find($id);

        if (false === $share) {
            throw new \Exception\ResourceNotFoundException();
        }

        $share = $this->map($data, $share->getOwner(), $share);

        if ($share->isValid() === false) {
            return false;
        }

        $this->dm->persist($share);
        $this->dm->flush();

        return $share;
    }

    public function delete($id)
    {
        $share = $this->find($id);

        if (is_null($share)) {
            throw new \Exception("Not found", 404);
        }

        $this->dm->remove($share);
        $this->dm->flush();
    }


    public function map(array $data, UserDocument $owner, ShareDocument $share = null)
    {
        if (is_null($share)) {
            $share = new ShareDocument();
            $share->setCreateDate(new \DateTime());

        } else {
            $share->setUpdateDate(new \DateTime());

        }

        $setIfExistFields = array('title', 'notification', 'createDate', 'updateDate');

        foreach ($setIfExistFields as $field) {
            if (isset($data[$field]) && !is_null($data[$field])) {
                $share->{"set{$field}"}($data[$field]);
            }
        }

        $share->addNotification(new \Document\Share($data));
        $share->setOwner($owner);

        return $share;
    }

    protected function _toArrayAll($results)
    {
        $share = array();
        foreach ($results as $data) {
            $share[] = $data->toArray();
        }

        return $share;
    }
}

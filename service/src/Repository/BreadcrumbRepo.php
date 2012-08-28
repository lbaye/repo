<?php

namespace Repository;

use Doctrine\ODM\MongoDB\DocumentRepository;
use Document\Breadcrumb as BreadcrumbDocument;
use Document\User as UserDocument;
use Repository\UserRepo as UserRepository;
use Helper\Image as ImageHelper;

class BreadcrumbRepo extends DocumentRepository
{
    public function getByUser(UserDocument $user)
    {
        $breadcrumb = $this->findBy(array('owner' => $user->getId()));
        return $this->_toArrayAll($breadcrumb);
    }

    public function getAll($limit = 20, $offset = 0)
    {
        $results = $this->findBy(array(), null, $limit, $offset);
        return $this->_toArrayAll($results);
    }

    public function insert(BreadcrumbDocument $breadcrumb)
    {
        $valid = $breadcrumb->isValid();

        if ($valid !== true) {
            throw new \InvalidArgumentException('Invalid breadcrumb data', 406);
        }


        $this->dm->persist($breadcrumb);
        $this->dm->flush($breadcrumb);

        return $breadcrumb;
    }

    public function update($data, $id)
    {
        $breadcrumb = $this->find($id);

        if (false === $breadcrumb) {
            throw new \Exception\ResourceNotFoundException();
        }

        $breadcrumb = $this->map($data, $breadcrumb->getOwner(), $breadcrumb);

        if ($breadcrumb->isValid() === false) {
            return false;
        }

        $this->dm->persist($breadcrumb);
        $this->dm->flush();

        return $breadcrumb;
    }

    public function addPhoto($data, $id)
    {
        $breadcrumb = $this->find($id);

        if (false === $breadcrumb) {
            throw new \Exception\ResourceNotFoundException();
        }

        $breadcrumb = $this->mapPhoto($data, $breadcrumb->getOwner(), $breadcrumb);
       //ImageHelper::saveImageFromBase64($breadcrumb->getImage());

        $this->dm->persist($breadcrumb);
        $this->dm->flush();

        return $breadcrumb;
    }

    public function delete($id)
    {
        $breadcrumb = $this->find($id);

        if (is_null($breadcrumb)) {
            throw new \Exception("Not found", 404);
        }

        $this->dm->remove($breadcrumb);
        $this->dm->flush();
    }

    public function map(array $data, UserDocument $owner, BreadcrumbDocument $breadcrumb = null)
    {
        if (is_null($breadcrumb)) {
            $breadcrumb = new BreadcrumbDocument();
            $breadcrumb->setCreateDate(new \DateTime());

        } else {
            $breadcrumb->setUpdateDate(new \DateTime());

        }

        $setIfExistFields = array('title', 'position', 'createDate', 'updateDate');

        foreach ($setIfExistFields as $field) {
            if (isset($data[$field]) && !is_null($data[$field])) {
                $breadcrumb->{"set{$field}"}($data[$field]);
            }
        }

        $breadcrumb->addPosition(new \Document\Position($data));

        $breadcrumb->setOwner($owner);

        return $breadcrumb;
    }

    public function mapPhoto(array $data, UserDocument $owner, BreadcrumbDocument $breadcrumb = null)
    {
        if (is_null($breadcrumb)) {
            $breadcrumb = new BreadcrumbDocument();
            $breadcrumb->setCreateDate(new \DateTime());

        } else {
            $breadcrumb->setUpdateDate(new \DateTime());

        }

        $setIfExistFields = array('position', 'createDate', 'updateDate');

        foreach ($setIfExistFields as $field) {
            if (isset($data[$field]) && !is_null($data[$field])) {
                $breadcrumb->{"set{$field}"}($data[$field]);
            }
        }

        $breadcrumb->addPosition(new \Document\Position($data));

        $breadcrumb->setOwner($owner);

        return $breadcrumb;
    }

    protected function _toArrayAll($results)
    {
        $breadcrumb = array();
        foreach ($results as $data) {
            $breadcrumb[] = $data->toArray();
        }

        return $breadcrumb;
    }
}
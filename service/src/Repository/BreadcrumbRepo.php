<?php

namespace Repository;

use Doctrine\ODM\MongoDB\DocumentRepository;
use Document\Breadcrumb as BreadcrumbDocument;
use Document\User as UserDocument;
use Repository\UserRepo as UserRepository;
use Helper\Image as ImageHelper;

class BreadcrumbRepo extends Base
{
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
}
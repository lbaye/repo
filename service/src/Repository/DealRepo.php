<?php

namespace Repository;

use Doctrine\ODM\MongoDB\DocumentRepository;
use Document\Deal as DealDocument;
use Document\User as UserDocument;
use Helper\Security as SecurityHelper;

class DealRepo extends DocumentRepository
{

    public function getAll($limit = 20, $offset = 0)
    {

        $results = $this->findBy(array(), null, $limit, $offset);
        return $this->_toArrayAll($results);

    }

    public function getNearBy($lat, $lng, $limit = 20)
    {
        $deals = $this->createQueryBuilder()
            ->field('location.lat')->near($lat)
            ->field('location.lng')->near($lng)
            ->limit($limit)
            ->getQuery()->execute();

        return (count($deals))? $this->_toArrayAll($deals) : array();
    }

    public function insert(DealDocument $deal)
    {
        $valid  = $deal->isValid();

        if ($valid !== true) {
            throw new \InvalidArgumentException('Invalid Location data', 406);
        }

        $this->dm->persist($deal);
        $this->dm->flush($deal);

        return $deal;
    }

    public function update($data, $id)
    {
        $deal = $this->find($id);

        if (false === $deal) {
            throw new \Exception\ResourceNotFoundException();
        }

        $deal = $this->map($data, $deal);

        if ($deal->isValid() === false) {
            return false;
        }

        $this->dm->persist($deal);
        $this->dm->flush();

        return $deal;
    }

    public function delete($id)
    {
        $place = $this->find($id);

        if (is_null($place)) {
            throw new \Exception("Not found", 404);
        }

        $this->dm->remove($place);
        $this->dm->flush();
    }

    public function map(array $data, DealDocument $deal = null)
    {
        if(is_null($deal)){
            $deal = new DealDocument();
            $deal->setCreateDate(new \DateTime());
        } else {
            $deal->setUpdateDate(new \DateTime());
        }

        $setIfExistFields = array('title', 'description', 'link', 'maplink', 'category', 'expiration');

        foreach($setIfExistFields as $field) {
            if (isset($data[$field]) && !is_null($data[$field])) {
                $deal->{"set{$field}"}($data[$field]);
            }
        }

        if(isset($data['lng']) && isset($data['lat'])) {
            $deal->setLocation(array('lng' => floatval($data['lng']), 'lat' => floatval($data['lat'])));
        }
        return $deal;
    }

    private function _toArrayAll($results)
    {
        $deals = array();
        foreach ($results as $deal) {
            $deals[] = $deal->toArray();
        }

        return $deals;
    }
}
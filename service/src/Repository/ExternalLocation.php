<?php

namespace Repository;

use Doctrine\ODM\MongoDB\DocumentRepository;
use Document\ExternalLocation as ExternalLocationDocument;

class ExternalLocation extends DocumentRepository
{
    public function insertFromFacebook($data)
    {
        $externalLocation = $this->map($data);

        $this->dm->persist($externalLocation);
        $this->dm->flush();

        return $externalLocation;
    }

    public function map(array $data, ExternalLocationDocument $externalLocation = null)
    {
        if (is_null($externalLocation)) {
            $externalLocation = new ExternalLocationDocument();
        }

        $setIfExistFields = array(
            'id'          => 'refId',
            'author_uid'  => 'refUserId',
            'page_id'     => 'refLocationId',
            'type'        => 'refType',
            'coords'      => 'coords',
            'timestamp'   => 'refTimestamp',
            'tagged_uids' => 'refTaggedUserIds',
            'source'      => 'source'
        );

        foreach ($setIfExistFields as $externalField => $field) {
            if (isset($data[$externalField]) && !is_null($data[$externalField])) {
                $method = "set" . ucfirst($field);
                $externalLocation->$method($data[$externalField]);
            }
        }

        return $externalLocation;
    }
}
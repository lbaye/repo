<?php

namespace Repository;

use Symfony\Component\HttpFoundation\Response;
use Doctrine\ODM\MongoDB\DocumentRepository;
use Document\User as UserDocument;
use Repository\UserRepo as UserRepository;
use Document\Photo as Photo;
use Helper\Security as SecurityHelper;
use Helper\Image as ImageHelper;

class PhotosRepo extends Base
{
    public function map(array $data, Photo $photo = null)
    {
        if (is_null($photo)) $photo = new Photo();
        foreach ($data as $key => $value) $photo->{'set' . ucfirst($key)}($value);

        return $photo;
    }
}
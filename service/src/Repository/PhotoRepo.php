<?php

namespace Repository;

use Symfony\Component\HttpFoundation\Response;
use Doctrine\ODM\MongoDB\DocumentRepository;
use Document\User as UserDocument;
use Repository\UserRepo as UserRepository;
use Document\Photo as PhotoDocument;
use Helper\Security as SecurityHelper;
use Helper\Image as ImageHelper;

class PhotoRepo extends Base
{

    public function map(array $data, PhotoDocument $photo = null)
    {
        if (is_null($photo)) {
            $photo = new PhotoDocument();
        }

        $setIfExistFields = array(
            'id',
            'fileName',
            'mimeType',
            'uploadDate',
            'updateDate'
        );

        foreach ($setIfExistFields as $field) {
            if (isset($data[$field]) && !is_null($data[$field])) {
                $photo->{"set{$field}"}($data[$field]);
            }
        }

        return $photo;
    }


    protected function _toArrayAll($results, $filterFields = false)
    {
        $photoInfo = array();
        foreach ($results as $photo) {
            $photoArr = ($filterFields) ? $photo->toArrayFiltered($this->currentUser) : $photo->toArray();

            $photoArr['photo'] = $this->_buildPhotoUrl($photoArr);
            $photoInfo[] = $photoArr;

        }

        return $photoInfo;
    }

    public function savePhoto($id, $photo)
    {
        $user = $this->find($id);

        if (false === $user) {
            throw new \Exception\ResourceNotFoundException();
        }

        $user->setUpdateDate(new \DateTime());

        $timeStamp = $user->getUpdateDate()->getTimestamp();

        $filePath = "/images/photos/" . $user->getId();
        $avatarUrl = filter_var($photo, FILTER_VALIDATE_URL);

        if ($avatarUrl !== false) {
            $user->setAvatar($avatarUrl);
        } else {
            @ImageHelper::saveImageFromBase64($photo, ROOTDIR . $filePath);
            $user->setAvatar($filePath . "?" . $timeStamp);
        }


        $this->dm->persist($user);
        $this->dm->flush();

        return $user;
    }

}
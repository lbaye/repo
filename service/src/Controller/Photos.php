<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;
use Helper\Status;
use Repository\UserRepo as userRepository;
use Repository\PhotosRepo as photoRepository;
use Document\Photo as photoDocument;
use Helper\Image as ImageHelper;

class Photos extends Base
{
    private $photoRepo;

    public function init()
    {
        parent::init();

        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->photoRepo = $this->dm->getRepository('Document\Photo');
        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);

        $this->_ensureLoggedIn();
    }

    public function create()
    {

        $postData = $this->request->request->all();

        $imageData = $postData['image'];

        $user = $this->user;
        $user->setUpdateDate(new \DateTime());
        $timeStamp = $user->getUpdateDate()->getTimestamp();

        # Ensure directory is created
        $dirPath = '/images/photos/' . $user->getId();

        if(!file_exists(ROOTDIR. "/" .$dirPath)) {
           mkdir(ROOTDIR ."/". $dirPath, 0777, true);
        }

        $filePath = $dirPath . '/' . (time() * rand(100, 1000)) . '.jpg';

        $photoUrl = filter_var($imageData, FILTER_VALIDATE_URL);

        if ($photoUrl !== false) {
            $uri = $photoUrl;
        } else {
            ImageHelper::saveImageFromBase64($imageData, ROOTDIR . $filePath);
            $uri = $filePath . "?" . $timeStamp;
        }

        $photo = $this->photoRepo->set_photo($user, $postData['title'], $postData['description'], $uri, $postData['lat'], $postData['lng']);
       // $photo = $this->photoRepo->map($postData, $user);

        $this->photoRepo->insert($photo);


        return $this->_generateResponse($photo->toArray(), Status::CREATED);
    }


    public function getByAuthenticatedUser()
    {
        $photos = $this->photoRepo->getByUser($this->user);
        if (count($photos) > 0) {
            return $this->_generateResponse($this->_toArrayAll($photos->toArray()));
        } else {
            return $this->_generateResponse(null, Status::NO_CONTENT);
        }
    }

    public function getById($id){

        $user = $this->userRepository->find($id);
        $photos = $this->photoRepo->getByUser($user);
        return $this->_generateResponse($this->_toArrayAll($photos->toArray()));
    }

    public function update($id){

        $data = $this->request->request->all();
        $photo = $this->photoRepo->find($id);

        if(empty($photo) || $photo->getOwner() != $this->user){
          return $this->_generateUnauthorized();
        }

        $photo = $this->photoRepo->update($data, $id);
        return $this->_generateResponse($photo->toArray(), Status::OK);


    }

    public function delete($id){
        $photo = $this->photoRepo->find($id);

        if(empty($photo) || $photo->getOwner() != $this->user){
            return $this->_generateUnauthorized();
        }

        try {
            $this->photoRepo->delete($id);
        } catch (\Exception $e) {
            $this->_generateException($e);
        }
        return $this->_generateResponse(array('message'=>'Deleted Successfully'));


    }


    private function imageResize($maxWidth, $maxHeight, $image)
    {

        // Get current dimensions
        $oldWidth = imagesx($image);
        $oldHeight = imagesy($image);

        // Calculate the scaling we need to do to fit the image inside our frame
        $scale = min($maxWidth / $oldWidth, $maxHeight / $oldHeight);

        // Get the new dimensions
        $newWidth = ceil($scale * $oldWidth);
        $newHeight = ceil($scale * $oldHeight);

        // Create new empty image
        $new = imagecreatetruecolor($newWidth, $newHeight);

        // Resize old image into new
        imagecopyresampled($new, $image,
            0, 0, 0, 0,
            $newWidth, $newHeight, $oldWidth, $oldHeight);

        // Catch the imagedata
        ob_start();
        imagejpeg($new, NULL, 90);
        $data = ob_get_clean();


        // Destroy resources
        imagedestroy($image);
        imagedestroy($new);

        return $data;
    }


}
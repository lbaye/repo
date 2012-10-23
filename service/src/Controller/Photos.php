<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;
use Helper\Status;
use Repository\UserRepo as userRepository;
use Repository\PhotosRepo as photoRepository;
use Document\Photo as  photoDocument;

class Photos extends Base
{
    private $photoRepo;

    public function init()
    {
        $this->response = new Response();
        $this->response->headers->set('Content-Type', 'application/json');

        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->photoRepo = $this->dm->getRepository('Document\Photo');
        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);

        $this->_ensureLoggedIn();
    }

    # TODO Check authentication
    public function create() {
        $postData = $this->request->request->all();
        // Check if file was uploaded ok
        if (!is_uploaded_file($_FILES['image']['tmp_name']) || $_FILES['image']['error'] !== UPLOAD_ERR_OK) {
            $this->response->setContent(json_encode(array('message' => 'File not uploaded. Possibly too large.')));
            $this->response->setStatusCode(Status::NOT_ACCEPTABLE);
            return $this->response;
        }

        // Create image from file
        switch (strtolower($_FILES['image']['type'])) {
            case 'image/jpeg':
                $image = imagecreatefromjpeg($_FILES['image']['tmp_name']);
                break;
            case 'image/png':
                $image = imagecreatefrompng($_FILES['image']['tmp_name']);
                break;
            case 'image/gif':
                $image = imagecreatefromgif($_FILES['image']['tmp_name']);
                break;
            default:
                $this->response->setContent(json_encode(array('message' => 'Unsupported type: ' . $_FILES['image']['type'])));
                $this->response->setStatusCode(Status::NOT_ACCEPTABLE);
                return $this->response;
        }

        // Target dimensions
        $maxWidth = 240;
        $maxHeight = 180;

        $data = $this->imageResize($maxWidth,$maxHeight,$image);

        // Output data
        echo $data;
//        var_dump($postData);
        exit;
        $photo = $this->photoRepo->map($postData);

        $photo = $this->photoRepo->insert($photo);
        $this->response->setContent(json_encode($photo));
        $this->response->setStatusCode(Status::CREATED);
        return $this->response;
    }

    public function imageResize($maxWidth,$maxHeight,$image)
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
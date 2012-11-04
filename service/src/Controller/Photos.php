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

        $thumbWidth = $this->config['imagetype']['thumb']['width'];
        $thumbHeight = $this->config['imagetype']['thumb']['height'];

        $mediumWidth = $this->config['imagetype']['medium']['width'];
        $mediumHeight = $this->config['imagetype']['medium']['height'];

        $largeWidth = $this->config['imagetype']['large']['width'];
        $largeHeight = $this->config['imagetype']['large']['height'];

        # Ensure directory is created
        $dirPath = '/images/photos/' . $user->getId();

        $thumbPath = $dirPath . "/thumb";
        $mediumPath = $dirPath . "/medium";
        $largePath = $dirPath . "/large";

        if (!file_exists(ROOTDIR . "/" . $thumbPath)) {
            mkdir(ROOTDIR . "/" . $thumbPath, 0777, true);
        }

        if (!file_exists(ROOTDIR . "/" . $mediumPath)) {
            mkdir(ROOTDIR . "/" . $mediumPath, 0777, true);
        }

        if (!file_exists(ROOTDIR . "/" . $largePath)) {
            mkdir(ROOTDIR . "/" . $largePath, 0777, true);
        }

        $fileThumbPath = $thumbPath . '/' . (time() * rand(100, 1000)) . '.jpg';
        $fileMediumPath = $mediumPath . '/' . (time() * rand(100, 1000)) . '.jpg';
        $fileLargePath = $largePath . '/' . (time() * rand(100, 1000)) . '.jpg';
        $photoUrl = filter_var($imageData, FILTER_VALIDATE_URL);

        if ($photoUrl !== false) {
            $uri = $photoUrl;
        } else {
            $tPath = ROOTDIR . $fileThumbPath;
            $mPath = ROOTDIR . $fileMediumPath;
            $lPath = ROOTDIR . $fileLargePath;
            ImageHelper::saveResizeImageFromBase64($imageData, $tPath, $mPath, $lPath,
                                                   $thumbWidth, $thumbHeight,
                                                   $mediumWidth, $mediumHeight,
                                                   $largeWidth, $largeHeight);
            $uriThumb = $fileThumbPath . "?" . $timeStamp;
            $uriMedium = $fileMediumPath . "?" . $timeStamp;
            $uriLarge = $fileLargePath . "?" . $timeStamp;
        }
        $postData['uriThumb'] = $uriThumb;
        $postData['uriMedium'] = $uriMedium;
        $postData['uriLarge'] = $uriLarge;

        $photo = $this->photoRepo->map($postData, $this->user);
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

     /**
     * POST /photos/{id}/like
     *
     * @param $id
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function likePhoto($id)
    {
        $postData = $this->request->request->all();
        $photo = $this->photoRepo->find($id);

        if (!empty($postData['like'])) {
            foreach ($postData['like'] as $userId) {
                $likeUser = $this->userRepository->find($userId);

                if ($photo instanceof \Document\Photo) {
                    if (!in_array($likeUser->getId(), $photo->getLike())) {
                        $photo->addLikedUser($likeUser->getId());
                        $this->dm->persist($photo);
                        $this->dm->flush();
                        $this->response->setContent(json_encode(array('message' => 'Done')));
                        $this->response->setStatusCode(Status::OK);
                    } else {
                        $this->response->setContent(json_encode(array('message' => 'You already like this photo.')));
                        $this->response->setStatusCode(Status::BAD_REQUEST);
                    }

                }
            }
        }
        return $this->response;
    }

    /**
     * POST /photos/{id}/dislike
     *
     * @param $id
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function dislikePhoto($id)
    {
        $postData = $this->request->request->all();
        $photo = $this->photoRepo->find($id);

        if (!empty($postData['dislike'])) {
            foreach ($postData['dislike'] as $userId) {
                $dislikeUser = $this->userRepository->find($userId);

                if ($photo instanceof \Document\Photo) {
                    if (in_array($dislikeUser->getId(), $photo->getLike())) {
                        $removeDislikeUser = array_diff($photo->getLike(), array($dislikeUser->getId()));
                        $photo->setLikedUser($removeDislikeUser);
                        $this->dm->persist($photo);
                        $this->dm->flush();
                        $this->response->setContent(json_encode(array('message' => 'Done')));
                        $this->response->setStatusCode(Status::OK);
                    } else {
                        $this->response->setContent(json_encode(array('message' => 'You never like this photo.')));
                        $this->response->setStatusCode(Status::BAD_REQUEST);
                    }

                }
            }
        }
        return $this->response;
    }

     /**
     * POST /photos/{id}/comments
     *
     * @param $id
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function createComment($id)
    {
        $postData = $this->request->request->all();
        $photo = $this->photoRepo->find($id);
        if (!empty($postData['message']) && !empty($postData['userId'])) {
            $comments = $this->photoRepo->addComments($id, $postData);
            $this->response->setContent(json_encode(array('message' => 'Your comment added Successfully.')));
            $this->response->setStatusCode(Status::OK);
        } else {
            $this->response->setContent(json_encode(array('message' => 'Not added.')));
            $this->response->setStatusCode(Status::BAD_REQUEST);
        }
        return $this->response;
    }

    /**
     * POST /photos/{id}/comments/{commentId}
     *
     * @param $id
     * @param $commentId
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function deleteCommentById($id,$commentId)
    {
        $photoComment = $this->photoRepo->find($id);
        if (empty($photoComment) || $photoComment->getOwner() != $this->user) {
            return $this->_generateUnauthorized();
        }
        $i = 0;
        foreach ($photoComment->getPhotoComment() as $property) {

            if ($property->getId() == $commentId) {
                $photoComment->getPhotoComment()->removeElement($property);
                $this->dm->flush($photoComment);
                $i = 1;
                $this->response->setContent(json_encode(array('message' => 'Deleted successfully.')));
                $this->response->setStatusCode(Status::OK);
            }
        }
        if ($i == 0) {
            $this->response->setContent(json_encode(array('message' => 'Your request is not exist.')));
            $this->response->setStatusCode(Status::BAD_REQUEST);
        }

        return $this->response;
    }

}
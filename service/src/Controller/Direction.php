<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;
use Document\User;
use Repository\DirectionRepo as directionRepository;
use Document\Direction as DirectionDocument;

use Helper\Status;

/**
 * Manage user direction sharing related resources
 */
class Direction extends Base
{
    /**
     * @var directionRepository
     */

    private $directionRepository;

    public function init()
    {
        parent::init();

        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->directionRepository = $this->dm->getRepository('Document\Direction');

        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);
        $this->_ensureLoggedIn();

    }

    /**

     * GET /direction/share/
     *
     * Share direction with the selected friends
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function index()
    {
        $this->_initRepository('direction');
        $postData = $this->request->request->all();

        $direction         = $this->directionRepository->map($postData, $this->user);
        $directionLocation = $this->directionRepository->insert($direction);

        $notificationData = array(
            'title' => $this->user->getName() . " shared a direction with you",
            'message' => "{$this->user->getName()} has shared a direction with you",
            'objectId' => $direction->getId(),
            'objectType' => 'direction',
        );

        if (!empty($directionLocation)) {

            \Helper\Notification::send($notificationData, $this->userRepository->getAllByIds($postData['permittedUsers'], false) );
            $this->_sendPushNotification($postData['permittedUsers'], $this->_createPushMessage(), 'direction_share');
            return $this->_generateResponse($directionLocation->toArray(), Status::CREATED);

        } else {
            return $this->_generateResponse(array('message' => 'No direction found'), Status::NO_CONTENT);
        }
    }

    private function _createPushMessage()
    {
        return $this->user->getUsernameOrFirstName() . " has shared a direction with you.";
    }

    private function _initRepository($type)
    {
       if ($type == 'direction') {
           $this->directionRepository = $this->dm->getRepository('Document\Direction');
       }
    }

}
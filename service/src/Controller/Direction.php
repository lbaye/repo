<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;
use Document\User;
use Repository\DirectionRepo as directionRepository;
use Document\Direction as DirectionDocument;

use Helper\Status;


class Direction extends Base
{
    /**
     * @var directionRepository
     */

    private $directionRepository;

     /**
     * Initialize the controller.
     */
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
     * @return \Symfony\Component\HttpFoundation\Response
     */

    public function index()
    {
        $this->_initRepository('direction');
        $latlngInfo = $this->request->request->all();

        $direction         = $this->directionRepository->map($latlngInfo, $this->user);
        $directionLocation = $this->directionRepository->insert($direction);

        $notification  = new \Document\Notification();

        $notificationData = array(
            'title' => $this->user->getName() . " shared an direction Request",
            'message' => "{$this->user->getName()} has shared direction with you",
            'objectId' => $direction->getId(),
            'objectType' => 'direction',
        );

        \Helper\Notification::send($notificationData, $this->userRepository->getAllByIds($latlngInfo['permittedUsers'], false) );

        if (!empty($directionLocation)) {
            return $this->_generateResponse($directionLocation->toArray(), Status::CREATED);
        } else {
            return $this->_generateResponse(array('message' => 'No direction found'), Status::NO_CONTENT);
        }
    }

    private function _initRepository($type)
    {
       if ($type == 'direction') {
           $this->directionRepository = $this->dm->getRepository('Document\Direction');
       }
    }

}
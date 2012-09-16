<?php

namespace Service\Notification;

class SocialMaps extends Base
{
    public function send(array $data, array $users)
    {

    }

    private function _createNotificationData($friend)
    {
        return array(
            'title' => 'Your friend is here!',
            'photoUrl' => $friend->getAvatar(),
            'objectId' => $friend->getId(),
            'objectType' => 'proximity_alert',
            'message' => 'Your friend '. $friend->getName() .' is near your location!',
        );
    }
}
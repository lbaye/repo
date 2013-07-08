<?php

namespace Helper;

/**
 * Utility method for storing notification
 */
class Notification
{
    public static function send($data, $users)
    {
        foreach($users as $receiver) {
            if($receiver) {

                $receiver->addNotification(new \Document\Notification($data));
                Dependencies::$dm->persist($receiver);
            }
        }

        Dependencies::$dm->flush();
    }
}
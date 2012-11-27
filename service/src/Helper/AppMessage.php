<?php
namespace Helper;
 
class AppMessage {
    const FRIEND_REQUEST = 'friend_request';
    const ACCEPTED_FRIEND_REQUEST = 'accepted_request';
    const MEETUP_REQUEST = 'meetup';
    const EVENT_GUEST_REQUEST = 'event_guest';
    const NEW_MESSAGE = 'new_message';
    const REPLY_MESSAGE = 'reply_message';
    const RECOMMEND_VENUE_MESSAGE = 'recommend_venue';
    const RECOMMEND_PLACE_MESSAGE = 'recommend_place';
    const RECOMMEND_GEOTAG_MESSAGE = 'recommend_geotag';

    /**
     * List of notification messages
     */
    static $MESSAGES = array(
        self::FRIEND_REQUEST => '%s added you as a friend.',
        self::MEETUP_REQUEST => '%s wants to meet you %s',
        self::EVENT_GUEST_REQUEST => '%s has invited you in %s',
        self::NEW_MESSAGE => 'New message from %s',
        self::REPLY_MESSAGE => 'New reply from %s',
        self::RECOMMEND_VENUE_MESSAGE => '%s has recommended you at %s',
        self::RECOMMEND_PLACE_MESSAGE => '%s has recommended you at %s',
        self::RECOMMEND_GEOTAG_MESSAGE => '%s has recommended you at %s',
        self::ACCEPTED_FRIEND_REQUEST => '%s has accepted your friend request'
    );

    public static function getMessage($key) {
        if (func_num_args() > 1) {
            return call_user_func_array(
                'sprintf', array_merge(array(self::$MESSAGES[$key]), array_slice(func_get_args(), 1)));
        } else
            return self::$MESSAGES[$key];
    }
}


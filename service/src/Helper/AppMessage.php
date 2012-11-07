<?php
namespace Helper;
 
class AppMessage {
    const FRIEND_REQUEST = 'friend_request';
    const MEETUP_REQUEST = 'meetup';
    const EVENT_GUEST_REQUEST = 'event_guest';
    const NEW_MESSAGE = 'new_message';
    const REPLY_MESSAGE = 'reply_message';

    /**
     * List of notification messages
     */
    static $MESSAGES = array(
        self::FRIEND_REQUEST => '%s added you as a friend.',
        self::MEETUP_REQUEST => '%s wants to meet you %s',
        self::EVENT_GUEST_REQUEST => '%s has invited you in %s',
        self::NEW_MESSAGE => 'New message from %s',
        self::REPLY_MESSAGE => 'New reply from %s'
    );

    public static function getMessage($key) {
        if (func_num_args() > 1) {
            return call_user_func_array(
                'sprintf', array_merge(array(self::$MESSAGES[$key]), array_slice(func_get_args(), 1)));
        } else
            return self::$MESSAGES[$key];
    }
}


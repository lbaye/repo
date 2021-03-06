<?php
namespace Helper;

/**
 * Location sharing related constants
 */
class ShareConstant {

    //Share location,profile picture and news feed
    const SHARING_ALL_USERS  = 1;
    const SHARING_FRIENDS    = 2;
    const SHARING_NO_ONE     = 3;
    const SHARING_CIRCLES    = 4;
    const SHARING_CUSTOM     = 5;

    //Meetup expire unit minutes
    const MEETUP_EXPIRE     = 120;

    //Event expire unit minutes
    const EVENT_EXPIRE     = 1440;
}
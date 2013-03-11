//
//  Constants.h
//  SocialMaps
//
//  Created by Arif Shakoor on 7/23/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file Constants.h
 * @brief Stores constants and singleton object.
 */

extern NSString * const WS_URL;
extern NSString * const NOTIF_LOGIN_DONE;
extern NSString * const NOTIF_REG_DONE;
extern NSString * const NOTIF_FORGOT_PW_DONE;
extern NSString * const NOTIF_FBLOGIN_DONE;
extern NSString * const NOTIF_FB_REG_DONE;
extern NSString * const FB_APPID;
extern NSString * const NOTIF_GET_PLATFORM_DONE;
extern NSString * const NOTIF_GET_LAYER_DONE;
extern NSString * const NOTIF_GET_SHARING_PREFS_DONE;
extern NSString * const NOTIF_GET_ACCT_SETTINGS_DONE;
extern NSString * const NOTIF_GET_GEOFENCE_DONE;
extern NSString * const NOTIF_GET_SHARELOC_DONE;
extern NSString * const NOTIF_GET_NOTIFS_DONE;
extern NSString * const NOTIF_GET_LISTINGS_DONE;
extern NSString * const NOTIF_GET_FRIEND_REQ_DONE;
extern NSString * const NOTIF_GET_INBOX_DONE;
extern NSString * const NOTIF_GET_REPLIES_DONE;
extern NSString * const NOTIF_GET_NOTIFICATIONS_DONE;
extern NSString * const NOTIF_FBFRIENDLIST_DONE;
extern NSString * const NOTIF_GET_ALL_EVENTS_DONE;
extern NSString * const NOTIF_GET_EVENTS_BY_USERID_DONE;
extern NSString * const NOTIF_GET_EVENT_DETAIL_DONE;
extern NSString * const NOTIF_DELETE_EVENT_DONE;
extern NSString * const NOTIF_CREATE_EVENT_DONE;
extern NSString * const NOTIF_SET_RSVP_EVENT_DONE;
extern NSString * const NOTIF_UPDATE_EVENT_DONE;
extern NSString * const NOTIF_INVITE_FRIENDS_EVENT_DONE;
extern NSString * const NOTIF_GET_BASIC_PROFILE_DONE;
extern NSString * const NOTIF_UPDATE_BASIC_PROFILE_DONE;
extern NSString * const NOTIF_GET_MY_PLACES_DONE;
extern NSString * const NOTIF_GET_MEET_UP_REQUEST_DONE;
extern NSString * const NOTIF_SEND_MEET_UP_REQUEST_DONE;
extern NSString * const NOTIF_UPDATE_MEET_UP_REQUEST_DONE;
extern NSString * const NOTIF_PUSH_NOTIFICATION_RECEIVED;
extern NSString * const NOTIF_SET_MESSAGE_STATUS_DONE;
extern NSString * const NOTIF_SEND_FRIEND_REQUEST_DONE;
extern NSString * const NOTIF_GET_ALL_CIRCLES_DONE;
extern NSString * const NOTIF_CREATE_CIRCLE_DONE;
extern NSString * const NOTIF_UPDATE_CIRCLE_DONE;
extern NSString * const NOTIF_GET_ALL_BLOCKED_USERS_DONE;
extern NSString * const NOTIF_SET_BLOCKED_USERS_DONE;
extern NSString * const NOTIF_SET_UNBLOCKED_USERS_DONE;
extern NSString * const NOTIF_GET_ALL_EVENTS_FOR_MAP_DONE;
extern NSString * const NOTIF_GET_OTHER_USER_PROFILE_DONE;
extern NSString * const NOTIF_DO_CONNECT_FB_DONE;
extern NSString * const NOTIF_DO_CONNECT_WITH_FB;
extern NSString * const NOTIF_DO_UPLOAD_PHOTO;
extern NSString * const NOTIF_GET_USER_ALL_PHOTO;
extern NSString * const NOTIF_DELETE_USER_PHOTO_DONE;
extern NSString * const NOTIF_GET_FRIENDS_ALL_PHOTO;
extern NSString * const NOTIF_GET_PHOTO_FOR_GEOTAG;
extern NSString * const NOTIF_CREATE_GEOTAG_DONE;
extern NSString * const NOTIF_GET_ALL_GEOTAG_DONE;
extern NSString * const NOTIF_GET_PLACES_DONE;
extern NSString * const NOTIF_DELETE_USER_CIRCLE_DONE;
extern NSString * const NOTIF_RENAME_USER_CIRCLE_DONE;
extern NSString * const NOTIF_GET_FRIEND_LIST_DONE;
extern NSString * const NOTIF_CREATE_PLAN_DONE;
extern NSString * const NOTIF_GET_ALL_PLANS_DONE;
extern NSString * const NOTIF_GET_FRIENDS_PLANS_DONE;
extern NSString * const NOTIF_DELETE_PLANS_DONE;
extern NSString * const NOTIF_UPDATE_PLANS_DONE;
extern NSString * const NOTIF_FRIENDS_REQUEST_ACCEPTED;
extern NSString * const NOTIF_LOCATION_SHARING_SETTING_DONE;
extern NSString * const NOTIF_GET_MESSAGE_WITH_ID_DONE;
extern NSString * const NOTIF_SEND_REPLY_DONE;
extern NSString * const NOTIF_GET_NEW_THREAD_DONE;
extern NSString * const SET_SHARE_LOCATION_DONE;

// Font related stuff
extern NSString * const kFontName;
extern NSString * const kFontNameBold;
extern float const kStatusFontSize;
extern float const kLabelFontSize;
extern float const kBenefitFontSize;
extern float const kNumbersFontSize;
extern float const kNumbersLargeFontSize;
extern float const kSmallNumbersFontSize;
extern float const kLargeLabelFontSize;
extern float const kMediumLabelFontSize;
extern float const kSmallLabelFontSize;
extern float const kNumberRGBRed;
extern float const kNumberRGBGreen;
extern float const kNumberRGBBlue;

// Maximum number of visible annotation
extern int const MAX_VISIBLE_ANNO;

/**
 * comment the next line out to disable debug logging
 * when bundling the Application for Production
 */
#define DEBUG_MODE

#ifdef DEBUG_MODE
#define DebugLog( s, ... ) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DebugLog( s, ... )
#endif

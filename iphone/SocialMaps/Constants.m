//
//  Constants.m
//  SocialMaps
//
//  Created by Arif Shakoor on 7/23/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "Constants.h"

NSString * const WS_URL = @"http://services.socialmapsapp.com/prodtest";
//http://services.socialmapsapp.com/v2_4";
NSString * const NOTIF_LOGIN_DONE = @"com.genweb2.socialmaps.logindone";
NSString * const NOTIF_REG_DONE = @"com.genweb2.socialmaps.regdone";
NSString * const NOTIF_FORGOT_PW_DONE = @"com.genweb2.socialmaps.forgotpwdone";
NSString * const NOTIF_FBLOGIN_DONE = @"com.genweb2.socialmaps.fblogindone";
NSString * const NOTIF_FB_REG_DONE= @"com.genweb2.socialmaps.fbregdone";
NSString * const NOTIF_SETPROFILE_DONE = @"com.genweb2.socialmaps.setprofiledone";
NSString * const NOTIF_GET_PLATFORM_DONE= @"com.genweb2.socialmaps.getplatformdone";
NSString * const NOTIF_GET_LAYER_DONE= @"com.genweb2.socialmaps.getlayerdone";
NSString * const NOTIF_GET_SHARING_PREFS_DONE= @"com.genweb2.socialmaps.getsharingprefsdone";
NSString * const NOTIF_GET_ACCT_SETTINGS_DONE= @"com.genweb2.socialmaps.getacctsettingsdone";
NSString * const NOTIF_GET_GEOFENCE_DONE= @"com.genweb2.socialmaps.getgeofencedone";
NSString * const NOTIF_GET_SHARELOC_DONE= @"com.genweb2.socialmaps.getsharelocdone";
NSString * const NOTIF_GET_NOTIFS_DONE= @"com.genweb2.socialmaps.getnotifsdone";
NSString * const NOTIF_GET_LISTINGS_DONE= @"com.genweb2.socialmaps.getlistingsdone";
NSString * const NOTIF_GET_FRIEND_REQ_DONE= @"com.genweb2.socialmaps.getfriendrequestdone";
NSString * const NOTIF_GET_INBOX_DONE= @"com.genweb2.socialmaps.getinboxdone";
NSString * const NOTIF_GET_REPLIES_DONE= @"com.genweb2.socialmaps.getrepliesdone";
NSString * const NOTIF_GET_NOTIFICATIONS_DONE= @"com.genweb2.socialmaps.getnotificationsdone";
NSString * const NOTIF_FBFRIENDLIST_DONE= @"com.genweb2.socialmaps.fbfriendlistdone";
NSString * const NOTIF_GET_ALL_EVENTS_DONE= @"com.genweb2.socialmaps.getalleventsdone";
NSString * const NOTIF_GET_EVENTS_BY_USERID_DONE= @"com.genweb2.socialmaps.geteventsbyuserid";
NSString * const NOTIF_GET_EVENT_DETAIL_DONE= @"com.genweb2.socialmaps.geteventdetaildone";
NSString * const NOTIF_DELETE_EVENT_DONE= @"com.genweb2.socialmaps.deleteeventdone";
NSString * const NOTIF_CREATE_EVENT_DONE= @"com.genweb2.socialmaps.createeventdone";
NSString * const NOTIF_SET_RSVP_EVENT_DONE= @"com.genweb2.socialmaps.setrsvpeventdone";
NSString * const NOTIF_UPDATE_EVENT_DONE= @"com.genweb2.socialmaps.updateeventdone";
NSString * const NOTIF_INVITE_FRIENDS_EVENT_DONE= @"com.genweb2.socialmaps.invitefriendseventdone";
NSString * const NOTIF_GET_MY_PLACES_DONE= @"com.genweb2.socialmaps.getmyplacesdone";
NSString * const NOTIF_GET_MEET_UP_REQUEST_DONE= @"com.genweb2.socialmaps.getmeetuprequestdone";
NSString * const NOTIF_GET_BASIC_PROFILE_DONE= @"com.genweb2.socialmaps.getbasicprofiledone";
NSString * const NOTIF_UPDATE_BASIC_PROFILE_DONE= @"com.genweb2.socialmaps.updatebasicprofiledone";
NSString * const NOTIF_UPDATE_MEET_UP_REQUEST_DONE= @"com.genweb2.socialmaps.updatemeetuprequestdone";
NSString * const NOTIF_SEND_MEET_UP_REQUEST_DONE= @"com.genweb2.socialmaps.sendmeetuprequestdone";
NSString * const NOTIF_PUSH_NOTIFICATION_RECEIVED= @"com.genweb2.socialmaps.sendmeetuprequestdone";
NSString * const NOTIF_SET_MESSAGE_STATUS_DONE= @"com.genweb2.socialmaps.setmessagestatusdone";;
NSString * const NOTIF_SEND_FRIEND_REQUEST_DONE= @"com.genweb2.socialmaps.sendfriendrequestdone";
NSString * const NOTIF_GET_ALL_CIRCLES_DONE= @"com.genweb2.socialmaps.getallcirclesdone";
NSString * const NOTIF_CREATE_CIRCLE_DONE=@"com.genweb2.socialmaps.createcirclesdone";
NSString * const NOTIF_UPDATE_CIRCLE_DONE=@"com.genweb2.socialmaps.updatecirclesdone";
NSString * const NOTIF_GET_ALL_BLOCKED_USERS_DONE=@"com.genweb2.socialmaps.getallblockedusersdone";
NSString * const NOTIF_SET_BLOCKED_USERS_DONE=@"com.genweb2.socialmaps.setblockedusersdone";
NSString * const NOTIF_SET_UNBLOCKED_USERS_DONE=@"com.genweb2.socialmaps.setunblockedusersdone";
NSString * const NOTIF_GET_ALL_EVENTS_FOR_MAP_DONE= @"com.genweb2.socialmaps.getalleventsformapdone";
NSString * const NOTIF_GET_OTHER_USER_PROFILE_DONE= @"com.genweb2.socialmaps.getotheruserprofiledone";
NSString * const NOTIF_DO_CONNECT_FB_DONE= @"com.genweb2.socialmaps.doconnectfbdone";
NSString * const NOTIF_DO_CONNECT_WITH_FB= @"com.genweb2.socialmaps.doconnectwithfb";
NSString * const NOTIF_DO_UPLOAD_PHOTO= @"com.genweb2.socialmaps.douploadphoto";
NSString * const NOTIF_GET_USER_ALL_PHOTO= @"com.genweb2.socialmaps.getuserallphoto";
NSString * const NOTIF_DELETE_USER_PHOTO_DONE= @"com.genweb2.socialmaps.deleteuserphotodone";
NSString * const NOTIF_GET_FRIENDS_ALL_PHOTO= @"com.genweb2.socialmaps.getfriendsallphoto";
NSString * const NOTIF_GET_PHOTO_FOR_GEOTAG= @"com.genweb2.socialmaps.getphotoforgeotag";
NSString * const NOTIF_CREATE_GEOTAG_DONE=@"com.genweb2.socialmaps.creategeotagdone";
NSString * const NOTIF_GET_ALL_GEOTAG_DONE=@"com.genweb2.socialmaps.getallgeotagdone";
NSString * const NOTIF_GET_PLACES_DONE= @"com.genweb2.socialmaps.getplacesdone";
NSString * const NOTIF_DELETE_USER_CIRCLE_DONE= @"com.genweb2.socialmaps.deleteusercircledone";
NSString * const NOTIF_RENAME_USER_CIRCLE_DONE= @"com.genweb2.socialmaps.renameeusercircledone";
NSString * const NOTIF_GET_FRIEND_LIST_DONE= @"com.genweb2.socialmaps.getfriendslistdone";

NSString * const NOTIF_CREATE_PLAN_DONE=@"com.genweb2.socialmaps.createplandone";
NSString * const NOTIF_GET_ALL_PLANS_DONE=@"com.genweb2.socialmaps.getallplandone";
NSString * const NOTIF_DELETE_PLANS_DONE=@"com.genweb2.socialmaps.deleteplandone";
NSString * const NOTIF_UPDATE_PLANS_DONE=@"com.genweb2.socialmaps.updateplandone";
NSString * const NOTIF_GET_FRIENDS_PLANS_DONE=@"com.genweb2.socialmaps.getfriendsplandone";
NSString * const NOTIF_FRIENDS_REQUEST_ACCEPTED=@"com.genweb2.socialmaps.friendsrequestaccepteddone";
NSString * const NOTIF_LOCATION_SHARING_SETTING_DONE=@"com.genweb2.socialmaps.locationsharingsettingdone";
NSString * const NOTIF_GET_MESSAGE_WITH_ID_DONE=@"com.genweb2.socialmaps.notifgetmessagewithiddone";
NSString * const NOTIF_SEND_REPLY_DONE=@"com.genweb2.socialmaps.notifsendreplydone";
NSString * const NOTIF_GET_NEW_THREAD_DONE=@"com.genweb2.socialmaps.notifgetnewthread";
NSString * const SET_SHARE_LOCATION_DONE=@"com.genweb2.socialmaps.setsharelocation";
NSString * const GET_SEARCH_RESULT_DONE=@"com.genweb2.socialmaps.getsearchresult";

NSString * const FB_APPID = @"343783602384766"; // Social Maps

NSString * const kFontName			= @"HelveticaNeue";
NSString * const kFontNameBold		= @"HelveticaNeue-Bold";
float const kStatusFontSize			= 14;
float const kBenefitFontSize		= 14;
float const kLabelFontSize          = 12;
float const kNumbersFontSize		= 26;
float const kNumbersLargeFontSize	= 48;
float const kSmallNumbersFontSize	= 17;
float const kLargeLabelFontSize		= 16;
float const kMediumLabelFontSize	= 14;
float const kSmallLabelFontSize		= 12;
float const kNumberRGBRed			= 0.44;
float const kNumberRGBGreen			= 0.67;
float const kNumberRGBBlue			= 0.0;

int const MAX_VISIBLE_ANNO          = 400;

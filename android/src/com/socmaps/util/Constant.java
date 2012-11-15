package com.socmaps.util;

public class Constant {

	final static public String APP_SHARED_PREFS = "com.socmap.socmaps_preferences";

	/*
	 * App ID: 260432304058696 App Secret: 5b08deeee59a2228ac3a29dadfa4438b
	 */
	// final static public String FB_APP_ID = "260432304058696";
	final static public String FB_APP_ID = "343783602384766";
	final static public String[] facebookPermissions = { "offline_access",
			"publish_stream", "user_photos", "publish_checkins",
			"photo_upload", "email", "friends_activities", "friends_checkins",
			"friends_location", "user_checkins", "user_location",
			"user_about_me", "user_birthday", "user_relationships",
			"user_likes", "read_stream", "friends_status", "user_checkins",
			"friends_checkins" };

	// final static public String[] facebookPermissions =
	// {"publish_stream","publish_checkins"};

	final static public int AUTHORIZE_ACTIVITY_RESULT_CODE = 0;
	final static public int PICK_EXISTING_PHOTO_RESULT_CODE = 1;

	// final static public String smServerUrl = "http://174.143.240.157";
	// final static public String smServerUrl = "http://203.76.126.69";
	// final static public String smServerUrl =
	// "http://192.168.1.71/social_maps_final/service/trunk/web";
	// final static public String smServerUrl =
	// "http://203.76.126.69/social_maps_git/social-maps-service/web";
	// final static public String smServerUrl =
	// "http://203.76.126.69/social_maps/web";
	// final static public String smServerUrl =
	// "http://ec2-46-51-157-204.eu-west-1.compute.amazonaws.com";

	// test server
	// final static public String smServerUrl =
	// "http://203.76.126.69/stage_social_maps/web";
	// final static public String smServerUrl =
	// "http://192.168.1.71/social_maps/web";
	// staging server
	final static public String smServerUrl = "http://ec2-46-51-157-204.eu-west-1.compute.amazonaws.com/prodtest";
	//final static public String smServerUrl ="http://ec2-46-51-157-204.eu-west-1.compute.amazonaws.com/v1_5";

	// production server
	//final static public String smServerUrl = "http://ec2-46-51-157-204.eu-west-1.compute.amazonaws.com/v1_5";

	final static public String smRegistrationUrl = smServerUrl
			+ "/auth/registration";
	final static public String smLoginUrl = smServerUrl + "/auth/login";
	final static public String smFbLoginUrl = smServerUrl + "/auth/login/fb";
	final static public String smForgotPassUrl = smServerUrl
			+ "/auth/forgot_pass";
	final static public String smAccountSettingsUrl = smServerUrl
			+ "/settings/account_settings";
	final static public String smNotificationSettingsUrl = smServerUrl
			+ "/settings/notifications";
	final static public String platformsSettingsUrl = smServerUrl
			+ "/settings/platforms";
	final static public String avatarPrefixUrl = smServerUrl + "/images";
	final static public String changePasswordUrl = smServerUrl
			+ "/auth/change_pass";
	final static public String layersSettingsUrl = smServerUrl
			+ "/settings/layers";
	// final static public String
	// getAccountSettingsUrl=smServerUrl+"/settings/account_settings";
	final static public String informationSharingSettingsUrl = smServerUrl
			+ "/settings/sharing_preference_settings";
	final static public String smGetUserUrl = smServerUrl + "/search";

	final static public String fbFriendListUrl = "https://graph.facebook.com/me/friends?access_token=";

	final static public String smUpdateLocationUrl = smServerUrl
			+ "/current-location";
	final static public String smFriendRequestUrl = smServerUrl
			+ "/request/friend";
	final static public String smMessagesUrl = smServerUrl + "/messages";
	final static public String smGetEventUrl = smServerUrl + "/events";
	final static public String smEventUrl = smServerUrl + "/events";
	final static public String smMeetupUrl = smServerUrl + "/meetups";
	final static public String smFriendList = smServerUrl + "/me/friends";
	final static public String smCircleUrl = smServerUrl + "/me/circles";
	final static public String smBlockUrl = smServerUrl + "/me/users/block";
	final static public String smUnBlockUrl = smServerUrl + "/me/users/un-block";
	final static public String smBlockUnblockUrl = smServerUrl + "/me/users/block/overwrite"; 
	final static public String smGeoTag = smServerUrl + "/geotags";
	
	final static public String smPlaces = smServerUrl + "/me/places";
	final static public String smCreatePlaces = smServerUrl + "/places";
	final static public String smUploadPhoto = smServerUrl +"/photos";
	
	final static public String smPhotoUrl = smServerUrl + "/photos";
	

	/*
	 * GENERAL STATUS CODE: 400 – Bad Request 401 – Unauthorized, Auth-Token
	 * missing / Invalid Auth-Token / User not authorized 404 – Not Found, The
	 * requested resource is not found 501 – Not Implemented, The requested
	 * endpoint is not implemented (pending or business decision) 503 – Service
	 * Unavailable, server or DB down
	 * 
	 * GET: Success (content available): 200 Success (no content) : 204 Bad
	 * Request: 400 Unauthorized: 401
	 * 
	 * POST: Created: 201 Expectation Failed: 417 – Required data missing
	 * Conflict: 409 – The resource already exist (duplicate unique field)
	 * 
	 * PUT: Success: 200 Expectation Failed: 417 – Required data missing
	 * Conflict: 409 – The resource already exist (duplicate unique field)
	 * 
	 * DELETE: Success: 200 Not Found: 404 – The requested resource is not found
	 */
	public final static String UNIT_METRIC = "metric";
	public final static String UNIT_IMPERIAL = "imperial";
	public final static int STATUS_SUCCESS = 200;
	public final static int STATUS_CREATED = 201;
	public final static int STATUS_SUCCESS_NODATA = 204;

	public final static int STATUS_BADREQUEST = 400;
	public final static int STATUS_UNAUTHORIZEZ = 401;
	public final static int STATUS_NOTFOUND = 404;
	public final static int STATUS_CONFLICT = 409;
	public final static int STATUS_EXPECTATION_FAILED = 417;
	public final static int STATUS_GENERAL_NOTIMPLEMENTED = 501;
	public final static int STATUS_GENERAL_UNAVAILABLE = 503;

	public final static int thumbWidth = 100;
	public final static int thumbHeight = 100;

	public final static int profileCoverWidth = 320;
	public final static int profileCoverHeight = 160;

	public final static int eventPhotoWidth = 320;
	public final static int eventPhotoHeight = 180;

	public final static String authTokenParam = "Auth-Token";

	public final static String responseKey = "result";

	public final static int FLAG_PEOPLE = 1;
	public final static int FLAG_PLACE = 2;
	public final static int FLAG_SELF = 3;
	public final static int FLAG_EVENT = 4;
	public final static int FLAG_MEETUP = 5;
	public final static int FLAG_SECOND_DEGREE = 6;
	public final static int FLAG_GEOTAG = 7;

	public final static String PEOPLE = "peoples";
	public final static String PLACE = "places";
	public final static String DEAL = "deal";
	public final static String EVENT = "event";

	public final static String PERMISSION_PUBLIC = "public";
	public final static String PERMISSION_FRIENDS = "friends";
	public final static String PERMISSION_NONE = "private";
	public final static String PERMISSION_CIRCLES = "circles";
	public final static String PERMISSION_CUSTOM = "custom";

	public final static int REQUEST_CODE_MAP_PICKER = 11111;
	public final static int REQUEST_CODE_CAMERA = 100;
	public final static int REQUEST_CODE_GALLERY = 101;

	public final static String MY_RESPONSE_YES = "yes";
	public final static String MY_RESPONSE_NO = "no";
	public final static String MY_RESPONSE_MAYBE = "maybe";

	public final static String STATUS_FRIENDSHIP_NONE = "none";
	public final static String STATUS_FRIENDSHIP_FRIEND = "friend";
	public final static String STATUS_FRIENDSHIP_PENDING = "pending";
	public final static String STATUS_FRIENDSHIP_REQUESTED = "requested";
	public final static String STATUS_FRIENDSHIP_REJECTED_BY_HIM = "rejected_by_him";
	public final static String STATUS_FRIENDSHIP_REJECTED_BY_ME = "rejected_by_me";

	public final static String STATUS_MESSAGE_READ = "read";
	public final static String STATUS_MESSAGE_UNREAD = "unread";

	public final static String betaPassword = "discover2012";
	public final static String socialmapsWebUrl = "http://www.socialmapsapp.com";

	public final static String sourceSocialmaps = "sm";
	public final static String sourceFacebook = "fb";

	public final static String PEOPLE_SOCIALMAPS = "peoplesocialplaces";
	public final static String PEOPLE_FACEBOOK = "peoplefacebook";

}

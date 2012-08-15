package com.socmaps.util;

public class Constant 
{	
	final static public String serverUrl = "http://192.168.1.19/android/smapi/";
	final static public String registerUrl = serverUrl+"register.php";
	final static public String loginUrl = serverUrl+"login.php";
	final static public String profileInfoUrl = serverUrl+"profile.php";
	final static public String forgotPassUrl = serverUrl+"forgotpass.php";
	final static public String accountSettingsUrl = serverUrl+"acc_settings_info.php";
	final static public String changePassUrl = serverUrl+"forgotpass.php";
	
	
	/*
	App ID:	260432304058696
	App Secret:	5b08deeee59a2228ac3a29dadfa4438b
	*/
	
	final static public String FB_APP_ID = "260432304058696";
	final static public String[] facebookPermissions = { "offline_access", "publish_stream", "user_photos",	"publish_checkins", "photo_upload","email","friends_activities","friends_checkins", "friends_location","user_checkins","user_location" };

	
	final static public int AUTHORIZE_ACTIVITY_RESULT_CODE = 0;
    final static public int PICK_EXISTING_PHOTO_RESULT_CODE = 1;
    
    //final static public String smServerUrl = "http://174.143.240.157";
    //final static public String smServerUrl = "http://203.76.126.69";
    //final static public String smServerUrl = "http://192.168.1.71/social_maps_final/service/trunk/web";
    final static public String smServerUrl = "http://203.76.126.69/social_maps_git/social-maps-service/web";
	final static public String smRegistrationUrl = smServerUrl+"/auth/registration";
	final static public String smLoginUrl = smServerUrl+"/auth/login";
	final static public String smForgotPassUrl = smServerUrl+"/auth/forget_password";
	final static public String smAccountSettingsUrl = smServerUrl+"/settings/account_settings";
	final static public String smNotificationSettingsUrl = smServerUrl+"/settings/notifications";
	final static public String platformsSettingsUrl=smServerUrl+"/settings/platforms";
	final static public String avatarPrefixUrl = smServerUrl+"/images";
	final static public String changePasswordUrl=smServerUrl+"/auth/change_pass";
	final static public String layersSettingsUrl=smServerUrl+"/settings/layers";
	//final static public String getAccountSettingsUrl=smServerUrl+"/settings/account_settings";
    /*
	GENERAL STATUS CODE:
    400 – Bad Request
    401 – Unauthorized, Auth-Token missing / Invalid Auth-Token / User not authorized
    404 – Not Found, The requested resource is not found
    501 – Not Implemented, The requested endpoint is not implemented (pending or business decision)
    503 – Service Unavailable, server or DB down
        
    GET:
    Success (content available): 200
    Success (no content) : 204
    Bad Request: 400
    Unauthorized: 401
        
    POST:
    Created: 201
    Expectation Failed: 417 – Required data missing
    Conflict: 409 – The resource already exist (duplicate unique field)
    
    PUT:
    Success: 200
    Expectation Failed: 417 – Required data missing
    Conflict: 409 – The resource already exist (duplicate unique field)
    
    DELETE:
    Success: 200
    Not Found: 404 – The requested resource is not found
    */
	
	public final static int STATUS_SUCCESS= 200;
	public final static int STATUS_CREATED= 201;
	public final static int STATUS_SUCCESS_NODATA= 204;
	
	public final static int STATUS_BADREQUEST= 400;
	public final static int STATUS_UNAUTHORIZEZ= 401;
	public final static int STATUS_NOTFOUND= 404;
	public final static int STATUS_CONFLICT= 409;
	public final static int STATUS_EXPECTATION_FAILED= 417;
	public final static int STATUS_GENERAL_NOTIMPLEMENTED= 501;
	public final static int STATUS_GENERAL_UNAVAILABLE= 503;
	
	

	public final static int thumbWidth = 100;
	public final static int thumbHeight = 100;
	
	public final static String authTokenParam = "Auth-Token";

	public final static String responseKey="result";
	
	
}

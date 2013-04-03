//
//  AppDelegate.m
//  SocialMaps
//
//  Created by Arif Shakoor on 7/22/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "CustomAlert.h"
#import "FacebookHelper.h"
#import "NotifMessage.h"
#import "NotifRequest.h"
#import "TagNotification.h"
#import "LocationItemPeople.h"
#import "LocationItemPlace.h"
#import "UserFriends.h"
#import "RestClient.h"
#import "UserCircle.h"
#import "Globals.h"
#import "UserDefault.h"
#import "PushNotification.h"
#import "MessageListViewController.h"
#import "NotifMessage.h"
#import "ViewEventListViewController.h"
#import "NotificationController.h"
#import "Globals.h"
#import "FriendsProfileViewController.h"
#import "MapViewController.h"
#import "LoadingView.h"
#import "RestClient.h"
#import "GoogleConversionPing.h"
#import "UtilityClass.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize rememberLoginInfo;
@synthesize email;
@synthesize password;
@synthesize authToken;
@synthesize loginCount;
@synthesize fbId;
@synthesize userId;
@synthesize fbAccessToken;
@synthesize activityView;
@synthesize fbHelper;
@synthesize savedFilters;
@synthesize pickSavedFilter;
@synthesize friendRequests;
@synthesize messages;
@synthesize notifications;
@synthesize msgRead;
@synthesize notifRead;
@synthesize ignoreCount;
@synthesize defPlatforms;
@synthesize defLayers;
@synthesize infoList;
@synthesize defInfoPref;
@synthesize peopleList;
@synthesize placeList;
@synthesize dealList;
@synthesize eventList;
@synthesize displayList;
@synthesize friendList;
@synthesize platformPrefs;
@synthesize layerPrefs;
@synthesize informationPrefs;
@synthesize userAccountPrefs;
@synthesize geofencePrefs;
@synthesize locSharingPrefs;
@synthesize notifPrefs;
@synthesize currPosition;
@synthesize lastPosition;
@synthesize screenCenterPosition;
@synthesize showDeals;
@synthesize showPeople;
@synthesize showPlaces;
@synthesize showEvents;
@synthesize peopleIndex;
@synthesize gotListing;
@synthesize placeIndex;
@synthesize meetUpRequests;
@synthesize needToCenterMap;
@synthesize deviceTokenId;
@synthesize deviceTokenChanged;
@synthesize facebookLogin;
@synthesize smLogin,geotagList;
@synthesize resetZoom;
@synthesize currentModelViewController;
@synthesize isAppInBackgound;
@synthesize shareLocationOption;
@synthesize timerGotListing;
@synthesize myPhotoList;
@synthesize currZoom;
@synthesize mapDrawnFirstTime;

//static AppDelegate *sharedInstance=nil;

// Get the shared instance and create it if necessary.
+ (AppDelegate *)sharedInstance {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    if (launchOptions != nil)
	{
		NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if (dictionary != nil)
		{
            PushNotification *newNotif = [PushNotification parsePayload:dictionary];
            NSLog(@"Launched from push notification: count:%d, data:%@", newNotif.badgeCount, dictionary);
            // Temporary - set badge count to zero
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
		}
	}
    dicImages_msg = [[NSMutableDictionary alloc] init];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults]; 
    facebookLogin = FALSE;
    smLogin = FALSE;
    gotListing = FALSE;
    needToCenterMap = TRUE;
    rememberLoginInfo = [prefs boolForKey:@"rememberLoginInfo"];
    email = [prefs stringForKey:@"email"];
    password = [prefs stringForKey:@"password"];
    authToken = [prefs stringForKey:@"authToken"];
    userId = [prefs stringForKey:@"userId"];
    fbId = [prefs stringForKey:@"FBUserId"];
    fbAccessToken = [prefs stringForKey:@"FBAccessTokenKey"];
    loginCount = [prefs integerForKey:@"loginCount"];
    deviceTokenId = [prefs stringForKey:@"deviceTokenId"];
    deviceTokenChanged = FALSE;
    NSLog(@"email=%@,password=%@,remember=%d, login count=%d, authToken=%@",email,password,rememberLoginInfo,
          loginCount, authToken);
    NSLog(@"FB id=%@, FBAuthToken=%@", fbId, fbAccessToken);
    NSLog(@"Device Token=%@", deviceTokenId);

    // Singleton instance
    fbHelper = [FacebookHelper sharedInstance];

    userFriendslistArray=[[NSMutableArray alloc] init];
    userFriendslistIndex = [[NSMutableDictionary alloc] init];

    // Preferences data structure
    platformPrefs = [[Platform alloc] init];
    layerPrefs    = [[Layer alloc] init];
    informationPrefs = [[InformationPrefs alloc] init];
    userAccountPrefs = [[UserInfo alloc] init];
    userAccountPrefs.icon = nil;
    geofencePrefs = [[Geofence alloc] init];
    locSharingPrefs = [[ShareLocation alloc] init];
    notifPrefs = [[NotificationPref alloc] init];
    peopleList = [[NSMutableArray alloc] init];
    peopleIndex = [[NSMutableDictionary alloc] init];
    placeList  = [[NSMutableArray alloc] init];
    placeIndex = [[NSMutableDictionary alloc] init];
    dealList   = [[NSMutableArray alloc] init];
    eventList  =[[NSMutableArray alloc] init];
    displayList= [[NSMutableArray alloc] init];
    geotagList= [[NSMutableArray alloc] init];

    // Location coordinates
    currPosition = [[Geolocation alloc] init];
    lastPosition = [[Geolocation alloc] init];
    screenCenterPosition = [[Geolocation alloc] init];
    currZoom.latitudeDelta = .02;
    currZoom.longitudeDelta = .02;
    
    UserDefault *userDefaults = [[UserDefault alloc] init];
    currPosition.latitude = [userDefaults readFromUserDefaults:@"lastLatitude"];
    currPosition.longitude = [userDefaults readFromUserDefaults:@"lastLongitude"];
    screenCenterPosition.latitude = [userDefaults readFromUserDefaults:@"lastLatitude"];
    screenCenterPosition.longitude = [userDefaults readFromUserDefaults:@"lastLongitude"];
    [userDefaults release];
    
    showPeople = TRUE;
    showDeals  = FALSE;
    showPlaces = FALSE;
    showEvents = FALSE;
    resetZoom  = TRUE;
    mapDrawnFirstTime = TRUE;
    
    msgRead = FALSE;
    notifRead = FALSE;
    ignoreCount = 0;
    
    // Create some dummy data to show
    // Friend requests
    friendRequests = [[NSMutableArray alloc] init];
    
    // Messages
    messages       = [[NSMutableArray alloc] init];
    
    // Notifications
    notifications  = [[NSMutableArray alloc] init];
    
    // Meet up request
    meetUpRequests = [[NSMutableArray alloc] init];
    
    // Setup default platforms
    defPlatforms = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:1], 
                    [NSNumber numberWithInt:0],
                    [NSNumber numberWithInt:0], nil] ;
    
    // Setup default layers
    defLayers = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:0], 
                    [NSNumber numberWithInt:0],
                    [NSNumber numberWithInt:0], nil] ;

    // Setup information sharing preferences
    infoList = [[NSMutableArray alloc] initWithObjects:@"First name", @"Last name", @"Email", @"Gender", @"Date of birth", @"Bio", @"Address", @"Relationship status",nil];
    defInfoPref = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],nil];
    
    // GCD notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotPlatform:) name:NOTIF_GET_PLATFORM_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotLayer:) name:NOTIF_GET_LAYER_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotSharingPrefs:) name:NOTIF_GET_SHARING_PREFS_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotAccountSettings:) name:NOTIF_GET_ACCT_SETTINGS_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotGeofence:) name:NOTIF_GET_GEOFENCE_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotShareLoc:) name:NOTIF_GET_SHARELOC_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotNotifications:) name:NOTIF_GET_NOTIFS_DONE object:nil];
    
    [GoogleConversionPing pingWithConversionId:@"999663340" label:@"A2W1CPykpQUQ7M3W3AM" value:@"0" isRepeatable:NO idfaOnly:NO];
    
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
    
    // Need to update server if new token received
    NSString* newToken = [deviceToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"New token=[%@] old token=[%@]", newToken, deviceTokenId);
    if ([newToken caseInsensitiveCompare:deviceTokenId] != NSOrderedSame) {
        deviceTokenId = [[NSString alloc] initWithString: newToken];
        deviceTokenChanged = TRUE;
        NSLog(@"Updating device token");
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:deviceTokenId forKey:@"deviceTokenId"];
        [prefs synchronize];
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
    [UtilityClass showCustomAlert:@"Failed to get token" subTitle:[error localizedDescription] bgColor:[UIColor redColor] strokeColor:[UIColor grayColor] btnText:@"ok"];
}

-(void)initData
{
    platformPrefs = [[Platform alloc] init];
    layerPrefs    = [[Layer alloc] init];
    informationPrefs = [[InformationPrefs alloc] init];
    userAccountPrefs = [[UserInfo alloc] init];
    userAccountPrefs.icon = nil;
    geofencePrefs = [[Geofence alloc] init];
    locSharingPrefs = [[ShareLocation alloc] init];
    notifPrefs = [[NotificationPref alloc] init];

}

//
- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    PushNotification *newNotif = [PushNotification parsePayload:userInfo];
    
    if (![self.userId isEqualToString:newNotif.receiverId]) return;
    
    NSLog(@"Received notification: count:%d, data:%@  id:%@ type:%d", newNotif.badgeCount, userInfo, newNotif.objectIds, newNotif.notifType);
    notifBadgeFlag=TRUE;
    badgeCount= newNotif.badgeCount;
    [self.currentModelViewController viewWillAppear:NO];
    // Temporary - set count to zero
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    if (gotListing == TRUE && isAppInBackgound == TRUE) {
        
        RestClient *rc=[[[RestClient alloc] init] autorelease];
        [rc getMessageById:@"Auth-Token" authTokenVal:authToken:[newNotif.objectIds objectAtIndex:0]];
        
        if (newNotif.notifType == PushNotificationMessage || newNotif.notifType == PushNotificationMeetupRequest) {
            
            UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            MessageListViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"messageList"];
            
            
            controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            
            if (newNotif.notifType != PushNotificationMeetupRequest) {
                
                BOOL isParentMsgExist = FALSE;
                
                for (NotifMessage *notifMsg in self.messages) {
                    if ([notifMsg.notifID isEqualToString:[newNotif.objectIds lastObject]]) 
                    {
                        isParentMsgExist = TRUE;
                        controller.selectedMessage = notifMsg;
                        break;
                    }
                }
                
                if (!isParentMsgExist) 
                {
                    NotifMessage *notifMessage = [[NotifMessage alloc] init];
                    notifMessage.notifID = [newNotif.objectIds lastObject];
                    notifMessage.notifMessage = newNotif.message;
                    notifMessage.notifSender = @"sender";
                    notifMessage.notifSenderId = @"sender_id";
                    notifMessage.notifSubject = @"";
                    notifMessage.notifTime = nil;
                    notifMessage.notifAvater = @"avater";
                    controller.selectedMessage = notifMessage;
                    [notifMessage release];
                }
            }
            
            if ([self.currentModelViewController isKindOfClass:[MessageListViewController class]]) {

                if (newNotif.notifType != PushNotificationMeetupRequest) {
                    [(MessageListViewController*)self.currentModelViewController setSelectedMessage:controller.selectedMessage];
                } else {
                    [(MessageListViewController*)self.currentModelViewController setWillSelectMeetUp:YES];
                }
                
                [self.currentModelViewController viewDidAppear:NO];
                return;
            }
            
            if (newNotif.notifType == PushNotificationMeetupRequest)
                controller.willSelectMeetUp = YES;
            else
                controller.willSelectMeetUp = NO;
            
            UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
            [self.currentModelViewController presentModalViewController:nav animated:YES];
            nav.navigationBarHidden = YES;
            
        } else if (newNotif.notifType == PushNotificationEventInvite) {
            
            UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            ViewEventListViewController *controller = [storybrd instantiateViewControllerWithIdentifier:@"viewEventList"];
            controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            
            if ([self.currentModelViewController isKindOfClass:[ViewEventListViewController class]]) {
                [self.currentModelViewController viewDidAppear:NO];
                return;
            }
            
            [self.currentModelViewController presentModalViewController:controller animated:YES];
        
        } else if (newNotif.notifType == PushNotificationFriendRequest) {
            
            UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            NotificationController *controller =[storybrd instantiateViewControllerWithIdentifier:@"notificationViewController"];
            controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            controller.selectedType = Request;
            
            if ([self.currentModelViewController isKindOfClass:[NotificationController class]]) {
                [self.currentModelViewController viewDidAppear:NO];
                return;
            }
            
            [self.currentModelViewController presentModalViewController:controller animated:YES];
        }
        else if (newNotif.notifType == PushNotificationAcceptedRequest) 
        {
            RestClient *rc=[[RestClient alloc] init];
            [rc getUserFriendList:@"Auth-Token" tokenValue:self.authToken andUserId:self.userId];
            FriendsProfileViewController *frndProfile = [[FriendsProfileViewController alloc] init];
            frndProfile.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
            frndProfile.friendsId=[newNotif.objectIds objectAtIndex:0];
            [self.currentModelViewController presentModalViewController:frndProfile animated:YES];
            [frndProfile release];
            frndProfile = nil;
        }
        else if (newNotif.notifType == PushNotificationProximityAlert)
        {
            NSLog(@"in proxomity alert");            
            UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            MapViewController *controller = [storybrd instantiateViewControllerWithIdentifier:@"mapViewController"];
            controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            LocationItemPeople *locItemPeople=[[LocationItemPeople alloc] init];
            for (int i=0; i<[self.displayList count]; i++)
            {
                LocationItemPeople *locItem = (LocationItemPeople*)[self.displayList objectAtIndex:i];
                if ([[newNotif.objectIds objectAtIndex:0] isEqualToString:locItem.userInfo.userId])
                {
                    locItemPeople=locItem;
                }                
            }

            
            if ([self.currentModelViewController isKindOfClass:[MapViewController class]]) 
            {
                [(MapViewController *) self.currentModelViewController showAnnotationDetailView:locItemPeople];
                return;
            }
            
            [controller showAnnotationDetailView:locItemPeople];
            [self.currentModelViewController presentModalViewController:controller animated:YES];
        }
    }
    else 
    {
        //apps not in background
        if (newNotif.notifType == PushNotificationAcceptedRequest) 
        {
            RestClient *rc=[[RestClient alloc] init];
            [rc getUserFriendList:@"Auth-Token" tokenValue:self.authToken andUserId:self.userId];
        }
        else if (newNotif.notifType == PushNotificationMessage)
        {
            NSLog(@"did received push for msg");
            RestClient *rc=[[RestClient alloc] init];
            [rc getMessageById:@"Auth-Token" authTokenVal:authToken:[newNotif.objectIds objectAtIndex:0]];
            /*
            if ([self.currentModelViewController isKindOfClass:[NotificationController class]])
            {
                [[(NotificationController *)[self currentModelViewController] notificationItems] reloadData];
            }
            */
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    self.isAppInBackgound = YES;
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    self.isAppInBackgound = NO;
    RestClient *rc = [[[RestClient alloc] init] autorelease];
    if ([authToken isKindOfClass:[NSString class]]) {
        [rc getInbox:@"Auth-Token" authTokenVal:authToken];
    }

    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"applicationWillTerminate");
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_PLATFORM_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_LAYER_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_SHARING_PREFS_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_ACCT_SETTINGS_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_GEOFENCE_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_SHARELOC_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_NOTIFS_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_NOTIFICATIONS_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_FRIEND_REQ_DONE object:nil];
}

// For iOS 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [fbHelper.facebookApi handleOpenURL:url];
}

-(void)hideActivityViewer
{
    [self.window setUserInteractionEnabled:YES];
    LoadingView *loadingView2 =(LoadingView *)[self.window viewWithTag:11111111];
    [loadingView2 removeView];
}

-(void)showActivityViewer:(UIView*) sender
{
    [[self.window viewWithTag:11111111] removeFromSuperview];
    LoadingView *loadingView = [LoadingView loadingViewInView:sender];
	loadingView.tag=11111111;
    [self.window setUserInteractionEnabled:NO];
    [loadingView bringSubviewToFront:self.window];
    [self performSelector:@selector(showCloseButton:) withObject:loadingView afterDelay:120];
    
}


- (void) showCloseButton:(id)sender
{
    UIButton *buttonClose = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonClose setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [buttonClose addTarget:self action:@selector(hideActivityViewer) forControlEvents:UIControlEventTouchUpInside];
    UIView *senderView = sender;
    senderView.superview.userInteractionEnabled = YES;
    senderView.superview.superview.userInteractionEnabled = YES;
    senderView.userInteractionEnabled = YES;
    self.window.userInteractionEnabled = YES;
    [senderView addSubview:buttonClose];
    
    buttonClose.frame = CGRectMake(senderView.frame.size.width - 100, senderView.frame.size.height - 70, 100, 70);
    
    [buttonClose setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [buttonClose.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:12.0f]];
    [buttonClose setTitle:@"Close" forState:UIControlStateNormal];
    buttonClose.backgroundColor = [UIColor clearColor];
    buttonClose.showsTouchWhenHighlighted = YES;
}


// Get User information
// - messages
// - requests
// - information details
//
- (void) getUserInformation:(NSString*) token {
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    [restClient getFriendRequests:@"Auth-Token" authTokenVal:token];
    [restClient getInbox:@"Auth-Token" authTokenVal:token];
    [restClient getMeetUpRequest:@"Auth-Token" authTokenVal:token];
}

// Get preferences settings
//
- (void) getPreferenceSettings:(NSString*) token {
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    [restClient getPlatForm:@"Auth-Token" :token];
    [restClient getLayer:@"Auth-Token" :token];
    [restClient getSharingPreference:@"Auth-Token" :token];
    [restClient getAccountSettings:@"Auth-Token" :token];
    [restClient getShareLocation:@"Auth-Token" :token];
    [restClient getGeofence:@"Auth-Token" :token];
    [restClient getNotifications:@"Auth-Token" :token];
}

// Async call notifications
//
- (void)gotPlatform:(NSNotification *)notif {
    platformPrefs = [notif object];
    NSLog(@"AppDelegate: gotPlatform - %@", platformPrefs);
}
- (void)gotLayer:(NSNotification *)notif {
    layerPrefs = [notif object];
    NSLog(@"AppDelegate: gotLayer - %@", layerPrefs);
}
- (void)gotSharingPrefs:(NSNotification *)notif {
    informationPrefs = [notif object];
    NSLog(@"AppDelegate: gotSharingPrefs - %@", informationPrefs);
}
- (void)gotAccountSettings:(NSNotification *)notif {
    userAccountPrefs = [notif object];
    NSLog(@"AppDelegate: gotAccountSettings - %@", userAccountPrefs);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:userAccountPrefs.avatar]];
        UIImage *image = [UIImage imageWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            userAccountPrefs.icon = image;
        });
    });

    // Get information about friends
    for (UserCircle* circle in userAccountPrefs.circles) {
        NSLog(@"************** Circle = %@", circle.circleName);
        if([circle.circleName caseInsensitiveCompare:@"friends"] == NSOrderedSame )
            friendList = circle.friends;
            
        for (UserInfo* friend in circle.friends) {
            NSLog(@"++++++++++ Friend = %@", friend.userId);
            RestClient *restClient = [[[RestClient alloc] init] autorelease];
            [restClient getUserInfo:&friend tokenStr:@"Auth-Token" tokenValue:authToken];
        }
    }
}
- (void)gotGeofence:(NSNotification *)notif {
    geofencePrefs = [notif object];
    NSLog(@"AppDelegate: gotGeofence - %@", geofencePrefs);
}
- (void)gotShareLoc:(NSNotification *)notif {
    locSharingPrefs = [notif object];
    NSLog(@"AppDelegate: gotShareLoc - %@", locSharingPrefs);
}
- (void)gotNotifications:(NSNotification *)notif {
    notifPrefs = [notif object];
    NSLog(@"AppDelegate: gotNotifications - %@", notifPrefs);
}
@end

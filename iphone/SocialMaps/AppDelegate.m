//
//  AppDelegate.m
//  SocialMaps
//
//  Created by Arif Shakoor on 7/22/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

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
@synthesize showDeals;
@synthesize showPeople;
@synthesize showPlaces;
@synthesize peopleIndex;
@synthesize gotListing;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults]; 
    gotListing = FALSE;
    rememberLoginInfo = [prefs boolForKey:@"rememberLoginInfo"];
    email = [prefs stringForKey:@"email"];
    password = [prefs stringForKey:@"password"];
    authToken = [prefs stringForKey:@"authToken"];
    userId = [prefs stringForKey:@"userId"];
    fbId = [prefs stringForKey:@"FBUserId"];
    fbAccessToken = [prefs stringForKey:@"FBAccessTokenKey"];
    loginCount = [prefs integerForKey:@"loginCount"];
    NSLog(@"email=%@,password=%@,remember=%d, login count=%d, authToken=%@",email,password,rememberLoginInfo,
          loginCount, authToken);
    NSLog(@"FB id=%@, FBAuthToken=%@", fbId, fbAccessToken);

    // Singleton instance
    fbHelper = [FacebookHelper sharedInstance];

    // Preferences data structure
    platformPrefs = [[[Platform alloc] init] autorelease];
    layerPrefs    = [[[Layer alloc] init] autorelease];
    informationPrefs = [[[InformationPrefs alloc] init] autorelease];
    userAccountPrefs = [[[UserInfo alloc] init] autorelease];
    geofencePrefs = [[[Geofence alloc] init] autorelease];
    locSharingPrefs = [[[ShareLocation alloc] init] autorelease];
    notifPrefs = [[[NotificationPref alloc] init] autorelease];
    peopleList = [[NSMutableArray alloc] init];
    peopleIndex = [[NSMutableDictionary alloc] init];
    placeList  = [[NSMutableArray alloc] init];
    dealList   = [[NSMutableArray alloc] init];
    displayList= [[NSMutableArray alloc] init];

    // Location coordinates
    currPosition = [[Geolocation alloc] init];
    lastPosition = [[Geolocation alloc] init];
                    
    showPeople = TRUE;
    showDeals  = FALSE;
    showPlaces = FALSE;
    
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

    // Friend list
//    friendList = [[NSMutableArray alloc] init];
//    for (int i=0; i <15; i++) {
//        NSString *imgName = [NSString stringWithFormat:@"Photo-%d.png",i%4];
//        UserFriends *aFriend = [[UserFriends alloc] init];
//        aFriend.userId = [NSString stringWithFormat:@"%d", i];
//        aFriend.userName = [NSString stringWithFormat:@"Firstname%d", rand()%15];
//        aFriend.imageUrl = nil;
//        aFriend.userProfileImage = [UIImage imageNamed:imgName];
//        [friendList addObject:aFriend];
//    }
    
    // GCD notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotPlatform:) name:NOTIF_GET_PLATFORM_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotLayer:) name:NOTIF_GET_LAYER_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotSharingPrefs:) name:NOTIF_GET_SHARING_PREFS_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotAccountSettings:) name:NOTIF_GET_ACCT_SETTINGS_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotGeofence:) name:NOTIF_GET_GEOFENCE_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotShareLoc:) name:NOTIF_GET_SHARELOC_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotNotifications:) name:NOTIF_GET_NOTIFS_DONE object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotNotifMessages:) name:NOTIF_GET_NOTIFICATIONS_DONE object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotFriendRequests:) name:NOTIF_GET_FRIEND_REQ_DONE object:nil];
    
    return YES;
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
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
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
    return [fbHelper.facebook handleOpenURL:url];
}

-(void)hideActivityViewer
{
	[activityView removeFromSuperview];
	activityView = nil;
}

-(void)showActivityViewer:(UIView*) sender
{
	CGRect frame = CGRectMake(sender.frame.size.width / 2 - 12, sender.frame.size.height / 2 - 12, 24, 24);
	activityView = [[UIActivityIndicatorView alloc] initWithFrame:frame];
	[activityView startAnimating];
	activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	[activityView sizeToFit];
	activityView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                     UIViewAutoresizingFlexibleRightMargin |
                                     UIViewAutoresizingFlexibleTopMargin |
                                     UIViewAutoresizingFlexibleBottomMargin);
	[sender addSubview: activityView];
	[activityView release];
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
//- (void)gotNotifMessages:(NSNotification *)notif {
//    messages = [notif object];
//    NSLog(@"AppDelegate: gotNotifications - %@", notifPrefs);
//}
//- (void)gotFriendRequests:(NSNotification *)notif {
//    friendRequests = [notif object];
//    NSLog(@"AppDelegate: gotNotifications - %@", notifPrefs);
//}
@end

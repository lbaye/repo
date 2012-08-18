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

@implementation AppDelegate

@synthesize window = _window;
@synthesize rememberLoginInfo;
@synthesize email;
@synthesize password;
@synthesize authToken;
@synthesize loginCount;
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

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults]; 
    rememberLoginInfo = [prefs boolForKey:@"rememberLoginInfo"];
    email = [prefs stringForKey:@"email"];
    password = [prefs stringForKey:@"password"];
    authToken = [prefs stringForKey:@"authToken"];
    loginCount = [prefs integerForKey:@"loginCount"];
    NSLog(@"email=%@,password=%@,remember=%d, login count=%d, authToken=%@",email,password,rememberLoginInfo,
          loginCount, authToken);
    
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
    NotifRequest *fReq = [[NotifRequest alloc] init];
    fReq.notifSender = @"John Doe";
    fReq.notifTime   = [NSDate dateWithTimeIntervalSinceNow:-(24*60*60)];
    fReq.notifMessage = @"Please add me as your friend";
    fReq.numCommonFriends = 6;
    fReq.ignored = FALSE;
    [friendRequests addObject:fReq];
    [fReq release];
    
    fReq = [[NotifRequest alloc] init];
    fReq.notifSender = @"Jane Doe";
    fReq.notifTime   = [NSDate dateWithTimeIntervalSinceNow:-(24*60*60*3)];
    fReq.numCommonFriends = 24;
    fReq.ignored = FALSE;
    [friendRequests addObject:fReq];
    [fReq release];
    
    // Messages
    messages       = [[NSMutableArray alloc] init];
    NotifMessage *msg = [[NotifMessage alloc] init];
    msg.notifSender = @"Robert Adonis";
    msg.notifTime   = [NSDate dateWithTimeIntervalSinceNow:-200];
    msg.notifMessage = @"Busy ...Busy ...Busy ...Busy ...Busy ...Busy ...Busy ...Busy ...Busy ...";
    msg.showDetail = FALSE;
    [messages addObject:msg];
    [msg release];
    
    msg = [[NotifMessage alloc] init];
    msg.notifSender = @"Martin Adonis";
    msg.notifTime   = [NSDate dateWithTimeIntervalSinceNow:-2000];
    msg.notifMessage = @"meeting now ...meeting now ...meeting now ...meeting now ...meeting now ...meeting now ...meeting now ...meeting now ...";
    msg.showDetail = FALSE;
    [messages addObject:msg];
    [msg release];
    
    msg = [[NotifMessage alloc] init];
    msg.notifSender = @"Arif Shakoor";
    msg.notifTime   = [NSDate dateWithTimeIntervalSinceNow:-2500];
    msg.notifMessage = @"blah blah blah ...blah blah blah ...blah blah blah ...blah blah blah ...blah blah blah ...blah blah blah ...blah blah blah ......blah blah blah ...blah blah blah ......blah blah blah ...blah blah blah ...blah blah blah ...blah blah blah ...blah blah blah ...";
    msg.showDetail = FALSE;
    [messages addObject:msg];
    [msg release];
    
    // Notifications
    notifications  = [[NSMutableArray alloc] initWithCapacity:2];
    Notification *notif = [[Notification alloc] init];
    notif.notifSender = @"2 friends ";
    notif.notifTime   = [NSDate dateWithTimeIntervalSinceNow:0];
    notif.notifMessage = @"Emran Hasan and Mahmudur Rahman are near you at Gulshan 2";
    [notifications addObject:notif];
    [notif release];
    
    TagNotification *tagNotif = [[TagNotification alloc] init];
    tagNotif.notifSender = @"Mahadi Hasan";
    tagNotif.notifTime   = [NSDate dateWithTimeIntervalSinceNow:-150];
    tagNotif.notifMessage = @"Mahadi Hasan tagged you at Genweb2 Eid party";
    tagNotif.photo = [UIImage imageNamed:@"tagged_image.png"];
    [notifications addObject:tagNotif];
    [tagNotif release];
    
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
    
    // Dummy data
    // starting lat,long 23.795240529083365, 90.41318893432617
//    peopleList = [[NSMutableArray alloc] init];
//    float currLat = 23.795633200965806;
//    float currLong = 90.41279196739197;
//    float dist;
//    for (int i=0; i < 4; i++) {
//        UIImage *bg = [UIImage imageNamed:@"listview_bg.png"];
//        UIImage *icon = [UIImage imageNamed:@"Photo-3.png"];
//        dist = rand()%500;
//        CLLocationCoordinate2D loc;
//        loc.latitude = currLat;
//        loc.longitude = currLong;
//        
//        LocationItemPeople *aPerson = [[LocationItemPeople alloc] initWithName:[NSString stringWithFormat:@"Person %d", i] address:[NSString stringWithFormat:@"Address %d", i] type:ObjectTypePeople category:@"Male" coordinate:loc dist:dist icon:icon bg:bg];
//        currLat += 0.004;
//        currLong += 0.004;
//        dist -= 100;
//        [peopleList addObject:aPerson];
//        [aPerson release];
//    }
//    
//    placeList = [[NSMutableArray alloc] init];
//    currLat = 23.796526525077528;
//    currLong = 90.41537761688232;
//    
//    for (int i=0; i < 3; i++) {
//        UIImage *bg = [UIImage imageNamed:@"listview_bg.png"];
//        UIImage *icon = [UIImage imageNamed:@"user_thumb_only.png"];
//        CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(currLat, currLong);
//        dist = rand()%500;
//        LocationItemPlace *aPlace = [[LocationItemPlace alloc] initWithName:[NSString stringWithFormat:@"Place %d", i] address:[NSString stringWithFormat:@"Place Address %d", i] type:ObjectTypePeople category:@"Bar" coordinate:loc dist:dist icon:icon bg:bg];
//        currLat += 0.004;
//        currLong += 0.004;
//        [placeList addObject:aPlace];
//        [aPlace release];
//    }
//    
//    dealList = [[NSMutableArray alloc] initWithCapacity:0];
//    displayList = [[NSMutableArray alloc] initWithCapacity:0];

    // Friend list
    friendList = [[NSMutableArray alloc] init];
    for (int i=0; i <15; i++) {
        NSString *imgName = [NSString stringWithFormat:@"Photo-%d.png",i%4];
        UserFriends *aFriend = [[UserFriends alloc] init];
        aFriend.userId = [NSString stringWithFormat:@"%d", i];
        aFriend.userName = [NSString stringWithFormat:@"Firstname%d", rand()%15];
        aFriend.imageUrl = nil;
        aFriend.userProfileImage = [UIImage imageNamed:imgName];
        [friendList addObject:aFriend];
    }
    
    // GCD notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotPlatform:) name:NOTIF_GET_PLATFORM_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotLayer:) name:NOTIF_GET_LAYER_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotSharingPrefs:) name:NOTIF_GET_SHARING_PREFS_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotAccountSettings:) name:NOTIF_GET_ACCT_SETTINGS_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotGeofence:) name:NOTIF_GET_GEOFENCE_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotShareLoc:) name:NOTIF_GET_SHARELOC_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotNotifications:) name:NOTIF_GET_NOTIFS_DONE object:nil];
    
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

//
//  FacebookHelper.m
//  SocialMaps
//
//  Created by Arif Shakoor on 7/27/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "FacebookHelper.h"
#import "Constants.h"
#import "User.h"
#import "UserFriends.h"
#import "Globals.h"
#import "UserDefault.h"
#import "AppDelegate.h"

@implementation FacebookHelper
@synthesize facebookApi;

static FacebookHelper *sharedInstance=nil;
bool frndListFlag=FALSE;
NSMutableArray *friendlist;
UserDefault *userDefault;

// Get the shared instance and create it if necessary.
+ (FacebookHelper *)sharedInstance {
    
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[FacebookHelper allocWithZone:NULL] init];
        }
    }
    
    return sharedInstance;
}

// We can still have a regular init method, that will get called the first time the Singleton is used.
- (id)init
{
    self = [super init];
    if (self) {
        // Work your initialising magic here as you normally would
        facebookApi = [[Facebook alloc] initWithAppId:FB_APPID andDelegate:self];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"FBAccessTokenKey"] 
            && [defaults objectForKey:@"FBExpirationDateKey"]) {
            facebookApi.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
            facebookApi.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        }
    }
    
    return self;
}

// Your dealloc method will never be called, as the singleton survives for the duration of your app.
// However, I like to include it so I know what memory I'm using (and incase, one day, I convert away from Singleton).
-(void)dealloc
{
    [super dealloc];
}


// Equally, we don't want to generate multiple copies of the singleton.
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

// Once again - do nothing, as we don't have a retain counter for this object.
- (id)retain {
    return self;
}

// Replace the retain counter so we can never release this object.
- (NSUInteger)retainCount {
    return NSUIntegerMax;
}

// This function is empty, as we don't want to let the user release this object.
- (oneway void)release {
    
}

//Do nothing, other than return the shared instance - as this is expected from autorelease.
- (id)autorelease {
    return self;
}

// Facebook delegates

- (void)fbDidLogin {
    [FBSession setActiveSession:[FBSession activeSession]];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSLog(@"Access Token is %@", facebookApi.accessToken );
    NSLog(@"Expiration Date is %@", facebookApi.expirationDate );
    if (![facebookApi.accessToken isKindOfClass:[NSString class]])
    {
        NSLog(@"got facebook access token null so asking for permission again");
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"email",
                                @"user_likes",
                                @"user_photos",
                                @"publish_checkins",
                                @"photo_upload",
                                @"user_location",
                                @"user_birthday",
                                @"user_about_me",
                                @"publish_stream",
                                @"read_stream",
                                @"friends_status",
                                @"user_checkins",
                                @"friends_checkins",
                                nil];
        [facebookApi authorize:permissions];
        [permissions release];
    }
    if ([facebookApi accessToken])
    {
        [prefs setObject:[facebookApi accessToken] forKey:@"FBAccessTokenKey"];
    }
    [prefs setObject:[facebookApi expirationDate] forKey:@"FBExpirationDateKey"];
    [prefs synchronize];
    NSLog(@"did log in");
    [self getUserInfo:self];
    AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    smAppDelegate.fbAccessToken = [facebookApi accessToken];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_FBLOGIN_DONE object:nil];
}

- (void)fbSessionInvalidated {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:@"FBAccessTokenKey"];
    [prefs removeObjectForKey:@"FBExpirationDateKey"];
}
- (void)fbDidLogout{
    [self fbSessionInvalidated];
}

- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:accessToken forKey:@"FBAccessTokenKey"];
    [prefs setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [prefs synchronize];
}

- (void)getUserInfo:(id)sender {
    [facebookApi requestWithGraphPath:@"me" andDelegate:self];
}

- (void)getUserFriendListRequest:(id)sender
{
    frndListFlag=TRUE;
    [facebookApi requestWithGraphPath:@"me/friends" andDelegate:self];
}

-(void)getUserFriendListFromFB:(id)result
{
    NSArray *items= [[(NSDictionary *)result objectForKey:@"data"]retain];
    NSLog(@"getUserFriendListFromFB items %d",[items count]);

    for (int i=0; i<[items count]; i++) 
    {
        NSDictionary *friend = [items objectAtIndex:i];
        long long fbid = [[friend objectForKey:@"id"]longLongValue];
        NSString *name = [friend objectForKey:@"name"];
        
        UserFriends *aUserFriend=[[UserFriends alloc] init];
        aUserFriend.userName=name;
        aUserFriend.userId=[NSString stringWithFormat:@"%lld",fbid];
        aUserFriend.imageUrl=[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",aUserFriend.userId];
        [userFriendslistIndex setObject:[NSNumber numberWithInt:userFriendslistArray.count]  forKey:aUserFriend.userId]; 
        [userFriendslistArray addObject:aUserFriend];
        
        NSLog(@"id: %@ - Name: %@", aUserFriend.userId, name);
    } 
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_FBFRIENDLIST_DONE object:userFriendslistArray];
}

// FBRequestDelegate

/**
 * Called when the Facebook API request has returned a response. This callback
 * gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Inside didReceiveResponse: received response");
    NSLog(@"URL %@", [response URL]);
}

/**
 * Called when a request returns and its response has been parsed into
 * an object. The resulting object may be a dictionary, an array, a string,
 * or a number, depending on the format of the API response. If you need access
 * to the raw response, use:
 *
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
    NSLog(@"Inside didLoad");
    {
        NSString *name;
        NSString *firstName;
        NSString *lastName;
        NSString *email;
        NSString *fbId;
        NSString *gender;
        NSString *userName;
        NSString *dob;
        if ([result isKindOfClass:[NSArray class]]) {
            result = [result objectAtIndex:0];
        }
        // When we ask for user infor this will happen.
        if ([result isKindOfClass:[NSDictionary class]]){
            NSLog(@"Birthday: %@", [result objectForKey:@"birthday"]);
            NSLog(@"Name: %@", [result objectForKey:@"name"]); 
            firstName = [result objectForKey:@"first_name"];
            lastName  = [result objectForKey:@"last_name"];
            name = [result objectForKey:@"name"];
            gender = [result objectForKey:@"gender"];
            dob = [result objectForKey:@"birthday"];
            email = [result objectForKey:@"email"];
            fbId = [result objectForKey:@"id"];
            userName = [result objectForKey:@"username"]; 
            AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            smAppDelegate.fbId = fbId;
            NSLog(@"first=%@,last=%@,email=%@,id=%@",firstName,lastName,email,fbId);
        }
        if ([result isKindOfClass:[NSData class]])
        {
            NSLog(@"Profile Picture");
        }
        NSLog(@"request returns %@",result);
        User *aUser = [[User alloc] init];
        [aUser setFirstName:firstName];
        [aUser setLastName:lastName];
        [aUser setFacebookAuthToken:[facebookApi accessToken]];
        [aUser setEmail:email];
        [aUser setFacebookId:fbId];
        [aUser setGender:gender];
        [aUser setDateOfBirth:dob];
        [aUser setAvatar:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal", fbId]];
        AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_FBLOGIN_DONE object:aUser];
        
        // Save the FB id

        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSLog(@"FB Id is %@  sm:%i fb:%i", fbId,smAppDelegate.smLogin,smAppDelegate.facebookLogin);
        [prefs setObject:fbId forKey:@"FBUserId"];
        smAppDelegate.fbId=fbId;
        if (smAppDelegate.smLogin==TRUE)
        {
            NSLog(@"callin get connect fb");
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DO_CONNECT_WITH_FB object:facebookApi.accessToken];
        }

        [prefs synchronize];
        }
        frndListFlag=TRUE;
    }
    
};
                                                                      
/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */

-(void)inviteFriends:(NSMutableArray *)frndList
{
    facebookApi = [[FacebookHelper sharedInstance] facebookApi];
    AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* params;
    
    if (smAppDelegate.fbAccessToken) 
    {
        NSString * stringOfFriends = [frndList componentsJoinedByString:@","];
        params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"Invite your Facebook friends", @"title",
                                       @"Come check out Social Maps.",  @"message",
                                       stringOfFriends, @"to",smAppDelegate.fbAccessToken, @"access_token",
                                       nil]; 

    }
    else if ([userDefault readFromUserDefaults:@"FBAccessTokenKey"]) 
    {
        NSString * stringOfFriends = [frndList componentsJoinedByString:@","];
        params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"Invite your Facebook friends", @"title",
                                       @"Come check out Social Maps.",  @"message",
                                       stringOfFriends, @"to",[prefs stringForKey:@"FBAccessTokenKey"], @"access_token",
                                       nil]; 

    }
    
        
    NSLog(@"facebook params: %@", params);
    NSLog(@"delegate %@  userdef %@ fb %@", smAppDelegate.fbAccessToken,[prefs stringForKey:@"FBAccessTokenKey"],[facebookApi accessToken]);

    [facebookApi dialog:@"apprequests" andParams:params andDelegate:self];


}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error 
{
};

@end

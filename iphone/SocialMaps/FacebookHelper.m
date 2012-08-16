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

@implementation FacebookHelper
@synthesize facebook;

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
        facebook = [[Facebook alloc] initWithAppId:FB_APPID andDelegate:self];
        //[facebook requestWithGraphPath:@"me/friends" andDelegate:self];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"FBAccessTokenKey"] 
            && [defaults objectForKey:@"FBExpirationDateKey"]) {
            facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
            facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        }
    }
    
    return self;
}

// Your dealloc method will never be called, as the singleton survives for the duration of your app.
// However, I like to include it so I know what memory I'm using (and incase, one day, I convert away from Singleton).
-(void)dealloc
{
    // I'm never called!
    [super dealloc];
}

// We don't want to allocate a new instance, so return the current one.
/*+ (id)allocWithZone:(NSZone*)zone {
 //return [[self sharedInstance] retain];
 return [self sharedInstance];
 }*/

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
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSLog(@"Access Token is %@", facebook.accessToken );
    NSLog(@"Expiration Date is %@", facebook.expirationDate );
    [prefs setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [prefs setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [prefs synchronize];
    
    [self getUserInfo:self];
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
    [facebook requestWithGraphPath:@"me" andDelegate:self];
}

- (void)getUserFriendListRequest:(id)sender
{
    [facebook requestWithGraphPath:@"me/friends" andDelegate:self];
}

-(void)getUserFriendListFromFB:(id)result
{
    NSArray * items=[[NSArray alloc] init];
    NSMutableArray *userNameArr=[[NSMutableArray alloc] init];
    NSMutableArray *userIdArr=[[NSMutableArray alloc] init];
    NSMutableArray *imageUrlArr=[[NSMutableArray alloc] init];
    
    items= [[(NSDictionary *)result objectForKey:@"data"]retain];
    NSLog(@"items %d",[items count]);
    friendlist=[[NSMutableArray alloc] initWithCapacity:[items count]];
    for (int i=0; i<[items count]; i++) 
    {
        NSDictionary *friend = [items objectAtIndex:i];
        long long fbid = [[friend objectForKey:@"id"]longLongValue];
        NSString *name = [friend objectForKey:@"name"];
        
        UserFriends *aUserFriend=[[UserFriends alloc] init];
        aUserFriend.userName=name;
        aUserFriend.userId=[NSString stringWithFormat:@"%lld",fbid];
        aUserFriend.imageUrl=[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=normal",aUserFriend.userId];
        [friendlist addObject:aUserFriend];
        [userNameArr addObject:aUserFriend.userName];
        [userIdArr addObject:aUserFriend.userId];
        [imageUrlArr addObject:aUserFriend.imageUrl];
        
        NSLog(@"id: %@ - Name: %@", aUserFriend.userId, name);
    } 
    userFriendslistArray=friendlist;
    userDefault=[[UserDefault alloc ]init];
//    [userDefault writeDataToUserDefaults:@"userFriendslist" withArray:userFriendslistArray];
    [userDefault writeArrayToUserDefaults:@"userNameArr" withArray:userNameArr];
    [userDefault writeArrayToUserDefaults:@"userIdArr" withArray:userIdArr];
    [userDefault writeArrayToUserDefaults:@"imageUrlArr" withArray:imageUrlArr];
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
    //NSLog(@"Status Code @", [response statusCode]);
    NSLog(@"URL %@", [response URL]);
}

/**
 * Called when a request returns and its response has been parsed into
 * an object. The resulting object may be a dictionary, an array, a string,
 * or a number, depending on the format of the API response. If you need access
 * to the raw response, use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
    NSLog(@"Inside didLoad");
    if (frndListFlag==FALSE) 
    {
        NSString *name;
        NSString *firstName;
        NSString *lastName;
        NSString *email;
        NSString *fbId;
        if ([result isKindOfClass:[NSArray class]]) {
            result = [result objectAtIndex:0];
        }
        // When we ask for user infor this will happen.
        if ([result isKindOfClass:[NSDictionary class]]){
            //NSDictionary *hash = result;
            NSLog(@"Birthday: %@", [result objectForKey:@"birthday"]);
            NSLog(@"Name: %@", [result objectForKey:@"name"]); 
            name = [result objectForKey:@"name"];
            NSArray *fields = [name componentsSeparatedByString:@" "];
            int numTokens = [fields count];
            if (numTokens > 0)
                firstName = [fields objectAtIndex:0];
            if (numTokens > 1)
                lastName = [fields objectAtIndex:numTokens-1];
            
            email = [result objectForKey:@"email"];
            fbId = [result objectForKey:@"id"];
            NSLog(@"first=%@,last=%@,email=%@,id=%@",firstName,lastName,email,fbId);
        }
        if ([result isKindOfClass:[NSData class]])
        {
            NSLog(@"Profile Picture");
            //[profilePicture release];
            //profilePicture = [[UIImage alloc] initWithData: result];
        }
        NSLog(@"request returns %@",result);
        //if ([result objectForKey:@"owner"]) {}
        User *aUser = [[User alloc] init];
        [aUser setFirstName:firstName];
        [aUser setLastName:lastName];
        [aUser setFacebookAuthToken:[facebook accessToken]];
        [aUser setEmail:email];
        [aUser setFacebookId:fbId];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_FBLOGIN_DONE object:aUser];
        frndListFlag=TRUE;
        [self getUserFriendListRequest:self];
    }
    
    else
    {
        //Getting friend list from user by zubair
        [self getUserFriendListFromFB:result];
    }
};
                                                                      
/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */

-(void)inviteFriends:(NSMutableArray *)frndList
{
    facebook = [[Facebook alloc] initWithAppId:FB_APPID andDelegate:self];
    
    
   
        
        NSString * stringOfFriends = [frndList componentsJoinedByString:@","];
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"My Title", @"title",
                                       @"Come check out my app.",  @"message",
                                       stringOfFriends, @"to",[userDefault readFromUserDefaults:@"FBAccessTokenKey"], @"access_token",
                                       nil]; 
//        [params setObject:stringOfFriends forKey:@"to"];
        
    NSLog(@"%@", params);
    [facebook dialog:@"apprequests" andParams:params andDelegate:self];


}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error 
{
    //[self.label setText:[error localizedDescription]];
};

@end

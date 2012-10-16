//
//  RestClient.m
//  SocialMaps
//
//  Created by Arif Shakoor on 7/23/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//
#import "ASIFormDataRequest.h"
#import "RestClient.h"
#import "SBJson.h"
#import "NotificationPref.h"
#import "InfoSharing.h"
#import "UserInfo.h"
#import "Geofence.h"
#import "Geolocation.h"
#import "SearchLocation.h"
#import "People.h"
#import "Places.h"
#import "InformationPrefs.h"
#import "UtilityClass.h"
#import "Notification.h"
#import "NotifMessage.h"
#import "NotifRequest.h"
#import "UserCircle.h"
#import "UserFriends.h"
#import "Event.h"
#import "UserDefault.h"
#import "EventList.h"
#import "Globals.h"
#import "MessageReply.h"
#import "MeetUpRequest.h"
#import "AppDelegate.h"

@implementation RestClient
AppDelegate *smAppDelegate;

- (void) login:(NSString*) email password:(NSString*)pass 
{
    NSURL *url = [NSURL URLWithString:[WS_URL stringByAppendingString:@"/auth/login"]];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:email forKey:@"email"];
    [request setPostValue:pass forKey:@"password"];
    
    // Handle successful REST call
    [request setCompletionBlock:^{
                
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204)
        {
            User *aUser = [[User alloc] init];
            
            [aUser setFirstName:[jsonObjects objectForKey:@"firstName"]];
            [aUser setLastName:[jsonObjects objectForKey:@"lastName"]];
            [aUser setAuthToken:[jsonObjects objectForKey:@"authToken"]];
            [aUser setEmail:[jsonObjects objectForKey:@"email"]];
            [aUser setId:[jsonObjects objectForKey:@"id"]];
            aUser.currentLocationLat = [[self getNestedKeyVal:jsonObjects key1:@"currentLocation" key2:@"lat" key3:nil] stringValue];
            aUser.currentLocationLng = [[self getNestedKeyVal:jsonObjects key1:@"currentLocation" key2:@"lng" key3:nil] stringValue];

            [jsonObjects objectForKey:@"friends"];
            NSMutableArray *frndList=[[NSMutableArray alloc] init];
            for (NSDictionary *item in [jsonObjects objectForKey:@"friends"]) {
                UserFriends *frnd = [[UserFriends alloc] init];
                frnd.userId = [self getNestedKeyVal:item key1:@"id" key2:nil key3:nil];
                NSString *firstName = [self getNestedKeyVal:item key1:@"firstName" key2:nil key3:nil];
                NSString *lastName = [self getNestedKeyVal:item key1:@"lastName" key2:nil key3:nil];
                frnd.userName=[NSString stringWithFormat:@"%@ %@", firstName, lastName];
                frnd.imageUrl = [self getNestedKeyVal:item key1:@"avatar" key2:nil key3:nil];
                frnd.distance = [[self getNestedKeyVal:item key1:@"distance" key2:nil key3:nil] doubleValue];
                frnd.coverImageUrl = [self getNestedKeyVal:item key1:@"coverPhoto" key2:nil key3:nil];
                frnd.address =[NSString stringWithFormat:@"%@, %@",[self getNestedKeyVal:item key1:@"address" key2:@"street" key3:nil],[self getNestedKeyVal:item key1:@"address" key2:@"city" key3:nil]];
                frnd.statusMsg = [self getNestedKeyVal:item key1:@"status" key2:nil key3:nil];
                frnd.regMedia = [self getNestedKeyVal:item key1:@"regMedia" key2:nil key3:nil];

                [frndList addObject:frnd];
                NSLog(@"frnd.userId: %@",frnd.userId);
            }
            
            [aUser setFriendsList:frndList];
            friendListGlobalArray=frndList;
            
            NSMutableArray *circleList=[[NSMutableArray alloc] init];
            for (int i=0; i<[[jsonObjects objectForKey:@"circles"] count];i++)
            {
                UserCircle *circle=[[UserCircle alloc] init];
                circle.circleID=[[[jsonObjects objectForKey:@"circles"] objectAtIndex:i] objectForKey:@"id"];
                circle.circleName=[[[jsonObjects objectForKey:@"circles"] objectAtIndex:i] objectForKey:@"name"];
//                circle.type=[[[jsonObjects objectForKey:@"circles"] objectAtIndex:i] objectForKey:@"type"];
                circle.friends=[[[jsonObjects objectForKey:@"circles"] objectAtIndex:i] objectForKey:@"friends"];
                [circleList addObject:circle];
                NSLog(@"circle.circleID: %@",circle.circleID);
            }
            [aUser setCircleList:circleList];
            circleListGlobalArray=circleList;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LOGIN_DONE object:aUser];
        } 
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LOGIN_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LOGIN_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    [request startAsynchronous];
}

- (void) register:(User*) userInfo {
    NSURL *url = [NSURL URLWithString:[WS_URL stringByAppendingString:@"/auth/registration"]];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:userInfo.email forKey:@"email"];
    [request setPostValue:userInfo.password forKey:@"password"];
    [request setPostValue:userInfo.lastName forKey:@"lastName"];
    [request setPostValue:userInfo.firstName forKey:@"firstName"];
    [request setPostValue:userInfo.avatar forKey:@"avatar"]; 
    [request setPostValue:userInfo.gender forKey:@"gender"];
    [request setPostValue:userInfo.bio forKey:@"bio"];
    [request setPostValue:userInfo.street forKey:@"street"];
    [request setPostValue:userInfo.city forKey:@"city"];
    [request setPostValue:userInfo.state forKey:@"state"];
    [request setPostValue:userInfo.postCode forKey:@"postCode"];
    [request setPostValue:userInfo.country forKey:@"country"];
    [request setPostValue:userInfo.interests forKey:@"interests"];
    [request setPostValue:userInfo.workStatus forKey:@"workStatus"];
    [request setPostValue:userInfo.relationshipStatus forKey:@"relationshipStatus"];
    //[request setPostValue:[UtilityClass convertDateToDBFormat:userInfo.dateOfBirth] forKey:@"dateOfBirth"];
    
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204) {
            User *aUser = [[User alloc] init];
            
            [aUser setFirstName:[jsonObjects objectForKey:@"firstName"]];
            [aUser setLastName:[jsonObjects objectForKey:@"lastName"]];
            [aUser setAuthToken:[jsonObjects objectForKey:@"authToken"]];
            [aUser setEmail:[jsonObjects objectForKey:@"email"]];
            [aUser setId:[jsonObjects objectForKey:@"id"]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:aUser];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    [request startAsynchronous];
}

- (void) registerFB:(User*) userInfo {

}


- (void) loginFacebook:(User*) userInfo {
    NSURL *url = [NSURL URLWithString:[WS_URL stringByAppendingString:@"/auth/login/fb"]];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    //[request setPostValue:userInfo.email forKey:@"email"];
    //[request setPostValue:userInfo.password forKey:@"password"];
    [request setPostValue:userInfo.facebookId forKey:@"facebookId"];
    [request setPostValue:userInfo.facebookAuthToken forKey:@"facebookAuthToken"]; 
    if (userInfo.lastName != NULL)
        [request setPostValue:userInfo.lastName forKey:@"lastName"];
    if (userInfo.firstName != NULL)
        [request setPostValue:userInfo.firstName forKey:@"firstName"];
    if (userInfo.avatar != NULL)
        [request setPostValue:userInfo.avatar forKey:@"avatar"]; 
    if (userInfo.gender != NULL)
        [request setPostValue:userInfo.gender forKey:@"gender"]; 
    if (userInfo.dateOfBirth != NULL)
        [request setPostValue:[UtilityClass convertDateToDBFormat:userInfo.dateOfBirth] forKey:@"dateOfBirth"];
    
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204 || responseStatus == 400) {
            User *aUser = [[User alloc] init];
            
            [aUser setFirstName:[jsonObjects objectForKey:@"firstName"]];
            [aUser setLastName:[jsonObjects objectForKey:@"lastName"]];
            [aUser setAuthToken:[jsonObjects objectForKey:@"authToken"]];
            [aUser setEmail:[jsonObjects objectForKey:@"email"]];
            [aUser setId:[jsonObjects objectForKey:@"id"]];
            aUser.currentLocationLat = [[self getNestedKeyVal:jsonObjects key1:@"currentLocation" key2:@"lat" key3:nil] stringValue];
            aUser.currentLocationLng = [[self getNestedKeyVal:jsonObjects key1:@"currentLocation" key2:@"lng" key3:nil] stringValue];

            [jsonObjects objectForKey:@"friends"];
            NSMutableArray *frndList=[[NSMutableArray alloc] init];
            for (NSDictionary *item in [jsonObjects objectForKey:@"friends"]) {
                UserFriends *frnd = [[UserFriends alloc] init];
                frnd.userId = [self getNestedKeyVal:item key1:@"id" key2:nil key3:nil];
                NSString *firstName = [self getNestedKeyVal:item key1:@"firstName" key2:nil key3:nil];
                NSString *lastName = [self getNestedKeyVal:item key1:@"lastName" key2:nil key3:nil];
                frnd.userName=[NSString stringWithFormat:@"%@ %@", firstName, lastName];
                frnd.imageUrl = [self getNestedKeyVal:item key1:@"avatar" key2:nil key3:nil];
                [frndList addObject:frnd];
                NSLog(@"frnd.userId: %@",frnd.userId);
            }
            
            [aUser setFriendsList:frndList];
            friendListGlobalArray=frndList;
            
            NSMutableArray *circleList=[[NSMutableArray alloc] init];
            for (int i=0; i<[[jsonObjects objectForKey:@"circles"] count];i++)
            {
                UserCircle *circle=[[UserCircle alloc] init];
                circle.circleID=[[[jsonObjects objectForKey:@"circles"] objectAtIndex:i] objectForKey:@"id"];
                circle.circleName=[[[jsonObjects objectForKey:@"circles"] objectAtIndex:i] objectForKey:@"name"];
                //                circle.type=[[[jsonObjects objectForKey:@"circles"] objectAtIndex:i] objectForKey:@"type"];
                circle.friends=[[[jsonObjects objectForKey:@"circles"] objectAtIndex:i] objectForKey:@"friends"];
                [circleList addObject:circle];
                NSLog(@"circle.circleID: %@",circle.circleID);
            }
            [aUser setCircleList:circleList];
            circleListGlobalArray=circleList;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_FB_REG_DONE object:aUser];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_FB_REG_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_FB_REG_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    [request startAsynchronous];
}

- (void) forgotPassword:(NSString*)email 
{
    NSString *route = [NSString stringWithFormat:@"%@/auth/forgot_pass/%@",WS_URL,email];
    NSURL *url = [NSURL URLWithString:route];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request setTimeOutSeconds:300];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200) 
        {
            User *aUser = [[User alloc] init];
            
            [aUser setEmail:email];
            [aUser setPassword:[jsonObjects objectForKey:@"password"]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_FORGOT_PW_DONE object:aUser];
        } 
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_FORGOT_PW_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        NSLog(@"Status=%d", [request responseStatusCode]);
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_FORGOT_PW_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    [request startAsynchronous];
}

//getting platform from here
-(void) getPlatForm:(NSString *)authToken:(NSString *)authTokenValue
{
    NSString *route = [NSString stringWithFormat:@"%@/settings/platforms",WS_URL];
    NSURL *url = [NSURL URLWithString:route];
    Platform *platform = [[Platform alloc] init];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:authToken value:authTokenValue];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            
            platform.facebook = [[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"fb" key3:nil] boolValue];
            platform.fourSquare = [[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"4sq" key3:nil] boolValue];
            platform.googlePlus = [[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"googlePlus" key3:nil] boolValue];
            platform.gmail = [[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"gmail" key3:nil] boolValue];
            platform.twitter = [[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"twitter" key3:nil] boolValue];
            platform.yahoo = [[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"yahoo" key3:nil] boolValue];
            platform.badoo = [[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"badoo" key3:nil] boolValue];

            NSLog(@"getPlatforms response: %@",jsonObjects);    
                
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_PLATFORM_DONE object:platform];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_PLATFORM_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_PLATFORM_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt getPlatForm");
    [request startAsynchronous];
 
}

-(void) getLayer:(NSString *)authToken:(NSString *)authTokenValue
{
    NSString *route = [NSString stringWithFormat:@"%@/settings/layers",WS_URL];
    NSURL *url = [NSURL URLWithString:route];
     Layer *layer = [[Layer alloc] init];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:authToken value:authTokenValue];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            layer.wikipedia = [[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"wikipedia" key3:nil] boolValue];
            layer.tripadvisor = [[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"tripadvisor" key3:nil] boolValue];
            layer.foodspotting = [[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"foodspotting" key3:nil] boolValue];
            
            NSLog(@"layer.wiki: %d %d %d",layer.wikipedia,layer.tripadvisor,layer.foodspotting);  
            NSLog(@"Is Kind of NSString: %@",jsonObjects);

            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_LAYER_DONE object:layer];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_LAYER_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_LAYER_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt getLayer");
    [request startAsynchronous];
}

-(void)getSharingPreference:(NSString *)authToken:(NSString *)authTokenValue
{
    NSString *route = [NSString stringWithFormat:@"%@/settings/sharing_preference_settings",WS_URL];
    NSURL *url = [NSURL URLWithString:route];
    InformationPrefs *informationPrefs = [[InformationPrefs alloc] init];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:authToken value:authTokenValue];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            
            
            //firstname
            NSLog(@"0");
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"firstName"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setFirstNameStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"firstName"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"firstName"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setFirstNameFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"firstName"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"firstName"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setFirstNameCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"firstName"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setFirstNameFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"firstName"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setFirstNameFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"firstName"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            NSLog(@"1");
            
            //lastName
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"lastName"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setLastNameStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"lastName"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"lastName"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setLastNameFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"lastName"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"lastName"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setLastNameCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"lastName"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setLastNameFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"lastName"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setLastNameCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"lastName"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"2");            
            //email
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"email"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setEmailStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"email"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"email"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setEmailFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"email"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"email"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setEmailCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"email"]objectForKey:@"circle"]];
            }
            
            else
            {
                [informationPrefs setEmailFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"email"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setEmailCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"email"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"3");
            //dateOfBirth
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"dateOfBirth"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setDateOfBirthStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"dateOfBirth"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"dateOfBirth"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setDateOfBirthFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"dateOfBirth"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"dateOfBirth"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setDateOfBirthCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"dateOfBirth"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setDateOfBirthFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"dateOfBirth"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setDateOfBirthCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"dateOfBirth"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"4");
            //bio
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"bio"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setBioStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"bio"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"bio"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setBioFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"bio"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"bio"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setBioCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"bio"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setBioFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"bio"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setBioCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"bio"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"5");
            //interest
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"interests"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setInterestsStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"interests"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"interests"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setInterestsFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"interests"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"interests"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setInterestsCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"interests"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setInterestsFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"interests"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setInterestsCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"interests"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"6");
            //worksts
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"workStatus"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setWorkStatusStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"workStatus"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"workStatus"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setWorkStatusFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"workStatus"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"workStatus"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setWorkStatusCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"workStatus"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setWorkStatusFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"workStatus"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setWorkStatusCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"workStatus"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"7");
            //relation sts
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"relationshipStatus"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setRelationshipStatusStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"relationshipStatus"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"relationshipStatus"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setRelationshipStatusFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"relationshipStatus"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"relationshipStatus"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setRelationshipStatusCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"relationshipStatus"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setRelationshipStatusFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"relationshipStatus"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setRelationshipStatusCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"relationshipStatus"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"8");
            //address
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"address"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setAddressStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"address"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"address"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setAddressFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"address"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"address"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setAddressCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"address"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setAddressFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"address"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setAddressCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"address"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"9");
            //frnd req
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"friendRequest"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setFriendRequestStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"friendRequest"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"friendRequest"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setFriendRequestFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"friendRequest"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"friendRequest"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setFriendRequestCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"friendRequest"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setFriendRequestFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"friendRequest"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setFriendRequestCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"friendRequest"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"10");
            //circles
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"circles"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setCirclesStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"circles"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"circles"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setCirclesFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"circles"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"circles"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setCirclesCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"circles"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setCirclesFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"circles"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setCirclesCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"circles"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"11");
            //newsfeed
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"newsfeed"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setNewsfeedStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"newsfeed"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"newsfeed"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setNewsfeedFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"newsfeed"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"newsfeed"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setNewsfeedCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"newsfeed"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setNewsfeedFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"newsfeed"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setNewsfeedCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"newsfeed"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"12");
            //avatar
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"avatar"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setAvatarStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"avatar"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"avatar"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setAvatarFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"avatar"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"avatar"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setAvatarCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"avatar"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setAvatarFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"avatar"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setAvatarCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"avatar"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"13");
            //username
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"username"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setUsernameStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"username"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"username"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setUsernameFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"username"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"username"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setUsernameCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"username"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setUsernameFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"username"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setUsernameCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"username"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"14");
            //name
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"name"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setNameStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"name"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"name"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setNameFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"name"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"name"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setNameCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"name"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setNameFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"name"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setNameCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"name"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"15");
            //gender
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"gender"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setGenderStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"gender"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"gender"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setGenderFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"gender"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"gender"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setGenderCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"gender"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setGenderFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"gender"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setGenderCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"gender"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"aUserInfo.lastNameStr: %@  informationPrefs.firstNameStr: %@",informationPrefs.lastNameStr,informationPrefs.firstNameStr);
            NSLog(@"Is Kind of NSString: %@",jsonObjects);
            if (informationPrefs.emailStr)
            {
                NSLog(@"infoPref.emailFrnd %@",informationPrefs.emailStr);
            }
            else if (informationPrefs)             
            {
                NSLog(@"infoPref.emailFrnd %@  %@",informationPrefs.emailFrnd,informationPrefs.emailCircle);
            }
            
            if (informationPrefs.friendRequestStr)
            {
                NSLog(@"infoPref.friendRequest %@",informationPrefs.friendRequestStr);
            }
            else if (informationPrefs)             
            {
                NSLog(@"infoPref.friendRequest %@  %@",informationPrefs.friendRequestFrnd,informationPrefs.friendRequestCircle);
            }
            
            if (informationPrefs.firstNameStr)
            {
                NSLog(@"infoPref.firstNameStr %@",informationPrefs.firstNameStr);
            }
            else if (informationPrefs)     
            {
                NSLog(@"infoPref.firstNameStr %@  %@",informationPrefs.firstNameFrnd,informationPrefs.firstNameCircle);
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_SHARING_PREFS_DONE object:informationPrefs];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_SHARING_PREFS_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_SHARING_PREFS_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt getSharingPreference");
    [request startAsynchronous];
}

- (NSDate*) getDateFromJsonStruct:(NSDictionary*) jsonObjects name:(NSString*) name {
    NSString *date = [self getNestedKeyVal:jsonObjects key1:name key2:@"date" key3:nil];
    NSString *timeZoneType = [self getNestedKeyVal:jsonObjects key1:name key2:@"timezone_type" key3:nil];
    NSString *timeZone = [self getNestedKeyVal:jsonObjects key1:name key2:@"timezone" key3:nil];
    
    return [UtilityClass convertDate:date tz_type:timeZoneType tz:timeZone];
}

- (UserInfo*) parseAccountSettings:(NSDictionary*) jsonObjects user:(UserInfo**)user{
    UserInfo *aUserInfo;
    if (user != nil)
        aUserInfo = *user;
    else
        aUserInfo = [[UserInfo alloc] init];
    aUserInfo.userId = [self getNestedKeyVal:jsonObjects key1:@"id" key2:nil key3:nil];
    aUserInfo.email = [self getNestedKeyVal:jsonObjects key1:@"email" key2:nil key3:nil];
    aUserInfo.firstName = [self getNestedKeyVal:jsonObjects key1:@"firstName" key2:nil key3:nil];
    aUserInfo.lastName = [self getNestedKeyVal:jsonObjects key1:@"lastName" key2:nil key3:nil];
    aUserInfo.avatar = [self getNestedKeyVal:jsonObjects key1:@"avatar" key2:nil key3:nil];
    aUserInfo.deactivated = [self getNestedKeyVal:jsonObjects key1:@"deactivated" key2:nil key3:nil];
    aUserInfo.authToken = [self getNestedKeyVal:jsonObjects key1:@"authToken" key2:nil key3:nil];
    aUserInfo.unit = [self getNestedKeyVal:jsonObjects key1:@"settings" key2:@"unit" key3:nil];
    aUserInfo.source = [self getNestedKeyVal:jsonObjects key1:@"source" key2:nil key3:nil];
    aUserInfo.dateOfBirth = [self getDateFromJsonStruct:jsonObjects name:@"dateOfBirth"];
    aUserInfo.bio = [self getNestedKeyVal:jsonObjects key1:@"bio" key2:nil key3:nil];
    aUserInfo.gender = [self getNestedKeyVal:jsonObjects key1:@"gender" key2:nil key3:nil];
    aUserInfo.username = [self getNestedKeyVal:jsonObjects key1:@"username" key2:nil key3:nil];
    aUserInfo.interests = [self getNestedKeyVal:jsonObjects key1:@"interests" key2:nil key3:nil];
    aUserInfo.workStatus = [self getNestedKeyVal:jsonObjects key1:@"workStatus" key2:nil key3:nil];
    aUserInfo.relationshipStatus = [self getNestedKeyVal:jsonObjects key1:@"relationshipStatus" key2:nil key3:nil];
    aUserInfo.source = [self getNestedKeyVal:jsonObjects key1:@"source" key2:nil key3:nil];
    aUserInfo.currentLocationLat = [self getNestedKeyVal:jsonObjects key1:@"currentLocation" key2:@"lat" key3:nil];
    aUserInfo.currentLocationLng = [self getNestedKeyVal:jsonObjects key1:@"currentLocation" key2:@"lng" key3:nil];
    aUserInfo.enabled = [[self getNestedKeyVal:jsonObjects key1:@"enabled" key2:nil key3:nil] boolValue];
    aUserInfo.visible = [[self getNestedKeyVal:jsonObjects key1:@"visible" key2:nil key3:nil] boolValue];
    aUserInfo.regMedia = [self getNestedKeyVal:jsonObjects key1:@"regMedia" key2:nil key3:nil];
    aUserInfo.loginCount = [self getNestedKeyVal:jsonObjects key1:@"loginCount" key2:nil key3:nil];
    aUserInfo.lastLogin = [self getDateFromJsonStruct:jsonObjects name:@"lastLogin"];
    aUserInfo.createDate = [self getDateFromJsonStruct:jsonObjects name:@"createDate"];
    aUserInfo.updateDate = [self getDateFromJsonStruct:jsonObjects name:@"updateDate"];
    aUserInfo.blockedUsers = [[NSMutableArray alloc] init];
    aUserInfo.blockedUsers = [self getNestedKeyVal:jsonObjects key1:@"blockedUsers" key2:nil key3:nil];
    aUserInfo.blockedBy = [[NSMutableArray alloc] init];
    aUserInfo.blockedBy = [self getNestedKeyVal:jsonObjects key1:@"blockedBy" key2:nil key3:nil];
    aUserInfo.distance = [[self getNestedKeyVal:jsonObjects key1:@"distance" key2:nil key3:nil] integerValue];
    aUserInfo.age = [[self getNestedKeyVal:jsonObjects key1:@"age" key2:nil key3:nil] integerValue];
    aUserInfo.coverPhoto = [self getNestedKeyVal:jsonObjects key1:@"coverPhoto" key2:nil key3:nil];
    aUserInfo.status = [self getNestedKeyVal:jsonObjects key1:@"status" key2:nil key3:nil];
        
    aUserInfo.circles = [[NSMutableArray alloc] init];
    for (NSDictionary *item in [jsonObjects objectForKey:@"circles"]) {
        UserCircle *aCircle = [[UserCircle alloc] init];
        NSString *type = [self getNestedKeyVal:item key1:@"type" key2:nil key3:nil];
        aCircle.circleName = [self getNestedKeyVal:item key1:@"name" key2:nil key3:nil];
        aCircle.friends = [[NSMutableArray alloc] init];
        // Get friends for the circle
        for (NSString *id in [self getNestedKeyVal:item key1:@"friends" key2:nil key3:nil]) {
            UserInfo *afriend = [[UserInfo alloc] init];
            afriend.userId = id;
            [aCircle.friends addObject:afriend];
//            NSLog(@"In getAccountSettings: Circle=%@, friend=%@", aCircle.circleName, afriend.userId);
        }
        if ([type caseInsensitiveCompare:@"system"] == NSOrderedSame) {
            aCircle.type = CircleTypeSystem;
        } else {
            aCircle.type = CircleTypeCustom;
        }
        [aUserInfo.circles addObject:aCircle];
    }
    aUserInfo.address = [[Address alloc] init];
    aUserInfo.address.id = [self getNestedKeyVal:jsonObjects key1:@"address" key2:@"id" key3:nil];
    aUserInfo.address.street = [self getNestedKeyVal:jsonObjects key1:@"address" key2:@"street" key3:nil];
    aUserInfo.address.city = [self getNestedKeyVal:jsonObjects key1:@"address" key2:@"city" key3:nil];
    aUserInfo.address.state = [self getNestedKeyVal:jsonObjects key1:@"address" key2:@"state" key3:nil];
    aUserInfo.address.postCode = [self getNestedKeyVal:jsonObjects key1:@"address" key2:@"postCode" key3:nil];
    aUserInfo.address.country = [self getNestedKeyVal:jsonObjects key1:@"address" key2:@"country" key3:nil];

    return aUserInfo;
}
/*
- (NSDate*) getDateFromJsonStruct:(NSDictionary*) jsonObjects name:(NSString*) name {
    NSString *date = [self getNestedKeyVal:jsonObjects key1:@"result" key2:name key3:@"date"];
    NSString *timeZoneType = [self getNestedKeyVal:jsonObjects key1:@"result" key2:name key3:@"timezone_type"];
    NSString *timeZone = [self getNestedKeyVal:jsonObjects key1:@"result" key2:name key3:@"timezone"];
    
    return [UtilityClass convertDate:date tz_type:timeZoneType tz:timeZone];
}

- (UserInfo*) parseAccountSettings:(NSDictionary*) jsonObjects {
    UserInfo *aUserInfo = [[UserInfo alloc] init];
    aUserInfo.userId = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"id" key3:nil];
    aUserInfo.email = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"email" key3:nil];
    aUserInfo.firstName = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"firstName" key3:nil];
    aUserInfo.lastName = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"lastName" key3:nil];
    aUserInfo.userId = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"id" key3:nil];
    aUserInfo.avatar = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"avatar" key3:nil];
    aUserInfo.deactivated = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"deactivated" key3:nil];
    aUserInfo.authToken = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"authToken" key3:nil];
    aUserInfo.unit = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"settings" key3:@"unit"];
    aUserInfo.source = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"source" key3:nil];
    aUserInfo.dateOfBirth = [self getDateFromJsonStruct:jsonObjects name:@"dateOfBirth"];
    aUserInfo.bio = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"bio" key3:nil];
    aUserInfo.gender = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"gender" key3:nil];
    aUserInfo.username = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"username" key3:nil];
    aUserInfo.interests = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"interests" key3:nil];
    aUserInfo.workStatus = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"workStatus" key3:nil];
    aUserInfo.relationshipStatus = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"relationshipStatus" key3:nil];
    aUserInfo.source = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"source" key3:nil];
    aUserInfo.currentLocationLat = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"currentLocation" key3:@"lat"];
    aUserInfo.currentLocationLng = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"currentLocation" key3:@"lng"];
    aUserInfo.enabled = [[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"enabled" key3:nil] boolValue];
    aUserInfo.visible = [[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"visible" key3:nil] boolValue];
    aUserInfo.regMedia = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"regMedia" key3:nil];
    aUserInfo.loginCount = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"loginCount" key3:nil];
    aUserInfo.lastLogin = [self getDateFromJsonStruct:jsonObjects name:@"lastLogin"];
    aUserInfo.createDate = [self getDateFromJsonStruct:jsonObjects name:@"createDate"];
    aUserInfo.updateDate = [self getDateFromJsonStruct:jsonObjects name:@"updateDate"];
    aUserInfo.blockedUsers = [[NSMutableArray alloc] init];
    aUserInfo.blockedUsers = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"blockedUsers" key3:nil];
    aUserInfo.blockedBy = [[NSMutableArray alloc] init];
    aUserInfo.blockedBy = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"blockedBy" key3:nil];
    aUserInfo.distance = [[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"distance" key3:nil] integerValue];
    aUserInfo.age = [[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"age" key3:nil] integerValue];
    
    aUserInfo.circles = [[NSMutableArray alloc] init];
    for (NSDictionary *item in [jsonObjects objectForKey:@"circles"]) {
        UserCircle *aCircle = [[UserCircle alloc] init];
        NSString *type = [self getNestedKeyVal:item key1:@"type" key2:nil key3:nil];
        aCircle.circleName = [self getNestedKeyVal:item key1:@"name" key2:nil key3:nil];
        aCircle.friends    = [self getNestedKeyVal:item key1:@"friends" key2:nil key3:nil];
        if ([type caseInsensitiveCompare:@"system"] == NSOrderedSame) {
            aCircle.type = CircleTypeSystem;
        } else {
            aCircle.type = CircleTypeCustom;
        }
        [aUserInfo.circles addObject:aCircle];
    }
    aUserInfo.address = [[Address alloc] init];
    aUserInfo.address.id = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"address" key3:@"id"];
    aUserInfo.address.street = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"address" key3:@"street"];
    aUserInfo.address.city = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"address" key3:@"city"];
    aUserInfo.address.state = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"address" key3:@"state"];
    aUserInfo.address.postCode = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"address" key3:@"postCode"];
    aUserInfo.address.country = [self getNestedKeyVal:jsonObjects key1:@"result" key2:@"address" key3:@"country"];
    
    return aUserInfo;
}
*/

-(void)getAccountSettings:(NSString *)authToken:(NSString *)authTokenValue
{
    NSString *route = [NSString stringWithFormat:@"%@/settings/account_settings",WS_URL];
    NSURL *url = [NSURL URLWithString:route];
    __block UserInfo *aUserInfo = nil;
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:authToken value:authTokenValue];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            
            aUserInfo = [self parseAccountSettings:[jsonObjects objectForKey:@"result"] user:nil];
            
//            NSLog(@"getAccountSettings: %@",jsonObjects);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_ACCT_SETTINGS_DONE object:aUserInfo];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_ACCT_SETTINGS_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_ACCT_SETTINGS_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt getAccountSettings");
    [request startAsynchronous];

}

-(void)getUserProfile:(NSString *)authToken:(NSString *)authTokenValue
{
    NSString *route = [NSString stringWithFormat:@"%@/settings/account_settings",WS_URL];
    NSURL *url = [NSURL URLWithString:route];
    __block UserInfo *aUserInfo = nil;
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:authToken value:authTokenValue];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            
            aUserInfo = [self parseAccountSettings:[jsonObjects objectForKey:@"result"] user:nil];
            
            NSLog(@"getAccountSettings: %@",jsonObjects);
            NSLog(@"aUserInfo.avatar %@",aUserInfo.avatar);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_BASIC_PROFILE_DONE object:aUserInfo];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_BASIC_PROFILE_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_BASIC_PROFILE_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt getBasicProfile");
    [request startAsynchronous];

}

-(void)getUserInfo:(UserInfo**)userRef tokenStr:(NSString *)authToken tokenValue:(NSString *)authTokenValue
{
    __block UserInfo *user = *userRef;
    NSString *route = [NSString stringWithFormat:@"%@/users/%@",WS_URL, user.userId];
    NSURL *url = [NSURL URLWithString:route];
    NSLog(@"///////// RestClient:%@", route);
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:authToken value:authTokenValue];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            
            [self parseAccountSettings:jsonObjects user:&user];
            // Load image if present
            if (user.avatar != nil && ![user.avatar isEqualToString:@""]) {
                NSLog(@"<<<<<<<<<<<<< Getting image for %@", user.userId);
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:user.avatar]];
                    UIImage *image = [UIImage imageWithData:imageData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        user.icon = image;
                        NSLog(@">>>>>>>>>>>>>> Got image for %@", user.userId);
                    });
                });
            }
            
            NSLog(@"getAccountSettings: %@",jsonObjects);
            
            //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_ACCT_SETTINGS_DONE object:aUserInfo];
        } 
        else 
        {
            //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_ACCT_SETTINGS_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_ACCT_SETTINGS_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt getUserInfo");
    [request startAsynchronous];
    
}


-(void)getGeofence:(NSString *)authToken:(NSString *)authTokenValue
{
    NSString *route = [NSString stringWithFormat:@"%@/settings/geo_fence",WS_URL];
    NSURL *url = [NSURL URLWithString:route];
    Geofence *geofence = [[Geofence alloc] init];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:authToken value:authTokenValue];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            [geofence setLat:[[jsonObjects objectForKey:@"result"] valueForKey:@"lat"]];
            [geofence setLng:[[jsonObjects objectForKey:@"result"] valueForKey:@"lng"]];
            [geofence setRadius:[[jsonObjects objectForKey:@"result"] valueForKey:@"radius"]];
            
            NSLog(@"layer.wiki: %@ %@ %@",geofence.lat,geofence.lng,[[jsonObjects objectForKey:@"result"] valueForKey:@"radius"]);  
            NSLog(@"Is Kind of NSString: %@",jsonObjects);
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_GEOFENCE_DONE object:geofence];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_GEOFENCE_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_GEOFENCE_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt getGeofence");
    [request startAsynchronous];
}

-(void)getShareLocation:(NSString *)authToken:(NSString *)authTokenValue
{
    NSString *route = [NSString stringWithFormat:@"%@/settings/share/location",WS_URL];
    NSURL *url = [NSURL URLWithString:route];
    ShareLocation *shareLocation = [[ShareLocation alloc] init];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:authToken value:authTokenValue];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            [shareLocation setStatus:[[jsonObjects objectForKey:@"result"] valueForKey:@"status"]];
            [shareLocation setFriendDuration:[[[jsonObjects objectForKey:@"result"] objectForKey:@"friends"]valueForKey:@"duration"]];
            [shareLocation setFriendRadius:[[[jsonObjects objectForKey:@"result"] objectForKey:@"friends"]valueForKey:@"radius"]];            
            shareLocation.permittedUsers=[[[jsonObjects objectForKey:@"result"] objectForKey:@"friends"]valueForKey:@"permitted_users"];
            shareLocation.permittedCircles=[[[jsonObjects objectForKey:@"result"] objectForKey:@"friends"]valueForKey:@"permitted_circles"];

            [shareLocation setFriendDuration:[[[jsonObjects objectForKey:@"result"] objectForKey:@"friends"]valueForKey:@"duration"]];
            [shareLocation setFriendRadius:[[[jsonObjects objectForKey:@"result"] objectForKey:@"friends"]valueForKey:@"radius"]];            
            
            NSLog(@"shareLocation.status: %@  shareLocation.permittedCircles: %@ %@",shareLocation.status,shareLocation.permittedCircles,shareLocation.friendRadius);  
            NSLog(@"Is Kind of NSString: %@",jsonObjects);
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_SHARELOC_DONE object:shareLocation];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_SHARELOC_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_SHARELOC_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt getShareLocation");
    [request startAsynchronous];
}

-(void)getMyPlaces:(NSString *)authToken:(NSString *)authTokenValue
{
    NSString *route = [NSString stringWithFormat:@"%@/me/places",WS_URL];
    NSURL *url = [NSURL URLWithString:route];
    NSMutableArray *myPlaces = [[NSMutableArray alloc] init];
    
    NSLog(@"route = %@", route);
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:authToken value:authTokenValue];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 204) 
        {
            for (NSDictionary *item in jsonObjects) {
                Places *aPlace = [[Places alloc] init];
                
                Geolocation *loc=[[Geolocation alloc] init];
                loc.latitude=[self getNestedKeyVal:item key1:@"location" key2:@"lat" key3:nil];
                loc.longitude=[self getNestedKeyVal:item key1:@"location" key2:@"lng" key3:nil];
                aPlace.location = loc;
                aPlace.address = [self getNestedKeyVal:item key1:@"location" key2:@"address" key3:nil];
                aPlace.name = [self getNestedKeyVal:item key1:@"location" key2:@"title" key3:nil];
                
                [myPlaces addObject:aPlace];
                
            }
            
            NSLog(@"messageReplies = %@", myPlaces);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_MY_PLACES_DONE object:myPlaces];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_MY_PLACES_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_MY_PLACES_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt getReplies");
    [request startAsynchronous];
}

-(void)getNotifications:(NSString *)authToken:(NSString *)authTokenValue
{
    NSString *route = [NSString stringWithFormat:@"%@/settings/notifications",WS_URL];
    NSURL *url = [NSURL URLWithString:route];
    NotificationPref *notificationPref = [[NotificationPref alloc] init];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:authToken value:authTokenValue];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            
//            [notificationPref setFriend_requests_sm:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"friend_requests"] objectForKey:@"sm"]];
//            [notificationPref setPosts_by_friends_sm:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"posts_by_friends"] objectForKey:@"sm"]];
//            [notificationPref setComments_sm:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"comments"] objectForKey:@"sm"]];
//            [notificationPref setMessages_sm:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"messages"] objectForKey:@"sm"]];
//            [notificationPref setProximity_alerts_sm:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"proximity_alerts"] objectForKey:@"sm"]];
//            [notificationPref setRecommendations_sm:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"recommendations"] objectForKey:@"sm"]];
//            [notificationPref setFriend_requests_mail:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"friend_requests"] objectForKey:@"mail"]];
//            [notificationPref setPosts_by_friends_mail:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"posts_by_friends"] objectForKey:@"mail"]];
//            [notificationPref setComments_mail:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"comments"] objectForKey:@"mail"]];
//            [notificationPref setMessages_mail:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"messages"] objectForKey:@"mail"]];
//            [notificationPref setProximity_alerts_mail:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"proximity_alerts"] objectForKey:@"mail"]];
//            [notificationPref setRecommendations_mail:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"recommendations"] objectForKey:@"mail"]];
            
            NotificationPref *notificationPref=[[NotificationPref alloc] init];
            [notificationPref setFriend_requests_sm: [[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"friend_requests" key3:@"sm"] boolValue]];
            [notificationPref setPosts_by_friends_sm:[[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"posts_by_friends" key3:@"sm"] boolValue]];            
            [notificationPref setComments_sm: [[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"comments" key3:@"sm"] boolValue]];            
            [notificationPref setMessages_sm:[[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"messages" key3:@"sm"] boolValue]];           
            [notificationPref setProximity_alerts_sm:[[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"proximity_alerts" key3:@"sm"] boolValue]];
            [notificationPref setRecommendations_sm:[[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"recommendations" key3:@"sm"] boolValue]];
            [notificationPref setFriend_requests_mail:[[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"friend_requests" key3:@"mail"] boolValue]];
            [notificationPref setPosts_by_friends_mail:[[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"posts_by_friends" key3:@"mail"] boolValue]];
            [notificationPref setComments_mail:[[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"comments" key3:@"mail"] boolValue]];
            [notificationPref setMessages_mail:[[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"messages" key3:@"mail"] boolValue]];
            [notificationPref setProximity_alerts_mail:[[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"proximity_alerts" key3:@"mail"] boolValue]];
            [notificationPref setRecommendations_mail:[[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"recommendations" key3:@"mail"] boolValue]];
            
            [notificationPref setOffline_notifications_mail:[[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"offline_notifications" key3:@"mail"] boolValue]];
            [notificationPref setOffline_notifications_sm:[[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"offline_notifications" key3:@"sm"] boolValue]];
            [notificationPref setProximity_radius:[[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"proximity_radius" key3:nil] intValue]];
            
            NSLog(@"notif.recommendations_mail: %i %d",notificationPref.recommendations_mail,notificationPref.proximity_radius);  
            NSLog(@"Friend_requests_sm %i",notificationPref.friend_requests_sm);
            NSLog(@"Is Kind of NSString: %@",jsonObjects);
            
            NSLog(@"aNot %i %i",notificationPref.offline_notifications_sm,notificationPref.offline_notifications_mail);

            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_NOTIFS_DONE object:notificationPref];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_NOTIFS_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_NOTIFS_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt getNotifications");
    [request startAsynchronous];

}

- (id) getNestedKeyVal:(NSDictionary*)dict key1:(NSString*)key1 key2:(NSString*)key2 key3:(NSString*)key3 {
    id val = nil;
    
    @try {
        if (key3 != nil) {
            val=[[[dict objectForKey:key1] objectForKey:key2] objectForKey:key3];
        } else if (key2 != nil) {
            val=[[dict objectForKey:key1] objectForKey:key2];
        } else if (key1 != nil) {
            val=[dict objectForKey:key1];
        }
        if (val == [NSNull null])
            val = nil;
    }
    @catch (id ue) {
        NSLog(@"getNestedKeyVal: Caught %@", ue);
    }
    @finally {
    }
    return val;
}

-(void)getLocation:(Geolocation *)geolocation:(NSString *)authToken:(NSString *)authTokenValue
{
    NSString *route = [NSString stringWithFormat:@"%@/search",WS_URL];
    NSURL *url = [NSURL URLWithString:route];
    
    SearchLocation *searchLocation=[[SearchLocation alloc] init];
    searchLocation.peopleArr = [[NSMutableArray alloc] init];
    searchLocation.placeArr  = [[NSMutableArray alloc] init];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:authToken value:@"ada9369b801c733bfdf75bc2c6aa14c83e4a43bf"];
    [request addPostValue:geolocation.latitude forKey:@"lat"];
    [request addPostValue:geolocation.longitude forKey:@"lng"];
    
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
//        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }

            // Do the parsing in the background as this seems to make the user interaction sluggish
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                //get all people
                for (NSDictionary *item in [jsonObjects  objectForKey:@"people"]) 
                {
                    People *people=[[People alloc] init];

                    people.userId = [self getNestedKeyVal:item key1:@"id" key2:nil key3:nil];
                    people.email = [self getNestedKeyVal:item key1:@"email" key2:nil key3:nil];
                    people.firstName = [self getNestedKeyVal:item key1:@"firstName" key2:nil key3:nil];
                    people.lastName = [self getNestedKeyVal:item key1:@"lastName" key2:nil key3:nil];
                    people.avatar = [self getNestedKeyVal:item key1:@"avatar" key2:nil key3:nil];
                    people.enabled = [self getNestedKeyVal:item key1:@"enabled" key2:nil key3:nil];
                    people.gender = [self getNestedKeyVal:item key1:@"gender" key2:nil key3:nil];
                    people.relationsipStatus = [self getNestedKeyVal:item key1:@"relationshipStatus" key2:nil key3:nil];
                    people.city = [self getNestedKeyVal:item key1:@"city" key2:nil key3:nil];
                    people.workStatus = [self getNestedKeyVal:item key1:@"workStatus" key2:nil key3:nil];
                    people.external = [[self getNestedKeyVal:item key1:@"external" key2:nil key3:nil] boolValue];
                    NSString *friendship = [self getNestedKeyVal:item key1:@"friendship" key2:nil key3:nil];
					people.friendshipStatus = friendship;
                    people.isFriend = ![friendship caseInsensitiveCompare:@"friend"];
                    people.dateOfBirth = [self getDateFromJsonStruct:item name:@"dateOfBirth"];
                    people.age = [self getNestedKeyVal:item key1:@"age" key2:nil key3:nil];
                    people.currentLocationLng = [self getNestedKeyVal:item key1:@"currentLocation" key2:@"lng" key3:nil];
                    people.currentLocationLat = [self getNestedKeyVal:item key1:@"currentLocation" key2:@"lat" key3:nil];
                    
                    people.lastLogin = [self getDateFromJsonStruct:item name:@"lastLogin"];
                    [people setSettingUnit:[self getNestedKeyVal:item key1:@"settings" key2:@"unit" key3:nil]];
                    
                    people.createDate = [self getDateFromJsonStruct:item name:@"createDate"];
                    people.updateDate = [self getDateFromJsonStruct:item name:@"updateDate"];
                    
                    people.distance = [self getNestedKeyVal:item key1:@"distance" key2:nil key3:nil];  
                    
                    people.lastSeenAt = [self getNestedKeyVal:item key1:@"lastSeenAt" key2:nil key3:nil];
                    people.statusMsg=[self getNestedKeyVal:item key1:@"status" key2:nil key3:nil];
                    people.regMedia=[self getNestedKeyVal:item key1:@"regMedia" key2:nil key3:nil];
                    people.blockStatus=[self getNestedKeyVal:item key1:@"blockStatus" key2:nil key3:nil];
//                    NSLog(@"people.statusMsg rest: %@",people.statusMsg);
                    [searchLocation.peopleArr addObject:people];
                    
//                    NSLog(@"User: first %@  last:%@  id:%@ friend:%d",people.firstName, people.lastName, people.userId, people.isFriend);
                }
                
                //get all places
                for (NSDictionary *item in [jsonObjects  objectForKey:@"places"])
                {
                    Places *place=[[Places alloc] init];
                    
                    place.location = [[Geolocation alloc] init];
                    place.location.latitude=[[self getNestedKeyVal:item key1:@"geometry" key2:@"location" key3:@"lat"] stringValue];
                    place.location.longitude=[[self getNestedKeyVal:item key1:@"geometry" key2:@"location" key3:@"lng"] stringValue];
//                    NSLog(@"place location =  %@ %@", place.location.latitude, place.location.longitude);
                    place.northeast = [[Geolocation alloc] init];
                    place.northeast.latitude=[[self getNestedKeyVal:item key1:@"viewport" key2:@"northeast" key3:@"lat"] stringValue];
                    place.northeast.longitude=[[self getNestedKeyVal:item key1:@"viewport" key2:@"northeast" key3:@"lng"] stringValue];
                    
                    place.southwest = [[Geolocation alloc] init];
                    place.southwest.latitude=[[self getNestedKeyVal:item key1:@"viewport" key2:@"southwest" key3:@"lat"] stringValue];
                    place.southwest.longitude=[[self getNestedKeyVal:item key1:@"viewport" key2:@"southwest" key3:@"lng"] stringValue];
                    place.distance = [self getNestedKeyVal:item key1:@"distance" key2:nil key3:nil];
                    [place setIcon:[item objectForKey:@"icon"] ];
                    [place setID:[item objectForKey:@"id"] ];
                    [place setName:[item objectForKey:@"name"] ];
                    [place setReference:[item objectForKey:@"reference"]];
                    [place setTypeArr:[item objectForKey:@"types"]];
                    [place setVicinity:[item objectForKey:@"vicinity"] ];
                    [searchLocation.placeArr addObject:place];
                }
                for (NSDictionary *item in [jsonObjects  objectForKey:@"facebookFriends"])
                {
                    People *people=[[People alloc] init];
                    
                    people.userId = [self getNestedKeyVal:item key1:@"id" key2:nil key3:nil];
                    people.email = [self getNestedKeyVal:item key1:@"email" key2:nil key3:nil];
                    people.firstName = [self getNestedKeyVal:item key1:@"name" key2:nil key3:nil];
                    people.lastName = [self getNestedKeyVal:item key1:@"name" key2:nil key3:nil];
                    people.avatar = [self getNestedKeyVal:item key1:@"avatar" key2:nil key3:nil];
                    people.enabled = [self getNestedKeyVal:item key1:@"enabled" key2:nil key3:nil];
                    people.gender = [self getNestedKeyVal:item key1:@"gender" key2:nil key3:nil];
                    people.relationsipStatus = [self getNestedKeyVal:item key1:@"relationshipStatus" key2:nil key3:nil];
                    people.city = [self getNestedKeyVal:item key1:@"city" key2:nil key3:nil];
                    people.workStatus = [self getNestedKeyVal:item key1:@"workStatus" key2:nil key3:nil];
                    people.external = [[self getNestedKeyVal:item key1:@"external" key2:nil key3:nil] boolValue];
                    NSString *friendship = [self getNestedKeyVal:item key1:@"friendship" key2:nil key3:nil];
					people.friendshipStatus = friendship;
                    people.isFriend = ![friendship caseInsensitiveCompare:@"friend"];
                    people.dateOfBirth = [self getDateFromJsonStruct:item name:@"dateOfBirth"];
                    people.age = [self getNestedKeyVal:item key1:@"age" key2:nil key3:nil];
                    people.currentLocationLng = [self getNestedKeyVal:item key1:@"coords" key2:@"lng" key3:nil];
                    people.currentLocationLat = [self getNestedKeyVal:item key1:@"coords" key2:@"lat" key3:nil];
                    
                    people.lastLogin = [self getDateFromJsonStruct:item name:@"lastLogin"];
                    [people setSettingUnit:[self getNestedKeyVal:item key1:@"settings" key2:@"unit" key3:nil]];
                    
                    people.createDate = [self getDateFromJsonStruct:item name:@"createDate"];
                    people.updateDate = [self getDateFromJsonStruct:item name:@"updateDate"];
                    
                    people.distance = [self getNestedKeyVal:item key1:@"distance" key2:nil key3:nil];  
                    
                    people.lastSeenAt = [self getNestedKeyVal:item key1:@"lastSeenAt" key2:nil key3:nil];
                    people.statusMsg=[self getNestedKeyVal:item key1:@"status" key2:nil key3:nil];
                    people.regMedia=[self getNestedKeyVal:item key1:@"regMedia" key2:nil key3:nil];
                    people.blockStatus=[self getNestedKeyVal:item key1:@"blockStatus" key2:nil key3:nil];
                    people.source=[self getNestedKeyVal:item key1:@"source" key2:nil key3:nil];
//                    NSLog(@"people.statusMsg rest: %@",people.statusMsg);
                    [searchLocation.peopleArr addObject:people];
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_LISTINGS_DONE object:searchLocation];
                });
            });
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_LISTINGS_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_LISTINGS_DONE object:nil];
    }];
    
    //[request setDelegate:self];
//    NSLog(@"asyn srt getLocation");
    [request startAsynchronous];
}

-(void)getAllEvents:(NSString *)authToken:(NSString *)authTokenValue
{
    NSString *route = [NSString stringWithFormat:@"%@/events",WS_URL];
    NSURL *url = [NSURL URLWithString:route];
    Event *aEvent = [[Event alloc] init];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:authToken value:authTokenValue];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        EventList *eventList=[[EventList alloc] init];
        eventList.eventListArr=[[NSMutableArray alloc] init];
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            for (int i=0; i<[jsonObjects count]; i++)
            {
                Event *aEvent=[[Event alloc] init];
                [aEvent setEventID:[[jsonObjects objectAtIndex:i] objectForKey:@"id"]];
                [aEvent setEventName:[[jsonObjects objectAtIndex:i] objectForKey:@"title"]];
                
                Date *date=[[Date alloc] init];
                date.date=[self getNestedKeyVal:[jsonObjects objectAtIndex:i] key1:@"createDate" key2:@"date" key3:nil];
                
                date.timezone=[self getNestedKeyVal:[jsonObjects objectAtIndex:i] key1:@"createDate" key2:@"timezone" key3:nil];
                date.timezoneType=[self getNestedKeyVal:[jsonObjects objectAtIndex:i] key1:@"createDate" key2:@"timezone_type" key3:nil];
                
                [aEvent setEventCreateDate:date];
                
                date=[[Date alloc] init];
                date.date=[self getNestedKeyVal:[jsonObjects objectAtIndex:i] key1:@"time" key2:@"date" key3:nil];
                date.timezone=[self getNestedKeyVal:[jsonObjects objectAtIndex:i] key1:@"time" key2:@"timezone" key3:nil];            
                date.timezoneType=[self getNestedKeyVal:[jsonObjects objectAtIndex:i] key1:@"time" key2:@"timezone_type" key3:nil];           
                [aEvent setEventDate:date];
                
                Geolocation *loc=[[Geolocation alloc] init];
                loc.latitude=[self getNestedKeyVal:[jsonObjects objectAtIndex:i] key1:@"location" key2:@"lat" key3:nil];
                loc.longitude=[self getNestedKeyVal:[jsonObjects objectAtIndex:i] key1:@"location" key2:@"lng" key3:nil];
                [aEvent setEventLocation:loc];
                [aEvent setEventAddress:[self getNestedKeyVal:[jsonObjects objectAtIndex:i] key1:@"location" key2:@"address" key3:nil]];
                [aEvent setEventDistance:[self getNestedKeyVal:[jsonObjects objectAtIndex:i] key1:@"distance" key2:nil key3:nil]];
                [aEvent setEventImageUrl:[self getNestedKeyVal:[jsonObjects objectAtIndex:i] key1:@"eventImage" key2:nil key3:nil]];
                [aEvent setEventShortSummary:[self getNestedKeyVal:[jsonObjects objectAtIndex:i] key1:@"eventShortSummary" key2:nil key3:nil]];
                [aEvent setEventDescription:[self getNestedKeyVal:[jsonObjects objectAtIndex:i] key1:@"description" key2:nil key3:nil]];
                
                [aEvent setMyResponse:[self getNestedKeyVal:[jsonObjects objectAtIndex:i] key1:@"my_response" key2:nil key3:nil]];

                [aEvent setIsInvited:[[self getNestedKeyVal:[jsonObjects objectAtIndex:i] key1:@"is_invited" key2:nil key3:nil] boolValue]];
                [aEvent setGuestCanInvite:[[self getNestedKeyVal:[jsonObjects objectAtIndex:i] key1:@"guestsCanInvite" key2:nil key3:nil] boolValue]];
                [aEvent setOwner:[self getNestedKeyVal:[jsonObjects objectAtIndex:i] key1:@"owner" key2:nil key3:nil]];           
                [aEvent setEventType:[self getNestedKeyVal:[jsonObjects objectAtIndex:i] key1:@"event_type" key2:nil key3:nil]];
                [aEvent setPermission:[self getNestedKeyVal:[jsonObjects objectAtIndex:i] key1:@"permission" key2:nil key3:nil]];
                
                NSLog(@"aEvent.eventName: %@  aEvent.eventID: %@ %@",aEvent.eventName,aEvent.eventDistance,aEvent.eventAddress);
//                NSLog(@"Is Kind of NSString: %@",jsonObjects);
                
                [aEvent.eventList addObject:aEvent];
                [eventList.eventListArr addObject:aEvent];
            }
            NSLog(@"client eventList.eventListArr :%@",eventList.eventListArr);
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_ALL_EVENTS_DONE object:eventList.eventListArr];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_ALL_EVENTS_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_ALL_EVENTS_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt getShareLocation");
    [request startAsynchronous];
}

-(void)getEventDetailById:(NSString *) eventID:(NSString *)authToken:(NSString *)authTokenValue
{
    NSString *route = [NSString stringWithFormat:@"%@/events/%@",WS_URL,eventID];
    NSURL *url = [NSURL URLWithString:route];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:authToken value:authTokenValue];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            
                Event *aEvent=[[Event alloc] init];
                [aEvent setEventID:[jsonObjects objectForKey:@"id"]];
                [aEvent setEventName:[jsonObjects objectForKey:@"title"]];
                
                Date *date=[[Date alloc] init];
                date.date=[self getNestedKeyVal:jsonObjects key1:@"createDate" key2:@"date" key3:nil];
                
                date.timezone=[self getNestedKeyVal:jsonObjects key1:@"createDate" key2:@"timezone" key3:nil];
                date.timezoneType=[self getNestedKeyVal:jsonObjects key1:@"createDate" key2:@"timezone_type" key3:nil];
                
                [aEvent setEventCreateDate:date];
                
                date.date=[self getNestedKeyVal:jsonObjects key1:@"time" key2:@"date" key3:nil];
                date.timezone=[self getNestedKeyVal:jsonObjects key1:@"time" key2:@"timezone" key3:nil];            
                date.timezoneType=[self getNestedKeyVal:jsonObjects key1:@"time" key2:@"timezone_type" key3:nil];           
                [aEvent setEventDate:date];
            
                Geolocation *loc=[[Geolocation alloc] init];
                loc.latitude=[self getNestedKeyVal:jsonObjects key1:@"location" key2:@"lat" key3:nil];
                loc.longitude=[self getNestedKeyVal:jsonObjects key1:@"location" key2:@"lng" key3:nil];
                [aEvent setEventLocation:loc];
                [aEvent setEventAddress:[self getNestedKeyVal:jsonObjects key1:@"location" key2:@"address" key3:nil]];
                [aEvent setEventDistance:[self getNestedKeyVal:jsonObjects key1:@"distance" key2:nil key3:nil]];
                [aEvent setEventImageUrl:[self getNestedKeyVal:jsonObjects key1:@"eventImage" key2:nil key3:nil]];
                [aEvent setEventShortSummary:[self getNestedKeyVal:jsonObjects key1:@"eventShortSummary" key2:nil key3:nil]];
                [aEvent setEventDescription:[self getNestedKeyVal:jsonObjects key1:@"description" key2:nil key3:nil]];
                
                [aEvent setMyResponse:[self getNestedKeyVal:jsonObjects key1:@"my_response" key2:nil key3:nil]];
            
            [aEvent setIsInvited:[[self getNestedKeyVal:jsonObjects key1:@"is_invited" key2:nil key3:nil] boolValue]];
            [aEvent setGuestCanInvite:[[self getNestedKeyVal:jsonObjects key1:@"guestsCanInvite" key2:nil key3:nil] boolValue]];
            [aEvent setOwner:[self getNestedKeyVal:jsonObjects key1:@"owner" key2:nil key3:nil]]; 
            
            [aEvent setYesArr:[self getNestedKeyVal:jsonObjects key1:@"rsvp" key2:@"yes" key3:nil]];
            [aEvent setNoArr:[self getNestedKeyVal:jsonObjects key1:@"rsvp" key2:@"no" key3:nil]];
            [aEvent setMaybeArr:[self getNestedKeyVal:jsonObjects key1:@"rsvp" key2:@"maybe" key3:nil]];
            
            NSMutableArray *guestList=[[NSMutableArray alloc] init];
            for (int i=0; i<[[self getNestedKeyVal:jsonObjects key1:@"guests" key2:@"users" key3:nil] count]; i++)
            {
                UserFriends *guest=[[UserFriends alloc] init];
                guest.userId=[[[self getNestedKeyVal:jsonObjects key1:@"guests" key2:@"users" key3:nil] objectAtIndex:i] valueForKey:@"id"];
                guest.userName=[NSString stringWithFormat:@"%@ %@",[[[self getNestedKeyVal:jsonObjects key1:@"guests" key2:@"users" key3:nil] objectAtIndex:i] valueForKey:@"firstName"],[[[self getNestedKeyVal:jsonObjects key1:@"guests" key2:@"users" key3:nil] objectAtIndex:i] valueForKey:@"lastName"]];
                [[[self getNestedKeyVal:jsonObjects key1:@"guests" key2:@"users" key3:nil] objectAtIndex:i] valueForKey:@"id"];
                guest.imageUrl=[[[self getNestedKeyVal:jsonObjects key1:@"guests" key2:@"users" key3:nil] objectAtIndex:i] valueForKey:@"avatar"];
                [guestList addObject:guest];
            }
            [aEvent setGuestList:guestList];
                NSLog(@"aEvent.eventName: %@  aEvent.eventID: %@ %@",aEvent.eventName,aEvent.eventDistance,aEvent.eventAddress);
//                NSLog(@"Is Kind of NSString: %@",jsonObjects);
            [aEvent setPermission:[self getNestedKeyVal:jsonObjects key1:@"permission" key2:nil key3:nil]];
            [aEvent.eventList addObject:aEvent];                        
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_EVENT_DETAIL_DONE object:aEvent];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_EVENT_DETAIL_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_EVENT_DETAIL_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt get event detail.");
    [request startAsynchronous];
}

-(void)createEvent:(Event*)event:(NSString *)authToken:(NSString *)authTokenValue
{
    NSString *route = [NSString stringWithFormat:@"%@/events",WS_URL];
    NSURL *url = [NSURL URLWithString:route];
    
    SearchLocation *searchLocation=[[SearchLocation alloc] init];
    searchLocation.peopleArr = [[NSMutableArray alloc] init];
    searchLocation.placeArr  = [[NSMutableArray alloc] init];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:authToken value:authTokenValue];
    [request addPostValue:event.eventName forKey:@"title"];
    [request addPostValue:event.eventDescription forKey:@"description"];
    [request addPostValue:event.eventShortSummary forKey:@"eventShortSummary"];
    [request addPostValue:event.eventImageUrl forKey:@"eventImage"];
    [request addPostValue:event.eventAddress forKey:@"address"];
    [request addPostValue:event.eventLocation.latitude forKey:@"lat"];
    [request addPostValue:event.eventLocation.longitude forKey:@"lng"];
    [request addPostValue:event.eventDate.date forKey:@"time"];
    [request addPostValue:[NSNumber numberWithBool: event.guestCanInvite] forKey:@"guestsCanInvite"];
    for (int i=0; i<[event.guestList count]; i++)
    {
        [request addPostValue:[event.guestList objectAtIndex:i] forKey:@"guests[]"];
    }

    for (int i=0; i<[event.circleList count]; i++)
    {
        [request addPostValue:[event.circleList objectAtIndex:i] forKey:@"invitedCircles[]"];
    }

    [request addPostValue:event.permission forKey:@"permission"];
    if ([event.permission isEqualToString:@"custom"])
    {
        for (int i=0; i<[event.permittedUsers count]; i++)
        {
            [request addPostValue:[event.permittedUsers objectAtIndex:i] forKey:@"permittedUsers[]"];
        }
        
        for (int i=0; i<[event.permittedCircles count]; i++)
        {
            [request addPostValue:[event.permittedCircles objectAtIndex:i] forKey:@"permittedCircles[]"];
        }
    }
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            
            [jsonObjects objectForKey:@"message"];            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_CREATE_EVENT_DONE object:[jsonObjects objectForKey:@"message"]];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_CREATE_EVENT_DONE object:@"Event creation failed."];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_CREATE_EVENT_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt getLocation");
    [request startAsynchronous];
}

-(void)deleteEventById:(NSString *) eventID:(NSString *)authToken:(NSString *)authTokenValue
{
    NSString *route = [NSString stringWithFormat:@"%@/events/%@",WS_URL,eventID];
    NSURL *url = [NSURL URLWithString:route];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"DELETE"];
    [request addRequestHeader:authToken value:authTokenValue];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DELETE_EVENT_DONE object:[jsonObjects valueForKey:@"message"]];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DELETE_EVENT_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DELETE_EVENT_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt get event detail.");
    [request startAsynchronous];
}

-(void)setEventRsvp:(NSString *) eventID:(NSString *) rsvp:(NSString *)authToken:(NSString *)authTokenValue
{
    
    NSString *route = [NSString stringWithFormat:@"%@/events/%@/rsvp",WS_URL,eventID];
    NSURL *url = [NSURL URLWithString:route];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"PUT"];
    [request addRequestHeader:authToken value:authTokenValue];
    [request addPostValue:rsvp forKey:@"response"];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            Event *aEvent=[[Event alloc] init];
            [aEvent setEventID:[jsonObjects objectForKey:@"id"]];
            [aEvent setEventName:[jsonObjects objectForKey:@"title"]];
            
            Date *date=[[Date alloc] init];
            date.date=[self getNestedKeyVal:jsonObjects key1:@"createDate" key2:@"date" key3:nil];
            
            date.timezone=[self getNestedKeyVal:jsonObjects key1:@"createDate" key2:@"timezone" key3:nil];
            date.timezoneType=[self getNestedKeyVal:jsonObjects key1:@"createDate" key2:@"timezone_type" key3:nil];
            
            [aEvent setEventCreateDate:date];
            
            date.date=[self getNestedKeyVal:jsonObjects key1:@"time" key2:@"date" key3:nil];
            date.timezone=[self getNestedKeyVal:jsonObjects key1:@"time" key2:@"timezone" key3:nil];            
            date.timezoneType=[self getNestedKeyVal:jsonObjects key1:@"time" key2:@"timezone_type" key3:nil];           
            [aEvent setEventDate:date];
            
            Geolocation *loc=[[Geolocation alloc] init];
            loc.latitude=[self getNestedKeyVal:jsonObjects key1:@"location" key2:@"lat" key3:nil];
            loc.longitude=[self getNestedKeyVal:jsonObjects key1:@"location" key2:@"lng" key3:nil];
            [aEvent setEventLocation:loc];
            [aEvent setEventAddress:[self getNestedKeyVal:jsonObjects key1:@"location" key2:@"address" key3:nil]];
            [aEvent setEventDistance:[self getNestedKeyVal:jsonObjects key1:@"distance" key2:nil key3:nil]];
            [aEvent setEventImageUrl:[self getNestedKeyVal:jsonObjects key1:@"eventImage" key2:nil key3:nil]];
            [aEvent setEventShortSummary:[self getNestedKeyVal:jsonObjects key1:@"eventShortSummary" key2:nil key3:nil]];
            [aEvent setEventDescription:[self getNestedKeyVal:jsonObjects key1:@"description" key2:nil key3:nil]];
            
            [aEvent setMyResponse:[self getNestedKeyVal:jsonObjects key1:@"my_response" key2:nil key3:nil]];
            
            [aEvent setIsInvited:[[self getNestedKeyVal:jsonObjects key1:@"is_invited" key2:nil key3:nil] boolValue]];
            [aEvent setGuestCanInvite:[[self getNestedKeyVal:jsonObjects key1:@"guestsCanInvite" key2:nil key3:nil] boolValue]];
            [aEvent setOwner:[self getNestedKeyVal:jsonObjects key1:@"owner" key2:nil key3:nil]]; 
            
            NSMutableArray *guestList=[[NSMutableArray alloc] init];
            for (int i=0; i<[[self getNestedKeyVal:jsonObjects key1:@"guests" key2:nil key3:nil] count]; i++)
            {
                UserFriends *guest=[[UserFriends alloc] init];
                guest.userId=[[[self getNestedKeyVal:jsonObjects key1:@"guests" key2:nil key3:nil] objectAtIndex:i] valueForKey:@"id"];
                guest.userName=[NSString stringWithFormat:@"%@ %@",[[[self getNestedKeyVal:jsonObjects key1:@"guests" key2:nil key3:nil] objectAtIndex:i] valueForKey:@"firstName"],[[[self getNestedKeyVal:jsonObjects key1:@"guests" key2:nil key3:nil] objectAtIndex:i] valueForKey:@"lastName"]];
                [[[self getNestedKeyVal:jsonObjects key1:@"guests" key2:nil key3:nil] objectAtIndex:i] valueForKey:@"id"];
                guest.imageUrl=[[[self getNestedKeyVal:jsonObjects key1:@"guests" key2:nil key3:nil] objectAtIndex:i] valueForKey:@"avatar"];
                [guestList addObject:guest];
            }
            [aEvent setPermission:[self getNestedKeyVal:jsonObjects key1:@"permission" key2:nil key3:nil]];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SET_RSVP_EVENT_DONE object:[jsonObjects valueForKey:@"message"]];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SET_RSVP_EVENT_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SET_RSVP_EVENT_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt save rsvp detail.");
    [request startAsynchronous];
}

-(void)updateEvent:(NSString *) eventID:(Event*)event:(NSString *)authToken:(NSString *)authTokenValue
{
    NSString *route = [NSString stringWithFormat:@"%@/events/%@",WS_URL,eventID];
    NSURL *url = [NSURL URLWithString:route];
    
    SearchLocation *searchLocation=[[SearchLocation alloc] init];
    searchLocation.peopleArr = [[NSMutableArray alloc] init];
    searchLocation.placeArr  = [[NSMutableArray alloc] init];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"PUT"];
    [request addRequestHeader:authToken value:authTokenValue];
    [request addPostValue:event.eventName forKey:@"title"];
    [request addPostValue:event.eventDescription forKey:@"description"];
    [request addPostValue:event.eventShortSummary forKey:@"eventShortSummary"];
    [request addPostValue:event.eventImageUrl forKey:@"eventImage"];
    [request addPostValue:event.eventAddress forKey:@"address"];
    [request addPostValue:event.eventLocation.latitude forKey:@"lat"];
    [request addPostValue:event.eventLocation.longitude forKey:@"lng"];
    [request addPostValue:event.eventDate.date forKey:@"time"];
    [request addPostValue:[NSNumber numberWithBool: event.guestCanInvite] forKey:@"guestsCanInvite"];
    for (int i=0; i<[event.guestList count]; i++)
    {
        [request addPostValue:[event.guestList objectAtIndex:i] forKey:@"guests[]"];
    }
    
    for (int i=0; i<[event.circleList count]; i++)
    {
        [request addPostValue:[event.circleList objectAtIndex:i] forKey:@"circles[]"];
    }
    
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            Event *aEvent=[[Event alloc] init];
            [aEvent setEventID:[jsonObjects objectForKey:@"id"]];
            [aEvent setEventName:[jsonObjects objectForKey:@"title"]];
            
            Date *date=[[Date alloc] init];
            date.date=[self getNestedKeyVal:jsonObjects key1:@"createDate" key2:@"date" key3:nil];
            
            date.timezone=[self getNestedKeyVal:jsonObjects key1:@"createDate" key2:@"timezone" key3:nil];
            date.timezoneType=[self getNestedKeyVal:jsonObjects key1:@"createDate" key2:@"timezone_type" key3:nil];            
            [aEvent setEventCreateDate:date];
            
            date.date=[self getNestedKeyVal:jsonObjects key1:@"time" key2:@"date" key3:nil];
            date.timezone=[self getNestedKeyVal:jsonObjects key1:@"time" key2:@"timezone" key3:nil];            
            date.timezoneType=[self getNestedKeyVal:jsonObjects key1:@"time" key2:@"timezone_type" key3:nil];           
            [aEvent setEventDate:date];
            
            Geolocation *loc=[[Geolocation alloc] init];
            loc.latitude=[self getNestedKeyVal:jsonObjects key1:@"location" key2:@"lat" key3:nil];
            loc.longitude=[self getNestedKeyVal:jsonObjects key1:@"location" key2:@"lng" key3:nil];
            [aEvent setEventLocation:loc];
            [aEvent setEventAddress:[self getNestedKeyVal:jsonObjects key1:@"location" key2:@"address" key3:nil]];
            [aEvent setEventDistance:[self getNestedKeyVal:jsonObjects key1:@"distance" key2:nil key3:nil]];
            [aEvent setEventImageUrl:[self getNestedKeyVal:jsonObjects key1:@"eventImage" key2:nil key3:nil]];
            [aEvent setEventShortSummary:[self getNestedKeyVal:jsonObjects key1:@"eventShortSummary" key2:nil key3:nil]];
            [aEvent setEventDescription:[self getNestedKeyVal:jsonObjects key1:@"description" key2:nil key3:nil]];
            
            [aEvent setMyResponse:[self getNestedKeyVal:jsonObjects key1:@"my_response" key2:nil key3:nil]];
            
            [aEvent setIsInvited:[[self getNestedKeyVal:jsonObjects key1:@"is_invited" key2:nil key3:nil] boolValue]];
            [aEvent setGuestCanInvite:[[self getNestedKeyVal:jsonObjects key1:@"guestsCanInvite" key2:nil key3:nil] boolValue]];
            [aEvent setOwner:[self getNestedKeyVal:jsonObjects key1:@"owner" key2:nil key3:nil]]; 
            
            NSMutableArray *guestList=[[NSMutableArray alloc] init];
            for (int i=0; i<[[self getNestedKeyVal:jsonObjects key1:@"guests" key2:@"users" key3:nil] count]; i++)
            {
                UserFriends *guest=[[UserFriends alloc] init];
                guest.userId=[[[self getNestedKeyVal:jsonObjects key1:@"guests" key2:@"users" key3:nil] objectAtIndex:i] valueForKey:@"id"];
                guest.userName=[NSString stringWithFormat:@"%@ %@",[[[self getNestedKeyVal:jsonObjects key1:@"guests" key2:@"users" key3:nil] objectAtIndex:i] valueForKey:@"firstName"],[[[self getNestedKeyVal:jsonObjects key1:@"guests" key2:@"users" key3:nil] objectAtIndex:i] valueForKey:@"lastName"]];
                [[[self getNestedKeyVal:jsonObjects key1:@"guests" key2:@"users" key3:nil] objectAtIndex:i] valueForKey:@"id"];
                guest.imageUrl=[[[self getNestedKeyVal:jsonObjects key1:@"guests" key2:@"users" key3:nil] objectAtIndex:i] valueForKey:@"avatar"];
                [guestList addObject:guest];
            }
            [aEvent setPermission:[self getNestedKeyVal:jsonObjects key1:@"permission" key2:nil key3:nil]];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPDATE_EVENT_DONE object:aEvent];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPDATE_EVENT_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPDATE_EVENT_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn update event detail.");
    [request startAsynchronous];
}

-(void)setNotifications:(NotificationPref *)notificationPref:(NSString *)authToken:(NSString *)authTokenValue
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/settings/notifications",WS_URL]];    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"PUT"];
    
    //    [request setPostValue:@"Auth-Token" forKey:@"9068d1bdd04e1bdf66a24f97e7ddce46e71ca13b"];
    
    [request addRequestHeader:authToken value:authTokenValue];
    
    [request addPostValue:[NSNumber numberWithBool: notificationPref.friend_requests_sm] forKey:@"friend_requests_sm"];
    [request addPostValue:[NSNumber numberWithBool: notificationPref.posts_by_friends_sm ] forKey:@"posts_by_friends_sm"];
    [request addPostValue:[NSNumber numberWithBool: notificationPref.comments_sm ] forKey:@"comments_sm"];
    [request addPostValue:[NSNumber numberWithBool: notificationPref.messages_sm ] forKey:@"messages_sm"];
    [request addPostValue:[NSNumber numberWithBool: notificationPref.proximity_alerts_sm ] forKey:@"proximity_alerts_sm"];
    [request addPostValue:[NSNumber numberWithBool: notificationPref.recommendations_sm ] forKey:@"recommendations_sm"];
    [request addPostValue:[NSNumber numberWithBool: notificationPref.friend_requests_mail ] forKey:@"friend_requests_mail"];
    [request addPostValue:[NSNumber numberWithBool: notificationPref.posts_by_friends_mail ] forKey:@"posts_by_friends_mail"];
    [request addPostValue:[NSNumber numberWithBool: notificationPref.comments_mail ] forKey:@"comments_mail"];
    [request addPostValue:[NSNumber numberWithBool: notificationPref.messages_mail ] forKey:@"messages_mail"];
    [request addPostValue:[NSNumber numberWithBool: notificationPref.proximity_alerts_mail ] forKey:@"proximity_alerts_mail"];
    [request addPostValue:[NSNumber numberWithBool: notificationPref.recommendations_mail ]forKey:@"recommendations_mail"];

    
    [request addPostValue:[NSNumber numberWithBool: notificationPref.offline_notifications_mail ]forKey:@"offline_notifications_mail"];
    [request addPostValue:[NSNumber numberWithBool: notificationPref.offline_notifications_sm ] forKey:@"offline_notifications_sm"];
    [request addPostValue:[NSString stringWithFormat:@"%d",notificationPref.proximity_radius] forKey:@"proximity_radius"];
    
    NSLog(@"in put method");
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204 || responseStatus == 400)
        {
                    
            NotificationPref *notificationPref=[[NotificationPref alloc] init];
            [notificationPref setFriend_requests_sm: [[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"friend_requests" key3:@"sm"] boolValue]];
            [notificationPref setPosts_by_friends_sm:[[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"posts_by_friends" key3:@"sm"] boolValue]];            
            [notificationPref setComments_sm: [[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"comments" key3:@"sm"] boolValue]];            
            [notificationPref setMessages_sm:[[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"messages" key3:@"sm"] boolValue]];           
            [notificationPref setProximity_alerts_sm:[[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"proximity_alerts" key3:@"sm"] boolValue]];
            [notificationPref setRecommendations_sm:[[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"recommendations" key3:@"sm"] boolValue]];
            [notificationPref setFriend_requests_mail:[[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"friend_requests" key3:@"mail"] boolValue]];
            [notificationPref setPosts_by_friends_mail:[[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"posts_by_friends" key3:@"mail"] boolValue]];
            [notificationPref setComments_mail:[[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"comments" key3:@"mail"] boolValue]];
            [notificationPref setMessages_mail:[[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"messages" key3:@"mail"] boolValue]];
            [notificationPref setProximity_alerts_mail:[[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"proximity_alerts" key3:@"mail"] boolValue]];
            [notificationPref setRecommendations_mail:[[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"recommendations" key3:@"mail"] boolValue]];
            
            [notificationPref setOffline_notifications_mail:[[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"offline_notifications" key3:@"mail"] boolValue]];
            [notificationPref setOffline_notifications_sm:[[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"offline_notifications" key3:@"sm"] boolValue]];
            [notificationPref setProximity_radius:[[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"proximity_radius" key3:nil] intValue]];
                        
            NSLog(@"notif.recommendations_mail: %i %d",[[self getNestedKeyVal:jsonObjects key1:@"result" key2:@"recommendations" key3:@"mail"] boolValue],notificationPref.proximity_radius);  
            NSLog(@"aNot %i %i",notificationPref.offline_notifications_sm,notificationPref.offline_notifications_mail);
            //            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SETPROFILE_DONE object:platform];
        } 
        else
        {
            //            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SETPROFILE_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^
     {
         //        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:nil];
     }];
    
    //[request setDelegate:self];
    [request startAsynchronous];
}

-(void) setPlatForm:(Platform *)platform:(NSString *)authToken:(NSString *)authTokenValue
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/settings/platforms",WS_URL]];    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"PUT"];
    
//    [request setPostValue:@"Auth-Token" forKey:@"9068d1bdd04e1bdf66a24f97e7ddce46e71ca13b"];
    
    [request addRequestHeader:authToken value:authTokenValue];

    [request addPostValue:[NSNumber numberWithBool: platform.facebook] forKey:@"fb"];
    [request addPostValue:[NSNumber numberWithBool: platform.fourSquare] forKey:@"4sq"];
    [request addPostValue:[NSNumber numberWithBool: platform.googlePlus] forKey:@"googlePlus"];
    [request addPostValue:[NSNumber numberWithBool: platform.gmail] forKey:@"gmail"];
    [request addPostValue:[NSNumber numberWithBool: platform.twitter] forKey:@"twitter"];
    [request addPostValue:[NSNumber numberWithBool: platform.yahoo] forKey:@"yahoo"];
    [request addPostValue:[NSNumber numberWithBool: platform.badoo] forKey:@"badoo"];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204 || responseStatus == 400) {
            Platform *platform = [[Platform alloc] init];
            
            [platform setFacebook:[jsonObjects objectForKey:@"fb"]];
            [platform setFourSquare:[jsonObjects objectForKey:@"4sq"]];
            [platform setGooglePlus:[jsonObjects objectForKey:@"googlePlus"]];
            [platform setGmail:[jsonObjects objectForKey:@"gmail"]];
            [platform setTwitter:[jsonObjects objectForKey:@"twitter"]];
            [platform setYahoo:[jsonObjects objectForKey:@"yahoo"]];
            [platform setBadoo:[jsonObjects objectForKey:@"badoo"]];
            NSLog(@"platform.facebook: %@",[jsonObjects objectForKey:@"fb"]);
//            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SETPROFILE_DONE object:platform];
        } 
        else
        {
//            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SETPROFILE_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^
    {
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    [request startAsynchronous];
}

-(void) setLayer:(Layer *)layer:(NSString *)authToken:(NSString *)authTokenValue
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/settings/layers",WS_URL]];    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"PUT"];
    
    //    [request setPostValue:@"Auth-Token" forKey:@"9068d1bdd04e1bdf66a24f97e7ddce46e71ca13b"];
    
    [request addRequestHeader:authToken value:authTokenValue];
    
    [request addPostValue:[NSNumber numberWithBool: layer.wikipedia] forKey:@"wikipedia"];
    [request addPostValue:[NSNumber numberWithBool: layer.tripadvisor] forKey:@"tripadvisor"];
    [request addPostValue:[NSNumber numberWithBool: layer.foodspotting] forKey:@"foodspotting"];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204 || responseStatus == 400) {
            Layer *layer = [[Layer alloc] init];
            
            [layer setWikipedia:[jsonObjects objectForKey:@"wikipedia"]];
            [layer setTripadvisor:[jsonObjects objectForKey:@"tripadvisor"]];
            [layer setFoodspotting:[jsonObjects objectForKey:@"foodspotting"]];
            NSLog(@"l.wikipedia: %@",[jsonObjects objectForKey:@"wikipedia"]);
//            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SETPROFILE_DONE object:platform];
        } 
        else
        {
//            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SETPROFILE_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^
     {
         //        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:nil];
     }];
    
    //[request setDelegate:self];
    [request startAsynchronous];
    
}

-(void)setSharingPreferenceSettings:(InformationPrefs *)informationPrefs:(NSString *)authToken:(NSString *)authTokenValue
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/settings/sharing_preference_settings",WS_URL]];    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"PUT"];
    
    //    [request setPostValue:@"Auth-Token" forKey:@"9068d1bdd04e1bdf66a24f97e7ddce46e71ca13b"];
    
    [request addRequestHeader:authToken value:authTokenValue];
    ///request value goes here....
    
    if (informationPrefs.firstNameStr) 
    {
        [request addPostValue:informationPrefs.firstNameStr forKey:@"firstName"];        
    }
    else if(([informationPrefs.firstNameFrnd count]>0)&&([informationPrefs.firstNameCircle count]==0))
    {
        for (int i=0; i<[informationPrefs.firstNameFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.firstNameFrnd objectAtIndex:i] forKey:@"firstName[friends][]"];
        }
    }
    else if(([informationPrefs.firstNameFrnd count]==0)&&([informationPrefs.firstNameCircle count]>0))
    {
        for (int i=0; i<[informationPrefs.firstNameCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.firstNameCircle objectAtIndex:i] forKey:@"firstName[circle][]"];
        }        
    }
    else
    {
        for (int i=0; i<[informationPrefs.firstNameFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.firstNameFrnd objectAtIndex:i] forKey:@"firstName[custom][friends][]"];
        }
        for (int i=0; i<[informationPrefs.firstNameCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.firstNameCircle objectAtIndex:i] forKey:@"firstName[custom][circle][]"];
        }        
    }
    
    
    if (informationPrefs.lastNameStr) 
    {
        [request addPostValue:informationPrefs.lastNameStr forKey:@"lastName"];        
    }
    else if(([informationPrefs.lastNameFrnd count]>0)&&([informationPrefs.lastNameCircle count]==0))
    {
        for (int i=0; i<[informationPrefs.lastNameFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.lastNameFrnd objectAtIndex:i] forKey:@"lastName[friends][]"];
        }
    }
    else if(([informationPrefs.lastNameFrnd count]==0)&&([informationPrefs.lastNameCircle count]>0))
    {
        for (int i=0; i<[informationPrefs.lastNameCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.lastNameCircle objectAtIndex:i] forKey:@"lastName[circle][]"];
        }        
    }
    else
    {
        for (int i=0; i<[informationPrefs.lastNameFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.lastNameFrnd objectAtIndex:i] forKey:@"lastName[custom][friends][]"];
        }
        for (int i=0; i<[informationPrefs.lastNameCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.lastNameCircle objectAtIndex:i] forKey:@"lastName[custom][circle][]"];
        }        
    }
    
    
    if (informationPrefs.emailStr) 
    {
        [request addPostValue:informationPrefs.emailStr forKey:@"email"];        
    }
    else if(([informationPrefs.emailFrnd count]>0)&&([informationPrefs.emailCircle count]==0))
    {
        for (int i=0; i<[informationPrefs.emailFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.emailFrnd objectAtIndex:i] forKey:@"email[friends][]"];
        }
    }
    else if(([informationPrefs.emailFrnd count]==0)&&([informationPrefs.emailCircle count]>0))
    {
        for (int i=0; i<[informationPrefs.emailCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.emailCircle objectAtIndex:i] forKey:@"email[circle][]"];
        }        
    }
    else
    {
        for (int i=0; i<[informationPrefs.emailFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.emailFrnd objectAtIndex:i] forKey:@"email[custom][friends][]"];
        }
        for (int i=0; i<[informationPrefs.emailCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.emailCircle objectAtIndex:i] forKey:@"email[custom][circle][]"];
        }        
    }
    
    
    if (informationPrefs.dateOfBirthStr) 
    {
        [request addPostValue:informationPrefs.dateOfBirthStr forKey:@"dateOfBirth"];        
    }
    else if(([informationPrefs.dateOfBirthFrnd count]>0)&&([informationPrefs.dateOfBirthCircle count]==0))
    {
        for (int i=0; i<[informationPrefs.dateOfBirthFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.dateOfBirthFrnd objectAtIndex:i] forKey:@"dateOfBirth[friends][]"];
        }
    }
    else if(([informationPrefs.dateOfBirthFrnd count]==0)&&([informationPrefs.dateOfBirthCircle count]>0))
    {
        for (int i=0; i<[informationPrefs.dateOfBirthCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.dateOfBirthCircle objectAtIndex:i] forKey:@"dateOfBirth[circle][]"];
        }        
    }
    else
    {
        for (int i=0; i<[informationPrefs.dateOfBirthFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.dateOfBirthFrnd objectAtIndex:i] forKey:@"dateOfBirth[custom][friends][]"];
        }
        for (int i=0; i<[informationPrefs.dateOfBirthCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.dateOfBirthCircle objectAtIndex:i] forKey:@"dateOfBirth[custom][circle][]"];
        }        
    }
    
    
    if (informationPrefs.bioStr) 
    {
        [request addPostValue:informationPrefs.bioStr forKey:@"bio"];        
    }
    else if(([informationPrefs.bioFrnd count]>0)&&([informationPrefs.bioCircle count]==0))
    {
        for (int i=0; i<[informationPrefs.bioFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.bioFrnd objectAtIndex:i] forKey:@"bio[friends][]"];
        }
    }
    else if(([informationPrefs.bioFrnd count]==0)&&([informationPrefs.bioCircle count]>0))
    {
        for (int i=0; i<[informationPrefs.bioCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.bioCircle objectAtIndex:i] forKey:@"bio[circle][]"];
        }        
    }
    else
    {
        for (int i=0; i<[informationPrefs.bioFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.bioFrnd objectAtIndex:i] forKey:@"bio[custom][friends][]"];
        }
        for (int i=0; i<[informationPrefs.bioCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.bioCircle objectAtIndex:i] forKey:@"bio[custom][circle][]"];
        }        
    }
    
    //interests
    if (informationPrefs.interestsStr) 
    {
        [request addPostValue:informationPrefs.interestsStr forKey:@"interests"];        
    }
    else if(([informationPrefs.interestsFrnd count]>0)&&([informationPrefs.interestsCircle count]==0))
    {
        for (int i=0; i<[informationPrefs.interestsFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.interestsFrnd objectAtIndex:i] forKey:@"interests[friends][]"];
        }
    }
    else if(([informationPrefs.interestsFrnd count]==0)&&([informationPrefs.interestsCircle count]>0))
    {
        for (int i=0; i<[informationPrefs.interestsCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.interestsCircle objectAtIndex:i] forKey:@"interests[circle][]"];
        }        
    }
    else
    {
        for (int i=0; i<[informationPrefs.interestsFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.interestsFrnd objectAtIndex:i] forKey:@"interests[custom][friends][]"];
        }
        for (int i=0; i<[informationPrefs.interestsCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.interestsCircle objectAtIndex:i] forKey:@"interests[custom][circle][]"];
        }        
    }
    
    //workStatus
    if (informationPrefs.workStatusStr) 
    {
        [request addPostValue:informationPrefs.workStatusStr forKey:@"workStatus"];        
    }
    else if(([informationPrefs.workStatusFrnd count]>0)&&([informationPrefs.workStatusCircle count]==0))
    {
        for (int i=0; i<[informationPrefs.workStatusFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.workStatusFrnd objectAtIndex:i] forKey:@"workStatus[friends][]"];
        }
    }
    else if(([informationPrefs.workStatusFrnd count]==0)&&([informationPrefs.workStatusCircle count]>0))
    {
        for (int i=0; i<[informationPrefs.workStatusCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.workStatusCircle objectAtIndex:i] forKey:@"workStatus[circle][]"];
        }        
    }
    else
    {
        for (int i=0; i<[informationPrefs.workStatusFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.workStatusFrnd objectAtIndex:i] forKey:@"workStatus[custom][friends][]"];
        }
        for (int i=0; i<[informationPrefs.workStatusCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.workStatusCircle objectAtIndex:i] forKey:@"workStatus[custom][circle][]"];
        }        
    }
    
    //relationshipStatus
    if (informationPrefs.relationshipStatusStr) 
    {
        [request addPostValue:informationPrefs.relationshipStatusStr forKey:@"relationshipStatus"];        
    }
    else if(([informationPrefs.relationshipStatusFrnd count]>0)&&([informationPrefs.relationshipStatusCircle count]==0))
    {
        for (int i=0; i<[informationPrefs.relationshipStatusFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.relationshipStatusFrnd objectAtIndex:i] forKey:@"relationshipStatus[friends][]"];
        }
    }
    else if(([informationPrefs.relationshipStatusFrnd count]==0)&&([informationPrefs.relationshipStatusCircle count]>0))
    {
        for (int i=0; i<[informationPrefs.relationshipStatusCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.relationshipStatusCircle objectAtIndex:i] forKey:@"relationshipStatus[circle][]"];
        }        
    }
    else
    {
        for (int i=0; i<[informationPrefs.relationshipStatusFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.relationshipStatusFrnd objectAtIndex:i] forKey:@"relationshipStatus[custom][friends][]"];
        }
        for (int i=0; i<[informationPrefs.relationshipStatusCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.relationshipStatusCircle objectAtIndex:i] forKey:@"relationshipStatus[custom][circle][]"];
        }        
    }
    
    
    //address
    if (informationPrefs.addressStr) 
    {
        [request addPostValue:informationPrefs.addressStr forKey:@"address"];        
    }
    else if(([informationPrefs.addressFrnd count]>0)&&([informationPrefs.addressCircle count]==0))
    {
        for (int i=0; i<[informationPrefs.addressFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.addressFrnd objectAtIndex:i] forKey:@"address[friends][]"];
        }
    }
    else if(([informationPrefs.addressFrnd count]==0)&&([informationPrefs.addressCircle count]>0))
    {
        for (int i=0; i<[informationPrefs.addressCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.addressCircle objectAtIndex:i] forKey:@"address[circle][]"];
        }        
    }
    else
    {
        for (int i=0; i<[informationPrefs.addressFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.addressFrnd objectAtIndex:i] forKey:@"address[custom][friends][]"];
        }
        for (int i=0; i<[informationPrefs.addressCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.addressCircle objectAtIndex:i] forKey:@"address[custom][circle][]"];
        }        
    }
    
    
    //friendRequest
    if (informationPrefs.friendRequestStr) 
    {
        [request addPostValue:informationPrefs.friendRequestStr forKey:@"friendRequest"];        
    }
    else if(([informationPrefs.friendRequestFrnd count]>0)&&([informationPrefs.friendRequestCircle count]==0))
    {
        for (int i=0; i<[informationPrefs.friendRequestFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.friendRequestFrnd objectAtIndex:i] forKey:@"friendRequest[friends][]"];
        }
    }
    else if(([informationPrefs.friendRequestFrnd count]==0)&&([informationPrefs.friendRequestCircle count]>0))
    {
        for (int i=0; i<[informationPrefs.friendRequestCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.friendRequestCircle objectAtIndex:i] forKey:@"friendRequest[circle][]"];
        }        
    }
    else
    {
        for (int i=0; i<[informationPrefs.friendRequestFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.friendRequestFrnd objectAtIndex:i] forKey:@"friendRequest[custom][friends][]"];
        }
        for (int i=0; i<[informationPrefs.friendRequestCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.friendRequestCircle objectAtIndex:i] forKey:@"friendRequest[custom][circle][]"];
        }        
    }
    
    
    //circles
    if (informationPrefs.circlesStr) 
    {
        [request addPostValue:informationPrefs.circlesStr forKey:@"circles"];        
    }
    else if(([informationPrefs.circlesFrnd count]>0)&&([informationPrefs.circlesCircle count]==0))
    {
        for (int i=0; i<[informationPrefs.circlesFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.circlesFrnd objectAtIndex:i] forKey:@"circles[friends][]"];
        }
    }
    else if(([informationPrefs.circlesFrnd count]==0)&&([informationPrefs.circlesCircle count]>0))
    {
        for (int i=0; i<[informationPrefs.circlesCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.circlesCircle objectAtIndex:i] forKey:@"circles[circle][]"];
        }        
    }
    else
    {
        for (int i=0; i<[informationPrefs.circlesFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.circlesFrnd objectAtIndex:i] forKey:@"circles[custom][friends][]"];
        }
        for (int i=0; i<[informationPrefs.circlesCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.circlesCircle objectAtIndex:i] forKey:@"circles[custom][circle][]"];
        }        
    }
    
    
    //newsfeed
    if (informationPrefs.newsfeedStr) 
    {
        [request addPostValue:informationPrefs.newsfeedStr forKey:@"newsfeed"];        
    }
    else if(([informationPrefs.newsfeedFrnd count]>0)&&([informationPrefs.newsfeedCircle count]==0))
    {
        for (int i=0; i<[informationPrefs.newsfeedFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.newsfeedFrnd objectAtIndex:i] forKey:@"newsfeed[friends][]"];
        }
    }
    else if(([informationPrefs.newsfeedFrnd count]==0)&&([informationPrefs.newsfeedCircle count]>0))
    {
        for (int i=0; i<[informationPrefs.newsfeedCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.newsfeedCircle objectAtIndex:i] forKey:@"newsfeed[circle][]"];
        }        
    }
    else
    {
        for (int i=0; i<[informationPrefs.newsfeedFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.newsfeedFrnd objectAtIndex:i] forKey:@"newsfeed[custom][friends][]"];
        }
        for (int i=0; i<[informationPrefs.newsfeedCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.newsfeedCircle objectAtIndex:i] forKey:@"newsfeed[custom][circle][]"];
        }        
    }
    
    //avatar
    if (informationPrefs.avatarStr) 
    {
        [request addPostValue:informationPrefs.avatarStr forKey:@"avatar"];        
    }
    else if(([informationPrefs.avatarFrnd count]>0)&&([informationPrefs.avatarCircle count]==0))
    {
        for (int i=0; i<[informationPrefs.avatarFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.avatarFrnd objectAtIndex:i] forKey:@"avatar[friends][]"];
        }
    }
    else if(([informationPrefs.avatarFrnd count]==0)&&([informationPrefs.avatarCircle count]>0))
    {
        for (int i=0; i<[informationPrefs.avatarCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.avatarCircle objectAtIndex:i] forKey:@"avatar[circle][]"];
        }        
    }
    else
    {
        for (int i=0; i<[informationPrefs.avatarFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.avatarFrnd objectAtIndex:i] forKey:@"avatar[custom][friends][]"];
        }
        for (int i=0; i<[informationPrefs.avatarCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.avatarCircle objectAtIndex:i] forKey:@"avatar[custom][circle][]"];
        }        
    }
    
    //username
    if (informationPrefs.usernameStr) 
    {
        [request addPostValue:informationPrefs.usernameStr forKey:@"username"];        
    }
    else if(([informationPrefs.usernameFrnd count]>0)&&([informationPrefs.usernameCircle count]==0))
    {
        for (int i=0; i<[informationPrefs.usernameFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.usernameFrnd objectAtIndex:i] forKey:@"username[friends][]"];
        }
    }
    else if(([informationPrefs.usernameFrnd count]==0)&&([informationPrefs.usernameCircle count]>0))
    {
        for (int i=0; i<[informationPrefs.usernameCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.usernameCircle objectAtIndex:i] forKey:@"username[circle][]"];
        }        
    }
    else
    {
        for (int i=0; i<[informationPrefs.usernameFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.usernameFrnd objectAtIndex:i] forKey:@"username[custom][friends][]"];
        }
        for (int i=0; i<[informationPrefs.usernameCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.usernameCircle objectAtIndex:i] forKey:@"username[custom][circle][]"];
        }        
    }
    
    
    //name
    if (informationPrefs.nameStr) 
    {
        [request addPostValue:informationPrefs.nameStr forKey:@"name"];        
    }
    else if(([informationPrefs.nameFrnd count]>0)&&([informationPrefs.nameCircle count]==0))
    {
        for (int i=0; i<[informationPrefs.nameFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.nameFrnd objectAtIndex:i] forKey:@"name[friends][]"];
        }
    }
    else if(([informationPrefs.nameFrnd count]==0)&&([informationPrefs.nameCircle count]>0))
    {
        for (int i=0; i<[informationPrefs.nameCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.nameCircle objectAtIndex:i] forKey:@"name[circle][]"];
        }        
    }
    else
    {
        for (int i=0; i<[informationPrefs.nameFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.nameFrnd objectAtIndex:i] forKey:@"name[custom][friends][]"];
        }
        for (int i=0; i<[informationPrefs.nameCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.nameCircle objectAtIndex:i] forKey:@"name[custom][circle][]"];
        }        
    }
    
    
    //gender
    if (informationPrefs.genderStr) 
    {
        [request addPostValue:informationPrefs.genderStr forKey:@"gender"];        
    }
    else if(([informationPrefs.genderFrnd count]>0)&&([informationPrefs.genderCircle count]==0))
    {
        for (int i=0; i<[informationPrefs.genderFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.genderFrnd objectAtIndex:i] forKey:@"gender[friends][]"];
        }
    }
    else if(([informationPrefs.genderFrnd count]==0)&&([informationPrefs.genderCircle count]>0))
    {
        for (int i=0; i<[informationPrefs.genderCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.genderCircle objectAtIndex:i] forKey:@"gender[circle][]"];
        }        
    }
    else
    {
        for (int i=0; i<[informationPrefs.genderFrnd count]; i++)
        {
            [request addPostValue:[informationPrefs.genderFrnd objectAtIndex:i] forKey:@"gender[custom][friends][]"];
        }
        for (int i=0; i<[informationPrefs.genderCircle count]; i++)
        {
            [request addPostValue:[informationPrefs.genderCircle objectAtIndex:i] forKey:@"gender[custom][circle][]"];
        }        
    }
    
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204 || responseStatus == 400) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            //firstname
            NSLog(@"0");
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"firstName"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setFirstNameStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"firstName"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"firstName"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setFirstNameFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"firstName"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"firstName"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setFirstNameCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"firstName"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setFirstNameFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"firstName"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setFirstNameFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"firstName"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            NSLog(@"1");
            
            //lastName
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"lastName"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setLastNameStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"lastName"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"lastName"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setLastNameFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"lastName"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"lastName"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setLastNameCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"lastName"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setLastNameFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"lastName"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setLastNameCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"lastName"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"2");            
            //email
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"email"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setEmailStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"email"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"email"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setEmailFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"email"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"email"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setEmailCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"email"]objectForKey:@"circle"]];
            }
            
            else
            {
                [informationPrefs setEmailFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"email"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setEmailCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"email"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"3");
            //dateOfBirth
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"dateOfBirth"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setDateOfBirthStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"dateOfBirth"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"dateOfBirth"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setDateOfBirthFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"dateOfBirth"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"dateOfBirth"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setDateOfBirthCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"dateOfBirth"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setDateOfBirthFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"dateOfBirth"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setDateOfBirthCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"dateOfBirth"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"4");
            //bio
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"bio"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setBioStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"bio"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"bio"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setBioFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"bio"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"bio"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setBioCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"bio"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setBioFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"bio"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setBioCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"bio"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"5");
            //interest
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"interests"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setInterestsStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"interests"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"interests"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setInterestsFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"interests"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"interests"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setInterestsCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"interests"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setInterestsFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"interests"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setInterestsCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"interests"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"6");
            //worksts
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"workStatus"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setWorkStatusStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"workStatus"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"workStatus"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setWorkStatusFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"workStatus"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"workStatus"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setWorkStatusCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"workStatus"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setWorkStatusFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"workStatus"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setWorkStatusCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"workStatus"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"7");
            //relation sts
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"relationshipStatus"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setRelationshipStatusStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"relationshipStatus"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"relationshipStatus"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setRelationshipStatusFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"relationshipStatus"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"relationshipStatus"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setRelationshipStatusCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"relationshipStatus"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setRelationshipStatusFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"relationshipStatus"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setRelationshipStatusCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"relationshipStatus"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"8");
            //address
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"address"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setAddressStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"address"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"address"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setAddressFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"address"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"address"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setAddressCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"address"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setAddressFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"address"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setAddressCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"address"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"9");
            //frnd req
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"friendRequest"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setFriendRequestStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"friendRequest"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"friendRequest"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setFriendRequestFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"friendRequest"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"friendRequest"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setFriendRequestCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"friendRequest"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setFriendRequestFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"friendRequest"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setFriendRequestCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"friendRequest"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"10");
            //circles
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"circles"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setCirclesStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"circles"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"circles"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setCirclesFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"circles"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"circles"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setCirclesCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"circles"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setCirclesFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"circles"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setCirclesCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"circles"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"11");
            //newsfeed
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"newsfeed"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setNewsfeedStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"newsfeed"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"newsfeed"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setNewsfeedFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"newsfeed"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"newsfeed"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setNewsfeedCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"newsfeed"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setNewsfeedFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"newsfeed"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setNewsfeedCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"newsfeed"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"12");
            //avatar
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"avatar"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setAvatarStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"avatar"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"avatar"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setAvatarFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"avatar"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"avatar"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setAvatarCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"avatar"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setAvatarFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"avatar"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setAvatarCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"avatar"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"13");
            //username
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"username"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setUsernameStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"username"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"username"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setUsernameFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"username"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"username"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setUsernameCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"username"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setUsernameFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"username"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setUsernameCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"username"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"14");
            //name
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"name"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setNameStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"name"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"name"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setNameFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"name"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"name"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setNameCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"name"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setNameFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"name"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setNameCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"name"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"15");
            //gender
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"gender"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setGenderStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"gender"]];
            }
            else if([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"gender"] objectForKey:@"friends"]!=NULL)
            {
                [informationPrefs setGenderFrnd:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"gender"] objectForKey:@"friends"]];
            }
            else if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"gender"] objectForKey:@"circle"]!=NULL) 
            {
                [informationPrefs setGenderCircle:[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"gender"]objectForKey:@"circle"]];
            }
            else
            {
                [informationPrefs setGenderFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"gender"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setGenderCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"gender"] objectForKey:@"custom"]objectForKey:@"circle"]];
                
            }
            
            NSLog(@"aUserInfo.lastNameStr: %@  informationPrefs.firstNameStr: %@",informationPrefs.lastNameStr,informationPrefs.firstNameStr);
            NSLog(@"Is Kind of NSString: %@",jsonObjects);
            if (informationPrefs.emailStr)
            {
                NSLog(@"infoPref.emailFrnd %@",informationPrefs.emailStr);
            }
            else if (informationPrefs)             
            {
                NSLog(@"infoPref.emailFrnd %@  %@",informationPrefs.emailFrnd,informationPrefs.emailCircle);
            }
            
            if (informationPrefs.friendRequestStr)
            {
                NSLog(@"infoPref.friendRequest %@",informationPrefs.friendRequestStr);
            }
            else if (informationPrefs)             
            {
                NSLog(@"infoPref.friendRequest %@  %@",informationPrefs.friendRequestFrnd,informationPrefs.friendRequestCircle);
            }
            
            if (informationPrefs.firstNameStr)
            {
                NSLog(@"infoPref.firstNameStr %@",informationPrefs.firstNameStr);
            }
            else if (informationPrefs)     
            {
                NSLog(@"infoPref.firstNameStr %@  %@",informationPrefs.firstNameFrnd,informationPrefs.firstNameCircle);
            }
            
            //            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LOGIN_DONE object:aUser];
        } 
        else
        {
            //            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SETPROFILE_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^
     {
         //        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:nil];
     }];
    
    //[request setDelegate:self];
    [request startAsynchronous];
}


-(void)setAccountSettings:(UserInfo *)userInfo:(NSString *)authToken:(NSString *)authTokenValue;
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/settings/account_settings",WS_URL]];    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"PUT"];
    
    [request addRequestHeader:authToken value:authTokenValue];    
    [request addPostValue:userInfo.firstName forKey:@"firstName"];
    [request addPostValue:userInfo.lastName forKey:@"lastName"];
    [request addPostValue:userInfo.email forKey:@"email"];
//    [request addPostValue:userInfo.p forKey:@"password"];
    [request addPostValue:userInfo.avatar forKey:@"avatar"];
    [request addPostValue:userInfo.gender forKey:@"gender"];
    [request addPostValue:userInfo.username forKey:@"username"];
    [request addPostValue:userInfo.address.city forKey:@"city"];
    [request addPostValue:userInfo.address.postCode forKey:@"postCode"];
    [request addPostValue:userInfo.address.country forKey:@"country"];
    [request addPostValue:userInfo.workStatus forKey:@"workStatus"];
    [request addPostValue:userInfo.relationshipStatus forKey:@"relationshipStatus"];
    [request addPostValue:userInfo.settings forKey:@"settings[units]"];
    [request addPostValue:userInfo.bio forKey:@"bio"];
    [request addPostValue:userInfo.interests forKey:@"interests"];
    [request setPostValue:[UtilityClass convertNSDateToDBFormat:userInfo.dateOfBirth] forKey:@"dateOfBirth"];
    
    
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204 || responseStatus == 400) 
        {
            UserInfo *aUserInfo = [self parseAccountSettings:jsonObjects user:nil];
            
            NSLog(@"setSettingsPrefs: response = %@", jsonObjects);
            [UtilityClass showAlert:@"Social Maps" :@"Your Personal Information Saved"];
            //            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SETPROFILE_DONE object:platform];
        } 
        {
            //            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SETPROFILE_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^
     {
         //        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:nil];
     }];
    
    //[request setDelegate:self];
    [request startAsynchronous];
    

}

-(void)updateUserProfile:(UserInfo *)userInfo:(NSString *)authToken:(NSString *)authTokenValue
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/settings/account_settings",WS_URL]];    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"PUT"];
    
    [request addRequestHeader:authToken value:authTokenValue];  
    if (userInfo.firstName)
    {
        [request addPostValue:userInfo.firstName forKey:@"firstName"];
    }
    if(userInfo.lastName)
    {
        [request addPostValue:userInfo.lastName forKey:@"lastName"];
    }
    if(userInfo.email)
    {
        [request addPostValue:userInfo.email forKey:@"email"];
    }
    //    [request addPostValue:userInfo.p forKey:@"password"];
    if(userInfo.avatar)
    {
        [request addPostValue:userInfo.avatar forKey:@"avatar"];
    }
    if(userInfo.gender)
    {
        [request addPostValue:userInfo.gender forKey:@"gender"];
    }
    if(userInfo.username)
    {
        [request addPostValue:userInfo.username forKey:@"username"];
    }
    if(userInfo.address.city)
    {
        [request addPostValue:userInfo.address.city forKey:@"city"];
    }
    if(userInfo.address.postCode)
    {
        [request addPostValue:userInfo.address.postCode forKey:@"postCode"];
    }
    if(userInfo.address.country)
    {
        [request addPostValue:userInfo.address.country forKey:@"country"];
    }
    if(userInfo.workStatus)
    {
        [request addPostValue:userInfo.workStatus forKey:@"workStatus"];
    }
    if(userInfo.relationshipStatus)
    {
        [request addPostValue:userInfo.relationshipStatus forKey:@"relationshipStatus"];
    }
    if(userInfo.unit)
    {
        [request addPostValue:userInfo.settings forKey:@"settings[units]"];
    }
    if(userInfo.bio)
    {
        [request addPostValue:userInfo.bio forKey:@"bio"];
    }
    if(userInfo.interests)
    {
        [request addPostValue:userInfo.interests forKey:@"interests"];
    }
    if(userInfo.dateOfBirth)
    {
        [request setPostValue:[UtilityClass convertNSDateToDBFormat:userInfo.dateOfBirth] forKey:@"dateOfBirth"];
    }
    if(userInfo.avatar)
    {
        [request setPostValue:userInfo.avatar forKey:@"avatar"];
    }
    if(userInfo.coverPhoto)
    {
        [request setPostValue:userInfo.coverPhoto forKey:@"coverPhoto"];
    }
    if (userInfo.status)
    {
        [request setPostValue:userInfo.status forKey:@"status"];
    }
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204 || responseStatus == 400) 
        {
            UserInfo *aUserInfo = [self parseAccountSettings:jsonObjects user:nil];
            
            NSLog(@"setSettingsPrefs: response = %@", jsonObjects);
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPDATE_BASIC_PROFILE_DONE object:aUserInfo];
        } 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPDATE_BASIC_PROFILE_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^
     {
         [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPDATE_BASIC_PROFILE_DONE object:nil];
     }];
    
    //[request setDelegate:self];
    [request startAsynchronous];
    
    
}

-(void)setGeofence:(Geofence *)geofence:(NSString *)authToken:(NSString *)authTokenValue
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/settings/geo_fence",WS_URL]];
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"PUT"];
    
    //    [request setPostValue:@"Auth-Token" forKey:@"9068d1bdd04e1bdf66a24f97e7ddce46e71ca13b"];
    
    [request addRequestHeader:authToken value:authTokenValue];
    
    [request addPostValue:geofence.lat forKey:@"lat"];
    [request addPostValue:geofence.lng forKey:@"lng"];
    [request addPostValue:geofence.radius forKey:@"radius"];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204 || responseStatus == 400) 
        {
            Geofence *aGeofence = [[Geofence alloc] init];
            
            [aGeofence setLat:[[jsonObjects objectForKey:@"result"] valueForKey:@"lat"]];
            [aGeofence setLng:[[jsonObjects objectForKey:@"result"] valueForKey:@"lng"]];
            [aGeofence setRadius:[[jsonObjects objectForKey:@"result"] valueForKey:@"radius"]];
            
            NSLog(@"layer.wiki: %@ %@ %@",aGeofence.lat,aGeofence.lng,[[jsonObjects objectForKey:@"result"] valueForKey:@"radius"]);  
            NSLog(@"Is Kind of NSString: %@",jsonObjects);

            //            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SETPROFILE_DONE object:platform];
        } 
        else
        {
            //            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SETPROFILE_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^
     {
         //        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:nil];
     }];
    
    //[request setDelegate:self];
    [request startAsynchronous];
}

-(void)setShareLocation:(ShareLocation *)shareLocation:(NSString *)authToken:(NSString *)authTokenValue
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/settings/share/location",WS_URL]];
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"PUT"];

    [request addRequestHeader:authToken value:authTokenValue];
    
    [request addPostValue:shareLocation.status forKey:@"status"];
    for (int i=0; i<[shareLocation.permittedUsers count]; i++)
    {
        [request addPostValue:[shareLocation.permittedUsers objectAtIndex:i] forKey:@"friends[permitted_users][]"];
    }
    
    for (int i=0; i<[shareLocation.permittedCircles count]; i++)
    {
        [request addPostValue:[shareLocation.permittedCircles objectAtIndex:i] forKey:@"friends[permitted_circles][]"];
    }
    
    [request addPostValue:shareLocation.friendDuration forKey:@"friends[duration]"];
    [request addPostValue:shareLocation.friendRadius forKey:@"friends[radius]"];
    [request addPostValue:shareLocation.strangersDuration forKey:@"strangers[duration]"];
    [request addPostValue:shareLocation.strangersRadius forKey:@"strangers[radius]"];
    
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204 || responseStatus == 400) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            
            ShareLocation *aShareLocation=[[ShareLocation alloc] init];
            [aShareLocation setStatus:[[jsonObjects objectForKey:@"result"] valueForKey:@"status"]];
            [aShareLocation setFriendDuration:[[[jsonObjects objectForKey:@"result"] objectForKey:@"friends"]valueForKey:@"duration"]];
            [aShareLocation setFriendRadius:[[[jsonObjects objectForKey:@"result"] objectForKey:@"friends"]valueForKey:@"radius"]];            
            aShareLocation.permittedUsers=[[[jsonObjects objectForKey:@"result"] objectForKey:@"friends"]valueForKey:@"permitted_users"];
            aShareLocation.permittedCircles=[[[jsonObjects objectForKey:@"result"] objectForKey:@"friends"]valueForKey:@"permitted_circles"];
            
            [aShareLocation setFriendDuration:[[[jsonObjects objectForKey:@"result"] objectForKey:@"strangers"]valueForKey:@"duration"]];
            [aShareLocation setFriendRadius:[[[jsonObjects objectForKey:@"result"] objectForKey:@"strangers"]valueForKey:@"radius"]];            
            
            NSLog(@"shareLocation.status: %@ %@ %@",aShareLocation.status,aShareLocation.permittedUsers,[[[jsonObjects objectForKey:@"result"] objectForKey:@"strangers"]valueForKey:@"radius"]);  
            NSLog(@"Is Kind of NSString: %@",jsonObjects);
            
            //            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SETPROFILE_DONE object:platform];
        } 
        else
        {
            //            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SETPROFILE_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^
     {
         //        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:nil];
     }];
    
    //[request setDelegate:self];
    [request startAsynchronous];
}

- (void) updatePosition:(Geolocation*)currLocation authToken:(NSString*)authToken authTokenVal:(NSString*)authTokenValue {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/current-location",WS_URL]];
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"PUT"];
    
    //    [request setPostValue:@"Auth-Token" forKey:@"9068d1bdd04e1bdf66a24f97e7ddce46e71ca13b"];
    
    [request addRequestHeader:authToken value:authTokenValue];
    
    [request addPostValue:currLocation.latitude forKey:@"lat"];
    [request addPostValue:currLocation.longitude forKey:@"lng"];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200) 
        {
             NSLog(@"Updated position: %@",jsonObjects);
            
        } 
        else
        {
            NSLog(@"Failed to update position: status=%d", responseStatus);
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^
     {
         NSLog(@"Failed in REST call: status=%d", [request responseStatusCode]);
     }];
    
    //[request setDelegate:self];
    [request startAsynchronous];

}

// Send message to one or more SM users
- (void) sendMessage:(NSString*)subject content:(NSString*)content recipients:(NSArray*)recipients authToken:(NSString*)authToken authTokenVal:(NSString*)authTokenValue{
    NSURL *url = [NSURL URLWithString:[WS_URL stringByAppendingString:@"/messages"]];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];

    [request addRequestHeader:authToken value:authTokenValue];
    
    [request setPostValue:subject forKey:@"subject"];
    [request setPostValue:content forKey:@"content"];
    for (NSString *id in recipients) {
        [request addPostValue:id forKey:@"recipients[]"];
    }
    
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201) {
            [UtilityClass showAlert:@"" :@"Message Sent"];
            NSLog(@"sendMessage successful:status=%d", responseStatus);
            //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:aUser];
        } else {
            NSLog(@"sendMessage unsuccessful:status=%d", responseStatus);
            [UtilityClass showAlert:@"" :@"Failed to send message"];
            //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        NSLog(@"sendMessage failed: unknown error");
        //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    [request startAsynchronous];

}

// Send meet up request to one or more SM users
- (void) sendMeetUpRequest:(NSString*)title description:(NSString*)description latitude:(NSString*)latitude longitude:(NSString*)longitude address:(NSString*)address time:(NSString*)time recipients:(NSArray*)recipients authToken:(NSString*)authToken authTokenVal:(NSString*)authTokenValue
{
    NSURL *url = [NSURL URLWithString:[WS_URL stringByAppendingString:@"/meetups"]];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    
    [request addRequestHeader:authToken value:authTokenValue];
    
    //[request setPostValue:title forKey:@"title"];
    [request setPostValue:description forKey:@"message"];
    [request setPostValue:latitude forKey:@"lat"];
    [request setPostValue:longitude forKey:@"lng"];
    [request setPostValue:address forKey:@"address"];
    [request setPostValue:time forKey:@"time"];
    [request setPostValue:@"private" forKey:@"permission"];
    
    for (NSString *id in recipients) {
        [request addPostValue:id forKey:@"guests[]"];
    }
    
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201) {
            [UtilityClass showAlert:@"" :@"Meet-up request sent"];
            NSLog(@"sendMessage successful:status=%d", responseStatus);
            //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:aUser];
            //getmeetuprequestdone
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SEND_MEET_UP_REQUEST_DONE object:nil];
        } else {
            NSLog(@"sendMessage unsuccessful:status=%d", responseStatus);
            [UtilityClass showAlert:@"" :@"Failed to send meet-up request"];
            //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        NSLog(@"sendMeetup failed: unknown error");
        //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    [request startAsynchronous];
    
}

- (void) updateMeetUpRequest:(NSString*)meetUpId response:(NSString*)response authToken:(NSString*)authToken authTokenVal:(NSString*)authTokenValue
{
    NSString *route = [NSString stringWithFormat:@"%@/meetups/%@/rsvp", WS_URL, meetUpId];
    
    NSURL *url = [NSURL URLWithString:route];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"PUT"];
    
    [request addRequestHeader:authToken value:authTokenValue];
    [request setPostValue:response forKey:@"response"];
    
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201) {
            NSLog(@"updateMeetUp successful:status=%d", responseStatus);
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPDATE_MEET_UP_REQUEST_DONE object:nil];
        } else {
            NSLog(@"updateMeetUp unsuccessful:status=%d", responseStatus);
            [UtilityClass showAlert:@"" :@"Failed to save meet-up response"];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_UPDATE_MEET_UP_REQUEST_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        NSLog(@"sendMeetup failed: unknown error");
        [UtilityClass showAlert:@"" :@"Failed to save meet-up response"];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_UPDATE_MEET_UP_REQUEST_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    [request startAsynchronous];
    
}

- (void) sendReply:(NSString*)msgId content:(NSString*)content authToken:(NSString*)authToken authTokenVal:(NSString*)authTokenValue{
    NSURL *url = [NSURL URLWithString:[WS_URL stringByAppendingString:@"/messages"]];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    
    [request addRequestHeader:authToken value:authTokenValue];
    
    [request setPostValue:msgId forKey:@"thread"];
    [request setPostValue:content forKey:@"content"];
    
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201) {
            NSLog(@"sendMessage successful:status=%d", responseStatus);
            //[UtilityClass showAlert:@"" :@"Reply sent"];
            //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:aUser];
        } else {
            NSLog(@"sendMessage unsuccessful:status=%d", responseStatus);
            [UtilityClass showAlert:@"" :@"Failed to send reply"];
            //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        NSLog(@"sendMessage failed: unknown error");
        //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    [request startAsynchronous];
    
}

// Send friend request
- (void) sendFriendRequest:(NSString*)friendId message:(NSString*)message authToken:(NSString*)authToken authTokenVal:(NSString*)authTokenValue{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/request/friend/%@",WS_URL, friendId]];
    
    NSLog(@"SendFriendRequest: friend:%@ token:%@", friendId, authTokenValue);
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    
    [request addRequestHeader:authToken value:authTokenValue];
    
    [request setPostValue:message forKey:@"message"];
    
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201) {
            NSLog(@"sendFriendRequest successful:status=%d", responseStatus);
            [UtilityClass showAlert:@"" :@"Friend request sent"];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SEND_FRIEND_REQUEST_DONE object:nil];
        } else {
            NSLog(@"sendFriendRequest unsuccessful:status=%d", responseStatus);
            [UtilityClass showAlert:@"" :@"Friend request previously sent to this user."];
            //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        NSLog(@"sendFriendRequest failed: unknown error");
        [UtilityClass showAlert:@"" :@"Failed to send friend request"];
        //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    [request startAsynchronous];
}

- (void) getFriendRequests:(NSString*)authToken authTokenVal:(NSString*)authTokenValue {
    NSString *route = [NSString stringWithFormat:@"%@/request/friend/unaccepted",WS_URL];
    NSURL *url = [NSURL URLWithString:route];
    NSMutableArray *friendRequests = [[NSMutableArray alloc] init];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:authToken value:authTokenValue];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 204) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            
            NSString * message = [self getNestedKeyVal:jsonObjects key1:@"message" key2:nil key3:nil];
            if (message != nil && message.length > 0) {
                NSLog(@"No friend requests");
            } else {
                for (NSDictionary *item in jsonObjects) {
                    bool accepted = [[self getNestedKeyVal:item key1:@"accepted" key2:nil key3:nil] boolValue];
                    
                    if (accepted == FALSE) {
                        NotifRequest *req = [[NotifRequest alloc] init];
                        
                        req.notifSenderId = [self getNestedKeyVal:item key1:@"userId" key2:nil key3:nil];
                        req.notifSender   = [self getNestedKeyVal:item key1:@"friendName" key2:nil key3:nil];
                        req.notifMessage  = [self getNestedKeyVal:item key1:@"message" key2:nil key3:nil];
                        NSString *date = [self getNestedKeyVal:item key1:@"createDate" key2:@"date" key3:nil];
                        NSString *timeZoneType = [self getNestedKeyVal:item key1:@"createDate" key2:@"timezone_type" key3:nil];
                        NSString *timeZone = [self getNestedKeyVal:item key1:@"createDate" key2:@"timezone" key3:nil];
                        req.notifTime = [UtilityClass convertDate:date tz_type:timeZoneType tz:timeZone];
                        [friendRequests addObject:req];
                    }
                }
            }
            NSLog(@"Is Kind of NSString: %@",jsonObjects);
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_FRIEND_REQ_DONE object:friendRequests];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_FRIEND_REQ_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_FRIEND_REQ_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt getFriendRequests");
    [request startAsynchronous];
}

- (void) getMeetUpRequest:(NSString*)authToken authTokenVal:(NSString*)authTokenValue {
    
    NSLog(@"in RestClient getMeetUpRequest");
    NSLog(@"authTokenValue = %@", authTokenValue);
    NSLog(@"authToken = %@", authToken);
    
    NSString *route = [NSString stringWithFormat:@"%@/meetups/invited",WS_URL];
    NSURL *url = [NSURL URLWithString:route];
    NSMutableArray *meetUpRequests = [[NSMutableArray alloc] init];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:authToken value:authTokenValue];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 204) 
        {
            for (NSDictionary *item in jsonObjects) {
                MeetUpRequest *meetUpReq = [[MeetUpRequest alloc] init];
                
                meetUpReq.meetUpId = [self getNestedKeyVal:item key1:@"id" key2:nil key3:nil];
                //meetUpReq.meetUpTitle  = [self getNestedKeyVal:item key1:@"title" key2:nil key3:nil];
                meetUpReq.meetUpDescription  = [self getNestedKeyVal:item key1:@"message" key2:nil key3:nil];
                NSString *date = [self getNestedKeyVal:item key1:@"time" key2:@"date" key3:nil];
                NSString *timeZoneType = [self getNestedKeyVal:item key1:@"time" key2:@"timezone_type" key3:nil];
                NSString *timeZone = [self getNestedKeyVal:item key1:@"time" key2:@"timezone" key3:nil];
                meetUpReq.meetUpTime = [UtilityClass convertDate:date tz_type:timeZoneType tz:timeZone];
                meetUpReq.meetUpSenderId = [self getNestedKeyVal:item key1:@"owner" key2:nil key3:nil];
                meetUpReq.meetUpSender = [self getNestedKeyVal:item key1:@"ownerDetail" key2:@"firstName" key3:nil];
                meetUpReq.meetUpAvater = [self getNestedKeyVal:item key1:@"ownerDetail" key2:@"avatar" key3:nil];
                Geolocation *loc=[[Geolocation alloc] init];
                loc.latitude=[self getNestedKeyVal:item key1:@"location" key2:@"lat" key3:nil];
                loc.longitude=[self getNestedKeyVal:item key1:@"location" key2:@"lng" key3:nil];
    
                meetUpReq.meetUpLocation = loc;
                
                meetUpReq.meetUpAddress = [self getNestedKeyVal:item key1:@"location" key2:@"address" key3:nil];
                meetUpReq.meetUpId = [self getNestedKeyVal:item key1:@"id" key2:nil key3:nil];
                
                meetUpReq.meetUpRsvpYes = [self getNestedKeyVal:item key1:@"rsvp" key2:@"yes" key3:nil];
                meetUpReq.meetUpRsvpNo = [self getNestedKeyVal:item key1:@"rsvp" key2:@"no" key3:nil];
                meetUpReq.meetUpRsvpIgnore = [self getNestedKeyVal:item key1:@"rsvp" key2:@"maybe" key3:nil];
                
                [meetUpRequests addObject:meetUpReq];
            }
            NSLog(@"Is Kind of NSString: %@",jsonObjects);
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_MEET_UP_REQUEST_DONE object:meetUpRequests];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_MEET_UP_REQUEST_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_MEET_UP_REQUEST_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt getMeetUpReq");
    [request startAsynchronous];
    
}

- (void) getInbox:(NSString*)authToken authTokenVal:(NSString*)authTokenValue {
    
    //authTokenValue = @"44f89c2b1dc7b1b84dd57561556cb86486b5b38a";  //for test
    
    NSLog(@"in RestClient getInbox");
    NSLog(@"authTokenValue = %@", authTokenValue);
    NSLog(@"authToken = %@", authToken);
    
    //NSString *route = [NSString stringWithFormat:@"%@/messages/inbox",WS_URL];
    NSString *route = [NSString stringWithFormat:@"%@/messages/inbox?show_last_reply=1",WS_URL];
    NSURL *url = [NSURL URLWithString:route];
    NSMutableArray *messageInbox = [[NSMutableArray alloc] init];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:authToken value:authTokenValue];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 204) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            for (NSDictionary *item in jsonObjects) {
                NotifMessage *msg = [[NotifMessage alloc] init];
                
                msg.notifSenderId = [self getNestedKeyVal:item key1:@"sender" key2:@"id" key3:nil];
                NSString * firstName = [self getNestedKeyVal:item key1:@"sender" key2:@"firstName" key3:nil];
                NSString * lastName = [self getNestedKeyVal:item key1:@"sender" key2:@"lastName" key3:nil];              
                msg.notifSender   = [NSString stringWithFormat:@"%@ %@", firstName,  lastName];
                msg.notifMessage  = [self getNestedKeyVal:item key1:@"content" key2:nil key3:nil];
                msg.notifSubject  = [self getNestedKeyVal:item key1:@"subject" key2:nil key3:nil];
                NSString *date = [self getNestedKeyVal:item key1:@"createDate" key2:@"date" key3:nil];
                NSString *timeZoneType = [self getNestedKeyVal:item key1:@"createDate" key2:@"timezone_type" key3:nil];
                NSString *timeZone = [self getNestedKeyVal:item key1:@"createDate" key2:@"timezone" key3:nil];
                msg.notifTime = [UtilityClass convertDate:date tz_type:timeZoneType tz:timeZone];
                msg.notifAvater = [self getNestedKeyVal:item key1:@"sender" key2:@"avatar" key3:nil];
                msg.notifID = [self getNestedKeyVal:item key1:@"id" key2:nil key3:nil];
                msg.recipients = [item valueForKey:@"recipients"];
                msg.lastReply = [item valueForKey:@"replies"];
                msg.msgStatus=[self getNestedKeyVal:item key1:@"status" key2:nil key3:nil];
                
                NSLog(@"msg.notifAvater %@", msg.notifAvater);
                NSLog(@"msg.lastReply %@", msg.lastReply);
                
                [messageInbox addObject:msg];
            }
            NSLog(@"Is Kind of NSString: %@",jsonObjects);
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_INBOX_DONE object:messageInbox];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_INBOX_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_INBOX_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt getInbox");
    [request startAsynchronous];

}

- (void) getReplies:(NSString*)authToken authTokenVal:(NSString*)authTokenValue msgID:(NSString*)messageId since:(NSString*)ti {
    
    NSLog(@"in RestClient getReplies");
    NSLog(@"authTokenValue = %@", authTokenValue);
    NSLog(@"authToken = %@", authToken);
    NSLog(@"ti = %@", ti);
    
    NSString *route = [NSString stringWithFormat:@"%@/messages/%@/replies?since=%@", WS_URL, messageId, ti];
    
    //if (!ti) {
       //NSString *route = [NSString stringWithFormat:@"%@/messages/%@", WS_URL, messageId];
    //}
    
    NSURL *url = [NSURL URLWithString:route];
    NSMutableArray *messageReplies = [[NSMutableArray alloc] init];
    
    NSLog(@"route = %@", route);
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:authToken value:authTokenValue];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 204) 
        {
            for (NSDictionary *item in jsonObjects) {
                MessageReply *messageReply = [[MessageReply alloc] init];
                
                NSString *content = [item objectForKey:@"content"];
                messageReply.content = content;
                NSLog(@"content is: %@",content);
                
                NSString *date = [self getNestedKeyVal:item key1:@"createDate" key2:@"date" key3:nil];
                NSString *timeZoneType = [self getNestedKeyVal:item key1:@"createDate" key2:@"timezone_type" key3:nil];
                NSString *timeZone = [self getNestedKeyVal:item key1:@"createDate" key2:@"timezone" key3:nil];
                messageReply.time = [UtilityClass convertDate:date tz_type:timeZoneType tz:timeZone];
                NSLog(@"TIME is: %@",messageReply.time);
                
                NSString *senderName = [self getNestedKeyVal:item key1:@"sender" key2:@"firstName" key3:nil];
                messageReply.senderName = senderName;
                NSLog(@"sender name is: %@",senderName);
                
                NSString *senderID = [self getNestedKeyVal:item key1:@"sender" key2:@"id" key3:nil];
                messageReply.senderID = senderID;
                NSLog(@"sender id is: %@",senderID);
                
                NSString *senderAvater = [self getNestedKeyVal:item key1:@"sender" key2:@"avatar" key3:nil];
                messageReply.senderAvater = senderAvater;
                NSLog(@"sender avater is: %@",senderAvater);
                
                NSString *msgId = [self getNestedKeyVal:item key1:@"id" key2:nil key3:nil];
                messageReply.msgId = msgId;
                NSLog(@"sender msgId is: %@",msgId);
                
                [messageReplies addObject:messageReply];
                
            }
            
            NSLog(@"messageReplies = %@", messageReplies);

            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_REPLIES_DONE object:messageReplies];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_REPLIES_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_REPLIES_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt getReplies");
    [request startAsynchronous];
    
}

-(void)setMessageStatus:(NSString*)authToken authTokenVal:(NSString*)authTokenValue msgID:(NSString*)messageId status:(NSString*)status
{
    NSString *route = [NSString stringWithFormat:@"%@/messages/%@/status/%@", WS_URL, messageId, status];
    
    //if (!ti) {
    //NSString *route = [NSString stringWithFormat:@"%@/messages/%@", WS_URL, messageId];
    //}
    
    NSURL *url = [NSURL URLWithString:route];
    NSMutableArray *messageReplies = [[NSMutableArray alloc] init];
    
    NSLog(@"route = %@", route);
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:authToken value:authTokenValue];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 204) 
        {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SET_MESSAGE_STATUS_DONE object:messageReplies];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SET_MESSAGE_STATUS_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SET_MESSAGE_STATUS_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt set msg status");
    [request startAsynchronous];
}

-(void)updateMessageRecipients:(NSString*)authToken authTokenVal:(NSString*)authTokenValue msgID:(NSString*)messageId recipients:(NSMutableArray*)recipients
{
    NSString *route = [NSString stringWithFormat:@"%@/messages/%@/recipients/add", WS_URL, messageId];
    
    NSURL *url = [NSURL URLWithString:route];
    
    NSLog(@"route = %@", route);
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:authToken value:authTokenValue];
    
    for (int i=0; i<[recipients count]; i++) 
        [request addPostValue:[recipients objectAtIndex:i] forKey:@"recipients[]"];
    
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 204) {
            [UtilityClass showAlert:@"" :@"Saved recipients"];
        } else {
            [UtilityClass showAlert:@"" :@"Failed to save recipients"];
        }
        
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [UtilityClass showAlert:@"" :@"Failed to save recipients"];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt update message recipients");
    [request startAsynchronous];
}

/*
- (void) getReplies:(NSString*)authToken authTokenVal:(NSString*)authTokenValue msgID:(NSString*)messageId {
    
    NSLog(@"in RestClient getReplies");
    NSLog(@"authTokenValue = %@", authTokenValue);
    NSLog(@"authToken = %@", authToken);
    
    NSString *route = [NSString stringWithFormat:@"%@/messages/%@", WS_URL, messageId];
    NSURL *url = [NSURL URLWithString:route];
    NSMutableArray *messageReplies = [[NSMutableArray alloc] init];
    
    NSLog(@"route = %@", route);
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:authToken value:authTokenValue];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 204) 
        {
            NSArray *items = [jsonObjects objectForKey:@"replies"];
            
            for (NSDictionary *item in items)
            {
                MessageReply *messageReply = [[MessageReply alloc] init]; 
                
                NSString *content = [item objectForKey:@"content"];
                messageReply.content = content;
                NSLog(@"content is: %@",content);
                
                NSString *date = [self getNestedKeyVal:item key1:@"createDate" key2:@"date" key3:nil];
                NSString *timeZoneType = [self getNestedKeyVal:item key1:@"createDate" key2:@"timezone_type" key3:nil];
                NSString *timeZone = [self getNestedKeyVal:item key1:@"createDate" key2:@"timezone" key3:nil];
                messageReply.time = [UtilityClass convertDate:date tz_type:timeZoneType tz:timeZone];
                
                NSString *senderName = [self getNestedKeyVal:item key1:@"sender" key2:@"firstName" key3:nil];
                messageReply.senderName = senderName;
                NSLog(@"sender name is: %@",senderName);
                
                NSString *senderID = [self getNestedKeyVal:item key1:@"sender" key2:@"id" key3:nil];
                messageReply.senderID = senderID;
                NSLog(@"sender id is: %@",senderID);
                
                NSString *senderAvater = [self getNestedKeyVal:item key1:@"sender" key2:@"avatar" key3:nil];
                messageReply.senderAvater = senderAvater;
                NSLog(@"sender avater is: %@",senderAvater);
                
                //messageReply.senderImage = nil;
                
                [messageReplies addObject:messageReply];
            }
            
            NSLog(@"messageReplies = %@", messageReplies);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_REPLIES_DONE object:messageReplies];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_REPLIES_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_REPLIES_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt getReplies");
    [request startAsynchronous];
    
}*/


- (void) getNotificationMessages:(NSString*)authToken authTokenVal:(NSString*)authTokenValue {
    NSString *route = [NSString stringWithFormat:@"%@/request/Notification",WS_URL];
    NSURL *url = [NSURL URLWithString:route];
    NSMutableArray *notifications = [[NSMutableArray alloc] init];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:authToken value:authTokenValue];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 204) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            for (NSDictionary *item in jsonObjects) {
                Notification *notif = [[Notification alloc] init];
                
                notif.notifSenderId = [self getNestedKeyVal:item key1:@"sender" key2:@"__identifier__" key3:nil];
                notif.notifSender   = [self getNestedKeyVal:item key1:@"friendName" key2:nil key3:nil];
                notif.notifMessage  = [self getNestedKeyVal:item key1:@"content" key2:nil key3:nil];
                NSString *date = [self getNestedKeyVal:item key1:@"createDate" key2:@"date" key3:nil];
                NSString *timeZoneType = [self getNestedKeyVal:item key1:@"createDate" key2:@"timezone_type" key3:nil];
                NSString *timeZone = [self getNestedKeyVal:item key1:@"createDate" key2:@"timezone" key3:nil];
                notif.notifTime = [UtilityClass convertDate:date tz_type:timeZoneType tz:timeZone];
                [notifications addObject:notif];
            }
            NSLog(@"Is Kind of NSString: %@",jsonObjects);
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_NOTIFICATIONS_DONE object:notifications];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_NOTIFICATIONS_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_NOTIFICATIONS_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt getNotificationMessages");
    [request startAsynchronous];
}

// stat - accept/decline
- (void) respondToFriendRequest:(NSString*)friendId authToken:(NSString*) authToken authTokenVal:(NSString*)authTokenValue 
                         status:(NSString*) stat {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/request/friend/%@/%@",WS_URL, friendId, stat]];    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"PUT"];
    
    [request addRequestHeader:authToken value:authTokenValue];
    
    NSLog(@"in put method");
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201) {
            
            
            NSLog(@"respondToFriendRequest %@ successful: %@",stat, jsonObjects);
            
            //            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SETPROFILE_DONE object:platform];
        } 
        else
        {
            NSLog(@"respondToFriendRequest %@ unsuccessful: status=%d", stat, responseStatus);
            //            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SETPROFILE_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^
     {
         NSLog(@"respondToFriendRequest %@ unsuccessful: unknown reason", stat);
         //        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:nil];
     }];
    
    //[request setDelegate:self];
    [request startAsynchronous];
}

- (void) acceptFriendRequest:(NSString*)friendId authToken:(NSString*) authToken authTokenVal:(NSString*)authTokenValue {
    [self respondToFriendRequest:friendId authToken:authToken authTokenVal:authTokenValue status:@"accept"];
}

- (void) declineFriendRequest:(NSString*)friendId authToken:(NSString*) authToken authTokenVal:(NSString*)authTokenValue {
    [self respondToFriendRequest:friendId authToken:authToken authTokenVal:authTokenValue status:@"decline"];
}

- (bool) changePassword:(NSString*)passwd oldpasswd:(NSString*)oldpasswd authToken:(NSString*) authToken authTokenVal:(NSString*)authTokenValue {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/auth/change_pass",WS_URL]];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    __block   bool status=FALSE;
    [request setRequestMethod:@"PUT"];
        
    [request addRequestHeader:authToken value:authTokenValue];
    
    [request addPostValue:passwd forKey:@"password"];
    [request addPostValue:oldpasswd forKey:@"oldPassword"];

    
    NSLog(@"in put method");
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201) {
            
            status = [[self getNestedKeyVal:jsonObjects key1:@"password" key2:nil key3:nil] boolValue];
            NSLog(@"Change password: %@ to %@, status = %d",oldpasswd, passwd, status);
            
            //            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SETPROFILE_DONE object:platform];
                    } 
        else
        {
            //            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SETPROFILE_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^
     {
         //        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:nil];
     }];
    
    //[request setDelegate:self];
    [request startSynchronous];

    return status;

}

- (void) setPushNotificationSettings:(NSString*)deviceToken authToken:(NSString*)authToken authTokenVal:(NSString*)authTokenValue {
    NSLog(@"setPushNotificationSettings: device_id=%@", deviceToken);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/settings/push",WS_URL]];
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"PUT"];
    
    //    [request setPostValue:@"Auth-Token" forKey:@"9068d1bdd04e1bdf66a24f97e7ddce46e71ca13b"];
    
    [request addRequestHeader:authToken value:authTokenValue];
    
    [request addPostValue:@"iOS" forKey:@"device_type"];
    [request addPostValue:deviceToken forKey:@"device_id"];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200) 
        {
            NSLog(@"Registered device: %@",jsonObjects);
            
        } 
        else
        {
            NSLog(@"Failed to register device: status=%d", responseStatus);
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^
     {
         NSLog(@"Failed in REST call: status=%d", [request responseStatusCode]);
     }];
    
    //[request setDelegate:self];
    [request startAsynchronous];
}

//getting all circles from here
-(void) getAllCircles:(NSString *)authToken:(NSString *)authTokenValue
{
    NSString *route = [NSString stringWithFormat:@"%@/me/circles",WS_URL];
    NSURL *url = [NSURL URLWithString:route];
    UserCircle *platform = [[UserCircle alloc] init];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:authToken value:authTokenValue];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            NSMutableArray *circleList=[[NSMutableArray alloc] init];
            for (NSDictionary *item in jsonObjects) 
            {
                UserCircle *circle=[[UserCircle alloc] init];
                circle.circleID=[self getNestedKeyVal:item key1:@"id" key2:nil key3:nil];
                circle.circleName=[self getNestedKeyVal:item key1:@"name" key2:nil key3:nil];
                if ([[self getNestedKeyVal:item key1:@"type" key2:nil key3:nil] caseInsensitiveCompare:@"system"] == NSOrderedSame)
                {
                    circle.type = CircleTypeSystem;
                }
                else
                {
                    circle.type = CircleTypeCustom;
                }

//                circle.type=[self getNestedKeyVal:jsonObjects key1:@"currentLocation" key2:@"lat" key3:nil];
//                circle.friends=[[[jsonObjects objectForKey:@"circles"] objectAtIndex:i] objectForKey:@"friends"];
                NSLog(@"circle.circleID: %@",circle.circleID);
                NSMutableArray *userFrnds=[[NSMutableArray alloc] init];
                for (NSDictionary *frndDic in [self getNestedKeyVal:item key1:@"friends" key2:nil key3:nil]) 
                {
                    UserFriends *userFrnd=[[UserFriends alloc] init];
                    userFrnd.userName=[self getNestedKeyVal:frndDic key1:@"firstName" key2:nil key3:nil];
                    userFrnd.userId=[self getNestedKeyVal:frndDic key1:@"id" key2:nil key3:nil];
                    userFrnd.imageUrl=[self getNestedKeyVal:frndDic key1:@"avatar" key2:nil key3:nil];
                    userFrnd.distance=[[self getNestedKeyVal:frndDic key1:@"distance" key2:nil key3:nil] doubleValue];
                    userFrnd.coverImageUrl=[self getNestedKeyVal:frndDic key1:@"coverPhoto" key2:nil key3:nil];
                    userFrnd.address=[self getNestedKeyVal:frndDic key1:@"address" key2:@"street" key3:nil];
                    userFrnd.statusMsg=[self getNestedKeyVal:frndDic key1:@"status" key2:nil key3:nil];
                    userFrnd.regMedia=[self getNestedKeyVal:frndDic key1:@"regMedia" key2:nil key3:nil];
                    [userFrnds addObject:userFrnd];
                }
                circle.friends=userFrnds;
                [circleList addObject:circle];        
            }
            circleListDetailGlobalArray=circleList;
            
            NSLog(@"getPlatforms response: %@",jsonObjects);    
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_ALL_CIRCLES_DONE object:circleList];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_ALL_CIRCLES_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_ALL_CIRCLES_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt getPlatForm");
    [request startAsynchronous];
    
}

-(void) createCircle:(NSString *)authToken:(NSString *)authTokenValue:(UserCircle *)userCircle
{
    NSString *route = [NSString stringWithFormat:@"%@/me/circles",WS_URL];
    NSURL *url = [NSURL URLWithString:route];
    
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:authToken value:authTokenValue];
    [request addPostValue:userCircle.circleName forKey:@"name"];
    for (int i=0; i<[userCircle.friends count]; i++)
    {
        [request addPostValue:((UserFriends *)[userCircle.friends objectAtIndex:i]).userId forKey:@"friends[]"];
    }
    
     // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            NSMutableArray *circleList=[[NSMutableArray alloc] init];
            for (NSDictionary *item in jsonObjects) 
            {
                UserCircle *circle=[[UserCircle alloc] init];
                circle.circleID=[self getNestedKeyVal:item key1:@"id" key2:nil key3:nil];
                circle.circleName=[self getNestedKeyVal:item key1:@"name" key2:nil key3:nil];
                
                if ([[self getNestedKeyVal:item key1:@"type" key2:nil key3:nil] caseInsensitiveCompare:@"system"] == NSOrderedSame)
                {
                    circle.type = CircleTypeSystem;
                }
                else
                {
                    circle.type = CircleTypeCustom;
                }
                //                circle.type=[self getNestedKeyVal:jsonObjects key1:@"currentLocation" key2:@"lat" key3:nil];
                //                circle.friends=[[[jsonObjects objectForKey:@"circles"] objectAtIndex:i] objectForKey:@"friends"];
                NSLog(@"circle.circleID: %@",circle.circleID);
                NSMutableArray *userFrnds=[[NSMutableArray alloc] init];
                for (NSDictionary *frndDic in [self getNestedKeyVal:item key1:@"friends" key2:nil key3:nil]) 
                {
                    UserFriends *userFrnd=[[UserFriends alloc] init];
                    userFrnd.userName=[self getNestedKeyVal:frndDic key1:@"firstName" key2:nil key3:nil];
                    userFrnd.userId=[self getNestedKeyVal:frndDic key1:@"id" key2:nil key3:nil];
                    userFrnd.imageUrl=[self getNestedKeyVal:frndDic key1:@"avatar" key2:nil key3:nil];
                    userFrnd.distance=[[self getNestedKeyVal:frndDic key1:@"distance" key2:nil key3:nil] doubleValue];
                    userFrnd.coverImageUrl=[self getNestedKeyVal:frndDic key1:@"coverPhoto" key2:nil key3:nil];
                    userFrnd.address=[self getNestedKeyVal:frndDic key1:@"address" key2:@"street" key3:nil];
                    userFrnd.statusMsg=[self getNestedKeyVal:frndDic key1:@"status" key2:nil key3:nil];
                    userFrnd.regMedia=[self getNestedKeyVal:frndDic key1:@"regMedia" key2:nil key3:nil];
                    [userFrnds addObject:userFrnd];
                }
                circle.friends=userFrnds;
                [circleList addObject:circle];        
            }
            circleListDetailGlobalArray=circleList;

            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_CREATE_CIRCLE_DONE object:circleList];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_CREATE_CIRCLE_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_CREATE_CIRCLE_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt getLocation");
    [request startAsynchronous];
}

-(void) updateCircle:(NSString *)authToken:(NSString *)authTokenValue:(NSString *)friendId:(NSMutableArray *)userCircleArr
{
    NSString *route = [NSString stringWithFormat:@"%@/me/circles/friend/%@",WS_URL,friendId];
    NSURL *url = [NSURL URLWithString:route];
    
    NSLog(@"friend ID: %@",friendId);
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"PUT"];
    [request addRequestHeader:authToken value:authTokenValue];
    for (int i=0; i<[userCircleArr count]; i++)
    {
        UserCircle *circle=[userCircleArr objectAtIndex:i];
        NSLog(@"in service circle.circleID: %@",circle.circleID);
        [request addPostValue:circle.circleID forKey:@"circles[]"];
    }
    
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            NSMutableArray *circleList=[[NSMutableArray alloc] init];
            for (NSDictionary *item in jsonObjects) 
            {
                UserCircle *circle=[[UserCircle alloc] init];
                circle.circleID=[self getNestedKeyVal:item key1:@"id" key2:nil key3:nil];
                circle.circleName=[self getNestedKeyVal:item key1:@"name" key2:nil key3:nil];
                if ([[self getNestedKeyVal:item key1:@"type" key2:nil key3:nil] caseInsensitiveCompare:@"system"] == NSOrderedSame)
                {
                    circle.type = CircleTypeSystem;
                }
                else
                {
                    circle.type = CircleTypeCustom;
                }

                //                circle.type=[self getNestedKeyVal:jsonObjects key1:@"currentLocation" key2:@"lat" key3:nil];
                //                circle.friends=[[[jsonObjects objectForKey:@"circles"] objectAtIndex:i] objectForKey:@"friends"];
                NSLog(@"circle.circleID: %@",circle.circleID);
                NSMutableArray *userFrnds=[[NSMutableArray alloc] init];
                for (NSDictionary *frndDic in [self getNestedKeyVal:item key1:@"friends" key2:nil key3:nil]) 
                {
                    UserFriends *userFrnd=[[UserFriends alloc] init];
                    userFrnd.userName=[self getNestedKeyVal:frndDic key1:@"firstName" key2:nil key3:nil];
                    userFrnd.userId=[self getNestedKeyVal:frndDic key1:@"id" key2:nil key3:nil];
                    userFrnd.imageUrl=[self getNestedKeyVal:frndDic key1:@"avatar" key2:nil key3:nil];
                    userFrnd.distance=[[self getNestedKeyVal:frndDic key1:@"distance" key2:nil key3:nil] doubleValue];
                    userFrnd.coverImageUrl=[self getNestedKeyVal:frndDic key1:@"coverPhoto" key2:nil key3:nil];
                    userFrnd.address=[self getNestedKeyVal:frndDic key1:@"address" key2:@"street" key3:nil];
                    userFrnd.statusMsg=[self getNestedKeyVal:frndDic key1:@"status" key2:nil key3:nil];
                    userFrnd.regMedia=[self getNestedKeyVal:frndDic key1:@"regMedia" key2:nil key3:nil];
                    [userFrnds addObject:userFrnd];
                }
                circle.friends=userFrnds;
                [circleList addObject:circle];        
            }
            circleListDetailGlobalArray=circleList;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPDATE_CIRCLE_DONE object:circleList];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPDATE_CIRCLE_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPDATE_CIRCLE_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt getLocation");
    [request startAsynchronous];
}

-(void)getBlockUserList:(NSString *)authToken:(NSString *)authTokenValue
{
    NSString *route = [NSString stringWithFormat:@"%@/me/blocked-users",WS_URL];
    NSURL *url = [NSURL URLWithString:route];
     
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:authToken value:authTokenValue];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }

                NSMutableArray *userFrnds=[[NSMutableArray alloc] init];
                for (NSDictionary *item in jsonObjects) 
                {
                    People *people=[[People alloc] init];
                    people.userId = [self getNestedKeyVal:item key1:@"id" key2:nil key3:nil];
                    people.email = [self getNestedKeyVal:item key1:@"email" key2:nil key3:nil];
                    people.firstName = [self getNestedKeyVal:item key1:@"firstName" key2:nil key3:nil];
                    people.lastName = [self getNestedKeyVal:item key1:@"lastName" key2:nil key3:nil];
                    people.avatar = [self getNestedKeyVal:item key1:@"avatar" key2:nil key3:nil];
                    people.city = [self getNestedKeyVal:item key1:@"city" key2:nil key3:nil];
                    NSString *friendship = [self getNestedKeyVal:item key1:@"friendship" key2:nil key3:nil];
					people.friendshipStatus = friendship;
                    people.age = [self getNestedKeyVal:item key1:@"age" key2:nil key3:nil];
                    people.currentLocationLng = [self getNestedKeyVal:item key1:@"currentLocation" key2:@"lng" key3:nil];
                    people.currentLocationLat = [self getNestedKeyVal:item key1:@"currentLocation" key2:@"lat" key3:nil];
                    people.distance = [self getNestedKeyVal:item key1:@"distance" key2:nil key3:nil];  
                    people.statusMsg=[self getNestedKeyVal:item key1:@"status" key2:nil key3:nil];
                    [userFrnds addObject:people];
                }
                           
            NSLog(@"getPlatforms response: %@",userFrnds);    
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_ALL_BLOCKED_USERS_DONE object:userFrnds];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_ALL_BLOCKED_USERS_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_ALL_BLOCKED_USERS_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt getPlatForm");
    [request startAsynchronous];

}

-(void)blockUserList:(NSString *)authToken:(NSString *)authTokenValue:(NSMutableArray *)userIdArr
{
    NSString *route = [NSString stringWithFormat:@"%@/me/users/block",WS_URL];
    NSURL *url = [NSURL URLWithString:route];
    
    NSLog(@"friend ID: %@",userIdArr);
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"PUT"];
    [request addRequestHeader:authToken value:authTokenValue];
    for (int i=0; i<[userIdArr count]; i++)
    {
        NSLog(@"in service circle.circleID: %@",[userIdArr objectAtIndex:i]);
        [request addPostValue:[userIdArr objectAtIndex:i] forKey:@"users[]"];
    }
    
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            
            NSMutableArray *userFrnds=[[NSMutableArray alloc] init];
            for (NSDictionary *item in jsonObjects) 
            {
                People *people=[[People alloc] init];
                people.userId = [self getNestedKeyVal:item key1:@"id" key2:nil key3:nil];
                people.email = [self getNestedKeyVal:item key1:@"email" key2:nil key3:nil];
                people.firstName = [self getNestedKeyVal:item key1:@"firstName" key2:nil key3:nil];
                people.lastName = [self getNestedKeyVal:item key1:@"lastName" key2:nil key3:nil];
                people.avatar = [self getNestedKeyVal:item key1:@"avatar" key2:nil key3:nil];
                people.city = [self getNestedKeyVal:item key1:@"city" key2:nil key3:nil];
                NSString *friendship = [self getNestedKeyVal:item key1:@"friendship" key2:nil key3:nil];
                people.friendshipStatus = friendship;
                people.age = [self getNestedKeyVal:item key1:@"age" key2:nil key3:nil];
                people.currentLocationLng = [self getNestedKeyVal:item key1:@"currentLocation" key2:@"lng" key3:nil];
                people.currentLocationLat = [self getNestedKeyVal:item key1:@"currentLocation" key2:@"lat" key3:nil];
                people.distance = [self getNestedKeyVal:item key1:@"distance" key2:nil key3:nil];  
                people.statusMsg=[self getNestedKeyVal:item key1:@"status" key2:nil key3:nil];
                [userFrnds addObject:people];
            }
            
            NSLog(@"getPlatforms response: %@",userFrnds);    
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SET_BLOCKED_USERS_DONE object:userFrnds];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SET_BLOCKED_USERS_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SET_BLOCKED_USERS_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt getPlatForm");
    [request startAsynchronous];
}

-(void)unBlockUserList:(NSString *)authToken:(NSString *)authTokenValue:(NSMutableArray *)userIdArr
{
    NSString *route = [NSString stringWithFormat:@"%@/me/users/un-block",WS_URL];
    NSURL *url = [NSURL URLWithString:route];
    
    NSLog(@"friend ID: %@",userIdArr);
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"PUT"];
    [request addRequestHeader:authToken value:authTokenValue];
    for (int i=0; i<[userIdArr count]; i++)
    {
        NSLog(@"in service circle.circleID: %@",[userIdArr objectAtIndex:i]);
        [request addPostValue:[userIdArr objectAtIndex:i] forKey:@"users[]"];
    }
    
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            
            NSMutableArray *userFrnds=[[NSMutableArray alloc] init];
            for (NSDictionary *item in jsonObjects) 
            {
                People *people=[[People alloc] init];
                people.userId = [self getNestedKeyVal:item key1:@"id" key2:nil key3:nil];
                people.email = [self getNestedKeyVal:item key1:@"email" key2:nil key3:nil];
                people.firstName = [self getNestedKeyVal:item key1:@"firstName" key2:nil key3:nil];
                people.lastName = [self getNestedKeyVal:item key1:@"lastName" key2:nil key3:nil];
                people.avatar = [self getNestedKeyVal:item key1:@"avatar" key2:nil key3:nil];
                people.city = [self getNestedKeyVal:item key1:@"city" key2:nil key3:nil];
                NSString *friendship = [self getNestedKeyVal:item key1:@"friendship" key2:nil key3:nil];
                people.friendshipStatus = friendship;
                people.age = [self getNestedKeyVal:item key1:@"age" key2:nil key3:nil];
                people.currentLocationLng = [self getNestedKeyVal:item key1:@"currentLocation" key2:@"lng" key3:nil];
                people.currentLocationLat = [self getNestedKeyVal:item key1:@"currentLocation" key2:@"lat" key3:nil];
                people.distance = [self getNestedKeyVal:item key1:@"distance" key2:nil key3:nil];  
                people.statusMsg=[self getNestedKeyVal:item key1:@"status" key2:nil key3:nil];
                [userFrnds addObject:people];
            }
            
            NSLog(@"getPlatforms response: %@",userFrnds);    
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SET_UNBLOCKED_USERS_DONE object:userFrnds];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SET_UNBLOCKED_USERS_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SET_UNBLOCKED_USERS_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt getPlatForm");
    [request startAsynchronous];
}

-(void)getAllEventsForMap:(NSString *)authToken:(NSString *)authTokenValue
{
    NSString *route = [NSString stringWithFormat:@"%@/events",WS_URL];
    NSURL *url = [NSURL URLWithString:route];
    Event *aEvent = [[Event alloc] init];
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:authToken value:authTokenValue];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        EventList *eventList=[[EventList alloc] init];
        eventList.eventListArr=[[NSMutableArray alloc] init];
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            for (NSDictionary *item in jsonObjects)
            {
                Event *aEvent=[[Event alloc] init];
                [aEvent setEventID:[item objectForKey:@"id"]];
                [aEvent setEventName:[item objectForKey:@"title"]];
                
                Date *date=[[Date alloc] init];
                date.date=[self getNestedKeyVal:item key1:@"createDate" key2:@"date" key3:nil];
                
                date.timezone=[self getNestedKeyVal:item key1:@"createDate" key2:@"timezone" key3:nil];
                date.timezoneType=[self getNestedKeyVal:item key1:@"createDate" key2:@"timezone_type" key3:nil];
                
                [aEvent setEventCreateDate:date];
                
                date=[[Date alloc] init];
                date.date=[self getNestedKeyVal:item key1:@"time" key2:@"date" key3:nil];
                date.timezone=[self getNestedKeyVal:item key1:@"time" key2:@"timezone" key3:nil];            
                date.timezoneType=[self getNestedKeyVal:item key1:@"time" key2:@"timezone_type" key3:nil];           
                [aEvent setEventDate:date];
                
                Geolocation *loc=[[Geolocation alloc] init];
                loc.latitude=[self getNestedKeyVal:item key1:@"location" key2:@"lat" key3:nil];
                loc.longitude=[self getNestedKeyVal:item key1:@"location" key2:@"lng" key3:nil];
                [aEvent setEventLocation:loc];
                [aEvent setEventAddress:[self getNestedKeyVal:item key1:@"location" key2:@"address" key3:nil]];
                [aEvent setEventDistance:[self getNestedKeyVal:item key1:@"distance" key2:nil key3:nil]];
                [aEvent setEventImageUrl:[self getNestedKeyVal:item key1:@"eventImage" key2:nil key3:nil]];
                [aEvent setEventShortSummary:[self getNestedKeyVal:item key1:@"eventShortSummary" key2:nil key3:nil]];
                [aEvent setEventDescription:[self getNestedKeyVal:item key1:@"description" key2:nil key3:nil]];
                
                [aEvent setMyResponse:[self getNestedKeyVal:item key1:@"my_response" key2:nil key3:nil]];
                
                [aEvent setIsInvited:[[self getNestedKeyVal:item key1:@"is_invited" key2:nil key3:nil] boolValue]];
                [aEvent setGuestCanInvite:[[self getNestedKeyVal:item key1:@"guestsCanInvite" key2:nil key3:nil] boolValue]];
                [aEvent setOwner:[self getNestedKeyVal:item key1:@"owner" key2:nil key3:nil]];           
                [aEvent setEventType:[self getNestedKeyVal:item key1:@"event_type" key2:nil key3:nil]];
                [aEvent setPermission:[self getNestedKeyVal:item key1:@"permission" key2:nil key3:nil]];
                
                NSLog(@"aEvent.eventName: %@  aEvent.eventID: %@ %@",aEvent.eventName,aEvent.eventDistance,aEvent.eventAddress);
                //                NSLog(@"Is Kind of NSString: %@",jsonObjects);
                
                if ([[UtilityClass convertDateFromDisplay:date.date] compare:[NSDate date]] == NSOrderedDescending)
                {
                    NSLog(@"Date comapre %@",date.date);
                } 
                [aEvent.eventList addObject:aEvent];
                [eventList.eventListArr addObject:aEvent];
            }
            eventListGlobalArray=[eventList.eventListArr mutableCopy];
            smAppDelegate.eventList=[eventList.eventListArr mutableCopy];
            NSLog(@"client eventList.eventListArr :%@",eventList.eventListArr);
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_ALL_EVENTS_FOR_MAP_DONE object:eventList.eventListArr];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_ALL_EVENTS_FOR_MAP_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_ALL_EVENTS_FOR_MAP_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn start get all events for map");
    [request startAsynchronous];
}

-(void)getOtherUserProfile:(NSString *)authToken:(NSString *)authTokenValue:(NSString *)userId
{
    NSString *route = [NSString stringWithFormat:@"%@/users/%@",WS_URL,userId];
    NSURL *url = [NSURL URLWithString:route];
    __block UserInfo *aUserInfo = nil;
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request addRequestHeader:authToken value:authTokenValue];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            
            aUserInfo = [self parseAccountSettings:[jsonObjects objectForKey:@"result"] user:nil];
            
            NSLog(@"getAccountSettings: %@",jsonObjects);
            NSLog(@"aUserInfo.avatar %@",aUserInfo.avatar);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_OTHER_USER_PROFILE_DONE object:aUserInfo];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_OTHER_USER_PROFILE_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_OTHER_USER_PROFILE_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt getBasicProfile");
    [request startAsynchronous];
    
}

-(void)doConnectFB:(NSString *)authToken:(NSString *)authTokenValue:(NSString *)FBid:(NSString *)fbAuthToken
{
    NSString *route = [NSString stringWithFormat:@"%@/auth/fb_connect",WS_URL];
    NSURL *url = [NSURL URLWithString:route];
    __block UserInfo *aUserInfo = nil;
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"PUT"];
    [request addRequestHeader:authToken value:authTokenValue];
    [request addPostValue:FBid forKey:@"facebookId"];
    [request addPostValue:fbAuthToken forKey:@"facebookAuthToken"];
    // Handle successful REST call
    [request setCompletionBlock:^{
        
        // Use when fetching text data
        int responseStatus = [request responseStatusCode];
        
        // Use when fetching binary data
        // NSData *responseData = [request responseData];
        NSString *responseString = [request responseString];
        NSLog(@"request FBid,fbAuthToken %@ %@",FBid,fbAuthToken);
        NSLog(@"Response=%@, status=%d", responseString, responseStatus);
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSDictionary *jsonObjects = [jsonParser objectWithString:responseString error:&error];
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204|| responseStatus == 406) 
        {
            if ([jsonObjects isKindOfClass:[NSDictionary class]])
            {
                // treat as a dictionary, or reassign to a dictionary ivar
                NSLog(@"dict");
            }
            else if ([jsonObjects isKindOfClass:[NSArray class]])
            {
                // treat as an array or reassign to an array ivar.
                NSLog(@"Arr");
            }
            
            NSLog(@"fb response: %@",jsonObjects);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DO_CONNECT_FB_DONE object:[jsonObjects objectForKey:@"message"]];
        } 
        else 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DO_CONNECT_FB_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DO_CONNECT_FB_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt do connect fb");
    [request startAsynchronous];
    
}

@end

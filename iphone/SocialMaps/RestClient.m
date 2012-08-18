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

@implementation RestClient

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
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204) {
            User *aUser = [[User alloc] init];
            
            [aUser setFirstName:[jsonObjects objectForKey:@"firstName"]];
            [aUser setLastName:[jsonObjects objectForKey:@"lastName"]];
            [aUser setAuthToken:[jsonObjects objectForKey:@"authToken"]];
            [aUser setEmail:[jsonObjects objectForKey:@"email"]];
            [aUser setId:[jsonObjects objectForKey:@"id"]];

            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LOGIN_DONE object:aUser];
        } else {
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
    [request setPostValue:userInfo.lastName forKey:@"lastName"];
    [request setPostValue:userInfo.firstName forKey:@"firstName"];
    [request setPostValue:userInfo.facebookId forKey:@"facebookId"];
    [request setPostValue:userInfo.facebookAuthToken forKey:@"facebookAuthToken"]; 
    [request setPostValue:userInfo.avatar forKey:@"avatar"]; 
    [request setPostValue:userInfo.gender forKey:@"gender"]; 
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
    NSLog(@"asyn srt");
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
    NSLog(@"asyn srt");
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
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"firstName"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setFirstNameStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"firstName"]];
            }
            else
            {
                [informationPrefs setFirstNameFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"firstName"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setFirstNameFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"firstName"] objectForKey:@"custom"]objectForKey:@"circles"]];
                
            }
            
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"lastName"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setLastNameStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"lastName"]];
            }
            else
            {
                [informationPrefs setLastNameFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"lastName"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setLastNameCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"lastName"] objectForKey:@"custom"]objectForKey:@"circles"]];
                
            }
            
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"email"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setEmailStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"email"]];
            }
            else
            {
                [informationPrefs setEmailFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"email"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setEmailCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"email"] objectForKey:@"custom"]objectForKey:@"circles"]];
                
            }
            
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"dateOfBirth"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setDateOfBirthStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"dateOfBirth"]];
            }
            else
            {
                [informationPrefs setDateOfBirthFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"dateOfBirth"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setDateOfBirthCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"dateOfBirth"] objectForKey:@"custom"]objectForKey:@"circles"]];
                
            }
            
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"bio"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setBioStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"bio"]];
            }
            else
            {
                [informationPrefs setBioFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"bio"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setBioCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"bio"] objectForKey:@"custom"]objectForKey:@"circles"]];
                
            }
            
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"interests"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setInterestsStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"interests"]];
            }
            else
            {
                [informationPrefs setInterestsFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"interests"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setInterestsCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"interests"] objectForKey:@"custom"]objectForKey:@"circles"]];
                
            }
            
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"workStatus"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setWorkStatusStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"workStatus"]];
            }
            else
            {
                [informationPrefs setWorkStatusFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"workStatus"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setWorkStatusCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"workStatus"] objectForKey:@"custom"]objectForKey:@"circles"]];
                
            }
            
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"relationshipStatus"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setRelationshipStatusStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"relationshipStatus"]];
            }
            else
            {
                [informationPrefs setRelationshipStatusFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"relationshipStatus"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setRelationshipStatusCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"relationshipStatus"] objectForKey:@"custom"]objectForKey:@"circles"]];
                
            }
            
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"address"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setAddressStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"address"]];
            }
            else
            {
                [informationPrefs setAddressFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"address"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setAddressCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"address"] objectForKey:@"custom"]objectForKey:@"circles"]];
                
            }
            
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"friendRequest"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setFriendRequestStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"friendRequest"]];
            }
            else
            {
                [informationPrefs setFriendRequestFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"friendRequest"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setFriendRequestCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"friendRequest"] objectForKey:@"custom"]objectForKey:@"circles"]];
                
            }
            
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"circles"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setCirclesStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"circles"]];
            }
            else
            {
                [informationPrefs setCirclesFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"circles"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setCirclesCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"circles"] objectForKey:@"custom"]objectForKey:@"circles"]];
                
            }
            
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"newsfeed"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setNewsfeedStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"newsfeed"]];
            }
            else
            {
                [informationPrefs setNewsfeedFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"newsfeed"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setNewsfeedCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"newsfeed"] objectForKey:@"custom"]objectForKey:@"circles"]];
                
            }
            
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"avatar"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setAvatarStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"avatar"]];
            }
            else
            {
                [informationPrefs setAvatarFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"avatar"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setAvatarCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"avatar"] objectForKey:@"custom"]objectForKey:@"circles"]];
                
            }
            
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"username"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setUsernameStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"username"]];
            }
            else
            {
                [informationPrefs setUsernameFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"username"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setUsernameCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"username"] objectForKey:@"custom"]objectForKey:@"circles"]];
                
            }
            
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"name"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setNameStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"name"]];
            }
            else
            {
                [informationPrefs setNameFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"name"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setNameCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"name"] objectForKey:@"custom"]objectForKey:@"circles"]];
                
            }
            
            if ([[[jsonObjects   objectForKey:@"result"]  objectForKey:@"gender"]isKindOfClass:[NSString class]])
            {
                [informationPrefs setGenderStr:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"gender"]];
            }
            else
            {
                [informationPrefs setGenderFrnd:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"gender"] objectForKey:@"custom"]objectForKey:@"friends"]];
                [informationPrefs setGenderCircle:[[[[jsonObjects   objectForKey:@"result"]  objectForKey:@"gender"] objectForKey:@"custom"]objectForKey:@"circles"]];
                
            }
            
            NSLog(@"aUserInfo.email: %@  lat: %@",informationPrefs.lastNameStr,informationPrefs.firstNameStr);
            NSLog(@"Is Kind of NSString: %@",jsonObjects);
            
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
    NSLog(@"asyn srt");
    [request startAsynchronous];
}

-(void)getSharingPreferenceSettings:(NSString *)authToken:(NSString *)authTokenValue
{
    NSString *route = [NSString stringWithFormat:@"%@/settings/sharing_preference_settings",WS_URL];
    NSURL *url = [NSURL URLWithString:route];
    InformationPrefs *informationPrefs = [[InformationPrefs alloc] init];
    NSArray *keyArr=[[NSArray alloc] initWithObjects:@"friends",@"strangers",@"public",@"family",@"newsfeed", nil];
    NSMutableArray *valArr=[[NSMutableArray alloc] initWithObjects:informationPrefs.friends,informationPrefs.stranger,informationPrefs.people,informationPrefs.family,informationPrefs.newsFeed, nil];
    
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
            for (int i=0; i<=[[[jsonObjects  objectForKey:@"result"] objectForKey:@"profile_information"] count]; i++)
            {
                NSDictionary *dict=[[NSDictionary alloc] initWithDictionary:[[[jsonObjects  objectForKey:@"result"] objectForKey:@"profile_information"] objectForKey:[keyArr objectAtIndex:i]]];
                if (i==4)
                {
                    dict=[[NSDictionary alloc] initWithDictionary:[[jsonObjects  objectForKey:@"result"] objectForKey:@"newsfeed"]];
                    NewsFeed *newsFeed=[[NewsFeed alloc] init];
                    newsFeed.friends=[dict objectForKey:@"friends"];
                    newsFeed.strangers=[dict objectForKey:@"strangers"];
                    newsFeed.people=[dict objectForKey:@"public"];
                    newsFeed.family=[dict objectForKey:@"family"];
                    NSLog(@"newsFeed.family %@",newsFeed.family);
                    [valArr addObject:newsFeed];
                }
                else 
                {
                    User *aUser=[[User alloc] init];
                    aUser.lastName=[dict objectForKey:@"lastName"];
                    aUser.firstName=[dict objectForKey:@"firstName"];
                    aUser.email=[dict objectForKey:@"email"];
                    aUser.dateOfBirth=[dict objectForKey:@"dateOfBirth"];
                    aUser.bio=[dict objectForKey:@"bio"];
                    aUser.interests=[dict objectForKey:@"interests"];
                    aUser.workStatus=[dict objectForKey:@"workStatus"];
                    aUser.relationshipStatus=[dict objectForKey:@"relationshipStatus"];
                    aUser.address=[dict objectForKey:@"address"];
                    aUser.friendRequest=[dict objectForKey:@"friendRequest"];
                    aUser.circles=[dict objectForKey:@"circles"];
                    NSLog(@"aUser.circles: %@",aUser.circles);
                    [valArr addObject:aUser];

                }
                NSLog(@"Dict %@",dict);
            }
            informationPrefs.friends=[valArr objectAtIndex:0];
            informationPrefs.stranger=[valArr objectAtIndex:1];
            informationPrefs.people=[valArr objectAtIndex:2];
            informationPrefs.family=[valArr objectAtIndex:3];
            informationPrefs.newsFeed=[valArr objectAtIndex:4];
            
            NSLog(@"valArr %@",valArr);
            //NSLog(@"notif.recommendations_mail: %@",[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"recommendations"] objectForKey:@"mail"]);  
            //NSLog(@"Is Kind of NSString: %@",jsonObjects);
            
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
    NSLog(@"asyn srt");
    [request startAsynchronous];
}

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
            
            aUserInfo = [self parseAccountSettings:jsonObjects];
            
            NSLog(@"Is Kind of NSString: %@",jsonObjects);
            
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
    NSLog(@"asyn srt");
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
    NSLog(@"asyn srt");
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
            
            NSLog(@"layer.wiki: %@ %@ %@",shareLocation.status,shareLocation.permittedCircles,[[[jsonObjects objectForKey:@"result"] objectForKey:@"friends"]valueForKey:@"radius"]);  
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
    NSLog(@"asyn srt");
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
            
            [notificationPref setFriend_requests_sm:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"friend_requests"] objectForKey:@"sm"]];
            [notificationPref setPosts_by_friends_sm:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"posts_by_friends"] objectForKey:@"sm"]];
            [notificationPref setComments_sm:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"comments"] objectForKey:@"sm"]];
            [notificationPref setMessages_sm:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"messages"] objectForKey:@"sm"]];
            [notificationPref setProximity_alerts_sm:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"proximity_alerts"] objectForKey:@"sm"]];
            [notificationPref setRecommendations_sm:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"recommendations"] objectForKey:@"sm"]];
            [notificationPref setFriend_requests_mail:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"friend_requests"] objectForKey:@"mail"]];
            [notificationPref setPosts_by_friends_mail:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"posts_by_friends"] objectForKey:@"mail"]];
            [notificationPref setComments_mail:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"comments"] objectForKey:@"mail"]];
            [notificationPref setMessages_mail:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"messages"] objectForKey:@"mail"]];
            [notificationPref setProximity_alerts_mail:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"proximity_alerts"] objectForKey:@"mail"]];
            [notificationPref setRecommendations_mai:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"recommendations"] objectForKey:@"mail"]];
            NSLog(@"notif.recommendations_mail: %@",[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"recommendations"] objectForKey:@"mail"]);  
            NSLog(@"Is Kind of NSString: %@",jsonObjects);
            
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
    NSLog(@"asyn srt");
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
    [request addRequestHeader:authToken value:authTokenValue];
    [request addPostValue:geolocation.latitude forKey:@"lat"];
    [request addPostValue:geolocation.longitude forKey:@"lng"];
    
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
            
            //get all people
            for (NSDictionary *item in [jsonObjects  objectForKey:@"people"]) 
            {
                People *people=[[People alloc] init];

                [people setUserId:[item objectForKey:@"id"]];
                [people setEmail:[item objectForKey:@"email"]];                
                [people setFirstName:[item objectForKey:@"firstName"]];                
                [people setLastName:[item objectForKey:@"lastName"]];                
                people.avatar = [self getNestedKeyVal:item key1:@"avatar" key2:nil key3:nil];
                people.enabled = [self getNestedKeyVal:item key1:@"enabled" key2:nil key3:nil];
                people.gender = [self getNestedKeyVal:item key1:@"gender" key2:nil key3:nil];
                people.relationsipStatus = [self getNestedKeyVal:item key1:@"relationshipStatus" key2:nil key3:nil];
                people.city = [self getNestedKeyVal:item key1:@"city" key2:nil key3:nil];
                people.workStatus = [self getNestedKeyVal:item key1:@"workStatus" key2:nil key3:nil];
                people.external = [[self getNestedKeyVal:item key1:@"external" key2:nil key3:nil] boolValue];
                people.dateOfBirth = [self getDateFromJsonStruct:item name:@"dateOfBirth"];
                people.age = [self getNestedKeyVal:item key1:@"age" key2:nil key3:nil];
                people.currentLocationLng = [self getNestedKeyVal:item key1:@"currentLocation" key2:@"lng" key3:nil];
                people.currentLocationLat = [self getNestedKeyVal:item key1:@"currentLocation" key2:@"lat" key3:nil];
                
                people.lastLogin = [self getDateFromJsonStruct:item name:@"lastLogin"];
                [people setSettingUnit:[self getNestedKeyVal:item key1:@"settings" key2:@"unit" key3:nil]];
                
                people.createDate = [self getDateFromJsonStruct:item name:@"createDate"];
                people.updateDate = [self getDateFromJsonStruct:item name:@"updateDate"];
                
                [people setDistance:[item objectForKey:@"distance"]];                
                [searchLocation.peopleArr addObject:people];
                
                NSLog(@"User: first %@  last:%@  id:%@",people.firstName, people.lastName, people.userId);
            }
            
            //get all places
            for (NSDictionary *item in [jsonObjects  objectForKey:@"places"])
            {
                Places *place=[[Places alloc] init];
                

                Geolocation *geolocation=[[Geolocation alloc] init];
                
                geolocation.latitude=[self getNestedKeyVal:item key1:@"geometry" key2:@"location" key3:@"lat"];
                geolocation.longitude=[self getNestedKeyVal:item key1:@"geometry" key2:@"location" key3:@"lng"];
                [place setLocation:geolocation];
                
                geolocation.latitude=[self getNestedKeyVal:item key1:@"viewport" key2:@"northeast" key3:@"lat"];
                geolocation.longitude=[self getNestedKeyVal:item key1:@"viewport" key2:@"northeast" key3:@"lng"];
                [place setNortheast:geolocation];
                
                geolocation.latitude=[self getNestedKeyVal:item key1:@"viewport" key2:@"southwest" key3:@"lat"];
                geolocation.longitude=[self getNestedKeyVal:item key1:@"viewport" key2:@"southwest" key3:@"lng"];
                [place setSouthwest:geolocation];
                
                [place setIcon:[item objectForKey:@"icon"] ];
                [place setID:[item objectForKey:@"id"] ];
                [place setName:[item objectForKey:@"name"] ];
                [place setReference:[item objectForKey:@"reference"]];
                [place setTypeArr:[item objectForKey:@"types"]];
                [place setVicinity:[item objectForKey:@"vicinity"] ];
                [searchLocation.peopleArr addObject:place];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_GET_LISTINGS_DONE object:searchLocation];
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
    NSLog(@"asyn srt");
    [request startAsynchronous];
}

-(void)getLocationOld:(Geolocation *)geolocation:(NSString *)authToken:(NSString *)authTokenValue
{
    NSString *route = [NSString stringWithFormat:@"%@/search",WS_URL];
    NSURL *url = [NSURL URLWithString:route];
    
    SearchLocation *searchLocation=[[SearchLocation alloc] init];
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:authToken value:authTokenValue];
    [request addPostValue:geolocation.latitude forKey:@"lat"];
    [request addPostValue:geolocation.longitude forKey:@"lng"];
    
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
            
            People *people=[[People alloc] init];
            Places *place=[[Places alloc] init];
            
            //get all people
            for (int i=0; i<[[jsonObjects  objectForKey:@"people"] count]; i++) 
            {
                Date *date=[[Date alloc] init];
                [jsonObjects objectForKey:@"people"];
                [people setUserId:[[[jsonObjects  objectForKey:@"people"] objectAtIndex:i] objectForKey:@"id"]];
                [people setEmail:[[[jsonObjects objectForKey:@"people"] objectAtIndex:i] objectForKey:@"email"]];                
                [people setFirstName:[[[jsonObjects objectForKey:@"people"] objectAtIndex:i] objectForKey:@"firstName"]];                
                [people setLastName:[[[jsonObjects objectForKey:@"people"] objectAtIndex:i] objectForKey:@"lastName"]];                
                [people setAvatar:[[[jsonObjects objectForKey:@"people"] objectAtIndex:i] objectForKey:@"avatar"]];                
                [people setEnabled:[[[jsonObjects objectForKey:@"people"] objectAtIndex:i] objectForKey:@"enabled"]];                
                
                [people setSettingUnit:[[[[jsonObjects objectForKey:@"people"] objectAtIndex:i] objectForKey:@"settings"] objectForKey:@"unit"]];
                
                people.lastLogin = [self getDateFromJsonStruct:jsonObjects name:@"lastLogin"];
                people.createDate = [self getDateFromJsonStruct:jsonObjects name:@"createDate"];
                people.updateDate = [self getDateFromJsonStruct:jsonObjects name:@"updateDate"];
                
                [people setDistance:[[[jsonObjects objectForKey:@"people"] objectAtIndex:i] objectForKey:@"distance"]];                
                [searchLocation.peopleArr addObject:people];
                
                NSLog(@"enabled: %@  %@  %@ %d",[[[jsonObjects  objectForKey:@"people"] objectAtIndex:i] objectForKey:@"enabled"],people.distance,date.timezone,[searchLocation.peopleArr count]);
            }
            
            //get all places
            for (int i=0; i<[[jsonObjects  objectForKey:@"places"] count]; i++) 
            {
                Geolocation *geolocation=[[Geolocation alloc] init];
                [jsonObjects objectForKey:@"people"];

                geolocation.latitude=[[[[[jsonObjects  objectForKey:@"places"] objectAtIndex:i] objectForKey:@"geometry"] objectForKey:@"location"]objectForKey:@"lat"];
                geolocation.longitude=[[[[[jsonObjects  objectForKey:@"places"] objectAtIndex:i] objectForKey:@"geometry"] objectForKey:@"location"]objectForKey:@"lng"];
                [place setLocation:geolocation];
                
                geolocation.latitude=[[[[[jsonObjects  objectForKey:@"places"] objectAtIndex:i] objectForKey:@"viewport"] objectForKey:@"northeast"]objectForKey:@"lat"];
                geolocation.longitude=[[[[[jsonObjects  objectForKey:@"places"] objectAtIndex:i] objectForKey:@"viewport"] objectForKey:@"northeast"]objectForKey:@"lng"];
                [place setNortheast:geolocation];
                
                geolocation.latitude=[[[[[jsonObjects  objectForKey:@"places"] objectAtIndex:i] objectForKey:@"viewport"] objectForKey:@"southwest"]objectForKey:@"lat"];
                geolocation.longitude=[[[[[jsonObjects  objectForKey:@"places"] objectAtIndex:i] objectForKey:@"viewport"] objectForKey:@"southwest"]objectForKey:@"lng"];
                [place setSouthwest:geolocation];
                
                [place setIcon:[[[jsonObjects  objectForKey:@"places"] objectAtIndex:i] objectForKey:@"icon"] ];
                [place setID:[[[jsonObjects  objectForKey:@"places"] objectAtIndex:i] objectForKey:@"id"] ];
                [place setName:[[[jsonObjects  objectForKey:@"places"] objectAtIndex:i] objectForKey:@"name"] ];
                [place setReference:[[[jsonObjects  objectForKey:@"places"] objectAtIndex:i] objectForKey:@"reference"]];
                [place setTypeArr:[[[jsonObjects  objectForKey:@"places"] objectAtIndex:i] objectForKey:@"types"]];
                [place setVicinity:[[[jsonObjects  objectForKey:@"places"] objectAtIndex:i] objectForKey:@"vicinity"] ];
                [searchLocation.peopleArr addObject:place];
            }
            
            //            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LOGIN_DONE object:aUser];
        } 
        else 
        {
            //            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LOGIN_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LOGIN_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    NSLog(@"asyn srt");
    [request startAsynchronous];
}

-(void)setNotifications:(NotificationPref *)notificationPref:(NSString *)authToken:(NSString *)authTokenValue
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/settings/notifications",WS_URL]];    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"PUT"];
    
    //    [request setPostValue:@"Auth-Token" forKey:@"9068d1bdd04e1bdf66a24f97e7ddce46e71ca13b"];
    
    [request addRequestHeader:authToken value:authTokenValue];
    
    [request addPostValue:notificationPref.friend_requests_sm forKey:@"friend_requests_sm"];
    [request addPostValue:notificationPref.posts_by_friends_sm forKey:@"posts_by_friends_sm"];
    [request addPostValue:notificationPref.comments_sm forKey:@"comments_sm"];
    [request addPostValue:notificationPref.messages_sm forKey:@"messages_sm"];
    [request addPostValue:notificationPref.proximity_alerts_sm forKey:@"proximity_alerts_sm"];
    [request addPostValue:notificationPref.recommendations_sm forKey:@"recommendations_sm"];
    [request addPostValue:notificationPref.friend_requests_mail forKey:@"friend_requests_mail"];
    [request addPostValue:notificationPref.posts_by_friends_mail forKey:@"posts_by_friends_mail"];
    [request addPostValue:notificationPref.comments_mail forKey:@"comments_mail"];
    [request addPostValue:notificationPref.messages_mail forKey:@"messages_mail"];
    [request addPostValue:notificationPref.proximity_alerts_mail forKey:@"proximity_alerts_mail"];
    [request addPostValue:notificationPref.recommendations_mai forKey:@"recommendations_mail"];
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
        
        if (responseStatus == 200 || responseStatus == 201 || responseStatus == 204 || responseStatus == 400) {
                    
            NotificationPref *notificationPref=[[NotificationPref alloc] init];
            [notificationPref setFriend_requests_sm:[jsonObjects objectForKey:@"friend_requests_sm"]];
            [notificationPref setPosts_by_friends_sm:[jsonObjects objectForKey:@"posts_by_friends_sm"]];
            [notificationPref setComments_sm:[jsonObjects objectForKey:@"comments_sm"]];
            [notificationPref setMessages_sm:[jsonObjects objectForKey:@"messages_sm"]];
            [notificationPref setProximity_alerts_sm:[jsonObjects objectForKey:@"proximity_alerts_sm"]];
            [notificationPref setRecommendations_sm:[jsonObjects objectForKey:@"recommendations_sm"]];
            [notificationPref setFriend_requests_mail:[jsonObjects objectForKey:@"friend_requests_mail"]];
            [notificationPref setPosts_by_friends_mail:[jsonObjects objectForKey:@"posts_by_friends_mail"]];
            [notificationPref setComments_mail:[jsonObjects objectForKey:@"comments_mail"]];
            [notificationPref setMessages_mail:[jsonObjects objectForKey:@"messages_mail"]];
            [notificationPref setProximity_alerts_mail:[jsonObjects objectForKey:@"proximity_alerts_mail"]];
            [notificationPref setRecommendations_mai:[jsonObjects objectForKey:@"recommendations_mail"]];
            NSLog(@"notif.recommendations_mail: %@",[jsonObjects objectForKey:@"recommendations_mail"]);

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

-(void)setSharingPreferenceSettings:(InformationPrefs *)InformationPrefs:(NSString *)authToken:(NSString *)authTokenValue
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/settings/sharing_preference_settings",WS_URL]];    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"PUT"];
    
    //    [request setPostValue:@"Auth-Token" forKey:@"9068d1bdd04e1bdf66a24f97e7ddce46e71ca13b"];
    
    [request addRequestHeader:authToken value:authTokenValue];
    ///request value goes here....
//    [request addPostValue:layer.wikipedia forKey:@"wikipedia"];
//    [request addPostValue:layer.tripadvisor forKey:@"tripadvisor"];
//    [request addPostValue:layer.foodspotting forKey:@"foodspotting"];
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
            UserInfo *aUserInfo = [self parseAccountSettings:jsonObjects];
            
            NSLog(@"setSettingsPrefs: response = %@", jsonObjects);
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
        [request setPostValue:id forKey:@"recipients[]"];
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
            NSLog(@"sendMessage successful:status=%d", responseStatus);
            //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:aUser];
        } else {
            NSLog(@"sendMessage unsuccessful:status=%d", responseStatus);
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
            //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:aUser];
        } else {
            NSLog(@"sendFriendRequest unsuccessful:status=%d", responseStatus);
            //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^{
        NSLog(@"sendFriendRequest failed: unknown error");
        //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:nil];
    }];
    
    //[request setDelegate:self];
    [request startAsynchronous];
}

- (void) getFriendRequests:(NSString*)authToken authTokenVal:(NSString*)authTokenValue {
    NSString *route = [NSString stringWithFormat:@"%@/request/friend",WS_URL];
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
    NSLog(@"asyn srt");
    [request startAsynchronous];
}

- (void) getInbox:(NSString*)authToken authTokenVal:(NSString*)authTokenValue {
    NSString *route = [NSString stringWithFormat:@"%@/messages/inbox",WS_URL];
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
                msg.notifSender   = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                msg.notifMessage  = [self getNestedKeyVal:item key1:@"content" key2:nil key3:nil];
                msg.notifSubject  = [self getNestedKeyVal:item key1:@"subject" key2:nil key3:nil];
                NSString *date = [self getNestedKeyVal:item key1:@"createDate" key2:@"date" key3:nil];
                NSString *timeZoneType = [self getNestedKeyVal:item key1:@"createDate" key2:@"timezone_type" key3:nil];
                NSString *timeZone = [self getNestedKeyVal:item key1:@"createDate" key2:@"timezone" key3:nil];
                msg.notifTime = [UtilityClass convertDate:date tz_type:timeZoneType tz:timeZone];
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
    NSLog(@"asyn srt");
    [request startAsynchronous];

}
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
    NSLog(@"asyn srt");
    [request startAsynchronous];
}

- (void) acceptFriendRequest:(NSString*)friendId authToken:(NSString*) authToken authTokenVal:(NSString*)authTokenValue {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/request/friend/%@/accept",WS_URL, friendId]];    
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
            

            NSLog(@"acceptFriendRequest successful: %@",jsonObjects);
            
            //            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SETPROFILE_DONE object:platform];
        } 
        else
        {
            NSLog(@"acceptFriendRequest unsuccessful: status=%d", responseStatus);
            //            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SETPROFILE_DONE object:nil];
        }
        [jsonParser release], jsonParser = nil;
        [jsonObjects release];
    }];
    
    // Handle unsuccessful REST call
    [request setFailedBlock:^
     {
         NSLog(@"acceptFriendRequest unsuccessful: unknown reason");
         //        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REG_DONE object:nil];
     }];
    
    //[request setDelegate:self];
    [request startAsynchronous];
}
- (void) declineFriendRequest:(NSString*)friendId authToken:(NSString*) authToken authTokenVal:(NSString*)authTokenValue {
    
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
@end

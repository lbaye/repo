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

- (void) loginFacebook:(NSString*) facebookId password:(NSString*)facebookAuthToken {
}

- (void) register:(User*) userInfo {
    NSURL *url = [NSURL URLWithString:[WS_URL stringByAppendingString:@"/auth/registration"]];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:userInfo.email forKey:@"email"];
    [request setPostValue:userInfo.password forKey:@"password"];
    [request setPostValue:userInfo.lastName forKey:@"lastName"];
    [request setPostValue:userInfo.firstName forKey:@"firstName"];
    
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

- (void) registerFB:(User*) userInfo {
    NSURL *url = [NSURL URLWithString:[WS_URL stringByAppendingString:@"/auth/registration"]];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:userInfo.email forKey:@"email"];
    //[request setPostValue:userInfo.password forKey:@"password"];
    [request setPostValue:userInfo.lastName forKey:@"lastName"];
    [request setPostValue:userInfo.firstName forKey:@"firstName"];
    [request setPostValue:userInfo.facebookId forKey:@"facebookId"];
    [request setPostValue:userInfo.facebookAuthToken forKey:@"facebookAuthToken"];  
    
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
    NSString *route = [NSString stringWithFormat:@"%@/auth/forget_password/%@",WS_URL,email];
    NSURL *url = [NSURL URLWithString:route];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"PUT"];
    
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
            
            [platform setFacebook:[[jsonObjects objectForKey:@"result"]valueForKey:@"fb"]];
            [platform setFourSquare:[[jsonObjects objectForKey:@"result"]valueForKey:@"4sq"]];
            [platform setGooglePlus:[[jsonObjects objectForKey:@"result"]valueForKey:@"googlePlus"]];
            [platform setGmail:[[jsonObjects objectForKey:@"result"]valueForKey:@"gmail"]];
            [platform setTwitter:[[jsonObjects objectForKey:@"result"]valueForKey:@"twitter"]];
            [platform setYahoo:[[jsonObjects objectForKey:@"result"]valueForKey:@"yahoo"]];
            [platform setBadoo:[[jsonObjects objectForKey:@"result"]valueForKey:@"badoo"]];
            NSLog(@"platform.fac: %@",platform.facebook);    
                
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
            [layer setWikipedia:[[jsonObjects objectForKey:@"result"] valueForKey:@"wikipedia"]];
            [layer setTripadvisor:[[jsonObjects objectForKey:@"result"] valueForKey:@"tripadvisor"]];
            [layer setFoodspotting:[[jsonObjects objectForKey:@"result"] valueForKey:@"foodspotting"]];
            
            NSLog(@"layer.wiki: %@ %@ %@",layer.wikipedia,layer.tripadvisor,[[jsonObjects objectForKey:@"result"] valueForKey:@"wikipedia"]);  
            NSLog(@"Is Kind of NSString: %@",jsonObjects);

            
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
//            NSLog(@"notif.recommendations_mail: %@",[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"recommendations"] objectForKey:@"mail"]);  
//            NSLog(@"Is Kind of NSString: %@",jsonObjects);
            
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

-(void)getAccountSettings:(NSString *)authToken:(NSString *)authTokenValue
{
    NSString *route = [NSString stringWithFormat:@"%@/settings/account_settings",WS_URL];
    NSURL *url = [NSURL URLWithString:route];
    UserInfo *aUserInfo = [[UserInfo alloc] init];
    
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
            
            [aUserInfo setUserId:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"id"]];
            [aUserInfo setEmail:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"email"]];
            [aUserInfo setFirstName:[[jsonObjects   objectForKey:@"result"] objectForKey:@"firstName"]];
            [aUserInfo setLastName:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"lastName"]];
            [aUserInfo setAvatar:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"avatar"]];
            [aUserInfo setDeactivated:[[jsonObjects   objectForKey:@"result"] objectForKey:@"deactivated"]];
            [aUserInfo setAuthToken:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"authToken"]];
            [aUserInfo setSettings:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"settings"]];
            [aUserInfo setSource:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"source"]];
            [aUserInfo setDateOfBirth:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"dateOfBirth"]];
            [aUserInfo setBio:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"bio"]];
            [aUserInfo setGender:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"gender"]];
            [aUserInfo setUsername:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"username"]];
            [aUserInfo setInterests:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"interests"]];
            [aUserInfo setWorkStatus:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"workStatus"]];
            [aUserInfo setRelationshipStatus:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"relationshipStatus"]];
            [aUserInfo setCurrentLocationLat:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"currentLocation"] objectForKey:@"lat"]];
            [aUserInfo setCurrentLocationLng:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"currentLocation"] objectForKey:@"lng"]];
            [aUserInfo setEnabled:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"enabled"]];
            [aUserInfo setRegMedia:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"regMedia"]];
            [aUserInfo setLoginCount:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"loginCount"]];
            [aUserInfo setLastLogin:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"lastLogin"]];
            [aUserInfo setCreateDate:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"createDate"]];
            [aUserInfo setUpdateDate:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"updateDate"]];
            [aUserInfo setBlockedUsers:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"blockedUsers"]];
            [aUserInfo setBlockedBy:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"blockedBy"]];
            [aUserInfo setUnit:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"unit"]];
            [aUserInfo setDistance:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"distance"]];
            [aUserInfo setCircles:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"circles"]];
            [aUserInfo setAddress:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"address"]];
            [aUserInfo setVisible:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"visible"]];
            
            NSLog(@"aUserInfo.email: %@  lat: %@",aUserInfo.email,aUserInfo.currentLocationLat);
            NSLog(@"Is Kind of NSString: %@",jsonObjects);
            
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

    [request addPostValue:platform.facebook forKey:@"fb"];
    [request addPostValue:platform.fourSquare forKey:@"4sq"];
    [request addPostValue:platform.googlePlus forKey:@"googlePlus"];
    [request addPostValue:platform.gmail forKey:@"gmail"];
    [request addPostValue:platform.twitter forKey:@"twitter"];
    [request addPostValue:platform.yahoo forKey:@"yahoo"];
    [request addPostValue:platform.badoo forKey:@"badoo"];
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
    
    [request addPostValue:layer.wikipedia forKey:@"wikipedia"];
    [request addPostValue:layer.tripadvisor forKey:@"tripadvisor"];
    [request addPostValue:layer.foodspotting forKey:@"foodspotting"];
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
//    [request addPostValue:userInfo.email forKey:@"email"];
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
            UserInfo *aUserInfo=[[UserInfo alloc] init];
            [aUserInfo setUserId:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"id"]];
            [aUserInfo setEmail:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"email"]];
            [aUserInfo setFirstName:[[jsonObjects   objectForKey:@"result"] objectForKey:@"firstName"]];
            [aUserInfo setLastName:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"lastName"]];
            [aUserInfo setAvatar:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"avatar"]];
            [aUserInfo setDeactivated:[[jsonObjects   objectForKey:@"result"] objectForKey:@"deactivated"]];
            [aUserInfo setAuthToken:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"authToken"]];
            [aUserInfo setSettings:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"settings"]];
            [aUserInfo setSource:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"source"]];
            [aUserInfo setDateOfBirth:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"dateOfBirth"]];
            [aUserInfo setBio:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"bio"]];
            [aUserInfo setGender:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"gender"]];
            [aUserInfo setUsername:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"username"]];
            [aUserInfo setInterests:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"interests"]];
            [aUserInfo setWorkStatus:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"workStatus"]];
            [aUserInfo setRelationshipStatus:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"relationshipStatus"]];
            [aUserInfo setCurrentLocationLat:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"currentLocation"] objectForKey:@"lat"]];
            [aUserInfo setCurrentLocationLng:[[[jsonObjects  objectForKey:@"result"]  objectForKey:@"currentLocation"] objectForKey:@"lng"]];
            [aUserInfo setEnabled:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"enabled"]];
            [aUserInfo setRegMedia:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"regMedia"]];
            [aUserInfo setLoginCount:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"loginCount"]];
            [aUserInfo setLastLogin:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"lastLogin"]];
            [aUserInfo setCreateDate:[[jsonObjects   objectForKey:@"result"]  objectForKey:@"createDate"]];
            [aUserInfo setUpdateDate:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"updateDate"]];
            [aUserInfo setBlockedUsers:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"blockedUsers"]];
            [aUserInfo setBlockedBy:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"blockedBy"]];
            [aUserInfo setUnit:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"unit"]];
            [aUserInfo setDistance:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"distance"]];
            [aUserInfo setCircles:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"circles"]];
            [aUserInfo setAddress:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"address"]];
            [aUserInfo setVisible:[[jsonObjects  objectForKey:@"result"]  objectForKey:@"visible"]];
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

@end

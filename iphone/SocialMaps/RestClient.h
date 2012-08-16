//
//  RestClient.h
//  SocialMaps
//
//  Created by Arif Shakoor on 7/23/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"
#import "Constants.h"
#import "User.h"
#import "Platform.h"
#import "Layer.h"
#import "InformationPrefs.h"
#import "NotificationPref.h"
#import "UserInfo.h"
#import "Geofence.h"
#import "ShareLocation.h"

@interface RestClient : NSObject<ASIHTTPRequestDelegate>

- (void) login:(NSString*) email password:(NSString*)pass;
- (void) loginFacebook:(NSString*) facebookId password:(NSString*)facebookAuthToken;
- (void) register:(User*) userInfo;
- (void) registerFB:(User*) userInfo;
- (void) forgotPassword:(NSString*)email;
-(void) getPlatForm:(NSString *)authToken:(NSString *)authTokenValue;
-(void) getLayer:(NSString *)authToken:(NSString *)authTokenValue;
-(void)getSharingPreferenceSettings:(NSString *)authToken:(NSString *)authTokenValue;
-(void)getAccountSettings:(NSString *)authToken:(NSString *)authTokenValue;
-(void)getShareLocation:(NSString *)authToken:(NSString *)authTokenValue;
-(void)getGeofence:(NSString *)authToken:(NSString *)authTokenValue;
-(void)getNotifications:(NSString *)authToken:(NSString *)authTokenValue;
-(void)setNotifications:(NotificationPref *)notificationPref:(NSString *)authToken:(NSString *)authTokenValue;
-(void) setPlatForm:(Platform *)platform:(NSString *)authToken:(NSString *)authTokenValue;
-(void) setLayer:(Layer *)layer:(NSString *)authToken:(NSString *)authTokenValue;
-(void) setSharingPreferenceSettings:(InformationPrefs *)InformationPrefs:(NSString *)authToken:(NSString *)authTokenValue;
-(void)setAccountSettings:(UserInfo *)userInfo:(NSString *)authToken:(NSString *)authTokenValue;
-(void)setGeofence:(Geofence *)geofence:(NSString *)authToken:(NSString *)authTokenValue;
-(void)setShareLocation:(ShareLocation *)shareLocation:(NSString *)authToken:(NSString *)authTokenValue;

@end

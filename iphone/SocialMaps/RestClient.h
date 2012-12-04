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
#import "Geolocation.h"
#import "Event.h"
#import "UserCircle.h"
#import "Photo.h"
#import "Geotag.h"
#import "Plan.h"

@class Place;

@interface RestClient : NSObject<ASIHTTPRequestDelegate>

- (UserInfo*) parseAccountSettings:(NSDictionary*) jsonObjects user:(UserInfo**)user;
- (void) login:(NSString*) email password:(NSString*)pass;
- (void) loginFacebook:(User*) userInfo;
- (void) register:(User*) userInfo;
- (void) registerFB:(User*) userInfo;
- (void) forgotPassword:(NSString*)email;
-(void) getPlatForm:(NSString *)authToken:(NSString *)authTokenValue;
-(void) getLayer:(NSString *)authToken:(NSString *)authTokenValue;
-(void) getAccountSettings:(NSString *)authToken:(NSString *)authTokenValue;
-(void) getShareLocation:(NSString *)authToken:(NSString *)authTokenValue;
-(void) getGeofence:(NSString *)authToken:(NSString *)authTokenValue;
-(void) getLocation:(Geolocation *)geolocation:(NSString *)authToken:(NSString *)authTokenValue;
-(void) getNotifications:(NSString *)authToken:(NSString *)authTokenValue;
-(void)getUserProfile:(NSString *)authToken:(NSString *)authTokenValue;
-(void)updateUserProfile:(UserInfo *)userInfo:(NSString *)authToken:(NSString *)authTokenValue;
-(void)getAllEvents:(NSString *)authToken:(NSString *)authTokenValue;
-(void)getEventDetailById:(NSString *) eventID:(NSString *)authToken:(NSString *)authTokenValue;
-(void)deleteEventById:(NSString *) eventID:(NSString *)authToken:(NSString *)authTokenValue;
-(void)createEvent:(Event*)event:(NSString *)authToken:(NSString *)authTokenValue;
-(void)updateEvent:(NSString *) eventID:(Event*)event:(NSString *)authToken:(NSString *)authTokenValue;
-(void)inviteMoreFriendsEvent:(NSString *) eventID:(NSMutableArray *)friendsIdArr:(NSMutableArray *)circlesIdArr:(NSString *)authToken:(NSString *)authTokenValue;
-(void)setEventRsvp:(NSString *) eventID:(NSString *) rsvp:(NSString *)authToken:(NSString *)authTokenValue;

-(void) setNotifications:(NotificationPref *)notificationPref:(NSString *)authToken:(NSString *)authTokenValue;
-(void) setPlatForm:(Platform *)platform:(NSString *)authToken:(NSString *)authTokenValue;
-(void) setLayer:(Layer *)layer:(NSString *)authToken:(NSString *)authTokenValue;
-(void) setSharingPreferenceSettings:(InformationPrefs *)InformationPrefs:(NSString *)authToken:(NSString *)authTokenValue;
-(void) setAccountSettings:(UserInfo *)userInfo:(NSString *)authToken:(NSString *)authTokenValue;
-(void) setGeofence:(Geofence *)geofence:(NSString *)authToken:(NSString *)authTokenValue;
-(void)setShareLocation:(ShareLocation *)shareLocation:(NSString *)authToken:(NSString *)authTokenValue;
//-(void)setSharingPreference:(InformationPrefs *)informationPrefs:(NSString *)authToken:(NSString *)authTokenValue;
-(void) getSharingPreference:(NSString *)authToken:(NSString *)authTokenValue;
- (void) updatePosition:(Geolocation*)currLocation authToken:(NSString*)authToken authTokenVal:(NSString*)authTokenValue;
- (void) sendMessage:(NSString*)subject content:(NSString*)content recipients:(NSArray*)recipients authToken:(NSString*)authToken authTokenVal:(NSString*)authTokenValue;
- (void) sendReply:(NSString*)msgId content:(NSString*)content authToken:(NSString*)authToken authTokenVal:(NSString*)authTokenValue;
- (void) sendFriendRequest:(NSString*)friendId message:(NSString*)message authToken:(NSString*)authToken authTokenVal:(NSString*)authTokenValue;
- (void) getFriendRequests:(NSString*)authToken authTokenVal:(NSString*)authTokenValue;
- (void) getInbox:(NSString*)authToken authTokenVal:(NSString*)authTokenValue;
- (void) getReplies:(NSString*)authToken authTokenVal:(NSString*)authTokenValue msgID:(NSString*)messageId since:(NSString*)ti;
- (void) getNotificationMessages:(NSString*)authToken authTokenVal:(NSString*)authTokenValue;
- (void) acceptFriendRequest:(NSString*)friendId authToken:(NSString*) authToken authTokenVal:(NSString*)authTokenValue;
- (void) declineFriendRequest:(NSString*)friendId authToken:(NSString*) authToken authTokenVal:(NSString*)authTokenValue;
- (NSDate*) getDateFromJsonStruct:(NSDictionary*) jsonObjects name:(NSString*) name;
- (id) getNestedKeyVal:(NSDictionary*)dict key1:(NSString*)key1 key2:(NSString*)key2 key3:(NSString*)key3;
- (bool) changePassword:(NSString*)passwd oldpasswd:(NSString*)oldpasswd authToken:(NSString*) authToken authTokenVal:(NSString*)authTokenValue;
-(void)getUserInfo:(UserInfo**)user tokenStr:(NSString *)authToken tokenValue:(NSString *)authTokenValue;
-(void)getMyPlaces:(NSString *)authToken:(NSString *)authTokenValue;
- (void) sendMeetUpRequest:(NSString*)title description:(NSString*)description latitude:(NSString*)latitude longitude:(NSString*)longitude address:(NSString*)address time:(NSString*)time recipients:(NSArray*)recipients authToken:(NSString*)authToken authTokenVal:(NSString*)authTokenValue;
- (void) getMeetUpRequest:(NSString*)authToken authTokenVal:(NSString*)authTokenValue;
-(void)setMessageStatus:(NSString*)authToken authTokenVal:(NSString*)authTokenValue msgID:(NSString*)messageId status:(NSString*)status;
- (void) updateMeetUpRequest:(NSString*)meetUpId response:(NSString*)response authToken:(NSString*)authToken authTokenVal:(NSString*)authTokenValue;
- (void) setPushNotificationSettings:(NSString*)deviceToken authToken:(NSString*)authToken authTokenVal:(NSString*)authTokenValue;
-(void) getAllCircles:(NSString *)authToken:(NSString *)authTokenValue;
-(void) createCircle:(NSString *)authToken:(NSString *)authTokenValue:(UserCircle *)userCircle;
-(void) updateCircle:(NSString *)authToken:(NSString *)authTokenValue:(NSString *)friendId:(NSMutableArray *)userCircleArr;
-(void)updateMessageRecipients:(NSString*)authToken authTokenVal:(NSString*)authTokenValue msgID:(NSString*)messageId recipients:(NSMutableArray*)recipients;

-(void)getBlockUserList:(NSString *)authToken:(NSString *)authTokenValue;
-(void)blockUserList:(NSString *)authToken:(NSString *)authTokenValue:(NSMutableArray *)userIdArr;
-(void)unBlockUserList:(NSString *)authToken:(NSString *)authTokenValue:(NSMutableArray *)userIdArr;
-(void)getAllEventsForMap:(NSString *)authToken:(NSString *)authTokenValue;
-(void)getOtherUserProfile:(NSString *)authToken:(NSString *)authTokenValue:(NSString *)userId;
-(void)doConnectFB:(NSString *)authToken:(NSString *)authTokenValue:(NSString *)FBid:(NSString *)fbAuthToken;

- (void) setSharingPrivacySettings:(NSString*)authToken authTokenVal:(NSString*)authTokenValue privacyType:(NSString*)privacyType sharingOption:(NSString*)sharingOption;
-(void) uploadPhoto:(NSString *)authToken:(NSString *)authTokenValue:(Photo *)photo;
-(void) getPhotos:(NSString *)authToken:(NSString *)authTokenValue;
-(void) deletePhotoByPhotoId:(NSString *)authToken:(NSString *)authTokenValue:(NSString *)photoId;
-(void) getFriendsPhotos:(NSString *)authToken:(NSString *)authTokenValue:(NSString *)userId;

- (void) SavePlace:(Place*)place authToken:(NSString*)authToken authTokenVal:(NSString*)authTokenValue;
- (void) getPlaces:(NSString*)authToken authTokenVal:(NSString*)authTokenValue;
- (void) getOtherUserPlacesByUserId:(NSString*)userId  authToken:(NSString*)authToken authTokenVal:(NSString*)authTokenValue ;
- (void) updatePlaces:(NSString *)authToken:(NSString *)authTokenValue:(Place*)place;
- (void) deletePlaceByPlaceId:(NSString *)authToken:(NSString *)authTokenValue:(NSString *)placeId;
-(void) getGeotagPhotos:(NSString *)authToken:(NSString *)authTokenValue:(NSString *)userId;
-(void)createGeotag:(Geotag*)geotag:(NSString *)authToken:(NSString *)authTokenValue;
-(void) getAllGeotag:(NSString *)authToken:(NSString *)authTokenValue;
-(void) deleteCircleByCircleId:(NSString *)authToken:(NSString *)authTokenValue:(NSString *)circleId;
-(void) renameCircleByCircleId:(NSString *)authToken:(NSString *)authTokenValue:(NSString *)circleID:(NSString *)circleName;
- (void) recommendPlace:(Place*)place:(NSString *)authToken:(NSString *)authTokenValue withNote:(NSString*)note andRecipients:(NSMutableArray*)recipients;
-(void) getFriendListWithAuthKey:(NSString *)authTokenKey tokenValue:(NSString *)authTokenValue andFriendId:(NSString*)friendId;
-(void)createPlan:(Plan *)plan:(NSString *)authToken:(NSString *)authTokenValue;
-(void)getAllplans:(NSString *)authToken:(NSString *)authTokenValue;
-(void)deletePlans:(NSString *)authToken:(NSString *)authTokenValue:(NSString *)planId;
-(void)updatePlan:(Plan *)plan:(NSString *)authToken:(NSString *)authTokenValue;
-(void)getFriendsAllplans:(NSString *)userId:(NSString *)authToken:(NSString *)authTokenValue;
-(void) getUserFriendList:(NSString *)authTokenKey tokenValue:(NSString *)authTokenValue andUserId:(NSString*)userId;
@end

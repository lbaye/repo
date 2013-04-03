//
//  RestClient.h
//  SocialMaps
//
//  Created by Arif Shakoor on 7/23/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file RestClient.h
 * @brief Consumes all web services needed for this project
 */

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

/**
 * @brief Parse user information
 * @param (NSDictionary) - Parsed json data
 * @param (UserInfo) - User information in dictionary
 * @retval (UserInfo) - User information in objects
 */
- (UserInfo*) parseAccountSettings:(NSDictionary*) jsonObjects user:(UserInfo**)user;

/**
 * @brief Login request to service
 * @param (NSString) - User email address
 * @param (NSString) - User password
 * @retval none
 */
- (void) login:(NSString*) email password:(NSString*)pass;

/**
 * @brief Login with facebook and save user information
 * @param (User) - User information
 * @retval none
 */
- (void) loginFacebook:(User*) userInfo;

/**
 * @brief Register with user information
 * @param (User) - User information
 * @retval none
 */
- (void) register:(User*) userInfo;

/**
 * @brief Forgot password
 * @param (NSString) - Email address
 * @retval none
 */
- (void) forgotPassword:(NSString*)email;

/**
 * @brief Get platform from service
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void) getPlatForm:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Get layer from service
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void) getLayer:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Get account settings from service
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void) getAccountSettings:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Get share location data from service
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void) getShareLocation:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Get geofence from service
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void) getGeofence:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Get location from service
 * @param (Geolocation) - Geolocation with lat, long and address
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void) getLocation:(Geolocation *)geolocation:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Get notification from service
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void) getNotifications:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Get user own profile from service
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void)getUserProfile:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Update user information
 * @param (UserInfo) - User information
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void)updateUserProfile:(UserInfo *)userInfo:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Get all events
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void)getAllEvents:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Get detail of an event
 * @param (NSString) - ID of an event
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void)getEventDetailById:(NSString *) eventID:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Delete an event
 * @param (NSString) - ID of an event
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void)deleteEventById:(NSString *) eventID:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Create an event
 * @param (Event) - Event object
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void)createEvent:(Event*)event:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Update an event
 * @param (NSString) - Event id
 * @param (NSString) - Event object
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void)updateEvent:(NSString *) eventID:(Event*)event:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Invitr more friends to an event
 * @param (NSString) - Event id
 * @param (NSMutableArray) - Friends id array
 * @param (NSMutableArray) - Circles id array
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void)inviteMoreFriendsEvent:(NSString *) eventID:(NSMutableArray *)friendsIdArr:(NSMutableArray *)circlesIdArr:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Set event RSVP
 * @param (NSString) - Event id
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void)setEventRsvp:(NSString *) eventID:(NSString *) rsvp:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Set notification preference
 * @param (NotificationPref) - Notification preference
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void) setNotifications:(NotificationPref *)notificationPref:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Set platform settings
 * @param (Platform) - Platform object
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void) setPlatForm:(Platform *)platform:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Set layer settings
 * @param (Layer) - Layer object
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void) setLayer:(Layer *)layer:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Set information sharing preference
 * @param (InformationPrefs) - Information sharing preference object
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void) setSharingPreferenceSettings:(InformationPrefs *)InformationPrefs:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Set account settings
 * @param (UserInfo) - User information
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void) setAccountSettings:(UserInfo *)userInfo:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Set user geofence
 * @param (Geofence) - Geofence object
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void) setGeofence:(Geofence *)geofence:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Set sharing location
 * @param (ShareLocation) - Share location object
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void)setShareLocation:(ShareLocation *)shareLocation:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Get sharing preference
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
- (void) getSharingPreference:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Update user position
 * @param (Geolocation) - User geolocation with lat, long and address
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
- (void) updatePosition:(Geolocation*)currLocation authToken:(NSString*)authToken authTokenVal:(NSString*)authTokenValue;

/**
 * @brief Send message to multiple user
 * @param (NSString) - Message subject
 * @param (NSString) - Message content
 * @param (NSString) - Message recipients
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
- (void) sendMessage:(NSString*)subject content:(NSString*)content recipients:(NSArray*)recipients authToken:(NSString*)authToken authTokenVal:(NSString*)authTokenValue;

/**
 * @brief Send reply of a message
 * @param (NSString) - Message id
 * @param (NSString) - Message content
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
- (void) sendReply:(NSString*)msgId content:(NSString*)content authToken:(NSString*)authToken authTokenVal:(NSString*)authTokenValue;

/**
 * @brief Send friend request to a user
 * @param (NSString) - Friends id
 * @param (NSString) - Message
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
- (void) sendFriendRequest:(NSString*)friendId message:(NSString*)message authToken:(NSString*)authToken authTokenVal:(NSString*)authTokenValue;

/**
 * @brief Get friend request from service
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
- (void) getFriendRequests:(NSString*)authToken authTokenVal:(NSString*)authTokenValue;

/**
 * @brief Get message inbox from service
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
- (void) getInbox:(NSString*)authToken authTokenVal:(NSString*)authTokenValue;

/**
 * @brief Get message replies from service
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @param (NSString) - Message id
 * @param (NSString) - Time interval
 * @retval none
 */
- (void) getReplies:(NSString*)authToken authTokenVal:(NSString*)authTokenValue msgID:(NSString*)messageId since:(NSString*)ti;

/**
 * @brief Get notification message from service
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
- (void) getNotificationMessages:(NSString*)authToken authTokenVal:(NSString*)authTokenValue;

/**
 * @brief Accept friend request
 * @param (NSString) - Friends id
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
- (void) acceptFriendRequest:(NSString*)friendId authToken:(NSString*) authToken authTokenVal:(NSString*)authTokenValue;

/**
 * @brief Decline friend request
 * @param (NSString) - Friends id
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
- (void) declineFriendRequest:(NSString*)friendId authToken:(NSString*) authToken authTokenVal:(NSString*)authTokenValue;

/**
 * @brief Get data from json structure
 * @param (NSDictionary) - Json objects
 * @param (NSString) - Name
 * @retval none
 */
- (NSDate*) getDateFromJsonStruct:(NSDictionary*) jsonObjects name:(NSString*) name;

/**
 * @brief Get nested key value with null key checking
 * @param (NSString) - Key1
 * @param (NSString) - Key2
 * @param (NSString) - Key3
 * @retval none
 */
- (id) getNestedKeyVal:(NSDictionary*)dict key1:(NSString*)key1 key2:(NSString*)key2 key3:(NSString*)key3;

/**
 * @brief Change user password
 * @param (NSString) - New password
 * @param (NSString) - Old password
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
- (bool) changePassword:(NSString*)passwd oldpasswd:(NSString*)oldpasswd authToken:(NSString*) authToken authTokenVal:(NSString*)authTokenValue;

/**
 * @brief Get user information from service
 * @param (UserInfo) - User information
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
- (void)getUserInfo:(UserInfo**)user tokenStr:(NSString *)authToken tokenValue:(NSString *)authTokenValue;

/**
 * @brief Get all my places
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
- (void)getMyPlaces:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Send meet up request
 * @param (NSString) - Meet up request title
 * @param (NSString) - Meet up request description
 * @param (NSString) - Meet up request lat
 * @param (NSString) - Meet up request long
 * @param (NSString) - Meet up request address
 * @param (NSString) - Meet up request time
 * @param (NSArray) - Meet up request recipents
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value 
 * @retval none
 */
- (void) sendMeetUpRequest:(NSString*)title description:(NSString*)description latitude:(NSString*)latitude longitude:(NSString*)longitude address:(NSString*)address time:(NSString*)time recipients:(NSArray*)recipients authToken:(NSString*)authToken authTokenVal:(NSString*)authTokenValue;

/**
 * @brief Get meet up request from service
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
- (void) getMeetUpRequest:(NSString*)authToken authTokenVal:(NSString*)authTokenValue;

/**
 * @brief Set message status
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @param (NSString) - Message id
 * @retval none
 */
- (void) setMessageStatus:(NSString*)authToken authTokenVal:(NSString*)authTokenValue msgID:(NSString*)messageId status:(NSString*)status;

/**
 * @brief Update meet up request
 * @param (NSString) - Meet up id
 * @param (NSString) - Meet up response 
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
- (void) updateMeetUpRequest:(NSString*)meetUpId response:(NSString*)response authToken:(NSString*)authToken authTokenVal:(NSString*)authTokenValue;

/**
 * @brief Set push notification settings
 * @param (NSString) - Device Token
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
- (void) setPushNotificationSettings:(NSString*)deviceToken authToken:(NSString*)authToken authTokenVal:(NSString*)authTokenValue;

/**
 * @brief Get all circles
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void) getAllCircles:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Create circle
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @param (UserCircle) - Circle object
 * @retval none
 */
-(void) createCircle:(NSString *)authToken:(NSString *)authTokenValue:(UserCircle *)userCircle;

/**
 * @brief Update circle list and move user to circle
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @param (NSString) - Friends id
 * @param (NSMutableArray) - User circle array 
 * @retval none
 */
-(void) updateCircle:(NSString *)authToken:(NSString *)authTokenValue:(NSString *)friendId:(NSMutableArray *)userCircleArr;

/**
 * @brief Update message recipents
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @param (NSString) - Message id
 * @param (NSMutableArray) - Message recipents
 * @retval none
 */
-(void)updateMessageRecipients:(NSString*)authToken authTokenVal:(NSString*)authTokenValue msgID:(NSString*)messageId recipients:(NSMutableArray*)recipients;

/**
 * @brief Get blocked user from service
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void)getBlockUserList:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Block user list
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @param (NSMutableArray) - User's id list
 * @retval none
 */
-(void)blockUserList:(NSString *)authToken:(NSString *)authTokenValue:(NSMutableArray *)userIdArr;

/**
 * @brief Unblock user list
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @param (NSMutableArray) - User's id list
 * @retval none
 */
-(void)unBlockUserList:(NSString *)authToken:(NSString *)authTokenValue:(NSMutableArray *)userIdArr;

/**
 * @brief Get All events for map view from service
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void)getAllEventsForMap:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Get other user's profile from service
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @param (NSString) - User id of other user
 * @retval none
 */
-(void)getOtherUserProfile:(NSString *)authToken:(NSString *)authTokenValue:(NSString *)userId;

/**
 * @brief Do connect with facebook
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @param (NSString) - Facebook id
 * @param (NSString) - Facebook Auth Token
 * @retval none
 */
-(void)doConnectFB:(NSString *)authToken:(NSString *)authTokenValue:(NSString *)FBid:(NSString *)fbAuthToken;

/**
 * @brief Set sharing privacy settings
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @param (NSString) - Sharing privacy type
 * @param (NSString) - Privacy sharing option
 * @retval none
 */
- (void) setSharingPrivacySettings:(NSString*)authToken authTokenVal:(NSString*)authTokenValue privacyType:(NSString*)privacyType sharingOption:(NSString*)sharingOption;

/**
 * @brief Upload photo to server
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @param (Photo) - Photo
 * @retval none
 */
-(void) uploadPhoto:(NSString *)authToken:(NSString *)authTokenValue:(Photo *)photo;

/**
 * @brief Get photo list from service
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void) getPhotos:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Delete photo by photo id
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @param (NSString) - Photo id
 * @retval none
 */
-(void) deletePhotoByPhotoId:(NSString *)authToken:(NSString *)authTokenValue:(NSString *)photoId;

/**
 * @brief Delete photos by photo ids
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @param (NSMutableArray) - Photo ids
 * @retval none
 */
-(void) deletePhotosByPhotoIds:(NSMutableArray*)photoIds withAuthToken:(NSString *)authToken andAuthTokenValue:(NSString *)authTokenValue;

/**
 * @brief Get friends photo from service
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @param (NSString) - Friends user id
 * @retval none
 */
-(void) getFriendsPhotos:(NSString *)authToken:(NSString *)authTokenValue:(NSString *)userId;

/**
 * @brief Save place to server
 * @param (Place) - Place object
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
- (void) SavePlace:(Place*)place authToken:(NSString*)authToken authTokenVal:(NSString*)authTokenValue;

/**
 * @brief Get all places from service
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
- (void) getPlaces:(NSString*)authToken authTokenVal:(NSString*)authTokenValue;

/**
 * @brief Get other user's plave by user id from service
 * @param (NSString) - User id
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
- (void) getOtherUserPlacesByUserId:(NSString*)userId  authToken:(NSString*)authToken authTokenVal:(NSString*)authTokenValue ;

/**
 * @brief Update a place
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @param (Place) - Place object
 * @retval none
 */
- (void) updatePlaces:(NSString *)authToken:(NSString *)authTokenValue:(Place*)place;

/**
 * @brief Delete a place by place id
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @param (NSString) - Place id
 * @retval none
 */
- (void) deletePlaceByPlaceId:(NSString *)authToken:(NSString *)authTokenValue:(NSString *)placeId;

/**
 * @brief Creates a geotag
 * @param (Geotag) - Geotag object
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void)createGeotag:(Geotag*)geotag:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Get all geotag from service
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void) getAllGeotag:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Delete circle by circle id
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @param (NSString) - Circle id
 * @retval none
 */
-(void) deleteCircleByCircleId:(NSString *)authToken:(NSString *)authTokenValue:(NSString *)circleId;

/**
 * @brief Rename a circle
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @param (NSString) - Circle id
 * @param (NSString) - Circle name
 * @retval none
 */
- (void) renameCircleByCircleId:(NSString *)authToken:(NSString *)authTokenValue:(NSString *)circleID:(NSString *)circleName;

/**
 * @brief Recommend a place
 * @param (Place) - Place object
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @param (NSString) - Place note
 * @param (NSMutableArray) - Place recipents 
 * @retval none
 */
- (void) recommendPlace:(Place*)place:(NSString *)authToken:(NSString *)authTokenValue withNote:(NSString*)note andRecipients:(NSMutableArray*)recipients;

/**
 * @brief Get friend list with friend id
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @param (NSString) - Friend's id
 * @retval none
 */
-(void) getFriendListWithAuthKey:(NSString *)authTokenKey tokenValue:(NSString *)authTokenValue andFriendId:(NSString*)friendId;

/**
 * @brief Create a plan
 * @param (Plan) - Plan
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void)createPlan:(Plan *)plan:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Get all plans
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void)getAllplans:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Delete a plan
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @param (NSString) - Plan id
 * @retval none
 */
-(void)deletePlans:(NSString *)authToken:(NSString *)authTokenValue:(NSString *)planId;

/**
 * @brief Update a plan
 * @param (Plan) - Plan object
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void)updatePlan:(Plan *)plan:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Get friends plan list from service
 * @param (NSString) - User id
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void)getFriendsAllplans:(NSString *)userId:(NSString *)authToken:(NSString *)authTokenValue;

/**
 * @brief Get user friend list from service
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @param (NSString) - User id
 * @retval none
 */
-(void) getUserFriendList:(NSString *)authTokenKey tokenValue:(NSString *)authTokenValue andUserId:(NSString*)userId;

/**
 * @brief Get message by id from service
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @param (NSString) - Message Id
 * @retval none
 */
- (void) getMessageById:(NSString*)authToken authTokenVal:(NSString*)authTokenValue:(NSString*)messageId;

/**
 * @brief Get parent message by recipient id 
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @param (NSString) - Recipient Id
 * @retval none
 */
- (void)getThread:(NSString*)recipientId authToken:(NSString*)authToken authTokenVal:(NSString*)authTokenValue;

/**
 * @brief Get events by user id
 * @param (NSString) - Auth Token
 * @param (NSString) - Auth Token Value
 * @retval none
 */
-(void)getEventsByUserId:(NSString*)userId authToken:(NSString *)authToken authTokenValue:(NSString *)authTokenValue;

- (void)reportContentId:(NSString*)contentId withContentType:(NSString*)contentType authTokenValue:(NSString*)authTokenValue authTokenKey:(NSString*)authTokenKey callBack:(void(^)(NSString *message))block;

@end

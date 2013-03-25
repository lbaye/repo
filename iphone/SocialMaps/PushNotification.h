//
//  PushNotification.h
//  SocialMaps
//
//  Created by Arif Shakoor on 9/19/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _PUSH_NOTIFICATION_TYPE {
    PushNotificationProximityAlert=0,
    PushNotificationMessage,
    PushNotificationFriendRequest,
    PushNotificationMeetupRequest,
    PushNotificationPlan,
    PushNotificationEventInvite,
    PushNotificationShareDirection,
    PushNotificationShareMapix,
    PushNotificationSharePicture,
    PushNotificationShareBreadcrumb,
    PushNotificationAcceptedRequest
} PUSH_NOTIFICATION_TYPE;

@interface PushNotification : NSObject {
    NSString  *message;
    int       badgeCount;
    PUSH_NOTIFICATION_TYPE notifType;
    NSArray   *objectIds;
    NSString  *receiverId;
}
@property (nonatomic, retain) NSString  *message;
@property (nonatomic, retain) NSArray   *objectIds;
@property (nonatomic) int badgeCount;
@property (nonatomic) PUSH_NOTIFICATION_TYPE notifType;
@property (nonatomic, retain)NSString *receiverId;

+ (PushNotification*) parsePayload:(NSDictionary*) payload;
@end

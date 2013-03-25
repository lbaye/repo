//
//  PushNotification.m
//  SocialMaps
//
//  Created by Arif Shakoor on 9/19/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "PushNotification.h"

@implementation PushNotification

@synthesize message;
@synthesize badgeCount;
@synthesize objectIds;
@synthesize notifType;
@synthesize receiverId;

//
// Payload
// The objectId can in the future be a comma separated list!!
//
//{
//    
//    “aps”:{
//        
//        “alert”:“Your friend is here! Check him!”,
//        
//        "badge":3,
//        
//        “sound”:“default”,
//        
//        “custom_data”:{
//            
//            “objectType”:“proximity_alert”,
//            
//            “objectId”:“5030a6df757df2b610000000”
//            
//        }
//        
//    }
//    
//}

+ (PushNotification*)parsePayload:(NSDictionary*) payload
{
    PushNotification *newNotif = [[[PushNotification alloc] init] autorelease];
    newNotif.message = [[payload objectForKey:@"aps"] objectForKey:@"alert"];
    newNotif.badgeCount = 0;
    if ([[payload objectForKey:@"aps"] objectForKey:@"badge"] != [NSNull null])
        newNotif.badgeCount = [[[payload objectForKey:@"aps"] objectForKey:@"badge"] intValue];
    NSString *type = [[[payload objectForKey:@"aps"] objectForKey:@"custom_data"] objectForKey:@"objectType"];
    NSLog(@"type = %@", type);
    // Keep provision for comma separated list
    NSString *objectIds = [[[payload objectForKey:@"aps"] objectForKey:@"custom_data"] objectForKey:@"objectId"];
    NSString *receiverId = [[[payload objectForKey:@"aps"] objectForKey:@"custom_data"] objectForKey:@"receiverId"];
    NSArray *users = nil;
    
    // ObjectIds is null for multiple friend notification
    if ((objectIds != NULL) && ![objectIds isEqual:[NSNull null]]) {
        NSLog(@"Object ids - %@", objectIds);
        users = [objectIds componentsSeparatedByString:@","];
    }
    
    if ([type caseInsensitiveCompare:@"proximity_alert"] == NSOrderedSame) {
        newNotif.notifType = PushNotificationProximityAlert;
        newNotif.objectIds = [NSArray arrayWithArray:users];
    } else if ([type caseInsensitiveCompare:@"new_message"] == NSOrderedSame || [type caseInsensitiveCompare:@"reply_message"] == NSOrderedSame) {
        newNotif.notifType = PushNotificationMessage;
        newNotif.objectIds = [NSArray arrayWithArray:users];
    } else if ([type caseInsensitiveCompare:@"meetup"] == NSOrderedSame) {
        newNotif.notifType = PushNotificationMeetupRequest;
        newNotif.objectIds = [NSArray arrayWithArray:users];
    } else if ([type caseInsensitiveCompare:@"event_guest"] == NSOrderedSame) {
        newNotif.notifType = PushNotificationEventInvite;
        newNotif.objectIds = [NSArray arrayWithArray:users];
    } else if ([type caseInsensitiveCompare:@"friend_request"] == NSOrderedSame) {
        newNotif.notifType = PushNotificationFriendRequest;
        newNotif.objectIds = [NSArray arrayWithArray:users];
    } else if ([type caseInsensitiveCompare:@"accepted_request"] == NSOrderedSame) {
        newNotif.notifType = PushNotificationAcceptedRequest;
        newNotif.objectIds = [NSArray arrayWithArray:users];
    } else {
        newNotif.notifType = PushNotificationShareBreadcrumb;
    }
    
    newNotif.receiverId = receiverId;
    
    NSLog(@"parsePayload - Push notification: alert=%@,badge=%d,ids=%@, receiverId=%@",newNotif.message, newNotif.badgeCount, newNotif.objectIds, receiverId);
    
    return newNotif;
}

@end

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
    PushNotification *newNotif = [[PushNotification alloc] init];
    newNotif.message = [[payload objectForKey:@"aps"] objectForKey:@"alert"];
    newNotif.badgeCount = [[[payload objectForKey:@"aps"] objectForKey:@"badge"] intValue];
    NSString *type = [[[payload objectForKey:@"aps"] objectForKey:@"custom_data"] objectForKey:@"objectType"];
    
    // Keep provision for comma separated list
    NSString *objectIds = [[[payload objectForKey:@"aps"] objectForKey:@"custom_data"] objectForKey:@"objectId"];
    NSArray *users = [objectIds componentsSeparatedByString:@","];
    if ([type caseInsensitiveCompare:@"proximity_alert"] == NSOrderedSame) {
        newNotif.notifType = PushNotificationProximityAlert;
        newNotif.objectIds = [NSArray arrayWithArray:users];
    } else {
        newNotif.notifType = PushNotificationMessage;
    }
    NSLog(@"parsePayload - Push notification: alert=%@,badge=%d,ids=%@",newNotif.message, newNotif.badgeCount, newNotif.objectIds);
    return newNotif;
}

@end

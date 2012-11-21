//
//  Message.h
//  SocialMaps
//
//  Created by Arif Shakoor on 7/31/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "Notification.h"

@interface NotifMessage : Notification {
    bool        showDetail;
    NSString    *notifSubject;
    NSString    *notifID;
    NSDictionary *recipients;
    NSDictionary *lastReply;
    NSString    *msgStatus;
    NSString    *metaType;
    NSString    *address;
    NSString    *lat;
    NSString    *lng;
}

@property (atomic) bool showDetail;
@property (nonatomic, retain) NSString *notifSubject;
@property (nonatomic, retain) NSString *notifID;
@property (nonatomic, retain) NSDictionary *recipients;
@property (nonatomic, retain) NSDictionary *lastReply;
@property (nonatomic,retain) NSString* msgStatus;
@property (nonatomic, retain) NSString *metaType;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *lat;
@property (nonatomic, retain) NSString *lng;

@end

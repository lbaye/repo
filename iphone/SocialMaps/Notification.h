//
//  Notification.h
//  SocialMaps
//
//  Created by Arif Shakoor on 7/31/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>
//#include "NotificationController.h"
@class NotificationController;

#define NUM_LINES_IN_BRIEF_VIEW 1
@interface Notification : NSObject {
    NSString    *notifSenderId;
    NSString    *notifSender;
    NSDate      *notifTime;
    NSString    *notifMessage;
}

@property (nonatomic,retain) NSString *notifSenderId;
@property (nonatomic,retain) NSString *notifSender;
@property (nonatomic,retain) NSDate *notifTime;
@property (nonatomic,retain) NSString *notifMessage;

- (NSString*) timeAsString;
- (UITableViewCell*) getTableViewCell:(UITableView*)tv sender:(NotificationController*)controller;
- (CGFloat) getRowHeight:(UITableView*)tv;

@end

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
}

@property (atomic) bool showDetail;
@property (nonatomic, retain) NSString *notifSubject;

@end

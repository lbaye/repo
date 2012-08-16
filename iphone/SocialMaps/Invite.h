//
//  Invite.h
//  SocialMaps
//
//  Created by Arif Shakoor on 7/31/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "Notification.h"

@interface Invite : Notification {
    NSDate  *startTime;
    NSDate  *endTime;
    NSString    *location;
}
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) NSString * location;
@end

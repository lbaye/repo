//
//  Request.h
//  SocialMaps
//
//  Created by Arif Shakoor on 7/31/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "Notification.h"

@protocol NotifRequestDelegate<NSObject>
- (void) buttonClicked:(NSString*)name cellRow:(int)row;
@end

@interface NotifRequest : Notification {
    id<NotifRequestDelegate> delegate;
    int     numCommonFriends;
    bool    ignored;
}
@property (atomic) int numCommonFriends;
@property (assign) id<NotifRequestDelegate> delegate;
@property (atomic) bool ignored;

- (void) requestAccepted:(id)sender;
- (void) requestDeclined:(id)sender;
- (void) requestIgnored:(id)sender;

@end

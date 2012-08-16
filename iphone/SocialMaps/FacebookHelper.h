//
//  FacebookHelper.h
//  SocialMaps
//
//  Created by Arif Shakoor on 7/27/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"

@interface FacebookHelper : NSObject <FBSessionDelegate, FBRequestDelegate> {
    Facebook    *facebook;
}
@property (nonatomic, retain) Facebook *facebook;

+ (id) sharedInstance;
- (void)getUserInfo:(id)sender;
- (void)getUserFriendListRequest:(id)sender;
-(void)getUserFriendListFromFB:(id)sender;
-(void)inviteFriends:(NSMutableArray *)frndList;

@end

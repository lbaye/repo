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

/**
 * @brief Return shared instance of an object
 * @param (id) - Action sender
 * @retval (id) - Shared object
 */
+ (id) sharedInstance;

/**
 * @brief Get user information
 * @param (id) - Action sender
 * @retval none
 */
- (void)getUserInfo:(id)sender;

/**
 * @brief Get user's facebook friend list
 * @param (id) - Action sender
 * @retval none
 */
- (void)getUserFriendListRequest:(id)sender;

/**
 * @brief Get user's friend list and generate friends image url
 * @param (id) - Action sender
 * @retval none
 */
- (void)getUserFriendListFromFB:(id)sender;

/**
 * @brief Invite facebook friends to social map
 * @param (NSMutableArray) - Friend facebook id array
 * @retval none
 */
- (void)inviteFriends:(NSMutableArray *)frndList;

@end

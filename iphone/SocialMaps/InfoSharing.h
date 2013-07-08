//
//  InfoSharing.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/7/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file InfoSharing.h
 * @brief Display information sharing preference through this view controller.
 */

#import <UIKit/UIKit.h>
#define INFO_SHARING_ROW_HEIGHT 45

@interface InfoSharing : UIScrollView

/**
 * @brief Create information sharing scroll view
 * @param (CGRect) - Position and size of scroll view
 * @param (NSArray) - Information list
 * @param (NSArray) - Default list
 * @param (id) - Action sender
 * @retval (UIScrollView) - Created information sharing scroll view
 */
- (UIScrollView*) initWithFrame:(CGRect)frame infoList:(NSArray*)infoList
                        defList:(NSArray*)defList sender:(id) sender;

@end

//
//  UITextView+Rounded.h
//  SocialMaps
//
//  Created by Warif Rishi on 11/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file UITextView+Rounded.h
 * @brief UITextView methods added for make rounded corner and make rounded corner with border color.
 */

#import <UIKit/UIKit.h>

@interface UITextView (Rounded)

/**
 * @brief Make rounded corner
 * @param none
 * @retval none
 */
- (void) makeRoundCorner;

/**
 * @brief Make rounded corner with specific border color
 * @param (UIColor) - Border color
 * @retval none
 */
- (void) makeRoundCornerWithColor:(UIColor *)color;

@end

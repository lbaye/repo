//
//  UITextView+PlaceHolder.h
//  SocialMaps
//
//  Created by Warif Rishi on 11/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file UITextView+PlaceHolder.h
 * @brief UITextView methods added for placeholder text.
 */

#import <UIKit/UIKit.h>

@interface UITextView (PlaceHolder)

/**
 * @brief Set placeholder text
 * @param (NSString) - The text for placeholder
 * @retval none
 */
- (void) setPlaceHolderText: (NSString *) text;

/**
 * @brief Get placeholder text
 * @param none
 * @retval (NSString) - The placeholder text
 */
- (NSString *) getPlaceHolderText;

/**
 * @brief Reset placeholder text to blank
 * @param none
 * @retval none
 */
- (void) resetPlaceHolderText;

@end

//
//  AccountSettings.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/7/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountSettings : UIScrollView <UITextFieldDelegate>

/**
 * @brief Initialize scroll view with given dimension
 * @param (CGRect) - Scroll view frame size
 * @retval (UIScrollView) - Initialized scroll view
 */
- (UIScrollView*) initWithFrame:(CGRect)scrollFrame;

/**
 * @brief Perform action when clicked on button
 * @param (id) - Action sender, detect button tag and perform operation accordingly
 * @retval none
 */
- (void) accSettingButtonClicked:(id) sender;

/**
 * @brief Erase all data and personal information
 * @param (id) - Action sender
 * @retval none
 */
- (void) accSettingResetButtonClicked:(id) sender;

@end

//
//  UITextField+Scrolling.h
//  SocialMaps
//
//  Created by Arif Shakoor on 10/17/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file UITextField+Scrolling.h
 * @brief UITextField method added for scroll up / down to keep the the textField on top of the keyboard.
 */

#import <UIKit/UIKit.h>

@interface UITextField (Scrolling) 

@property (nonatomic) int movementDistance;

/**
 * @brief Animage textField up, down
 * @param (UITextField) - TextField which will animage
 * @param (BOOL) - Should go up or down
 * @retval none
 */
- (void) animateTextField: (UITextField*) textField up: (BOOL) up;

@end

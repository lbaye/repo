//
//  UILabel+Decoration.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 11/19/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file UILabel+Decoration.h
 * @brief UILabel methods added for glow effect and rounded corner with color border.
 */

#import <UIKit/UIKit.h>

@interface UILabel (Decoration)

/**
 * @brief Set label text glow effect
 * @param none
 * @retval none
 */
- (void) setLabelGlowEffect;

/**
 * @brief Make rounded corner with given color border
 * @param (UIColor) - Color for the rounded border
 * @retval none
 */
- (void) makeRoundCornerWithColor:(UIColor *)color;

@end

//
//  CustomAlert.h
//  SocialMaps
//
//  Created by Arif Shakoor on 7/24/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomAlert : UIAlertView

/**
 * @brief Create custom alert with specific color
 * @param (UIColor) - Background color of alert
 * @param (UIColor) - Stroke color of alert
 * @retval action
 */
+ (void) setBackgroundColor:(UIColor *) background 
            withStrokeColor:(UIColor *) stroke;

@end

//
//  LoadingView.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 11/29/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file LoadingView.h
 * @brief Display loading indicator.
 */

#import <UIKit/UIKit.h>

@interface LoadingView : UIView
{

}

/**
 * @brief Show loading indicotr in the param view
 * @param (UIView) - View in which loading indicator will be displayed
 * @retval action
 */
+ (id)loadingViewInView:(UIView *)aSuperview;

/**
 * @brief Remove loading indicotr from view
 * @param none
 * @retval none
 */
- (void)removeView;

@end

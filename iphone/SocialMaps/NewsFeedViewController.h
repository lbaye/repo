//
//  NewsFeedViewController.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 11/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file NewsFeedViewController.h
 * @brief Display user and friends combined newsfeed through this view controller.
 */

#import <UIKit/UIKit.h>

@interface NewsFeedViewController : UIViewController<UIScrollViewDelegate>
{
    IBOutlet UIWebView *newsFeedView;
    IBOutlet UILabel *totalNotifCount;
}
@property(nonatomic,retain) IBOutlet UIWebView *newsFeedView;
@property(nonatomic,retain) IBOutlet UILabel *totalNotifCount;

@property(nonatomic,retain) IBOutlet UIImageView *newsfeedImgView;
@property(nonatomic,retain) IBOutlet UIView *newsfeedImgFullView;
@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *newsFeedImageIndicator;

/**
 * @brief Navigate user to previous screen
 * @param (id) - Action sender
 * @retval action
 */
-(IBAction)backButton:(id)sender;

/**
 * @brief Navigate user to navigation screen
 * @param (id) - Action sender
 * @retval action
 */
-(IBAction)gotoNotification:(id)sender;

/**
 * @brief Close newsfeed enlarged image view
 * @param (id) - Action sender
 * @retval action
 */
-(IBAction)closeNewsfeedImgView:(id)sender;

@end

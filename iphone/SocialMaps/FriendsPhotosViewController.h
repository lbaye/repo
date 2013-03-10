//
//  FriendsPhotosViewController.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 11/1/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file FriendsPhotosViewController.h
 * @brief Display friends and other user's photos through this view controller.
 */

#import <UIKit/UIKit.h>

@class RestClient;
@class AppDelegate;

@interface FriendsPhotosViewController : UIViewController
{
    IBOutlet UIScrollView *photoScrollView;
    IBOutlet UIScrollView *zoomScrollView;
    IBOutlet UIView *zoomView;
    IBOutlet UILabel *labelNotifCount;
    IBOutlet UIButton *photoLabel;
    NSString *userName;
    NSString *userId;
    IBOutlet UIButton *nextButton;
    IBOutlet UIButton *prevButton;
    
    NSMutableArray *photoList;
    
    BOOL isDragging_msg, isDecliring_msg;
    int zoomIndex;
    
    RestClient *restClient;
    AppDelegate *smAppdelegate;
}

@property(nonatomic,retain) IBOutlet UILabel *labelNotifCount;
@property(nonatomic,retain) IBOutlet UIScrollView *photoScrollView;
@property(nonatomic,retain) IBOutlet UIScrollView *zoomScrollView;
@property(nonatomic,retain) IBOutlet UIView *zoomView;
@property(nonatomic,retain) IBOutlet UIButton *photoLabel;
@property(nonatomic,retain) NSString *userName;
@property(nonatomic,retain) NSString *userId;
@property(nonatomic,retain) IBOutlet UIButton *nextButton;
@property(nonatomic,retain) IBOutlet UIButton *prevButton;    
@property (nonatomic, retain) NSMutableArray *photoList;

/**
 * @brief Closes full screen view of a photo
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)closeZoomView:(id)sender;

/**
 * @brief Show user previous image
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)viewPrevImage:(id)sender;

/**
 * @brief Show user next image
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)viewNextImage:(id)sender;

/**
 * @brief Navigate user to notification screen
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)actionNotificationButton:(id)sender;

/**
 * @brief Navigate user to previous screen
 * @param (id) - action sender
 * @retval Action
 */
-(IBAction)backButtonAction:(id)sender;

@end

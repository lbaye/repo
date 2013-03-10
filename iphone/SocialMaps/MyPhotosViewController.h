//
//  MyPhotosViewController.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 10/29/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file MyPhotosViewController.h
 * @brief Display user's uploaded photo to this view controller.
 */

#import <UIKit/UIKit.h>

@class RestClient;
@class AppDelegate;

@interface MyPhotosViewController : UIViewController
{
    IBOutlet UIScrollView *photoScrollView;
    IBOutlet UIScrollView *zoomScrollView;
    IBOutlet UIView *zoomView;
    IBOutlet UILabel *labelNotifCount;
    IBOutlet UIButton *nextButton;
    IBOutlet UIButton *prevButton;
    
    NSMutableArray *selectedFriendsIndex, *photoList;
    
    BOOL isDragging_msg, isDecliring_msg;
    int zoomIndex;
    
    RestClient *restClient;
    AppDelegate *smAppdelegate;
}

@property(nonatomic,retain) IBOutlet UILabel *labelNotifCount;
@property(nonatomic,retain) IBOutlet UIScrollView *photoScrollView;
@property(nonatomic,retain) IBOutlet UIScrollView *zoomScrollView;
@property(nonatomic,retain) IBOutlet UIView *zoomView;
@property(nonatomic,retain) IBOutlet UIButton *nextButton;
@property(nonatomic,retain) IBOutlet UIButton *prevButton;
@property (nonatomic, retain) NSMutableArray *photoList;

/**
 * @brief navigate user to my photo screen
 * @param (id) - action sender
 * @retval action
 */
- (IBAction)myPhotosAction:(id)sender;

/**
 * @brief navigate user to upload new photo screen
 * @param (id) - action sender
 * @retval action
 */
- (IBAction)uploadNewPhotoAction:(id)sender;

/**
 * @brief delete selected photo
 * @param (id) - action sender
 * @retval action
 */
- (IBAction)deleteSelectedPhotosAction:(id)sender;

/**
 * @brief Closes full screen view of a image
 * @param (id) - action sender
 * @retval action
 */
- (IBAction)closeZoomView:(id)sender;

/**
 * @brief show previous image
 * @param (id) - action sender
 * @retval action
 */
- (IBAction)viewPrevImage:(id)sender;

/**
 * @brief show next image
 * @param (id) - action sender
 * @retval action
 */
- (IBAction)viewNextImage:(id)sender;

/**
 * @brief navigate user to notification screen
 * @param (id) - action sender
 * @retval action
 */
- (IBAction)actionNotificationButton:(id)sender;

/**
 * @brief navigate user to previous screen
 * @param (id) - action sender
 * @retval action
 */
- (IBAction)backButtonAction:(id)sender;

@end

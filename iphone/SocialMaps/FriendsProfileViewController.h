//
//  FriendsProfileViewController.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 10/18/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file FriendsProfileViewController.h
 * @brief Display friends and other user's profile through this view controller.
 */

#import <UIKit/UIKit.h>
#import "Plan.h"
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PhotoPicker.h"

@interface FriendsProfileViewController : UIViewController<UIPickerViewDataSource, 
UIPickerViewDelegate,
UITextFieldDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,PhotoPickerDelegate,MKMapViewDelegate,UIScrollViewDelegate>
{
    IBOutlet UIImageView *coverImageView;
    IBOutlet UIImageView *profileImageView;
    IBOutlet UILabel *nameLabl;
    IBOutlet UILabel *statusMsgLabel;
    IBOutlet UILabel *addressOrvenueLabel;
    IBOutlet UILabel *distanceLabel;
    IBOutlet UILabel *ageLabel;
    IBOutlet UILabel *relStsLabel;
    IBOutlet UILabel *livingPlace;
    IBOutlet UILabel *worksLabel;
    IBOutlet UIButton *regStatus;
    IBOutlet UIScrollView *userItemScrollView;
    IBOutlet MKMapView *mapView;
    IBOutlet UIView *mapContainer;
    IBOutlet UIView *statusContainer;
    IBOutlet UITextField *entityTextField;
    PhotoPicker *photoPicker;
    IBOutlet UIButton *buttonZoomView;
    
    
    BOOL isDragging_msg,isDecliring_msg;
    NSMutableArray *ImgesName; 
    BOOL isBackgroundTaskRunning;
    UIImage *coverImage;
    UIImage *profileImage;
    IBOutlet UILabel *totalNotifCount;
    int entityFlag;
    NSString *friendsId;
    IBOutlet UIView *msgView;
    IBOutlet UITextView *textViewNewMsg;
    IBOutlet UIButton *frndStatusButton;
    IBOutlet UIButton *addFrndButton;
    IBOutlet UILabel *lastSeenat;
    IBOutlet UIButton *meetUpButton;
    IBOutlet UIView *profileView;
    IBOutlet UIWebView *newsfeedView;
    IBOutlet UIScrollView *profileScrollView;
    IBOutlet UIView *zoomView;
    IBOutlet UIImageView *fullImageView;
}
@property(nonatomic,retain) IBOutlet UIImageView *coverImageView;
@property(nonatomic,retain) IBOutlet UIImageView *profileImageView;
@property(nonatomic,retain) IBOutlet UILabel *nameLabl;
@property(nonatomic,retain) IBOutlet UILabel *statusMsgLabel;
@property(nonatomic,retain) IBOutlet UILabel *addressOrvenueLabel;
@property(nonatomic,retain) IBOutlet UILabel *distanceLabel;
@property(nonatomic,retain) IBOutlet UILabel *ageLabel;
@property(nonatomic,retain) IBOutlet UILabel *relStsLabel;
@property(nonatomic,retain) IBOutlet UILabel *livingPlace;
@property(nonatomic,retain) IBOutlet UILabel *worksLabel;
@property(nonatomic,retain) IBOutlet UIButton *regStatus;
@property(nonatomic,retain) IBOutlet UIScrollView *userItemScrollView;
@property(nonatomic,retain) IBOutlet MKMapView *mapView;
@property(nonatomic,retain) IBOutlet UIView *mapContainer;
@property(nonatomic,retain) IBOutlet UIView *statusContainer;
@property(nonatomic,retain) IBOutlet UITextField *entityTextField;

@property(nonatomic,retain) PhotoPicker *photoPicker;
@property(nonatomic,retain) UIImage *coverImage;
@property(nonatomic,retain) UIImage *profileImage;
@property(nonatomic, retain) UIImagePickerController *picSel;
@property(nonatomic,retain) NSString *friendsId;
@property(nonatomic,retain) IBOutlet UILabel *totalNotifCount;

@property(nonatomic,retain) IBOutlet UIView *msgView;
@property(nonatomic,retain) IBOutlet UITextView *textViewNewMsg;
@property(nonatomic,retain) IBOutlet UIButton *frndStatusButton;
@property(nonatomic,retain) IBOutlet UIButton *addFrndButton;
@property(nonatomic,retain) IBOutlet UILabel *lastSeenat;
@property(nonatomic,retain) IBOutlet UIButton *meetUpButton;

@property(nonatomic,retain) IBOutlet UIView *profileView;
@property(nonatomic,retain) IBOutlet UIWebView *newsfeedView;
@property(nonatomic,retain) IBOutlet UIScrollView *profileScrollView;
@property(nonatomic,retain) IBOutlet UIView *zoomView;
@property(nonatomic,retain) IBOutlet UIImageView *fullImageView;

@property(nonatomic,retain) IBOutlet UIImageView *newsfeedImgView;
@property(nonatomic,retain) IBOutlet UIView *newsfeedImgFullView;
@property(nonatomic,retain) NSMutableData *activeDownload;
@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *newsFeedImageIndicator;

/**
 * @brief send friend request to user
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)friendRequestButton:(id)sender;

/**
 * @brief navigate user to upload photo
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)uploadPhotoButton:(id)sender;

/**
 * @brief show user position on map
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)viewOnMapButton:(id)sender;

/**
 * @brief close point on map view
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)closeMap:(id)sender;

/**
 * @brief navigate user to previous screen
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)backButton:(id)sender;

/**
 * @brief hide keyboard
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)hideKeyboard:(id)sender;

/**
 * @brief navigate user to notification screen
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)gotoNotification:(id)sender;

/**
 * @brief send message to friends
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)sendMsg:(id)sender;

/**
 * @brief cancel messaging to friends
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)cancelMsg:(id)sender;

/**
 * @brief show message view
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)showMsgView:(id)sender;

/**
 * @brief navigate user to direction screen
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)getDirection:(id)sender;

/**
 * @brief closes zoom view
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)closeZoomView:(id)sender;

/**
 * @brief enlarge profile imAGE
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)goToZoomView:(id)sender;

/**
 * @brief navigate user to view plan on map
 * @param (id) - action sender
 * @retval action
 **/
- (void) showPinOnMapViewPlan:(Plan *)plan;

/**
 * @brief closes newfeed image enlarged view
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)closeNewsfeedImgView:(id)sender;

@end

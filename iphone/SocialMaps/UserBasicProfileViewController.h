//
//  UserBasicProfileViewController.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 9/11/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PhotoPicker.h"
#import "Plan.h"

@interface UserBasicProfileViewController : UIViewController<UIPickerViewDataSource, 
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
    IBOutlet UIWebView *newsfeedView;
    PhotoPicker *photoPicker;

    
    BOOL isDragging_msg,isDecliring_msg;
    NSMutableArray *ImgesName; 
    BOOL isBackgroundTaskRunning;
    UIImage *coverImage;
    UIImage *profileImage;
    IBOutlet UILabel *totalNotifCount;
    int entityFlag;
    IBOutlet UILabel *lastSeenat;
    IBOutlet UIButton *nameButton;
    IBOutlet UIView *profileView;
    IBOutlet UIScrollView *profileScrollView;
    IBOutlet UIView *zoomView;
    IBOutlet UIImageView *fullImageView;
    
    IBOutlet UIImageView *newsfeedImgView;
    IBOutlet UIView *newsfeedImgFullView;
    NSMutableData *activeDownload;
    IBOutlet UIActivityIndicatorView *newsFeedImageIndicator;
}

@property(nonatomic,retain) IBOutlet UIImageView *fullImageView;
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
@property(nonatomic,retain) IBOutlet UIWebView *newsfeedView;

@property(nonatomic,retain) PhotoPicker *photoPicker;
@property(nonatomic,retain) UIImage *coverImage;
@property(nonatomic,retain) UIImage *profileImage;
@property(nonatomic, retain) UIImagePickerController *picSel;
@property(nonatomic,retain) IBOutlet UIButton *nameButton;

@property(nonatomic,retain) IBOutlet UILabel *totalNotifCount;
@property(nonatomic,retain) IBOutlet UILabel *lastSeenat;
@property(nonatomic,retain) IBOutlet UIView *profileView;
@property(nonatomic,retain) IBOutlet UIScrollView *profileScrollView;
@property(nonatomic,retain) IBOutlet UIView *zoomView;

@property(nonatomic,retain) IBOutlet UIImageView *newsfeedImgView;
@property(nonatomic,retain) IBOutlet UIView *newsfeedImgFullView;
@property(nonatomic,retain) NSMutableData *activeDownload;
@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *newsFeedImageIndicator;

/**
 * @brief change cover photo
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)editCoverButton:(id)sender;

/**
 * @brief change profile image
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)editProfilePicButton:(id)sender;

/**
 * @brief edit status
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)editStatusButton:(id)sender;

/**
 * @brief navigate user to create geotag screen
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)geotagButton:(id)sender;

/**
 * @brief navigate user to upload photo screen
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)uploadPhotoButton:(id)sender;

/**
 * @brief view user position on map
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)viewOnMapButton:(id)sender;

/**
 * @brief close map view for point on map
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)closeMap:(id)sender;

/**
 * @brief save user information entity
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)saveEntity:(id)sender;

/**
 * @brief cancel user information entity
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)cancelEntity:(id)sender;

/**
 * @brief navigate user to previous screen
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)backButton:(id)sender;

/**
 * @brief hides the keyboard
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
 * @brief changes date of birth of a user
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)ageButtonAction:(id)sender;

/**
 * @brief changes relationship status of a user
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)realstsButtonAction:(id)sender;

/**
 * @brief changes living address of user
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)liveatButtonAction:(id)sender;

/**
 * @brief works status of user
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)workatButtonAction:(id)sender;

/**
 * @brief changes name of user
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)nameButtonAction:(id)sender;

/**
 * @brief enlarge profile picture of user
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)goToZoomView:(id)sender;

/**
 * @brief closes zooming mode of profile picture
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)closeZoomView:(id)sender;

/**
 * @brief navigate user to view plan of a user
 * @param (id) - action sender
 * @retval action
 **/
- (void) showPinOnMapViewPlan:(Plan *)plan;

/**
 * @brief closes zoom view for newsfeed image of a user
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)closeNewsfeedImgView:(id)sender;

@end

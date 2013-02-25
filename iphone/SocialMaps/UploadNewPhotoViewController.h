//
//  UploadNewPhotoViewController.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 10/29/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file UploadNewPhotoViewController.h
 * @brief User upload his photo for photo feature through this view controller.
 */

#import <UIKit/UIKit.h>
#import "CustomRadioButton.h"
#import "PhotoPickerOriginalImage.h"
#import "Photo.h"

@interface UploadNewPhotoViewController : UIViewController<CustomRadioButtonDelegate, UITextFieldDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,PhotoPickerOriginalImageDelegate,UIScrollViewDelegate,UIImagePickerControllerDelegate>
{
    IBOutlet UIImageView *photoImageView;
    IBOutlet UIScrollView *mainScrollView;
    IBOutlet UIView *upperView;
    IBOutlet UIView *lowerView;
    IBOutlet UILabel *labelNotifCount;
    IBOutlet UILabel *addressLabel;
    IBOutlet UILabel *addressDetailLabel;
    PhotoPickerOriginalImage *photoPicker;
    UIImagePickerController *picSel;
    Photo *photo;
    IBOutlet UITextView *commentView;
    IBOutlet UIView *customView;
    IBOutlet UITableView *circleTableView;
    IBOutlet UIScrollView *frndsScrollView;
    IBOutlet UISegmentedControl *segmentControl;
    BOOL isDragging_msg;
    BOOL isDecliring_msg;
    IBOutlet UISearchBar *friendSearchbar;
}

@property(nonatomic,retain) IBOutlet UIImageView *photoImageView;
@property(nonatomic,retain) IBOutlet UIScrollView *mainScrollView;
@property(nonatomic,retain) IBOutlet UIView *upperView;
@property(nonatomic,retain) IBOutlet UIView *lowerView;    
@property(nonatomic,retain) IBOutlet UILabel *labelNotifCount;
@property(nonatomic,retain) IBOutlet UILabel *addressLabel;
@property(nonatomic,retain) IBOutlet UILabel *addressDetailLabel;
@property(nonatomic,retain) PhotoPickerOriginalImage *photoPicker;
@property(nonatomic,retain) UIImagePickerController *picSel;
@property(nonatomic,retain) Photo *photo;
@property(nonatomic,retain) IBOutlet UITextView *commentView;
@property(nonatomic,retain) IBOutlet UISearchBar *friendSearchbar;
@property (nonatomic,retain) IBOutlet UIView *customView;
@property (nonatomic,retain) IBOutlet UITableView *circleTableView;
@property (nonatomic,retain) IBOutlet UIScrollView *frndsScrollView;
@property (nonatomic,retain) IBOutlet UISegmentedControl *segmentControl;

/**
 * @brief Navigate user to my photo tab
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)myPhotos:(id)sender;

/**
 * @brief Image selection for user
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)addTakePhotos:(id)sender;

/**
 * @brief Upload the photo to server
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)uploadPhotos:(id)sender;

/**
 * @brief Cancel image upload and get back to my photo tab
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)cancel:(id)sender;

/**
 * @brief Navigate user to notification screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionNotificationButton:(id)sender;

/**
 * @brief Navigate user to previous screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)backButtonAction:(id)sender;

/**
 * @brief Change friend or circle selection option for custom sharing
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)segmentChanged:(id)sender;

/**
 * @brief Save custom sharing option
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)saveCustom:(id)sender;

/**
 * @brief Cancel custom sharing  option
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)cancelCustom:(id)sender;

@end

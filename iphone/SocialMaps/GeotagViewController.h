//
//  GeotagViewController.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 10/11/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file GeotagViewController.h
 * @brief Geotag created this view controller.
 */

#import <UIKit/UIKit.h>
#import "UserFriends.h"
#import "PhotoPicker.h"
#import "CustomRadioButton.h"
#import <Mapkit/Mapkit.h>

@interface GeotagViewController : UIViewController<UIPickerViewDataSource, 
UIPickerViewDelegate,
UITextFieldDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,PhotoPickerDelegate,MKMapViewDelegate,UIScrollViewDelegate,CustomRadioButtonDelegate>
{
    IBOutlet UILabel *createLabel;
    IBOutlet UIButton *createButton;
    
    IBOutlet UIButton *curLoc;
    IBOutlet UIButton *myPlace;    
    IBOutlet UIButton *neamePlace;
    IBOutlet UIButton *pointOnMap;    
    
    IBOutlet UIButton *private;
    IBOutlet UIButton *friends;
    IBOutlet UIButton *degreeFriends;    
    IBOutlet UIButton *people;
    IBOutlet UIButton *custom;        
    
    IBOutlet UIButton *nameButton;
    IBOutlet UIButton *summaryButton;    
    IBOutlet UIButton *descriptionButton;
    IBOutlet UIButton *dateButton;    
    IBOutlet UIButton *photoButton;
    IBOutlet UIButton *deleteButton; 
    IBOutlet UIImageView *eventImagview;
    
    IBOutlet UIButton *guestCanInviteButton;
    
    IBOutlet UIScrollView *frndListScrollView;
    IBOutlet UISearchBar *friendSearchbar;
    
    BOOL isDragging_msg;
    BOOL isDecliring_msg;
    NSMutableArray *ImgesName;
    
    CGFloat animatedDistance;
    NSMutableArray *selectedFriendsIndex, *customSelectedPhotoIndex;
    IBOutlet UIView *createView;
    PhotoPicker *photoPicker;
    UIImage *eventImage;
    UIImagePickerController *picSel;
    IBOutlet UITextField *entryTextField;
    IBOutlet MKMapView *mapView;
    IBOutlet UIView *mapContainerView;
    IBOutlet UILabel *addressLabel;
    IBOutlet UIView *circleView;
    IBOutlet UITableView *circleTableView;
    IBOutlet UIView *customSelectionView;
    IBOutlet UISegmentedControl *segmentControl;
    IBOutlet UIScrollView *customScrollView;
    IBOutlet UISearchBar *customSearchBar;
    IBOutlet UITableView *customTableView;
    
    IBOutlet UILabel *totalNotifCount;
    
    IBOutlet UIView *upperView;
    IBOutlet UIView *lowerView;    
    IBOutlet UIScrollView *viewContainerScrollView;
    IBOutlet UITextView *commentsView;
    IBOutlet UIScrollView *photoScrollView;
    
    IBOutlet UIButton *saveButton;
    IBOutlet UIButton *cancelButton;
    IBOutlet UIButton *deletePhotoButton;
    IBOutlet UIButton *uploadPhotoButton;
    IBOutlet UIView *zoomView;
    IBOutlet UITextField *titleTextField;
}

@property(nonatomic,retain) IBOutlet UILabel *createLabel;
@property(nonatomic,retain) IBOutlet UIButton *createButton;

@property(nonatomic,retain) IBOutlet UIButton *private;
@property(nonatomic,retain) IBOutlet UIButton *curLoc;
@property(nonatomic,retain) IBOutlet UIButton *myPlace;    
@property(nonatomic,retain) IBOutlet UIButton *neamePlace;
@property(nonatomic,retain) IBOutlet UIButton *pointOnMap;

@property(nonatomic,retain) IBOutlet UIButton *friends;
@property(nonatomic,retain) IBOutlet UIButton *degreeFriends;    
@property(nonatomic,retain) IBOutlet UIButton *people;
@property(nonatomic,retain) IBOutlet UIButton *custom;        

@property(nonatomic,retain) IBOutlet UIButton *nameButton;
@property(nonatomic,retain) IBOutlet UIButton *summaryButton;    
@property(nonatomic,retain) IBOutlet UIButton *descriptionButton;
@property(nonatomic,retain) IBOutlet UIButton *dateButton;    
@property(nonatomic,retain) IBOutlet UIButton *photoButton;
@property(nonatomic,retain) IBOutlet UIButton *deleteButton;    
@property(nonatomic,retain) IBOutlet UIImageView *eventImagview;

@property(nonatomic,retain) IBOutlet UIButton *guestCanInviteButton;
@property(nonatomic,retain) IBOutlet UIScrollView *frndListScrollView;
@property(nonatomic,retain) IBOutlet UISearchBar *friendSearchbar;

@property(nonatomic,retain) IBOutlet UIView *createView;
@property(nonatomic,retain) PhotoPicker *photoPicker;
@property(nonatomic,retain) UIImage *eventImage;
@property (nonatomic, retain) UIImagePickerController *picSel;

@property(nonatomic,retain) IBOutlet UITextField *entryTextField;
@property(nonatomic,retain) IBOutlet MKMapView *mapView;
@property(nonatomic,retain) IBOutlet UIView *mapContainerView;

@property(nonatomic,retain) IBOutlet UILabel *addressLabel;

@property(nonatomic,retain) IBOutlet UIView *circleView;
@property(nonatomic,retain) IBOutlet UITableView *circleTableView;

@property(nonatomic,retain) IBOutlet UIView *customSelectionView;
@property(nonatomic,retain) IBOutlet UISegmentedControl *segmentControl;

@property(nonatomic,retain) IBOutlet UIScrollView *customScrollView;
@property(nonatomic,retain) IBOutlet UISearchBar *customSearchBar;
@property(nonatomic,retain) IBOutlet UITableView *customTableView;

@property(nonatomic,retain) IBOutlet UILabel *totalNotifCount;

@property(nonatomic,retain) IBOutlet UIView *upperView;
@property(nonatomic,retain) IBOutlet UIView *lowerView;    
@property(nonatomic,retain) IBOutlet UIScrollView *viewContainerScrollView;    
@property(nonatomic,retain) IBOutlet UITextView *commentsView;
@property(nonatomic,retain) IBOutlet UIButton *line;
@property(nonatomic,retain) IBOutlet UIScrollView *photoScrollView;
@property(nonatomic,retain) IBOutlet UIButton *saveButton;
@property(nonatomic,retain) IBOutlet UIButton *cancelButton;
@property(nonatomic,retain) IBOutlet UIButton *deletePhotoButton;
@property(nonatomic,retain) IBOutlet UIButton *uploadPhotoButton;
@property(nonatomic,retain) IBOutlet UIView *zoomView;
@property(nonatomic,retain) IBOutlet UIButton *nextButton;
@property(nonatomic,retain) IBOutlet UIButton *prevButton;
@property(nonatomic,retain) IBOutlet UIScrollView *largePhotoScroller;
@property(nonatomic,retain) IBOutlet UITextField *titleTextField;

/**
 * @brief Save geotag name
 * @param (id) - Action sender
 * @retval action
 **/
-(IBAction)nameButtonAction;

/**
 * @brief Save geotag date
 * @param (id) - Action sender
 * @retval action
 **/
-(IBAction)dateButtonAction:(id)sender;

/**
 * @brief Save geotag photo
 * @param (id) - Action sender
 * @retval action
 **/
-(IBAction)photoButtonAction;

/**
 * @brief Save geotag categories
 * @param (id) - Action sender
 * @retval action
 **/
-(IBAction)categoriesButtonAction:(id)sender;

/**
 * @brief Remove geotag image
 * @param (id) - Action sender
 * @retval action
 **/
-(IBAction)deleteButtonAction;    

/**
 * @brief Save geotag sharing user circle
 * @param (id) - Action sender
 * @retval action
 **/
-(IBAction)showCircle:(id)sender;

/**
 * @brief Unselect all user
 * @param (id) - Action sender
 * @retval action
 **/
-(IBAction)unSelectAll:(id)sender;

/**
 * @brief Add all user
 * @param (id) - Action sender
 * @retval action
 **/
-(IBAction)addAll:(id)sender;

/**
 * @brief Save geotag
 * @param (id) - Action sender
 * @retval action
 **/
-(IBAction)createGeotag:(id)sender;

/**
 * @brief Cancel geotag
 * @param (id) - Action sender
 * @retval action
 **/
-(IBAction)cancelGeotag:(id)sender;

/**
 * @brief Save geotag entity
 * @param (id) - Action sender
 * @retval action
 **/
-(IBAction)saveEntity:(id)sender;

/**
 * @brief Cancel geotag cancel
 * @param (id) - Action sender
 * @retval action
 **/
-(IBAction)cancelEntity:(id)sender;

/**
 * @brief Save geotag map location
 * @param (id) - Action sender
 * @retval action
 **/
-(IBAction)saveMapLoc:(id)sender;

/**
 * @brief Cancel geotag map location
 * @param (id) - Action sender
 * @retval action
 **/
-(IBAction)cancelMapLoc:(id)sender;

/**
 * @brief Save geotag sharing circle
 * @param (id) - Action sender
 * @retval action
 **/
-(IBAction)saveCircle:(id)sender;

/**
 * @brief Cancel geotag sharing circle
 * @param (id) - Action sender
 * @retval action
 **/
-(IBAction)cancelCircle:(id)sender;

/**
 * @brief Save geotag sharing custom friends and circle
 * @param (id) - Action sender
 * @retval action
 **/
-(IBAction)saveCustom:(id)sender;

/**
 * @brief Cancel geotag sharing custom friends and circle
 * @param (id) - Action sender
 * @retval action
 **/
-(IBAction)cancelCustom:(id)sender;

/**
 * @brief Change custom segment
 * @param (id) - Action sender
 * @retval action
 **/
-(IBAction)customSegment:(id)sender;

/**
 * @brief Text input begin 
 * @param - Action sender
 * @retval action
 **/
-(void)beganEditing:(UISearchBar *)searchBar;

/**
 * @brief Text input end 
 * @param - Action sender
 * @retval action
 **/
-(void)endEditing;

/**
 * @brief Get back to previous screen 
 * @param - Action sender
 * @retval action
 **/
-(IBAction)backButton:(id)sender;

/**
 * @brief Navigate user to notification screen
 * @param (id) - Action sender
 * @retval action
 **/
-(IBAction)gotoNotification:(id)sender;

/**
 * @brief Save geotag comments
 * @param (id) - Action sender
 * @retval action
 **/
-(IBAction)saveComments:(id)sender;

/**
 * @brief Cancel geotag comments
 * @param (id) - Action sender
 * @retval action
 **/
-(IBAction)cancelComments:(id)sender;

/**
 * @brief Save geotag photo
 * @param (id) - Action sender
 * @retval action
 **/
-(IBAction)savePhoto:(id)sender;

/**
 * @brief Cancel geotag photo
 * @param (id) - Action sender
 * @retval action
 **/
-(IBAction)cancelPhoto:(id)sender;

/**
 * @brief Hide keyboard
 * @param (id) - Action sender
 * @retval action
 **/
-(IBAction)hideKeyboard:(id)sender;

@end
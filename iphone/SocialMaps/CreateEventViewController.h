//
//  CreateEventViewController.h
//  Event
//
//  Created by Abdullah Md. Zubair on 8/28/12.
//  Copyright (c) 2012 Genweb2 Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserFriends.h"
#import "PhotoPicker.h"
#import <Mapkit/Mapkit.h>
#import "Geolocation.h"
#import "CustomRadioButton.h"

@interface CreateEventViewController : UIViewController<UIPickerViewDataSource, 
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
    NSMutableArray *selectedFriendsIndex, *customSelectedFriendsIndex;
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
    NSString *venueAddress;
    Geolocation *geolocation;
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
@property(nonatomic,retain) NSString *venueAddress;
@property(nonatomic,retain) Geolocation *geolocation;

/**
 * @brief save event name
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)nameButtonAction;

/**
 * @brief save event sumary
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)summaryButtonAction;

/**
 * @brief save event description
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)descriptionButtonAction;

/**
 * @brief save event date
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)dateButtonAction:(id)sender;

/**
 * @brief save event photo
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)photoButtonAction;

/**
 * @brief delete event photo
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)deleteButtonAction;    

/**
 * @brief show user circle list
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)showCircle:(id)sender;

/**
 * @brief guest can invite friends
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)guestCanInvite:(id)sender;

/**
 * @brief unselect all friends
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)unSelectAll:(id)sender;

/**
 * @brief add all friends
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)addAll:(id)sender;

/**
 * @brief creates an event
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)createEvent:(id)sender;

/**
 * @brief cancel an event
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)cancelEvent:(id)sender;

/**
 * @brief save event entity
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)saveEntity:(id)sender;

/**
 * @brief cancel event entity
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)cancelEntity:(id)sender;

/**
 * @brief save event map location
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)saveMapLoc:(id)sender;

/**
 * @brief cancel event map location
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)cancelMapLoc:(id)sender;

/**
 * @brief save invited circle
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)saveCircle:(id)sender;

/**
 * @brief cancel invited circle
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)cancelCircle:(id)sender;

/**
 * @brief save custom invited guest
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)saveCustom:(id)sender;

/**
 * @brief cancel custom invited guest
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)cancelCustom:(id)sender;

/**
 * @brief manage segment for inviting friends or circle 
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)customSegment:(id)sender;

/**
 * @brief control begin editing, move textfield if that hides by keyboard
 * @param (id) - action sender
 * @retval action
 */
-(void)beganEditing:(UISearchBar *)searchBar;

/**
 * @brief control end editing, move textfield to original position if that hides by keyboard
 * @param (id) - action sender
 * @retval action
 */
-(void)endEditing;

/**
 * @brief navigate user to previous screen
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)backButton:(id)sender;

/**
 * @brief navigate user to notification screen
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)gotoNotification:(id)sender;

@end

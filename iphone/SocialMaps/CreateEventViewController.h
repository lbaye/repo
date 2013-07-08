//
//  CreateEventViewController.h
//  Event
//
//  Created by Abdullah Md. Zubair on 8/28/12.
//  Copyright (c) 2012 Genweb2 Limited. All rights reserved.
//

/**
 * @file CreateEventViewController.h
 * @brief Event created and updated through this view controller.
 */

#import <UIKit/UIKit.h>
#import "UserFriends.h"
#import "PhotoPicker.h"
#import <Mapkit/Mapkit.h>
#import "Geolocation.h"
#import "CustomRadioButton.h"

@interface CreateEventViewController : UIViewController<UITextFieldDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,PhotoPickerDelegate,MKMapViewDelegate,UIScrollViewDelegate,CustomRadioButtonDelegate>
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
 * @brief Save event name
 * @param (id) - Action sender
 * @retval Action
 */
-(IBAction)nameButtonAction;

/**
 * @brief Save event sumary
 * @param (id) - Action sender
 * @retval Action
 */
-(IBAction)summaryButtonAction;

/**
 * @brief Save event description
 * @param (id) - Action sender
 * @retval Action
 */
-(IBAction)descriptionButtonAction;

/**
 * @brief Save event date
 * @param (id) - Action sender
 * @retval Action
 */
-(IBAction)dateButtonAction:(id)sender;

/**
 * @brief Save event photo
 * @param (id) - Action sender
 * @retval Action
 */
-(IBAction)photoButtonAction;

/**
 * @brief Delete event photo
 * @param (id) - Action sender
 * @retval Action
 */
-(IBAction)deleteButtonAction;    

/**
 * @brief Show user circle list
 * @param (id) - Action sender
 * @retval Action
 */
-(IBAction)showCircle:(id)sender;

/**
 * @brief Guest can invite friends
 * @param (id) - Action sender
 * @retval Action
 */
-(IBAction)guestCanInvite:(id)sender;

/**
 * @brief Unselect all friends
 * @param (id) - Action sender
 * @retval Action
 */
-(IBAction)unSelectAll:(id)sender;

/**
 * @brief Add all friends
 * @param (id) - Action sender
 * @retval Action
 */
-(IBAction)addAll:(id)sender;

/**
 * @brief Creates an event
 * @param (id) - Action sender
 * @retval Action
 */
-(IBAction)createEvent:(id)sender;

/**
 * @brief Cancel an event
 * @param (id) - Action sender
 * @retval Action
 */
-(IBAction)cancelEvent:(id)sender;

/**
 * @brief Save event entity
 * @param (id) - Action sender
 * @retval Action
 */
-(IBAction)saveEntity:(id)sender;

/**
 * @brief Cancel event entity
 * @param (id) - Action sender
 * @retval Action
 */
-(IBAction)cancelEntity:(id)sender;

/**
 * @brief Save event map location
 * @param (id) - Action sender
 * @retval Action
 */
-(IBAction)saveMapLoc:(id)sender;

/**
 * @brief Cancel event map location
 * @param (id) - Action sender
 * @retval Action
 */
-(IBAction)cancelMapLoc:(id)sender;

/**
 * @brief Save invited circle
 * @param (id) - Action sender
 * @retval Action
 */
-(IBAction)saveCircle:(id)sender;

/**
 * @brief Cancel invited circle
 * @param (id) - Action sender
 * @retval Action
 */
-(IBAction)cancelCircle:(id)sender;

/**
 * @brief Save custom invited guest
 * @param (id) - Action sender
 * @retval Action
 */
-(IBAction)saveCustom:(id)sender;

/**
 * @brief Cancel custom invited guest
 * @param (id) - Action sender
 * @retval Action
 */
-(IBAction)cancelCustom:(id)sender;

/**
 * @brief Manage segment for inviting friends or circle 
 * @param (id) - Action sender
 * @retval Action
 */
-(IBAction)customSegment:(id)sender;

/**
 * @brief Control begin editing, move textfield if that hides by keyboard
 * @param (id) - Action sender
 * @retval Action
 */
-(void)beganEditing:(UISearchBar *)searchBar;

/**
 * @brief Control end editing, move textfield to original position if that hides by keyboard
 * @param (id) - Action sender
 * @retval Action
 */
-(void)endEditing;

/**
 * @brief Navigate user to previous screen
 * @param (id) - Action sender
 * @retval Action
 */
-(IBAction)backButton:(id)sender;

/**
 * @brief Navigate user to notification screen
 * @param (id) - Action sender
 * @retval Action
 */
-(IBAction)gotoNotification:(id)sender;

@end

//
//  ViewEventDetailViewController.h
//  Event
//
//  Created by Abdullah Md. Zubair on 8/23/12.
//  Copyright (c) 2012 Genweb2 Limited. All rights reserved.
//

/**
 * @file ViewEventDetailViewController.h
 * @brief Display an event detail through this view controller.
 */

#import <UIKit/UIKit.h>
#import <Mapkit/Mapkit.h>
#import "CustomRadioButton.h"

@interface ViewEventDetailViewController : UIViewController<UIScrollViewDelegate,CustomRadioButtonDelegate>
{
    IBOutlet UILabel *eventName;
    IBOutlet UILabel *eventDate;
    IBOutlet UILabel *eventShortDetail;
    IBOutlet UILabel *eventAddress;
    IBOutlet UILabel *eventDistance;
    IBOutlet UIImageView *eventImgView;
    
    IBOutlet UIButton *yesButton;
    IBOutlet UIButton *noButton;
    IBOutlet UIButton *maybeButton;    
    IBOutlet UITextView *descriptionView;
    
    IBOutlet UIScrollView *guestScrollView;
    IBOutlet UIView *rsvpView;
    IBOutlet UIView *detailView;
    
    BOOL isDragging_msg,isDecliring_msg;
    NSMutableArray *imagesName; 
    
    IBOutlet UIView *mapContainer;
    IBOutlet MKMapView *mapView;
    
    IBOutlet UIButton *editEventButton;
    IBOutlet UIButton *deleteEventButton;    
    IBOutlet UIButton *inviteEventButton;
    BOOL isBackgroundTaskRunning;
    IBOutlet UILabel *totalNotifCount;
    IBOutlet UIScrollView *addressScollview;
    IBOutlet UIScrollView *frndsScrollView;
    IBOutlet UITableView *circleTableView;
    IBOutlet UISearchBar *friendSearchbar;
    IBOutlet UISegmentedControl *segmentControl;
    IBOutlet UIView *customView;
}

@property(nonatomic,retain) IBOutlet UILabel *eventName;
@property(nonatomic,retain) IBOutlet UILabel *eventDate;
@property(nonatomic,retain) IBOutlet UILabel *eventShortDetail;
@property(nonatomic,retain) IBOutlet UILabel *eventAddress;
@property(nonatomic,retain) IBOutlet UILabel *eventDistance;    
@property(nonatomic,retain) IBOutlet UIImageView *eventImgView;
@property(nonatomic,retain) IBOutlet UIScrollView *addressScollview;
@property(nonatomic,retain) IBOutlet UIButton *yesButton;
@property(nonatomic,retain) IBOutlet UIButton *noButton;
@property(nonatomic,retain) IBOutlet UIButton *maybeButton;
@property(nonatomic,retain) IBOutlet UITextView *descriptionView;

@property(nonatomic,retain) IBOutlet UIScrollView *guestScrollView;
@property(nonatomic,retain) IBOutlet UIView *rsvpView;
@property(nonatomic,retain) IBOutlet UIView *detailView;

@property(nonatomic,retain) NSDictionary *results;
@property(nonatomic,retain) NSMutableArray *imagesName;

@property(nonatomic,retain) IBOutlet UIView *mapContainer;
@property(nonatomic,retain) IBOutlet MKMapView *mapView;

@property(nonatomic,retain) IBOutlet UIButton *editEventButton;
@property(nonatomic,retain) IBOutlet UIButton *deleteEventButton;    
@property(nonatomic,retain) IBOutlet UIButton *inviteEventButton;     
@property(nonatomic,retain) IBOutlet UILabel *totalNotifCount;
@property(nonatomic,retain) IBOutlet UIScrollView *frndsScrollView;
@property(nonatomic,retain) IBOutlet UITableView *circleTableView;
@property(nonatomic,retain) IBOutlet UISearchBar *friendSearchbar;
@property(nonatomic,retain) IBOutlet UISegmentedControl *segmentControl;
@property(nonatomic,retain) IBOutlet UIView *customView;

/**
 * @brief download event image
 * @param downloading index
 * @retval none
 */
-(void)DownLoad:(NSNumber *)path;

/**
 * @brief reloads guest scroll view
 * @param downloading index
 * @retval none
 */
-(void) reloadScrolview;

/**
 * @brief show event location on map
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)viewMapButton:(id)sender;

/**
 * @brief show guest list
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)guestList:(id)sender;

/**
 * @brief invite more people to event
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)invitePeople:(id)sender;

/**
 * @brief delete evnt
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)deleteEvent:(id)sender;

/**
 * @brief edit event
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)editEvent:(id)sender;

/**
 * @brief closes map view for event on map
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)closeMap:(id)sender;

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

/**
 * @brief segement changes for invite more people screen
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)segmentChanged:(id)sender;

/**
 * @brief save invited custom data
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)saveCustom:(id)sender;

/**
 * @brief cancel custom invitation
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)cancelCustom:(id)sender;

@end

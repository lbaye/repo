//
//  ViewEventListViewController.h
//  Event
//
//  Created by Abdullah Md. Zubair on 8/24/12.
//  Copyright (c) 2012 Genweb2 Limited. All rights reserved.
//

/**
 * @file ViewEventListViewController.h
 * @brief Display event list through this view controller.
 */

#import <UIKit/UIKit.h>
#import <Mapkit/Mapkit.h>
#import "EventImageDownloader.h"
#import "CustomRadioButton.h"

@interface ViewEventListViewController : UIViewController<EventImageDownloaderDelegate,CustomRadioButtonDelegate>
{
    IBOutlet UITableView *eventListTableView;
    IBOutlet UISearchBar *eventSearchBar;
    bool rsvpFlag;
    IBOutlet NSDictionary *downloadedImageDict;
    IBOutlet NSMutableDictionary *dicIcondownloaderEvents;
    IBOutlet UIView *mapContainer;
    IBOutlet MKMapView *mapView;
    IBOutlet UIButton *newEventButton;
    
    IBOutlet UIButton *dateButton;
    IBOutlet UIButton *distanceButton;
    IBOutlet UIButton *friendsEventButton;
    IBOutlet UIButton *myEventButton;
    IBOutlet UIButton *publicEventButton;
    IBOutlet UILabel *totalNotifCount;

}
@property(nonatomic,retain) IBOutlet UITableView *eventListTableView;
@property(nonatomic,retain) IBOutlet UISearchBar *eventSearchBar;
@property(nonatomic,retain) IBOutlet NSDictionary *downloadedImageDict;
@property(nonatomic,retain) IBOutlet NSMutableDictionary *dicIcondownloaderEvents;
@property(nonatomic,retain) IBOutlet UIView *mapContainer;
@property(nonatomic,retain) IBOutlet MKMapView *mapView;
@property(nonatomic,retain) IBOutlet UIButton *newEventButton;

@property(nonatomic,retain) IBOutlet UIButton *dateButton;
@property(nonatomic,retain) IBOutlet UIButton *distanceButton;
@property(nonatomic,retain) IBOutlet UIButton *friendsEventButton;
@property(nonatomic,retain) IBOutlet UIButton *myEventButton;
@property(nonatomic,retain) IBOutlet UIButton *publicEventButton;
@property(nonatomic,retain) IBOutlet UILabel *totalNotifCount;

/**
 * @brief sort event list according to date
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)dateAction:(id)sender;

/**
 * @brief sort event list according to distance
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)distanceAction:(id)sender;

/**
 * @brief filter friends event
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)friendsEventAction:(id)sender;

/**
 * @brief filter user's event
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)myEventAction:(id)sender;

/**
 * @brief filter public event
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)publicEventAction:(id)sender;

/**
 * @brief creates new event
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)newEventAction:(id)sender;

/**
 * @brief view event on map view
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)viewLocationButton:(id)sender;

/**
 * @brief closes map view for event on map
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)closeMapView:(id)sender;

/**
 * @brief navigate user to previous screen
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)backButton:(id)sender;

/**
 * @brief load data for event list
 * @param (id) - action sender
 * @retval action
 */
-(NSMutableArray *)loadDummyData;

/**
 * @brief set images if event image downloaded from an url.
 * @param (id) - action sender
 * @retval action
 */
- (void)appImageDidLoad:(NSString *)eventID;

/**
 * @brief navigate user to notification screen
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)gotoNotification:(id)sender;

@end

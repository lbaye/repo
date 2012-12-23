//
//  MeetUpRequestController.h
//  SocialMaps
//
//  Created by Warif Rishi on 9/8/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//


/**
 * @file MeetUpRequestController.h
 * @brief Send meetup request to specific friends.
 */

#import <UIKit/UIKit.h>
#import "CustomRadioButton.h"
#import <Mapkit/Mapkit.h>
#import "IconDownloader.h"

@class AppDelegate;
@class LocationItemPlace;

@interface MeetUpRequestController : UIViewController <CustomRadioButtonDelegate, UIScrollViewDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, IconDownloaderDelegate> {
    
    IBOutlet UILabel *labelAddress;
    IBOutlet UIScrollView *frndListScrollView;
    IBOutlet UISearchBar  *friendSearchbar;
    IBOutlet MKMapView *pointOnMapView;
    IBOutlet UITableView *tableViewPlaces;
    IBOutlet UITextView *textViewPersonalMsg;
    IBOutlet UIView *viewComposePersonalMsg;
    
    NSMutableArray *selectedFriendsIndex;
    BOOL isDragging_msg;
    BOOL isDecliring_msg;
    CGFloat animatedDistance;
    NSMutableDictionary *dicImages_msg;
    NSMutableArray *ImgesName;
    
    AppDelegate *smAppDelegate;
    int selectedPlaceIndex;
    NSMutableArray *myPlacesArray;
    NSString *currentAddress;
    
    NSString    *selectedfriendId;
    LocationItemPlace    *selectedLocatonItem;
    IBOutlet UILabel *totalNotifCount;
}

@property (nonatomic, retain) NSString *currentAddress;
@property (nonatomic, retain) NSString *selectedfriendId;
@property (nonatomic, retain) LocationItemPlace *selectedLocatonItem;
@property(nonatomic,retain) IBOutlet UILabel *totalNotifCount;

/**
 * @brief Navigate user to previous screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionBackMe:(id)sender;

/**
 * @brief Send meetup request and goto previous screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionMeetUpReqButton:(id)sender;

/**
 * @brief Select all friends for sending meetup request
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionSelectAll:(id)sender;

/**
 * @brief Cancel sending meetup request and goto previous screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionCancelButton:(id)sender;

/**
 * @brief Write a personal message
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionAddPersonalMsgBtn:(id)sender;

/**
 * @brief Save personal message
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionSavePersonalMsgBtn:(id)sender;

@end

//
//  ListViewController.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/13/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file ListViewController.h
 * @brief Display people, place and event list, filter and search them. User can also view circle menu and navigate to different feature
 */

#import <UIKit/UIKit.h>
#import "CustomCheckbox.h"
#import "LocationItem.h"
#import "LocationItemPlace.h"
#import "AppDelegate.h"
#import "PullableView.h"

@class OverlayViewController;

#define SECTION_HEADER_HEIGHT   44

@interface ListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CustomCheckboxDelegate, LocationItemDelegate, PullableViewDelegate> {
    OBJECT_TYPES   selectedType;
    int             selectedItemIndex;
    AppDelegate     *smAppDelegate;
    IBOutlet UILabel *totalNotifCount;
    BOOL						searching;
    OverlayViewController		*ovController;
    BOOL						letUserSelectRow;
    NSMutableArray				*copyListOfItems;
    IBOutlet UISearchBar *searchBar;
    IBOutlet UIView *viewSearch;
    
    IBOutlet UIView *viewNotification;
    PullableView *pullDownView;
    NSMutableArray *copyDisplayListArray;
    IBOutlet UIImageView *mapViewImg;
    IBOutlet UIImageView *listViewImg;
}
@property (nonatomic) OBJECT_TYPES selectedType;
@property (nonatomic) int selectedItemIndex;
@property (nonatomic, retain) AppDelegate *smAppDelegate;

@property (nonatomic,retain)  IBOutlet UIView  *circleView;
@property (retain, nonatomic) IBOutlet UIView *listPullupMenu;
@property (retain, nonatomic) IBOutlet UIView *listPulldownMenu;
@property (retain, nonatomic) IBOutlet UIView *listViewfilter;
@property (retain, nonatomic) IBOutlet UIView *listView;
@property (retain, nonatomic) IBOutlet UIButton *listPulldown;
@property (retain, nonatomic) IBOutlet UITableView *itemList;
@property (retain, nonatomic) IBOutlet UILabel *listNotifCount;
@property(nonatomic,retain) IBOutlet UILabel *totalNotifCount;
@property(nonatomic,retain) IBOutlet UIImageView *mapViewImg;
@property(nonatomic,retain) IBOutlet UIImageView *listViewImg;

/**
 * @brief Navigate user to map screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)backToMapview:(id)sender;

/**
 * @brief Closes pull up menu
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)closePullup:(id)sender;

/**
 * @brief Closes pull down menu
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)closePulldown:(id)sender;

/**
 * @brief Show pull up menu
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)showPullUpMenu:(id)sender;

/**
 * @brief Show pull down menu
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)showPulldownMenu:(id)sender;

/**
 * @brief Navigate user to notification screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)goToNotifications:(id)sender;

/**
 * @brief Navigate user to notification screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoNotification:(id)sender;

/**
 * @brief Delegate method of custom checkbox, uses in this view for filtering people, place and events
 * @param (int) - Button number of checkbox group
 * @param (int) - New state of checkbox
 * @param (id) - Action sender
 * @retval action
 */
- (void) checkboxClicked:(int)btnNum withState:(int) newState sender:(id) sender;

/**
 * @brief Sort item list according to distance
 * @param none
 * @retval none
 */
- (void) getSortedDisplayList;

/**
 * @brief Detect button click and perform action accordingly
 * @param (LOCATION_ACTION_TYPE) - Which type of item selected people, place or event 
 * @param (int) - Index of tapped button
 * @retval none
 */
- (void) buttonClicked:(LOCATION_ACTION_TYPE) action row:(int)row;

/**
 * @brief Navigate user to profile screen
 * @param (id) - Action sender
 * @retval none
 */
- (IBAction)gotoProfile:(id)sender;

/**
 * @brief Searching end
 * @param (id) - Action sender
 * @retval none
 */
- (void) doneSearching_Clicked:(id)sender;

/**
 * @brief Search nutton action
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionSearchButton:(id)sender;

/**
 * @brief Search button ok action
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionSearchOkButton:(id)sender;

/**
 * @brief Navigate user to events
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoEvents:(id)sender;

/**
 * @brief Navigate user to messages
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoMessages:(id)sender;

/**
 * @brief Navigate user to own profile from circle menu
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoUserBasicProfile:(id)sender;

/**
 * @brief Navigate user to settings screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoSettings:(id)sender;

/**
 * @brief Navigate user to meetup screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoMeetupReq:(id)sender;

/**
 * @brief Navigate user to circles tab
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoCircles:(id)sender;

/**
 * @brief Remove circle menu
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)removeCircleView:(id)sender;

/**
 * @brief Navigate user to place list screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoPlace:(id)sender;

/**
 * @brief Navigate user to friend list screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoFriends:(id)sender;

/**
 * @brief Navigate user to newsfeed screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotonNewsFeed:(id)sender;

/**
 * @brief Navigate user to deals screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotonDeals:(id)sender;

/**
 * @brief Select List view
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)selectListView:(id)sender;
/**
 * @brief Load images for onscreen images
 * @param none
 * @retval none
 */

- (void)loadImagesForOnscreenRows;

@end

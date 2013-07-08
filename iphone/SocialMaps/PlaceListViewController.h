//
//  PlaceListViewController.h
//  SocialMaps
//
//  Created by Warif Rishi on 11/3/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file PlaceListViewController.h
 * @brief Show list of places for a specific user.
 */

#import <UIKit/UIKit.h>

@class Place;
@class AppDelegate;
@class OverlayViewController;

typedef enum _PLACE_TYPES {
    Own=0,
    OtherPeople
} PLACE_TYPES;

@interface PlaceListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    IBOutlet    UITableView *tableViewPlaceList;
    IBOutlet    UILabel     *totalNotifCount;
    IBOutlet    UIView      *viewSearch;
    IBOutlet    UISearchBar *searchBar;
    IBOutlet    UILabel     *labelNearToMe;
    IBOutlet    UILabel     *labelPlaces;
    IBOutlet    UIButton    *buttonPlaces;
    IBOutlet    UIButton    *buttonNearToMe;
    IBOutlet    UIImageView *imageViewDivider;
    IBOutlet    UIView      *viewTabContainer;
    
    AppDelegate         *smAppDelegate;
    
    BOOL						searching;
    OverlayViewController		*ovController;
    NSMutableArray				*copyListOfItems;
}

@property (atomic) PLACE_TYPES placeType;
@property (nonatomic, retain) NSString *otherUserId;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSMutableArray *placeList;

/**
 * @brief Navigate user to previous screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionBackMe:(id)sender;

/**
 * @brief Navigate user to notification screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoNotification:(id)sender;

/**
 * @brief Pressed ok button of search bar
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionOkSearchButton:(id)sender;

/**
 * @brief Show search bar
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionShowSearchBarButton:(id)sender;

/**
 * @brief Display user's saved places
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionPlacesButton:(id)sender;

/**
 * @brief Display own user nearby places
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionNearToMeButton:(id)sender;

/**
 * @brief Delete place if user delete place from the edit screen
 * @param (Place) - Place which will be deleted
 * @retval none
 */
-(void) deletePlace:(Place*)place;

/**
 * @brief Load cover images of visible cells
 * @param none
 * @retval none
 */
-(void) loadImagesForOnscreenRows; 

/**
 * @brief Display the total notification number
 * @param none
 * @retval none
 */
-(void) displayNotificationCount;

/**
 * @brief Reload the place list table view
 * @param none
 * @retval none
 */
-(void) reloadTableView;

@end

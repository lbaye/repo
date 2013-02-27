//
//  MapViewController.h
//  SocialMaps
//
//  Created by Arif Shakoor on 7/23/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file MapViewController.h
 * @brief Display all user, places, events and geotag on map view. User can navigate to other user's profile and can also navigate to different feature to different 
 */

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CLLocationManager.h>
#import "IconDownloader.h"
#import "AppDelegate.h"
#import "MapAnnotation.h"
#import "MapAnnotationPeople.h"
#import "MapAnnotationPlace.h"
#import "MapAnnotationEvent.h"
#import "PullableView.h"
#import "CustomRadioButton.h"
#import "Plan.h"
#define METERS_PER_MILE 1609.344

typedef enum _SHARING_TYPES {
    All = 0,
    Friends,
    None,
    Circles,
    Custom
} SHARING_TYPES;

@interface MapViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate,
                                UITextFieldDelegate, UITextViewDelegate,UIPickerViewDataSource, 
                                UIPickerViewDelegate,UIScrollViewDelegate, 
                                MapAnnotationDelegate,
                                UIGestureRecognizerDelegate, PullableViewDelegate, CustomRadioButtonDelegate>
{
    BOOL _doneInitialZoom;
    CLLocationManager   *locationManager;
    SHARING_TYPES       selSharingType;

    NSMutableArray      *savedFilters;
    UIPickerView        *pickSavedFilter;
    IBOutlet UIView *inviteFriendView;
    IBOutlet UITableView *inviteFrndTableView;
    IBOutlet UISearchBar *friendSearchBar;
    AppDelegate         *smAppDelegate;
    MapAnnotation *mapAnno;
    MapAnnotationPeople *mapAnnoPeople;
    MapAnnotationPlace *mapAnnoPlace;
    NSMutableArray *filteredList;
    MapAnnotation *selectedAnno;
                                    
    PullableView *pullDownView;                                    
    PullableView *pullUpView;
    IBOutlet UIButton *buttonListView;
    IBOutlet UIButton *buttonProfileView;
    IBOutlet UIButton *buttonMapView;
    IBOutlet UIImageView *imageViewSliderOpenClose;
    IBOutlet UIView *viewNotification;
    IBOutlet UIView *viewSearch;
    IBOutlet UISearchBar *searchBar;
    NSMutableArray		*copySearchAnnotationList;
    IBOutlet UIView *circleView;
    BOOL isFirstTimeDownloading;
    MapAnnotationEvent *mapAnnoEvent;
    IBOutlet UIView *connectToFBView;
    IBOutlet UIView *viewSharingPrefMapPullDown;
    CustomRadioButton *radio;
    BOOL shouldTimerStop;
    IBOutlet UIImageView *mapViewImg;
    IBOutlet UIImageView *listViewImg;
                                    
    NSMutableArray *displayListForMap;
    BOOL shouldMainDisplayListChange;
}

@property (retain, nonatomic) IBOutlet MKMapView *mapView;
@property (retain, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) SHARING_TYPES selSharingType;
@property (nonatomic, retain) NSMutableArray *savedFilters;
@property (nonatomic, retain) UIPickerView *pickSavedFilter;
@property (nonatomic, retain) AppDelegate *smAppDelegate;
@property (nonatomic, retain) MapAnnotation *mapAnno;
@property (nonatomic, retain) MapAnnotation *mapAnnoPeople;
@property (nonatomic, retain) MapAnnotation *mapAnnoPlace;
@property (nonatomic, retain) MapAnnotationEvent *mapAnnoEvent;
@property (nonatomic, retain) NSMutableArray *filteredList;
@property (nonatomic, retain) MapAnnotation *selectedAnno;

@property (retain, nonatomic) IBOutlet UIView *mapPulldown;
@property (retain, nonatomic) IBOutlet UIButton *shareAllButton;
@property (retain, nonatomic) IBOutlet UIButton *shareFriendsButton;
@property (retain, nonatomic) IBOutlet UIButton *shareNoneButton;
@property (retain, nonatomic) IBOutlet UIButton *shareCircleButton;
@property (retain, nonatomic) IBOutlet UIButton *shareCustomButton;
@property (retain, nonatomic) IBOutlet UIButton *showPeopleButton;
@property (retain, nonatomic) IBOutlet UIButton *showPlacesButton;
@property (retain, nonatomic) IBOutlet UIButton *showDealsButton;
@property (retain, nonatomic) IBOutlet UIButton *mapNotifBubble;
@property (retain, nonatomic) IBOutlet UILabel *mapNotifCount;
@property (retain, nonatomic) IBOutlet UITextField *selSavedFilter;
@property (retain, nonatomic) IBOutlet UILabel *selectedFilter;
@property (retain, nonatomic) IBOutlet UIView *mapPullupMenu;
@property(nonatomic,retain) IBOutlet UIView *inviteFriendView;
@property(nonatomic,retain) IBOutlet UITableView *inviteFrndTableView;
@property(nonatomic,retain) IBOutlet UISearchBar *friendSearchBar;
@property(nonatomic,retain) IBOutlet UIView *circleView;
@property(nonatomic,retain) IBOutlet UIView *connectToFBView;
@property(nonatomic,retain) IBOutlet UIImageView *mapViewImg;
@property(nonatomic,retain) IBOutlet UIImageView *listViewImg;


/**
 * @brief Show pull down menu
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)showPullDown:(id)sender;

/**
 * @brief Hides pull down menu
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)hidePulldown:(id)sender;

/**
 * @brief Navigate user to my places screen
 * @param (id) - Action sender
 * @retval action
 */ 
- (IBAction)gotoMyPlaces:(id)sender;

/**
 * @brief Navigate user to directions screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoDirections:(id)sender;

/**
 * @brief Navigate user to breadcrumbs screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoBreadcrumbs:(id)sender;

/**
 * @brief Navigate user to checkins screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoCheckins:(id)sender;

/**
 * @brief Navigate user to meet up request screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoMeetupReq:(id)sender;

/**
 * @brief Navigate user to mapix screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoMapix:(id)sender;

/**
 * @brief Navigate user to filter editing screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoEditFilters:(id)sender;

/**
 * @brief Applies user defined filter
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)applyFilter:(id)sender;

/**
 * @brief Check people in filter checkbox group
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)peopleClicked:(id)sender;

/**
 * @brief Check places in filter checkbox group
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)placesClicked:(id)sender;

/**
 * @brief Check deals in filter checkbox group
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)dealsClicked:(id)sender;

/**
 * @brief Set location sharing with all people
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)shareWithAll:(id)sender;

/**
 * @brief Set location sharing with friends
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)shareWithFriends:(id)sender;

/**
 * @brief Set location sharing with none
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)shareWithNone:(id)sender;

/**
 * @brief Set location sharing with circle
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)shareWithCircles:(id)sender;

/**
 * @brief Set location sharing with custom friends and circles
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)shareWithCustom:(id)sender;

/**
 * @brief Show pull up menu
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)showPullupMenu:(id)sender;

/**
 * @brief Close pull up menu
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)closePullupMenu:(id)sender;

/**
 * @brief Navigate user to profile screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoProfile:(id)sender;

/**
 * @brief Navigate user to circle tab
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoCircle:(id)sender;

/**
 * @brief Navigate user to settings screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoSettings:(id)sender;

/**
 * @brief Reset share option
 * @param (SHARING_TYPES) - Share option
 * @retval none
 */
- (void) resetShareButton:(SHARING_TYPES)newSel;

/**
 * @brief Changes an annotation
 * @param (MKAnnotation) - Action sender
 * @retval none
 */
- (void) mapAnnotationChanged:(id <MKAnnotation>) anno;

/**
 * @brief Displays total notification number
 * @param none
 * @retval none
 */
- (void) displayNotificationCount;

/**
 * @brief Sort display data list
 * @param none
 * @retval none
 */
- (void) getSortedDisplayList;

/**
 * @brief Map annotation info updated
 * @param (id) - Map annotation
 * @retval none
 */
- (void) mapAnnotationInfoUpdated:(id <MKAnnotation>) anno;

/**
 * @brief Show or hide searchbar
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionShowHideSearchBtn:(id)sender;

/**
 * @brief Show circle menu
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)addCircleView:(id)sender;

/**
 * @brief Remove circle menu
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)removeCircleView:(id)sender;

/**
 * @brief Navigate user to own profile screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoBasicProfile:(id)sender;

/**
 * @brief Navigate user to settings screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoSettings:(id)sender;

/**
 * @brief Navigate user to places screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoPlace:(id)sender;

/**
 * @brief Navigate user to friends list screen
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
 * @brief Loads all annotations for events
 * @param none
 * @retval none
 */
- (void)loadAnnotationForEvents;

/**
 * @brief Make user's connection with facebook
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)connectWithFB:(id)sender;

/**
 * @brief Closes connectwith facebook view
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)closeConnectWithFB:(id)sender;

/**
 * @brief Selection of map view on pull down menu
 * @param (id) - Action sender
 * @retval none
 */

- (IBAction)selectMapView:(id)sender;

/**
 * @brief Selection of list view on pull down menu
 * @param (id) - Action sender
 * @retval none
 */

- (IBAction)selectListView:(id)sender;

/**
 * @brief Show pin for point on map option of map view
 * @param (id) - Action sender
 * @retval none
 */

- (void) showPinOnMapViewForPlan:(Plan*)plan;

/**
 * @brief Display summary view of an annotation
 * @param (id) - Action sender
 * @retval none
 */
- (void) showAnnotationDetailView:(id <MKAnnotation>) anno;

@end

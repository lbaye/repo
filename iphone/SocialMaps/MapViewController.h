//
//  MapViewController.h
//  SocialMaps
//
//  Created by Arif Shakoor on 7/23/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CLLocationManager.h>
#import "IconDownloader.h"
#import "AppDelegate.h"
#import "MapAnnotationPeople.h"

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
                                MapAnnotationDelegate, IconDownloaderDelegate> {
    BOOL _doneInitialZoom;
    CLLocationManager   *locationManager;
    SHARING_TYPES       selSharingType;
    bool                showPeople;
    bool                showPlaces;
    bool                showDeals;
    NSMutableArray      *savedFilters;
    UIPickerView        *pickSavedFilter;
    IBOutlet UIView *inviteFriendView;
    IBOutlet UITableView *inviteFrndTableView;
    IBOutlet UISearchBar *friendSearchBar;
//    NSMutableDictionary *imageDownloadsInProgress; 
    AppDelegate         *smAppDelegate;
    MapAnnotation *mapAnno;
    MapAnnotationPeople *mapAnnoPeople;
    bool needToCenterMap;
}

@property (retain, nonatomic) IBOutlet MKMapView *mapView;
@property (retain, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) SHARING_TYPES selSharingType;
@property (nonatomic) bool showPeople;
@property (nonatomic) bool showPlaces;
@property (nonatomic) bool showDeals;
@property (nonatomic, retain) NSMutableArray *savedFilters;
@property (nonatomic, retain) UIPickerView *pickSavedFilter;
@property (nonatomic, retain) AppDelegate *smAppDelegate;
@property (nonatomic, retain) MapAnnotation *mapAnno;
@property (nonatomic, retain) MapAnnotation *mapAnnoPeople;
@property (atomic) bool needToCenterMap;

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
//@property(nonatomic,retain) NSMutableDictionary *imageDownloadsInProgress; 

- (IBAction)showPullDown:(id)sender;
- (IBAction)hidePulldown:(id)sender;
- (IBAction)gotoMyPlaces:(id)sender;
- (IBAction)gotoDirections:(id)sender;
- (IBAction)gotoBreadcrumbs:(id)sender;
- (IBAction)gotoCheckins:(id)sender;
- (IBAction)gotoMeetupReq:(id)sender;
- (IBAction)gotoMapix:(id)sender;
- (IBAction)gotoEditFilters:(id)sender;
- (IBAction)applyFilter:(id)sender;
- (IBAction)peopleClicked:(id)sender;
- (IBAction)placesClicked:(id)sender;
- (IBAction)dealsClicked:(id)sender;
- (IBAction)shareWithAll:(id)sender;
- (IBAction)shareWithFriends:(id)sender;
- (IBAction)shareWithNone:(id)sender;
- (IBAction)shareWithCircles:(id)sender;
- (IBAction)shareWithCustom:(id)sender;
- (IBAction)showPullupMenu:(id)sender;
- (IBAction)closePullupMenu:(id)sender;
-(IBAction)closeInviteFrnds:(id)sender;
-(IBAction)inviteAllUsers:(id)sender;
-(IBAction)inviteSelectedUsers:(id)sender;

//
- (void) resetShareButton:(SHARING_TYPES)newSel;
-(void)searchResult;
-(void)appImageDidLoad:(NSIndexPath *)indexPath;
-(void)sendInvitationToSelectedUser:(NSMutableArray *)selectedRows;
-(void)loadFriendListsData;
-(void) mapAnnotationChanged:(id <MKAnnotation>) anno;
-(void) displayNotificationCount;
@end

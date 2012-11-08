//
//  PlaceListViewController.h
//  SocialMaps
//
//  Created by Warif Rishi on 11/3/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

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
    
    NSMutableArray      *placeList;
    AppDelegate         *smAppDelegate;
    
    BOOL						searching;
    OverlayViewController		*ovController;
    NSMutableArray				*copyListOfItems;
}

@property (atomic) PLACE_TYPES placeType;
@property (nonatomic, retain) NSString *otherUserId;

- (IBAction)actionBackMe:(id)sender;
- (IBAction)gotoNotification:(id)sender;
- (IBAction)actionOkSearchButton:(id)sender;
- (IBAction)actionShowSearchBarButton:(id)sender;

-(void) deletePlace:(Place*)place;
-(void) loadImagesForOnscreenRows; 
-(void) displayNotificationCount;
-(void) reloadTableView;

@end

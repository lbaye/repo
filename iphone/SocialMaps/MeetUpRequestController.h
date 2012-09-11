//
//  MeetUpRequestController.h
//  SocialMaps
//
//  Created by Warif Rishi on 9/8/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomRadioButton.h"
#import <Mapkit/Mapkit.h>

@class AppDelegate;

@interface MeetUpRequestController : UIViewController <CustomRadioButtonDelegate, UIScrollViewDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet UILabel *labelAddress;
    //friends list code
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
}


- (IBAction)actionBackMe:(id)sender;
- (IBAction)actionMeetUpReqButton:(id)sender;
- (IBAction)actionSelectAll:(id)sender;
- (IBAction)actionCancelButton:(id)sender;
- (IBAction)actionAddPersonalMsgBtn:(id)sender;
- (IBAction)actionSavePersonalMsgBtn:(id)sender;

@end

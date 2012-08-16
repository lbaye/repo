//
//  ListViewController.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/13/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCheckbox.h"
#import "LocationItem.h"
#import "LocationItemPlace.h"
#import "AppDelegate.h"

#define SECTION_HEADER_HEIGHT   44

@interface ListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CustomCheckboxDelegate, LocationItemPlaceDelegate> {
    OBJECT_TYPES   selectedType;
    bool            showPeople;
    bool            showPlaces;
    bool            showDeals;
    int             selectedItemIndex;
    //UITableView     *objectLists;
//    NSMutableArray  *peopleList;
//    NSMutableArray  *placeList;
//    NSMutableArray  *dealList;
    //NSMutableArray  *displayList;
    AppDelegate     *smAppDelegate;
}
@property (nonatomic) OBJECT_TYPES selectedType;
@property (nonatomic) bool showPeople;
@property (nonatomic) bool showPlaces;
@property (nonatomic) bool showDeals;
@property (nonatomic) int selectedItemIndex;
//@property (nonatomic, retain) UITableView     *objectLists;
//@property (nonatomic, retain) NSMutableArray  *peopleList;
//@property (nonatomic, retain) NSMutableArray  *placeList;
//@property (nonatomic, retain) NSMutableArray  *dealList;
//@property (nonatomic, retain) NSMutableArray  *displayList;
@property (nonatomic, retain) AppDelegate *smAppDelegate;

@property (retain, nonatomic) IBOutlet UIView *listPullupMenu;
@property (retain, nonatomic) IBOutlet UIView *listPulldownMenu;
@property (retain, nonatomic) IBOutlet UIView *listViewfilter;
@property (retain, nonatomic) IBOutlet UIView *listView;
@property (retain, nonatomic) IBOutlet UIButton *listPulldown;
@property (retain, nonatomic) IBOutlet UITableView *itemList;

- (IBAction)backToMapview:(id)sender;
- (IBAction)closePullup:(id)sender;
- (IBAction)closePulldown:(id)sender;
- (IBAction)showPullUpMenu:(id)sender;
- (IBAction)showPulldownMenu:(id)sender;

- (void) checkboxClicked:(int)btnNum withState:(int) newState sender:(id) sender;
- (void) getSortedDisplayList;

@end

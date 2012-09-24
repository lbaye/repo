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

@interface ListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CustomCheckboxDelegate, LocationItemDelegate> {
    OBJECT_TYPES   selectedType;
    int             selectedItemIndex;
    AppDelegate     *smAppDelegate;
    IBOutlet UILabel *totalNotifCount;
}
@property (nonatomic) OBJECT_TYPES selectedType;
@property (nonatomic) int selectedItemIndex;
@property (nonatomic, retain) AppDelegate *smAppDelegate;

@property (retain, nonatomic) IBOutlet UIView *listPullupMenu;
@property (retain, nonatomic) IBOutlet UIView *listPulldownMenu;
@property (retain, nonatomic) IBOutlet UIView *listViewfilter;
@property (retain, nonatomic) IBOutlet UIView *listView;
@property (retain, nonatomic) IBOutlet UIButton *listPulldown;
@property (retain, nonatomic) IBOutlet UITableView *itemList;
@property (retain, nonatomic) IBOutlet UILabel *listNotifCount;
@property(nonatomic,retain) IBOutlet UILabel *totalNotifCount;

- (IBAction)backToMapview:(id)sender;
- (IBAction)closePullup:(id)sender;
- (IBAction)closePulldown:(id)sender;
- (IBAction)showPullUpMenu:(id)sender;
- (IBAction)showPulldownMenu:(id)sender;
- (IBAction)goToNotifications:(id)sender;
-(IBAction)gotoNotification:(id)sender;
- (void) checkboxClicked:(int)btnNum withState:(int) newState sender:(id) sender;
- (void) getSortedDisplayList;
- (void) buttonClicked:(LOCATION_ACTION_TYPE) action row:(int)row;

@end

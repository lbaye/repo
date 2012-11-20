//
//  FriendListViewController.h
//  SocialMaps
//
//  Created by Warif Rishi on 9/19/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _FILTER_BY {
    AtoZ = 0,
    Distance,
    Circle
} FILTER_BY;

@class EachFriendInList;
@class AppDelegate;

@interface FriendListViewController : UIViewController {
    
    IBOutlet UIScrollView *scrollViewFriendList;
    IBOutlet UISearchBar  *searchBarFriendList;
    IBOutlet UILabel      *totalNotifCount;
    
    NSMutableArray *eachFriendList;
    NSMutableArray *circleList;
    NSMutableArray *filteredList;
    NSString       *previousLabelText;
    
    AppDelegate *smAppDelegate;
    
}

@property (nonatomic, retain) NSString* userId;

- (IBAction)actionBackMe:(id)sender;
- (IBAction)actionShowSearchBar:(id)sender;
- (IBAction)gotoNotification:(id)sender;

- (void)displayNotificationCount;
- (void) selectUserId:(NSString *)_userId;

@end

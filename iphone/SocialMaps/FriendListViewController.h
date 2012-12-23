//
//  FriendListViewController.h
//  SocialMaps
//
//  Created by Warif Rishi on 9/19/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file FriendListViewController.h
 * @brief Show friend list with userId. Sort options - alphabetic, distance, circle. 
 */

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

/**
 * @brief Navigate user to previous screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionBackMe:(id)sender;

/**
 * @brief Show search bar
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionShowSearchBar:(id)sender;

/**
 * @brief Navigate to notification screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoNotification:(id)sender;

/**
 * @brief Display total notification count
 * @param none
 * @retval none
 */
- (void)displayNotificationCount;

/**
 * @brief Set user id for whom friend list need to be shown
 * @param none
 * @retval none
 */
- (void) selectUserId:(NSString *)_userId;

@end

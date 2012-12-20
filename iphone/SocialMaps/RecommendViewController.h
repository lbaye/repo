//
//  RecommendViewController.h
//  SocialMaps
//
//  Created by Warif Rishi on 11/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Place;

@interface RecommendViewController : UIViewController
{
    IBOutlet UILabel *totalNotifCount;
    IBOutlet UISearchBar *friendSearchbar;
    IBOutlet UIScrollView *scrollViewFriends;
    IBOutlet UITextView *textViewComment;
    IBOutlet UITextView *textViewMsg;
    
    Place           *place;
    NSMutableArray  *selectedFriendsIndex;
    BOOL            searchFlag;
    CGFloat         animatedDistance;
    NSString        *searchTexts;
    NSMutableArray  *filteredList;
}

@property (nonatomic, retain) Place *place;

/**
 * @brief Navigate to notification screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoNotification:(id)sender;

/**
 * @brief Navigate user to previous screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionBackMe:(id)sender;

/**
 * @brief Select all friends for sending recomendation
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionAddAllFriendsButton:(id)sender;

/**
 * @brief Deselect all friends
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionRemoveAllFriendsButton:(id)sender;

/**
 * @brief Send recomendation
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionSendButton:(id)sender;

/**
 * @brief Initialize scroll view
 * @param (NSMutableArray) - Friend list for which scroll view needs to be initialized
 * @retval none
 */
- (void)initScrollView:(NSMutableArray*)friendList;

/**
 * @brief Set place to be recomended
 * @param (Place) - place which will be recomended
 * @retval none
 */
- (void)setSelectedPlace:(Place*)_place;

/**
 * @brief Display toatal notifiction count
 * @param none
 * @retval none
 */
- (void) displayNotificationCount;

@end

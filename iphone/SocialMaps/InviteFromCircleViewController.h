//
//  InviteFromCircleViewController.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 9/30/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file InviteFromCircleViewController.h
 * @brief Display second degree friends and send invitation to them to Socialmaps
 */

#import <UIKit/UIKit.h>
#import "CircleListViewController.h"

@interface InviteFromCircleViewController : CircleListViewController
{
    IBOutlet UITableView *inviteTableView;
    IBOutlet UISearchBar *inviteSearchBar;
    NSDictionary *downloadedImageDict;
    IBOutlet UIView *msgView;
    IBOutlet UITextView *textViewNewMsg;

    IBOutlet UILabel *labelNotifCount;
    IBOutlet UIButton *selectAllButton;
}

@property(nonatomic,retain) IBOutlet UITableView *inviteTableView;
@property(nonatomic,retain) IBOutlet UISearchBar *inviteSearchBar;
@property(nonatomic,retain) NSDictionary *downloadedImageDict;
@property (nonatomic,retain)  IBOutlet UIView *msgView;
@property (nonatomic,retain) IBOutlet UITextView *textViewNewMsg;
@property (nonatomic,retain) IBOutlet UIButton *selectAllButton;

/**
 * @brief Block selected user
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)cancel:(id)sender;

/**
 * @brief Invite selected user
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)selectedUser:(id)sender;

/**
 * @brief Select all user
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)selectAllpeople:(id)sender;

/**
 * @brief Navigate user to notification screen
 * @param (id) - action sender
 * @retval action
 */
- (IBAction)actionNotificationButton:(id)sender;

@end
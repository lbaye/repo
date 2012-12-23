//
// BlockUnblockCircleViewController.h
// SocialMaps
//
// Created by Abdullah Md. Zubair on 9/20/12.
// Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file BlockUnblockCircleViewController.h
 * @brief Other user can be blocked/unblocked from this view controller.
 */

#import <UIKit/UIKit.h>
#import "CircleImageDownloader.h"

@interface BlockUnblockCircleViewController : UIViewController
{
    IBOutlet UITableView *blockTableView;
    IBOutlet UISearchBar *blockSearchBar;
    NSDictionary *downloadedImageDict;
    IBOutlet UIView *msgView;
    IBOutlet UITextView *textViewNewMsg;

    IBOutlet UILabel *labelNotifCount;
    IBOutlet UIButton *selectAllButton;
}

@property(nonatomic,retain) IBOutlet UITableView *blockTableView;
@property(nonatomic,retain) IBOutlet UISearchBar *blockSearchBar;
@property(nonatomic,retain) NSDictionary *downloadedImageDict;

@property (nonatomic,retain)  IBOutlet UIView *msgView;
@property (nonatomic,retain) IBOutlet UITextView *textViewNewMsg;
@property (nonatomic,retain) IBOutlet UIButton *selectAllButton;

/**
 * @brief cancel view and return to previous view
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)cancel:(id)sender;

/**
 * @brief block selected user
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)selectedUser:(id)sender;

/**
 * @brief select all user
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)selectAllpeople:(id)sender;

/**
 * @brief navigate user to notification screen
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)actionNotificationButton:(id)sender;

@end
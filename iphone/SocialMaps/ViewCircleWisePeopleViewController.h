//
//  ViewCircleWisePeopleViewController.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 9/20/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "SectionHeaderView.h"

@class CircleListTableCell;
@interface ViewCircleWisePeopleViewController : UIViewController <MFMailComposeViewControllerDelegate, SectionHeaderViewDelegate>
{
    IBOutlet UITableView *circleTableView;
    IBOutlet UISearchBar *circleSearchBar;
    IBOutlet UIView *circleCreateView;
    IBOutlet UITableView *circleSelectTableView;
    IBOutlet UITextField *circleNameTextField;
    IBOutlet UIView *msgView;
    IBOutlet UITextView *textViewNewMsg;
    IBOutlet UILabel *labelNotifCount;
    
    IBOutlet UIView *renameUIView;
    IBOutlet UITextField *renameTextField;
}

@property(nonatomic,retain) IBOutlet UITableView *circleTableView;
@property(nonatomic,retain) IBOutlet UISearchBar *circleSearchBar;

@property (nonatomic, strong) NSArray* userCircle;
@property (nonatomic, strong) IBOutlet CircleListTableCell *circleListTableCell;
@property (nonatomic,retain) IBOutlet UIView *circleCreateView;
@property(nonatomic,retain) IBOutlet UITableView *circleSelectTableView;
@property(nonatomic,retain) IBOutlet UITextField *circleNameTextField;
@property (nonatomic,retain) IBOutlet UIView *msgView;
@property (nonatomic,retain) IBOutlet UITextView *textViewNewMsg;

@property(nonatomic,retain) IBOutlet UIView *renameUIView;
@property(nonatomic,retain) IBOutlet UITextField *renameTextField;

/**
 * @brief create circle action
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)addCircleAction:(id)sender;

/**
 * @brief show searchbar for searching
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)okAction:(id)sender;

/**
 * @brief move user to a circle
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)cancelAction:(id)sender;

/**
 * @brief navigate user to notification
 * @param (id) - action sender
 * @retval action
 */
- (IBAction)actionNotificationButton:(id)sender;

/**
 * @brief save renaming circle
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)saveRenameCircle:(id)sender;

/**
 * @brief cancel renaming circle
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)cancelRenameCircle:(id)sender;

@end

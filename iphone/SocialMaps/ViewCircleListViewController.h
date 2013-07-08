//
//  ViewCircleListViewController.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 9/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file ViewCircleListViewController.h
 * @brief Display people list with distance wise sorted through this view controller.
 */

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CustomCheckbox.h"
#import "CircleListViewController.h"

@interface ViewCircleListViewController : CircleListViewController <CustomCheckboxDelegate>
{
    IBOutlet UITableView *circleListTableView;
    IBOutlet UISearchBar *circleSearchBar;
    NSDictionary *downloadedImageDict;
    IBOutlet UIView *msgView;
    IBOutlet UITextView *textViewNewMsg;
    IBOutlet UILabel *labelNotifCount;
    float itemDistance;
}

@property(nonatomic,retain) IBOutlet UITableView *circleListTableView;
@property(nonatomic,retain) IBOutlet UISearchBar *circleSearchBar;
@property(nonatomic,retain) NSDictionary *downloadedImageDict;
@property (retain, nonatomic) IBOutlet UIView *listPulldownMenu;
@property (retain, nonatomic) IBOutlet UIButton *listPulldown;
@property (retain, nonatomic) IBOutlet UIView *listViewfilter;
@property (nonatomic,retain)  IBOutlet UIView *msgView;
@property (nonatomic,retain) IBOutlet UITextView *textViewNewMsg;
@property (nonatomic)    float itemDistance;

/**
 * @brief navigate user to notification screen
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)actionNotificationButton:(id)sender;

/**
 * @brief show searchbar for searching
 * @param (id) - action sender
 * @retval action
 */
-(IBAction)showSearch:(id)sender;

@end

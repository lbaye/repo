//
//  PlanListViewController.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 11/20/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlanImageDownloader.h"

@interface PlanListViewController : UIViewController<PlanImageDownloaderDelegate>
{
    IBOutlet UITableView *planListTableView;
    IBOutlet UILabel * totalNotifCount;
}

@property(nonatomic,retain) IBOutlet UITableView *planListTableView;
@property(nonatomic,retain) IBOutlet UILabel * totalNotifCount;

/**
 * @brief Navigate user to previous screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)backButtonAction:(id)sender;

/**
 * @brief Navigate user to notification screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoNotification:(id)sender;

/**
 * @brief Deletes a plan
 * @param (NSNotification) - Notification object
 * @retval none
 */
- (void)deletePlan:(NSNotification *)notif;

@end

//
//  FriendsPlanListViewController.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 11/22/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlanImageDownloader.h"
#import "UserInfo.h"

@interface FriendsPlanListViewController : UIViewController<PlanImageDownloaderDelegate>
{
    IBOutlet UITableView *planListTableView;
    IBOutlet UILabel * totalNotifCount;
    UserInfo *userInfo;
}

@property(nonatomic,retain) IBOutlet UITableView *planListTableView;
@property(nonatomic,retain) IBOutlet UILabel * totalNotifCount;
@property(nonatomic,retain) UserInfo *userInfo;

/**
 * @brief Navigate user to previous screen
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)backButtonAction:(id)sender;

/**
 * @brief Navigate user to notification screen
 * @param (id) - action sender
 * @retval action
 **/
-(IBAction)gotoNotification:(id)sender;

@end

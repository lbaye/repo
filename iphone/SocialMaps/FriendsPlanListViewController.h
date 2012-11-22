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

-(IBAction)backButtonAction:(id)sender;
-(IBAction)gotoNotification:(id)sender;

@end

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

-(IBAction)backButtonAction:(id)sender;
-(IBAction)gotoNotification:(id)sender;

@end

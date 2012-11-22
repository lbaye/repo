//
//  PlanListTableCell.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 11/20/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlanListTableCell : UITableViewCell
{
    IBOutlet UITextView *planDescriptionView;
    IBOutlet UILabel *addressLabel;
    IBOutlet UILabel *distanceLabel;
    IBOutlet UIButton *pointOnMap;
    IBOutlet UIButton *editPlanButton;
    IBOutlet UIButton *deletePlanButton;  
    IBOutlet UILabel *addressBg;
    IBOutlet UIScrollView *addressScroller;
    IBOutlet UIImageView *planBgImg;
}

@property(nonatomic,retain) IBOutlet UITextView *planDescriptionView;
@property(nonatomic,retain) IBOutlet UILabel *addressLabel;
@property(nonatomic,retain) IBOutlet UILabel *distanceLabel;
@property(nonatomic,retain) IBOutlet UIButton *pointOnMap;
@property(nonatomic,retain) IBOutlet UIButton *editPlanButton;
@property(nonatomic,retain) IBOutlet UIButton *deletePlanButton;    
@property(nonatomic,retain) IBOutlet UILabel *addressBg;
@property(nonatomic,retain) IBOutlet UIScrollView *addressScroller;
@property(nonatomic,retain) IBOutlet UIImageView *planBgImg;

@end

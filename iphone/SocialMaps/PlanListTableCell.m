//
//  PlanListTableCell.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 11/20/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "PlanListTableCell.h"

@implementation PlanListTableCell

@synthesize planDescriptionView;
@synthesize addressLabel;
@synthesize distanceLabel;
@synthesize pointOnMap;
@synthesize editPlanButton;
@synthesize deletePlanButton;
@synthesize addressBg;
@synthesize addressScroller;
@synthesize planBgImg;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

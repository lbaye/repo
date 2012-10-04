//
//  EventListTableCell.m
//  Event
//
//  Created by Abdullah Md. Zubair on 8/24/12.
//  Copyright (c) 2012 Genweb2 Limited. All rights reserved.
//

#import "EventListTableCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation EventListTableCell
@synthesize eventName;
@synthesize eventDate;
@synthesize eventAddress;
@synthesize eventDistance;
@synthesize eventDetail;
@synthesize viewEventOnMap;
@synthesize eventImage;
@synthesize footerView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [footerView.layer setCornerRadius:6.0f];
        [footerView.layer setMasksToBounds:YES];
        footerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.6];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

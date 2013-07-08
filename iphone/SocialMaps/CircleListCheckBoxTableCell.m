//
//  CircleListCheckBoxTableCell.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 9/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "CircleListCheckBoxTableCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation CircleListCheckBoxTableCell

@synthesize checkBoxButton;
@synthesize firstNameLabel;
@synthesize addressLabel;
@synthesize distanceLabel;
@synthesize inviteButton;
@synthesize messageButton;
@synthesize showOnMapButton;
@synthesize profilePicImgView;
@synthesize coverPicImgView;    
@synthesize regStsImgView;
@synthesize friendShipStatus;
@synthesize footerView;
@synthesize checkInImgView;

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

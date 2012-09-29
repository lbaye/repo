//
//  CircleListTableCell.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 9/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "CircleListTableCell.h"

@implementation CircleListTableCell
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

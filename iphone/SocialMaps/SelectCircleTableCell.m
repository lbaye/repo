//
//  SelectCircleTableCell.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 9/17/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "SelectCircleTableCell.h"

@implementation SelectCircleTableCell
@synthesize circrcleName;
@synthesize circrcleCheckbox;

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

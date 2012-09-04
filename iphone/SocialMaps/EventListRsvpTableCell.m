//
//  EventListRsvpTableCell.m
//  Event
//
//  Created by Abdullah Md. Zubair on 8/26/12.
//  Copyright (c) 2012 Genweb2 Limited. All rights reserved.
//

#import "EventListRsvpTableCell.h"

@implementation EventListRsvpTableCell

@synthesize eventName;
@synthesize eventDate;
@synthesize eventAddress;
@synthesize eventDistance;
@synthesize eventDetail;
@synthesize viewEventOnMap;
@synthesize eventImage,yesButton,noButton,maybesButton;

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

//
//  LocationItemPeople.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/14/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "LocationItemPeople.h"
#import "Constants.h"

@implementation LocationItemPeople
@synthesize userInfo;

- (UITableViewCell*) getTableViewCell:(UITableView*)tv sender:(ListViewController*)controller {
    
    cellIdent = @"peopleItem";
    UITableViewCell *cell = [super getTableViewCell:tv sender:controller];
    
    UILabel *lblAddress  = (UILabel*) [cell viewWithTag:2002];
    UILabel *lblName     = (UILabel*) [cell viewWithTag:2003];
    //UILabel *lblDist     = (UILabel*) [cell viewWithTag:2004];
    //UIView *line         = (UIView*) [cell viewWithTag:2005];
    UITextView   *txtMsg = (UITextView*) [cell viewWithTag:2006];  
    if (txtMsg == nil) {
        CGSize msgStringSize = [userInfo.statusMsg sizeWithFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize]];
        CGFloat msgRows = ceil(msgStringSize.width/tv.frame.size.width/2);
        
        CGFloat msgHeight = msgRows*msgStringSize.height+16;
        CGRect msgFrame = CGRectMake(10+itemIcon.size.width+10, 
                                     lblName.frame.origin.y+lblName.frame.size.height+5,
                                     tv.frame.size.width/2, msgHeight);
        txtMsg = [[[UITextView alloc] initWithFrame:msgFrame] autorelease];
		txtMsg.tag = 2006;
		txtMsg.textColor = [UIColor blackColor];
		txtMsg.font = [UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize];
		txtMsg.backgroundColor = [UIColor clearColor];
		[txtMsg setTextAlignment:UITextAlignmentLeft];
		
		[cell.contentView addSubview:txtMsg];
    }
    
	// Message
    txtMsg.text = userInfo.statusMsg;
    txtMsg.userInteractionEnabled = FALSE;
    
    // Debug
    CGRect tmp = CGRectMake(lblAddress.frame.origin.x,lblAddress.frame.origin.y,cell.frame.size.width, 37);
    lblAddress.frame = tmp;
    lblAddress.text = [NSString stringWithFormat:@"%@ %@",userInfo.currentLocationLat,userInfo.currentLocationLng];

	return cell;
}

@end

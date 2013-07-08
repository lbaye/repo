//
//  TagNotification.m
//  SocialMaps
//
//  Created by Arif Shakoor on 7/31/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "TagNotification.h"
#import "Constants.h"

@implementation TagNotification

@synthesize photo;

- (UITableViewCell*) getTableViewCell:(UITableView*)tv sender:(NotificationController*)controller{
    CGSize senderStringSize = [notifSender sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:kLargeLabelFontSize]];
    CGSize msgStringSize = [notifMessage sizeWithFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize]];
    CGSize fixedStringSize = [@" tagged you:" sizeWithFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize]];
    
    CGSize picSize = CGSizeMake(0.0, 0.0);
    CGSize scaledPic = picSize;
    
    if (photo != nil) {
        picSize = photo.size;
        scaledPic = CGSizeMake(tv.frame.size.width/3, picSize.height*(tv.frame.size.width/3)/picSize.width);
    }

    CGFloat msgHeight = ceil(msgStringSize.width/(tv.frame.size.width/3*2))*msgStringSize.height;
    if (msgHeight < scaledPic.height)
        msgHeight = scaledPic.height;

	CGRect CellFrame   = CGRectMake(0, 0, tv.frame.size.width, [self getRowHeight:tv]);
	CGRect senderFrame = CGRectMake(1, 1, senderStringSize.width, 
                                    senderStringSize.height);
    CGRect fixedFrame = CGRectMake(1+senderStringSize.width+1, 1, 
                                   fixedStringSize.width, senderStringSize.height);
	CGRect timeFrame = CGRectMake(senderStringSize.width+fixedStringSize.width+3, 
                                  1, tv.frame.size.width-3-senderStringSize.width-fixedStringSize.width, senderStringSize.height);
	CGRect msgFrame = CGRectMake(1, senderStringSize.height+1, tv.frame.size.width/3*2, msgHeight);
    
    CGRect picFrame = CGRectMake(msgFrame.size.width, senderStringSize.height+1, tv.frame.size.width/3, scaledPic.height);
	
    tv.backgroundColor = [UIColor clearColor];
	tv.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	//UILabel *lblCust;
	UILabel *lblSender;
    UILabel *lblFixed; // "are near you:"
	UILabel *lblTime;
    UITextView *txtMsg;
    UIImageView *imgPic;
    UIView *line;
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"notifTagList"];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notifTagList"] autorelease];
        cell.frame = CellFrame;
		cell.backgroundView = [[[UIImageView alloc] init] autorelease];
		cell.selectedBackgroundView = [[[UIImageView alloc] init] autorelease];
		
		// Message sender
		lblSender = [[[UILabel alloc] initWithFrame:senderFrame] autorelease];
		lblSender.tag = 2002;
		lblSender.font = [UIFont fontWithName:@"Helvetica-Bold" size:kLargeLabelFontSize];
		lblSender.textColor = [UIColor blackColor];
		lblSender.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:lblSender];
        
        // Fixed text "says:"
		lblFixed = [[[UILabel alloc] initWithFrame:fixedFrame] autorelease];
		lblFixed.tag = 2003;
        lblFixed.font = [UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize];
		lblFixed.textColor = [UIColor grayColor];
		lblFixed.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:lblFixed];
		
		// Time
		lblTime = [[[UILabel alloc] initWithFrame:timeFrame] autorelease];
		lblTime.tag = 2004;
        lblTime.textAlignment = UITextAlignmentRight;
		lblTime.font = [UIFont fontWithName:@"Helvetica-Oblique" size:kLargeLabelFontSize];
		lblTime.textColor = [UIColor blackColor];
		lblTime.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:lblTime];
		
		// Message
		txtMsg = [[[UITextView alloc] initWithFrame:msgFrame] autorelease];
		txtMsg.tag = 2005;
		txtMsg.textColor = [UIColor blackColor];
		txtMsg.font = [UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize];
		txtMsg.backgroundColor = [UIColor clearColor];
		[txtMsg setTextAlignment:UITextAlignmentLeft];
		
		[cell.contentView addSubview:txtMsg];
        
        // Picture
        imgPic = [[[UIImageView alloc] initWithFrame:picFrame] autorelease];
		imgPic.tag = 2007;

		imgPic.backgroundColor = [UIColor clearColor];
		
		[cell.contentView addSubview:imgPic];

        // Line
        CGRect lineFrame = CGRectMake(0, CellFrame.size.height-3, CellFrame.size.width, 2);
        line = [[UIView alloc] initWithFrame:lineFrame];
        line.tag = 2006;
        line.backgroundColor = [UIColor grayColor];
        [cell.contentView addSubview:line];
		
    } else {
		lblSender  = (UILabel*) [cell viewWithTag:2002];
        lblFixed  = (UILabel*) [cell viewWithTag:2003];
		lblTime    = (UILabel*) [cell viewWithTag:2004];
		txtMsg     = (UITextView*) [cell viewWithTag:2005];
        line       = (UIView*) [cell viewWithTag:2006];
        imgPic     = (UIImageView*) [cell viewWithTag:2007];
	}
    
	// Sender
    lblSender.frame = senderFrame;
	lblSender.text = notifSender;
    
    lblFixed.frame = fixedFrame;
    lblFixed.text  = @" tagged you:";
	
	// Time
    lblTime.frame = timeFrame;
	lblTime.text = [self timeAsString];
	
	// Message
    txtMsg.frame = msgFrame;
    txtMsg.text = notifMessage;
    txtMsg.userInteractionEnabled = FALSE;
    
    // Picture
    if (photo != nil)
        imgPic.image = photo;
        
    // Bottom line
    CGRect lineFrame = CGRectMake(0, CellFrame.size.height-3, CellFrame.size.width, 2);
    line.frame = lineFrame;
    
	return cell;
}

- (CGFloat) getRowHeight:(UITableView*)tv {
    CGSize senderStringSize = [notifSender sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:kLargeLabelFontSize]];
    CGSize msgStringSize = [notifMessage sizeWithFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize]];
    CGSize picSize = CGSizeMake(0.0, 0.0);
    CGSize scaledPic = picSize;
    
    if (photo != nil) {
        picSize = photo.size;
        scaledPic = CGSizeMake(tv.frame.size.width/3, picSize.height*(tv.frame.size.width/3)/picSize.width);
    }
    
    double msgHeight;
    msgHeight = ceil(msgStringSize.width/(tv.frame.size.width/3*2))*msgStringSize.height;
    if (msgHeight < scaledPic.height)
        msgHeight = scaledPic.height;
    
    return (senderStringSize.height + msgHeight + 10);
}
@end

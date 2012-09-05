//
//  Message.m
//  SocialMaps
//
//  Created by Arif Shakoor on 7/31/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "NotifMessage.h"
#import "Constants.h"

@implementation NotifMessage

@synthesize showDetail;
@synthesize notifSubject;
@synthesize notifID;
@synthesize recipients;

- (UITableViewCell*) getTableViewCell:(UITableView*)tv sender:(NotificationController*)controller{
    CGSize senderStringSize = [notifSender sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:kLargeLabelFontSize]];
    CGSize msgStringSize = [notifMessage sizeWithFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize]];
    CGSize fixedStringSize = [@"says:" sizeWithFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize]];
    CGFloat msgRows = ceil(msgStringSize.width/tv.frame.size.width);
    bool hideMoreButton = msgRows <= NUM_LINES_IN_BRIEF_VIEW;
    
    if (showDetail == FALSE)
        msgRows = msgRows > NUM_LINES_IN_BRIEF_VIEW ? NUM_LINES_IN_BRIEF_VIEW : msgRows;
    CGFloat msgHeight = msgRows*msgStringSize.height+10;
    UIImage *btnImage = [UIImage imageNamed:@"collapse_icon.png"];
    CGSize btnSize = btnImage.size;
    
	CGRect CellFrame   = CGRectMake(0, 0, tv.frame.size.width, [self getRowHeight:tv]);
	CGRect senderFrame = CGRectMake(1, 1, senderStringSize.width, 
                                    senderStringSize.height);
    CGRect fixedFrame = CGRectMake(1+senderStringSize.width+1, 1, 
                                   fixedStringSize.width, senderStringSize.height);
	CGRect timeFrame = CGRectMake(senderStringSize.width+fixedStringSize.width+3, 
                                  1, tv.frame.size.width-3-senderStringSize.width-fixedStringSize.width, senderStringSize.height);
	CGRect msgFrame = CGRectMake(1, msgStringSize.height+1, tv.frame.size.width-2, msgHeight);
    CGRect btnFrame = CGRectMake(1, senderFrame.size.height+msgFrame.size.height+3, 
                                 btnSize.width/2, btnSize.height/2);
	
    tv.backgroundColor = [UIColor clearColor];
	tv.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	//UILabel *lblCust;
	UILabel *lblSender;
    UILabel *lblFixed; // "says:"
	UILabel *lblTime;
    UITextView *txtMsg;
	UIButton *btnMore;
	UIImageView *btnMoreBg;
    UIView *line;
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"msgList"];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"msgList"] autorelease];
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
		
        // Button
        btnMore = [[[UIButton alloc] initWithFrame:btnFrame] autorelease];
		btnMore.tag = 2006;
        btnMore.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:btnMore];
        [btnMore addTarget:controller action:@selector(moreButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
		// Button BG
		btnMoreBg = [[[UIImageView alloc] init] autorelease];
		btnMoreBg.tag = 2007;
		btnMoreBg.frame = CGRectMake(btnFrame.origin.x, btnFrame.origin.y, btnFrame.size.width, btnFrame.size.height);
		[cell.contentView addSubview:btnMoreBg];
		[cell.contentView sendSubviewToBack:btnMoreBg];
        
        // Line
        CGRect lineFrame = CGRectMake(0, CellFrame.size.height-3, CellFrame.size.width, 2);
        line = [[UIView alloc] initWithFrame:lineFrame];
        line.tag = 2008;
        line.backgroundColor = [UIColor grayColor];
        [cell.contentView addSubview:line];
    } else {
		lblSender  = (UILabel*) [cell viewWithTag:2002];
        lblFixed  = (UILabel*) [cell viewWithTag:2003];
		lblTime    = (UILabel*) [cell viewWithTag:2004];
		txtMsg     = (UITextView*) [cell viewWithTag:2005];
        btnMore    = (UIButton*) [cell viewWithTag:2006];
		btnMoreBg  = (UIImageView*) [cell viewWithTag:2007];
        line       = (UIView*) [cell viewWithTag:2008];
	}
    
	// Sender
    lblSender.frame = senderFrame;
	lblSender.text = notifSender;
    
    lblFixed.frame = fixedFrame;
    lblFixed.text  = @"says:";
	
	// Time
    lblTime.frame = timeFrame;
	lblTime.text = [self timeAsString];
	
	// Message
    txtMsg.frame = msgFrame;
    txtMsg.text = notifMessage;
    txtMsg.userInteractionEnabled = FALSE;
    
    // Button
    btnMore.frame = btnFrame;
    btnMoreBg.frame = btnFrame;
    
	UIImage* btnBackground;
	if (showDetail == true) {
		btnBackground = [UIImage imageNamed:@"collapse_icon.png"];
	} else {
		btnBackground = [UIImage imageNamed:@"more_icon.png"];
	}
	((UIImageView *)btnMoreBg).image = btnBackground;
    if (hideMoreButton == TRUE) {
        btnMore.hidden = TRUE;
        btnMoreBg.hidden = TRUE;
    } else {
        btnMore.hidden = FALSE;
        btnMoreBg.hidden = FALSE;
    }
    
    // Bottom line
    CGRect lineFrame = CGRectMake(0, CellFrame.size.height-3, CellFrame.size.width, 2);
    line.frame = lineFrame;
    
	return cell;
}

- (CGFloat) getRowHeight:(UITableView*)tv {
    CGFloat cellRowHeight;
    
    CGSize senderStringSize = [notifSender sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:kLargeLabelFontSize]];
    CGSize msgStringSize = [notifMessage sizeWithFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize]];
    UIImage *btnImage = [UIImage imageNamed:@"collapse_icon.png"];
    CGSize btnSize = btnImage.size;
    CGFloat msgRows = ceil(msgStringSize.width/tv.frame.size.width);
    bool hideMoreButton = msgRows <= NUM_LINES_IN_BRIEF_VIEW;
    if (showDetail == FALSE)
        msgRows = msgRows > NUM_LINES_IN_BRIEF_VIEW ? NUM_LINES_IN_BRIEF_VIEW : msgRows;
    if (hideMoreButton == TRUE)
        cellRowHeight = senderStringSize.height + msgRows*msgStringSize.height + 12 + 2;
    else
        cellRowHeight = senderStringSize.height + msgRows*msgStringSize.height + btnSize.height + 4 + 2;
    return cellRowHeight;
}

@end

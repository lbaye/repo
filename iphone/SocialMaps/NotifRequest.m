//
//  Request.m
//  SocialMaps
//
//  Created by Arif Shakoor on 7/31/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//
#import "NotificationController.h"
#import "NotifRequest.h"
#import "Constants.h"

@implementation NotifRequest

@synthesize numCommonFriends;
@synthesize delegate;
@synthesize ignored;

- (UITableViewCell*) getTableViewCell:(UITableView*)tv sender:(NotificationController*)controller{
    CGSize senderStringSize = [notifSender sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:kLargeLabelFontSize]];
    CGSize msgStringSize = [notifMessage sizeWithFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize]];
    CGSize fixedStringSize = [@"wants to be your friend." sizeWithFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize]];
    CGFloat msgRows = ceil(msgStringSize.width/tv.frame.size.width);
    
    CGFloat msgHeight = msgRows*msgStringSize.height+4;
	CGRect CellFrame   = CGRectMake(0, 0, tv.frame.size.width, [self getRowHeight:tv]);
	CGRect senderFrame = CGRectMake(1, 1, senderStringSize.width, 
                                    senderStringSize.height);
    CGRect fixedFrame = CGRectMake(1+senderStringSize.width+1, 1, 
                                   fixedStringSize.width, senderStringSize.height);
	CGRect timeFrame = CGRectMake(senderStringSize.width+fixedStringSize.width+3, 
                                  1, tv.frame.size.width-3-senderStringSize.width-fixedStringSize.width, senderStringSize.height);
    CGRect countFrame = CGRectMake(1, senderStringSize.height+1, tv.frame.size.width-2, fixedFrame.size.height);
	CGRect msgFrame = CGRectMake(1, countFrame.size.height+1+senderFrame.size.height+1, tv.frame.size.width-2, msgHeight);
	
    tv.backgroundColor = [UIColor clearColor];
	tv.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	UILabel *lblSender;
    UILabel *lblFixed; // "are near you:"
	UILabel *lblTime;
    UILabel *lblCount;
    UITextView *txtMsg;
    UIView *line;
    UIButton *accept;
    UIButton *ignore;
    UIButton *decline;
    UIImageView *btnAcceptBg;
    UIImageView *btnDeclineBg;
    UIImageView *btnIgnoreBg;
    UIImage *btnImage;
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"reqList"];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reqList"] autorelease];
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
		
        // Count
		lblCount = [[[UILabel alloc] initWithFrame:countFrame] autorelease];
		lblCount.tag = 2013;
		lblCount.font = [UIFont fontWithName:@"Helvetica-Oblique" size:kSmallLabelFontSize];
		lblCount.textColor = [UIColor grayColor];
		lblCount.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:lblCount];
        
		// Message
		txtMsg = [[[UITextView alloc] initWithFrame:msgFrame] autorelease];
		txtMsg.tag = 2005;
		txtMsg.textColor = [UIColor blackColor];
		txtMsg.font = [UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize];
		txtMsg.backgroundColor = [UIColor clearColor];
		[txtMsg setTextAlignment:UITextAlignmentLeft];
		
		[cell.contentView addSubview:txtMsg];
        
        // Accept
        btnImage = [UIImage imageNamed:@"accept_button_a.png"];
        accept = [[UIButton alloc] initWithFrame:CGRectMake(1, CellFrame.size.height-btnImage.size.height/2-5, btnImage.size.width/2, btnImage.size.height/2)];
        accept.tag = 2007;
        accept.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:accept];
        
        // Accept Button BG
		btnAcceptBg = [[[UIImageView alloc] init] autorelease];
		btnAcceptBg.tag = 2010;
		btnAcceptBg.frame = CGRectMake(1, CellFrame.size.height-btnImage.size.height/2-5, btnImage.size.width/2, btnImage.size.height/2);
        //btnAcceptBg.image = btnImage;
        [accept.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:kMediumLabelFontSize]];
        [accept setTitle:@"Accept" forState:UIControlStateNormal];
        [accept setBackgroundImage:[UIImage imageNamed:@"btn_bg_green_small"] forState:UIControlStateNormal];
		[cell.contentView addSubview:btnAcceptBg];
		[cell.contentView sendSubviewToBack:btnAcceptBg];
        [accept addTarget:self action:@selector(requestAccepted:) forControlEvents:UIControlEventTouchUpInside];
                  
        // Decline
        btnImage = [UIImage imageNamed:@"decline_button_a.png"];
        decline = [[UIButton alloc] initWithFrame:CGRectMake(1+btnImage.size.width+10, 
                                                             CellFrame.size.height-btnImage.size.height/2-5, 
                                                             btnImage.size.width/2, 
                                                             btnImage.size.height/2)];
        decline.tag = 2008;
        decline.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:decline];
        
        // Decline Button BG
		btnDeclineBg = [[[UIImageView alloc] init] autorelease];
		btnDeclineBg.tag = 2011;
		btnDeclineBg.frame = CGRectMake(1+btnImage.size.width/2+10, 
                                        CellFrame.size.height-btnImage.size.height/2-5, 
                                        btnImage.size.width/2, 
                                        btnImage.size.height/2);
        btnDeclineBg.image = btnImage;
		[cell.contentView addSubview:btnDeclineBg];
		[cell.contentView sendSubviewToBack:btnDeclineBg];
        
        // Ignore
        btnImage = [UIImage imageNamed:@"ignore_button_a.png"];
        ignore = [[UIButton alloc] initWithFrame:CGRectMake(1+(btnImage.size.width/2+10)*2, 
                                                             CellFrame.size.height-btnImage.size.height/2-5, 
                                                             btnImage.size.width/2, 
                                                             btnImage.size.height/2)];
        ignore.tag = 2009;
        ignore.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:ignore];
        
        // Ignore Button BG
		btnIgnoreBg = [[[UIImageView alloc] init] autorelease];
		btnIgnoreBg.tag = 2012;
		btnIgnoreBg.frame = CGRectMake(1+(btnImage.size.width/2+10)*2, 
                                       CellFrame.size.height-btnImage.size.height/2-5, 
                                       btnImage.size.width/2, 
                                       btnImage.size.height/2);
        btnIgnoreBg.image = btnImage;
		[cell.contentView addSubview:btnIgnoreBg];
		[cell.contentView sendSubviewToBack:btnIgnoreBg];
        
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
        accept     = (UIButton*) [cell viewWithTag:2007];
        decline     = (UIButton*) [cell viewWithTag:2008];
        ignore     = (UIButton*) [cell viewWithTag:2009];
        lblCount   = (UILabel*) [cell viewWithTag:2013];
        accept      = (UIButton*) [cell viewWithTag:2007];
        btnAcceptBg      = (UIImageView*) [cell viewWithTag:2010];
        decline      = (UIButton*) [cell viewWithTag:2008];
        btnDeclineBg = (UIImageView*) [cell viewWithTag:2011];
        ignore      = (UIButton*) [cell viewWithTag:2009];
        btnIgnoreBg = (UIImageView*) [cell viewWithTag:2012];
	}
    
	// Sender
    lblSender.frame = senderFrame;
	lblSender.text = notifSender;
    
    lblFixed.frame = fixedFrame;
    lblFixed.text  = @"wants to be your friend.";
	
    // Count
    lblCount.text = [NSString stringWithFormat:@"%d friend(s) in common", numCommonFriends];
    
	// Time
    lblTime.frame = timeFrame;
	lblTime.text = [self timeAsString];
	
	// Message
    msgFrame = CGRectMake(1, countFrame.size.height+senderFrame.size.height, tv.frame.size.width-2, msgHeight+4);

    txtMsg.frame = msgFrame;
    txtMsg.text = notifMessage;
    txtMsg.userInteractionEnabled = FALSE;
    
    // Buttons
    btnImage = [UIImage imageNamed:@"accept_button_a.png"];
    CGRect btnFrame = CGRectMake(1, CellFrame.size.height-btnImage.size.height/2-5, btnImage.size.width/2, btnImage.size.height/2);
    accept.frame = btnFrame;
    btnAcceptBg.frame = btnFrame;
    
    btnFrame = CGRectMake(1+btnImage.size.width/2+10, CellFrame.size.height-btnImage.size.height/2-5, btnImage.size.width/2, btnImage.size.height/2);
    decline.frame = btnFrame;
    btnDeclineBg.frame = btnFrame;
    
    btnFrame = CGRectMake(1+(btnImage.size.width/2+10)*2, CellFrame.size.height-btnImage.size.height/2-5, btnImage.size.width/2, btnImage.size.height/2);
    ignore.frame = btnFrame;
    btnIgnoreBg.frame = btnFrame;
    
    [accept addTarget:self action:@selector(requestAccepted:) forControlEvents:UIControlEventTouchUpInside];
    [decline addTarget:self action:@selector(requestDeclined:) forControlEvents:UIControlEventTouchUpInside];
    [ignore addTarget:self action:@selector(requestIgnored:) forControlEvents:UIControlEventTouchUpInside];
    
    if (ignored == TRUE)
        [ignore setEnabled:FALSE];
    else
        [ignore setEnabled:TRUE];
    
    // Bottom line
    CGRect lineFrame = CGRectMake(0, CellFrame.size.height-3, CellFrame.size.width, 2);
    line.frame = lineFrame;
    NSLog(@"Heights = %f, %f, %f, %f, %f, %f", CellFrame.size.height, senderFrame.size.height,
          countFrame.size.height, msgFrame.size.height, btnFrame.size.height/2,
          senderFrame.size.height+
          countFrame.size.height+ msgFrame.size.height+ btnFrame.size.height/2);
    NSLog(@"TXT frame:%f,%f,%f,%f", txtMsg.frame.origin.x, txtMsg.frame.origin.y,
          txtMsg.frame.size.width, txtMsg.frame.size.height);
    
	return cell;
}

- (CGFloat) getRowHeight:(UITableView*)tv {
    CGSize senderStringSize = [notifSender sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:kLargeLabelFontSize]];
    CGSize msgStringSize = [notifMessage sizeWithFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize]];
    CGSize msgFriendCountSize = [@"friend(s) in common" sizeWithFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize]];
    
    UIImage *btnImage = [UIImage imageNamed:@"accept_button_a.png"];
    CGSize btnSize = btnImage.size;
    
    CGFloat cellHeight = senderStringSize.height + ceil(msgStringSize.width/tv.frame.size.width)*msgStringSize.height + msgFriendCountSize.height + btnSize.height/2 + 10 + 20;
    NSLog(@"Cellheight=%f, %f, %f, %f, %f", cellHeight, senderStringSize.height,msgFriendCountSize.height,ceil(msgStringSize.width/tv.frame.size.width)*msgStringSize.height, btnSize.height/2);
    return cellHeight;
}

// Button click handlers
- (int) getCellRow:(id)sender {
    UIButton *button = (UIButton *)sender;
    // Get the UITableViewCell which is the superview of the UITableViewCellContentView which is the superview of the UIButton
    UITableViewCell *cell = (UITableViewCell *) [[button superview] superview];
    NotificationController *notifTable = (NotificationController*) delegate;
    int row = [notifTable.notificationItems indexPathForCell:cell].row;
    return row;
}

- (void) requestAccepted:(id)sender {
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(buttonClicked:cellRow:)]) {
        int row = [self getCellRow:sender];
        [delegate buttonClicked:@"Accept" cellRow:row];
    }
}

- (void) requestDeclined:(id)sender {
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(buttonClicked:cellRow:)]) {
        int row = [self getCellRow:sender];
        [delegate buttonClicked:@"Decline" cellRow:row];
    }
}

- (void) requestIgnored:(id)sender {
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(buttonClicked:cellRow:)]) {
        int row = [self getCellRow:sender];
        [delegate buttonClicked:@"Ignore" cellRow:row];
    }
}
@end

//
//  Notification.m
//  SocialMaps
//
//  Created by Arif Shakoor on 7/31/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "Notification.h"
#import "Constants.h"

@implementation Notification

@synthesize notifSender;
@synthesize notifTime;
@synthesize notifMessage;

- (NSString*) timeAsString {
    NSString *timeStr = nil;
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *today = [[NSDateComponents alloc] init];
    NSDateComponents *todayComponents =
    [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit) fromDate:[NSDate date]];
    today.day = [todayComponents day];
    today.month = [todayComponents month];
    today.year = [todayComponents year];
    today.hour = 0;
    today.minute = 0;
    today.second = 0;
    NSDate *todayDate = [gregorian dateFromComponents:today];
    NSDate *yesterdayDate = [[NSDate alloc] initWithTimeInterval:-24*60*60 sinceDate:todayDate];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    NSLog(@"today %@", [dateFormatter stringFromDate:todayDate]);
    NSLog(@"yesterday %@", [dateFormatter stringFromDate:yesterdayDate]);
    NSLog(@"notif %@", [dateFormatter stringFromDate:notifTime]);
    
    if ([notifTime timeIntervalSinceDate:todayDate] >= 0) {
        // Today
        [dateFormatter setDateFormat:@"HH:mm"];
        timeStr = [dateFormatter stringFromDate:notifTime];
    }else if ([notifTime timeIntervalSinceDate:yesterdayDate] >= 0){
        // Yesterday
        timeStr = @"Yesterday";
        
    } else {
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];

        timeStr = [dateFormatter stringFromDate:notifTime];
    }
    return timeStr;
}

- (UITableViewCell*) getTableViewCell:(UITableView*)tv sender:(NotificationController*)controller{
    CGSize senderStringSize = [notifSender sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:kLargeLabelFontSize]];
    CGSize msgStringSize = [notifMessage sizeWithFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize]];
    CGSize fixedStringSize = [@"are near you:" sizeWithFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize]];
    CGFloat msgRows = ceil(msgStringSize.width/tv.frame.size.width);

    CGFloat msgHeight = msgRows*msgStringSize.height+16;
	CGRect CellFrame   = CGRectMake(0, 0, tv.frame.size.width, [self getRowHeight:tv]);
	CGRect senderFrame = CGRectMake(1, 1, senderStringSize.width, 
                                    senderStringSize.height);
    CGRect fixedFrame = CGRectMake(1+senderStringSize.width+1, 1, 
                                   fixedStringSize.width, senderStringSize.height);
	CGRect timeFrame = CGRectMake(senderStringSize.width+fixedStringSize.width+3, 
                                  1, tv.frame.size.width-3-senderStringSize.width-fixedStringSize.width, senderStringSize.height);
	CGRect msgFrame = CGRectMake(1, msgStringSize.height+1, tv.frame.size.width-2, msgHeight);
	
    tv.backgroundColor = [UIColor clearColor];
	tv.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	//UILabel *lblCust;
	UILabel *lblSender;
    UILabel *lblFixed; // "are near you:"
	UILabel *lblTime;
    UITextView *txtMsg;
    UIView *line;
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"notifList"];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notifList"] autorelease];
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
	}
    
	// Sender
    lblSender.frame = senderFrame;
	lblSender.text = notifSender;
    
    lblFixed.frame = fixedFrame;
    lblFixed.text  = @"are near you:";
	
	// Time
    lblTime.frame = timeFrame;
	lblTime.text = [self timeAsString];
	
	// Message
    txtMsg.frame = msgFrame;
    txtMsg.text = notifMessage;
    txtMsg.userInteractionEnabled = FALSE;
    
    // Bottom line
    CGRect lineFrame = CGRectMake(0, CellFrame.size.height-3, CellFrame.size.width, 2);
    line.frame = lineFrame;
    
	return cell;
}

- (CGFloat) getRowHeight:(UITableView*)tv {
    CGSize senderStringSize = [notifSender sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:kLargeLabelFontSize]];
    CGSize msgStringSize = [notifMessage sizeWithFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize]];
    
    return (senderStringSize.height + ceil(msgStringSize.width/tv.frame.size.width)*msgStringSize.height + 16 + 2);
}
@end

//
//  UtilityClass.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/11/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//
#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "UtilityClass.h"
#import "CustomAlert.h"
#import "AppDelegate.h"
#import "NotifMessage.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
CGFloat animatedDistance;

@implementation UtilityClass

+ (void) showCustomAlert:(NSString*)title subTitle:(NSString*)subTitle
                 bgColor:(UIColor*) bgColor strokeColor:(UIColor*) strokeColor btnText:(NSString*) btnText {
    
    [CustomAlert setBackgroundColor:bgColor 
                    withStrokeColor:strokeColor];
    CustomAlert *alert = [[CustomAlert alloc]
                               initWithTitle:title
                               message:subTitle
                               delegate:nil
                               cancelButtonTitle:btnText
                               otherButtonTitles:nil];
    
    [alert show];
    [alert autorelease];
}

+(void)showAlert:(NSString *)title:(NSString *)subTitle
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Socialmaps" 
                                                    message:subTitle 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles: nil];
    [alert show];
    [alert release];
}


// Converts dat from mm/dd/yyyy to yyyy-mm-dd fromat
+ (NSString*) convertDateToDBFormat:(NSString*)adate {
    NSArray *fields = [adate componentsSeparatedByString:@"/"];
    NSString * dbDate = [NSString stringWithFormat:@"%@-%@-%@", [fields objectAtIndex:2],
                         [fields objectAtIndex:0], [fields objectAtIndex:1]];
    
    return dbDate;
}

// Converts date from NSDate to yyyy-mm-dd fromat
+ (NSString*) convertNSDateToDBFormat:(NSDate*)adate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];	
	[formatter setDateFormat:@"yyyy-MM-dd"];
	NSString *stringFromDate = [formatter stringFromDate:adate];
    return stringFromDate;
}


//
+ (NSString*) convertDateToDisplayFormat:(NSDate*)adate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
        
    NSString *stringFromDate = [formatter stringFromDate:adate];
    
    [formatter release];
    return stringFromDate;
}

// Calculates the age given the birthday in mm/dd/yyyy format
+ (int) getAgeFromBirthday:(NSDate*)birthday {
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];

    NSDate *now = [NSDate date];
    unsigned int unitFlags =  NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    NSDateComponents *breakdownInfo = [sysCalendar components:unitFlags fromDate:birthday  toDate:now  options:0];
    
    NSLog(@"Break down: %ddays %dmoths %dyears",[breakdownInfo day], [breakdownInfo month], [breakdownInfo year]);

    return [breakdownInfo year];
    
}
// Converts date in the display format MM/dd/yyyy to NSDate
+ (NSDate*) convertDateFromDisplay:(NSString*) date {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *convDate = [dateFormatter dateFromString:date];
    
    return convDate;
}
// Converts date expressed in date:timezone to NSDate
// date - yyyy-mm-dd HH:mm:ss
// tmezone type - N
// timezone - Europe/London
//
+ (NSDate*) convertDate:(NSString*) date tz_type:(NSString*)tz_type tz:(NSString*) tz {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:tz]];
    NSDate *convDate = [dateFormatter dateFromString:date];

//    NSLog(@"convertDate date=%@:tz_type=%@:tz%@ ---> %@", date, tz_type, tz, [convDate description]);
    return convDate;
}

+(NSString *)getAddressFromLatLon:(double)pdblLatitude withLongitude:(double)pdblLongitude

{
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%f,%f&output=csv",pdblLatitude, pdblLongitude];
    
    NSError* error;
    NSString *locationString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSASCIIStringEncoding error:&error];
    
    locationString = [locationString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    return [locationString substringFromIndex:6];
    
}

+(NSString *)convertNSDateToUnix:(NSDate *)date
{
    NSTimeInterval interval=[date timeIntervalSince1970];
    [NSNumber numberWithDouble:interval];
    NSLog(@"interval %lf",interval);
    return [NSString stringWithFormat:@"%lf",interval];
}

+ (NSString*) timeAsString:(NSDate*)notifTime {
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

/* 
 Connectivity testing code pulled from Apple's Reachability Example: http://developer.apple.com/library/ios/#samplecode/Reachability
 */
+(BOOL)hasConnectivity {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if(reachability != NULL) {
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                // if target host is not reachable
                return NO;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                // if target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
                return YES;
            }
            
            
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
            {
                // ... and the connection is on-demand (or on-traffic) if the
                //     calling application is using the CFSocketStream or higher APIs
                
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    // ... and no [user] intervention is needed
                    return YES;
                }
            }
            
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
            {
                // ... but WWAN connections are OK if the calling application
                //     is using the CFNetwork (CFSocketStream?) APIs.
                return YES;
            }
        }
    }
    
    return NO;
}

+(int) getNotificationCount {
    
    AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    int ignoreCount = 0;
    
    if (smAppDelegate.msgRead == TRUE)
        ignoreCount += [[self getUnreadMessage:smAppDelegate.messages] count];
    
    if (smAppDelegate.notifRead == TRUE)
        ignoreCount += [smAppDelegate.notifications count];
    
    int totalNotif = smAppDelegate.friendRequests.count + [self getUnreadMessage:smAppDelegate.messages].count + smAppDelegate.notifications.count + smAppDelegate.meetUpRequests.count - smAppDelegate.ignoreCount;
    
    NSLog(@"[self getUnreadMessage:smAppDelegate.messages].count %d smAppDelegate.notifications.count %d smAppDelegate.meetUpRequests.count %d smAppDelegate.ignoreCount %d ignoreCount %d",[self getUnreadMessage:smAppDelegate.messages].count,smAppDelegate.notifications.count,smAppDelegate.meetUpRequests.count,smAppDelegate.ignoreCount,ignoreCount);
    
    return totalNotif;
}

+(NSMutableArray *)getUnreadMessage:(NSMutableArray *)messageList
{
    NSMutableArray *unReadMessage=[[NSMutableArray alloc] init];
    for (int i=0; i<[messageList count]; i++)
    {
        NSString *msgSts=((NotifMessage *)[messageList objectAtIndex:i]).msgStatus;
        if ([msgSts isEqualToString:@"unread"])
        {
            [unReadMessage addObject:[messageList objectAtIndex:i]];
        }
    }
    
    return unReadMessage;
}

+ (NSString *) convertDateToUTC:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    NSString *timeStamp = [dateFormatter stringFromDate:date];
    [dateFormatter release];
    return timeStamp;
}

+ (NSString *) convertFromUTCDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    dateFormatter1.dateFormat = @"yyyy-MM-dd HH:mm";    
    NSTimeZone *gmt1 = [NSTimeZone systemTimeZone];
    [dateFormatter1 setTimeZone:gmt1];
    NSString *timeStamp1 = [dateFormatter1 stringFromDate:date];
    [dateFormatter1 release];
    return timeStamp1;
}

+(NSString *)getLocalTimeFromString:(NSString *)timeStamp
{
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    dateFormatter1.dateFormat = @"yyyy-MM-dd HH:mm Z";
    NSTimeZone *gmt1 = [NSTimeZone systemTimeZone];
    [dateFormatter1 setTimeZone:gmt1];
    NSString *timeStamp1 = [dateFormatter1 stringFromDate:[self dateFromString:timeStamp]];
    [dateFormatter1 release];
    
    NSLog(@"timeStamp1 %@",timeStamp1);
    return timeStamp1;
}

+(NSDate *)dateFromString:(NSString *)string
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormat setLocale:locale];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeInterval interval = 5 * 60 * 60;
    
    NSDate *date1 = [dateFormat dateFromString:string];  
    date1 = [date1 dateByAddingTimeInterval:interval];
    if(!date1) date1= [NSDate date];
    [dateFormat release];
    [locale release];
    
    return date1;
}

+(NSString *)getCurrentTimeOrDate:(NSString *)dateTime
{
    NSDate *date=[self dateFromString:dateTime];
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    dateFormatter1.dateFormat = @"MMMM d, yyyy";
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    dateFormatter2.dateFormat = @"hh:mm a";

    NSString *timeStamp1 = [dateFormatter1 stringFromDate:date];
    NSString *timeStamp2 = [dateFormatter1 stringFromDate:[NSDate date]];
    NSString *timeStamp3 = [dateFormatter2 stringFromDate:date];
    [dateFormatter1 release];
    [dateFormatter2 release];
    NSLog(@"timeStamp1 %@ timeStamp2 %@ timeStamp3 %@",timeStamp1,timeStamp2,timeStamp3);
    if ([timeStamp1 isEqualToString:timeStamp2]) {
        return [NSString stringWithFormat:@"at %@",timeStamp3];
    }
    else {
        return [NSString stringWithFormat:@"on %@",timeStamp1];
    }
    
}

+(void)beganEditing:(UIControl *)control
{
    //UIControl need to config here
    AppDelegate *smAppDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    CGRect textFieldRect =
	[smAppDelegate.window convertRect:control.bounds fromView:control];
    
    CGRect viewRect =
	[smAppDelegate.window convertRect:smAppDelegate.window.bounds fromView:smAppDelegate.window];
	
	CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
	midline - viewRect.origin.y
	- MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
	(MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
	* viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
	if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
	UIInterfaceOrientation orientation =
	[[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
	CGRect viewFrame = smAppDelegate.window.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [smAppDelegate.window setFrame:viewFrame];
    
    [UIView commitAnimations];
    
}

+(void)endEditing
{
    AppDelegate *smAppDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    CGRect viewFrame = smAppDelegate.window.frame;
    viewFrame.origin.y += animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];    
    [smAppDelegate.window setFrame:viewFrame];    
    [UIView commitAnimations];    
}

+(NSString *)getDistanceWithFormattingFromLocation:(Geolocation *)location
{
    AppDelegate *smAppDelegate = [(UIApplication *)[UIApplication sharedApplication] delegate];
    NSString *distanceText;
    Geolocation *myPos = smAppDelegate.currPosition;
    CLLocation *myLoc = [[CLLocation alloc] initWithLatitude:[myPos.latitude floatValue] longitude:[myPos.longitude floatValue]];
    CLLocation *userLoc = [[CLLocation alloc] initWithLatitude:[location.latitude floatValue] longitude:[location.longitude floatValue]];
    CLLocationDistance distanceFromMe = [myLoc distanceFromLocation:userLoc];
    if (distanceFromMe > 99999)
    {
        distanceText = [NSString stringWithFormat:@"%.2fkm", distanceFromMe/1000];
    }
    else
    {
        distanceText = [NSString stringWithFormat:@"%.2fm", distanceFromMe];
    }
    
    return distanceText;
}

+(float)getDistanceWithoutFormattingFromLocation:(Geolocation *)location
{
    AppDelegate *smAppDelegate = [(UIApplication *)[UIApplication sharedApplication] delegate];
    Geolocation *myPos = smAppDelegate.currPosition;
    CLLocation *myLoc = [[CLLocation alloc] initWithLatitude:[myPos.latitude floatValue] longitude:[myPos.longitude floatValue]];
    CLLocation *userLoc = [[CLLocation alloc] initWithLatitude:[location.latitude floatValue] longitude:[location.longitude floatValue]];
    CLLocationDistance distanceFromMe = [myLoc distanceFromLocation:userLoc];    
    return distanceFromMe;
}

@end

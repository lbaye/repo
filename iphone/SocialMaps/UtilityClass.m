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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title 
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

    NSLog(@"%@:%@:%@ ---> %@", date, tz_type, tz, [convDate description]);
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
    
    int totalNotif = smAppDelegate.friendRequests.count+
    [self getUnreadMessage:smAppDelegate.messages].count+smAppDelegate.notifications.count+smAppDelegate.meetUpRequests.count-smAppDelegate.ignoreCount;
    
//    int totalNotif = smAppDelegate.friendRequests.count+
//    [self getUnreadMessage:smAppDelegate.messages].count+smAppDelegate.notifications.count+smAppDelegate.meetUpRequests.count-smAppDelegate.ignoreCount-ignoreCount;

    
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

@end

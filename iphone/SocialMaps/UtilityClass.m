//
//  UtilityClass.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/11/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "UtilityClass.h"
#import "CustomAlert.h"

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
+ (int) getAgeFromBirthday:(NSString*)birthday {
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];	
	[format setDateFormat:@"MM/dd/yyyy"];
	NSDate *dob = [format dateFromString:birthday];	
    
    
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];

    NSDate *now = [NSDate date];
    unsigned int unitFlags =  NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    NSDateComponents *breakdownInfo = [sysCalendar components:unitFlags fromDate:dob  toDate:now  options:0];
    
    NSLog(@"Break down: %ddays %dmoths %dyears",[breakdownInfo day], [breakdownInfo month], [breakdownInfo year]);

    return [breakdownInfo year];
    
}
// Converts date in the display format MM/dd/yyyy to NSDate
+ (NSDate*) convertDateFromDisplay:(NSString*) date {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
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
    //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:tz]];
    NSDate *convDate = [dateFormatter dateFromString:date];

    NSLog(@"%@:%@:%@ ---> %@", date, tz_type, tz, [convDate description]);
    return convDate;
}
@end

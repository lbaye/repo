//
//  UtilityClass.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/11/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UtilityClass : NSObject

+ (void) showCustomAlert:(NSString*)title subTitle:(NSString*)subTitle
                 bgColor:(UIColor*) bgColor strokeColor:(UIColor*) strokeColor btnText:(NSString*) btnText;
+ (void)showAlert:(NSString *)title:(NSString *)subTitle;
+ (NSString*) convertDateToDBFormat:(NSString*)adate ;
+ (NSString*) convertNSDateToDBFormat:(NSDate*)adate;
+ (int) getAgeFromBirthday:(NSString*)birthday;
+ (NSDate*) convertDate:(NSString*) date tz_type:(NSString*)tz_type tz:(NSString*) tz;
+ (NSDate*) convertDateFromDisplay:(NSString*) date;
+ (NSString*) convertDateToDisplayFormat:(NSDate*)adate ;


@end

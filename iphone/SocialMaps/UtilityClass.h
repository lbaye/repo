//
//  UtilityClass.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/11/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Geolocation.h"

@interface UtilityClass : NSObject

/**
 * @brief Show custom alert with title, subtitle and color
 * @param (NSString) - Title
 * @param (NSString) - Subtitle
 * @param (UIColor) - Background color
 * @param (UIColor) - Stroke color
 * @param (NSString) - Button text 
 * @retval none
 */
+ (void) showCustomAlert:(NSString*)title subTitle:(NSString*)subTitle
                 bgColor:(UIColor*) bgColor strokeColor:(UIColor*) strokeColor btnText:(NSString*) btnText;

/**
 * @brief Show alert with title and subtitle
 * @param (NSString) - Title
 * @param (NSString) - Subtitle
 * @retval none
 */
+ (void)showAlert:(NSString *)title:(NSString *)subTitle;

/**
 * @brief Convert date string to database format
 * @param (NSString) - Date
 * @retval none
 */
+ (NSString*) convertDateToDBFormat:(NSString*)adate ;

/**
 * @brief Convert NSDate to database format
 * @param (NSDate) - Date
 * @retval none
 */
+ (NSString*) convertNSDateToDBFormat:(NSDate*)adate;

/**
 * @brief get age from NSDate
 * @param (NSDate) - Birthdate
 * @retval (int) - Calculated date
 */
+ (int) getAgeFromBirthday:(NSDate*)birthday;

/**
 * @brief Convert date to specific timezone
 * @param (NSString) - Date time zone type
 * @param (NSString) - Time zone type
 * @param (NSString) - Time zone
 * @retval (NSDate) - Converted date
 */
+ (NSDate*) convertDate:(NSString*) date tz_type:(NSString*)tz_type tz:(NSString*) tz;

/**
 * @brief Convert to NSDate from displaying date format
 * @param (NSString) - Birthdate
 * @retval (NSDate) - Converted date
 */
+ (NSDate*) convertDateFromDisplay:(NSString*) date;

/**
 * @brief Convert to NSDate to display date format
 * @param (NSDate) - Birthdate
 * @retval (NSString) - Converted date
 */
+ (NSString*) convertDateToDisplayFormat:(NSDate*)adate ;

/**
 * @brief Get address from lat and long
 * @param (double) - Latitude
 * @param (double) - Longitude
 * @retval (NSString) - Converted date
 */
+ (NSString *)getAddressFromLatLon:(double)pdblLatitude withLongitude:(double)pdblLongitude;

/**
 * @brief Convert NSDate to unix format
 * @param (NSDate) - Date
 * @retval (NSString) - Converted unix date string
 */
+ (NSString *)convertNSDateToUnix:(NSDate *)date;

/**
 * @brief Convert NSDate to string
 * @param (NSDate) - Date
 * @retval (NSString) - Converted date string
 */
+ (NSString*) timeAsString:(NSDate*)notifTime;

/**
 * @brief Convert NSDate to UTC format
 * @param (NSDate) - Date
 * @retval (NSString) - Converted UTC date string
 */
+ (NSString*) convertDateToUTC:(NSDate *)date;

/**
 * @brief Convert from UTC date
 * @param (NSDate) - Date
 * @retval (NSString) - Converted from UTC date
 */
+ (NSString*) convertFromUTCDate:(NSDate *)date;

/**
 * @brief Check whether has internet connectivity or not 
 * @param none
 * @retval (Bool) - Internet status
 */
+ (BOOL) hasConnectivity;

/**
 * @brief Get total notification
 * @param none
 * @retval (Int) - Total notification
 */
+ (int) getNotificationCount;

/**
 * @brief Get unread message from message list 
 * @param (NSMutableArray) - Message list
 * @retval (NSMutableArray) - Unread message list
 */
+ (NSMutableArray *)getUnreadMessage:(NSMutableArray *)messageList;

/**
 * @brief Get local time from string 
 * @param (NSString) - Time string
 * @retval (NSString) - Local time string
 */
+ (NSString *)getLocalTimeFromString:(NSString *)timeStamp;

/**
 * @brief Get NSDate from string 
 * @param (NSString) - Date-time string
 * @retval (NSDate) - NSDate object
 */
+ (NSDate *)dateFromString:(NSString *)string;

/**
 * @brief Get today's time or other day's date 
 * @param (NSString) - Date-time string
 * @retval (NSString) - Formatted date time string for display
 */
+ (NSString *)getCurrentTimeOrDate:(NSString *)dateTime;

/**
 * @brief Editing bagns
 * @param (UIControl) - Editing control
 * @retval none
 */
+ (void)beganEditing:(UIControl *)control;

/**
 * @brief Editing ends
 * @param none
 * @retval none
 */
+ (void)endEditing;

/**
 * @brief Get distance with meter/ km formatting 
 * @param (Geolocation) - Position of item
 * @retval (NSString) - Formatted distance for display
 */
+ (NSString *)getDistanceWithFormattingFromLocation:(Geolocation *)location;

/**
 * @brief Get distance without formatting 
 * @param (Geolocation) - Position of item
 * @retval (NSString) - Unformatted distance for display
 */
+ (float)getDistanceWithoutFormattingFromLocation:(Geolocation *)location;

@end

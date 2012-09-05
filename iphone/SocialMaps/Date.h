//
//  Date.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/14/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Date : NSObject
{
   NSString *date;
   NSString *timezoneType;
   NSString *timezone;
}

@property(nonatomic,retain) NSString *date;
@property(nonatomic,retain) NSString *timezoneType;
@property(nonatomic,retain) NSString *timezone;

@end

//
//  Event.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/23/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Date.h"
#import "Geolocation.h"

@interface Event : NSObject
{
    NSString *eventID;
    NSString *eventName;
    Date *eventDate;
    Date *eventCreateDate;
    NSString *eventShortSummary;
    NSString *eventAddress;
    NSString *eventDistance;
    Geolocation *eventLocation;
    NSString *willAttend;
}

@property(nonatomic,retain) NSString *eventID;
@property(nonatomic,retain) NSString *eventName;
@property(nonatomic,retain) Date *eventDate;
@property(nonatomic,retain) Date *eventCreateDate;
@property(nonatomic,retain) NSString *eventShortSummary;
@property(nonatomic,retain) NSString *eventAddress;
@property(nonatomic,retain) NSString *eventDistance;
@property(nonatomic,retain) Geolocation *eventLocation;
@property(nonatomic,retain) NSString *willAttend;

@end


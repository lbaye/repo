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
    NSString *eventDescription;
    NSString *eventAddress;
    NSString *eventDistance;
    Geolocation *eventLocation;
    NSString *willAttend;
    NSString *eventImageUrl;
    UIImage *eventImage;
    NSMutableArray *eventList;
    NSString *myResponse;
    BOOL isInvited;
    BOOL guestCanInvite;
    NSMutableArray *guestList;
    NSMutableArray *circleList;
    NSString *owner;
    NSString *eventType;
    NSMutableArray *yesArr;
    NSMutableArray *noArr;
    NSMutableArray *maybeArr;
    NSString *permission;
    NSMutableArray *permittedUsers;
    NSMutableArray *permittedCircles;
}

@property(nonatomic,retain) NSString *eventID;
@property(nonatomic,retain) NSString *eventName;
@property(nonatomic,retain) Date *eventDate;
@property(nonatomic,retain) Date *eventCreateDate;
@property(nonatomic,retain) NSString *eventShortSummary;
@property(nonatomic,retain) NSString *eventDescription;
@property(nonatomic,retain) NSString *eventAddress;
@property(nonatomic,retain) NSString *eventDistance;
@property(nonatomic,retain) Geolocation *eventLocation;
@property(nonatomic,retain) NSString *willAttend;
@property(nonatomic,retain) NSMutableArray *eventList;

@property(nonatomic,retain) NSString *eventImageUrl;
@property(nonatomic,retain) UIImage *eventImage;
@property(nonatomic,retain) NSString *myResponse;
@property(nonatomic,assign) BOOL isInvited;
@property(nonatomic,assign) BOOL guestCanInvite;
@property(nonatomic,retain) NSMutableArray *guestList;
@property(nonatomic,retain) NSMutableArray *circleList;
@property(nonatomic,retain) NSString *owner;
@property(nonatomic,retain) NSString *eventType;

@property(nonatomic,retain) NSMutableArray *yesArr;
@property(nonatomic,retain) NSMutableArray *noArr;
@property(nonatomic,retain) NSMutableArray *maybeArr;    
@property(nonatomic,retain) NSString *permission;

@property(nonatomic,retain) NSMutableArray *permittedUsers;
@property(nonatomic,retain) NSMutableArray *permittedCircles;

@end

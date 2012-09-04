//
//  Event.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/23/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "Event.h"

@implementation Event
@synthesize eventID;
@synthesize eventName;
@synthesize eventShortSummary;
@synthesize eventAddress;
@synthesize eventDistance;
@synthesize eventLocation;
@synthesize willAttend;
@synthesize eventDate;
@synthesize eventCreateDate;
@synthesize eventList;
@synthesize eventImageUrl;
@synthesize eventImage;
@synthesize myResponse; 
@synthesize eventDescription;
@synthesize isInvited,guestCanInvite,guestList,owner,circleList;

- (id)init
{
    eventDate=[[Date alloc] init];
    eventCreateDate=[[Date alloc] init];
    eventLocation=[[Geolocation alloc] init];
    return self;
}
@end

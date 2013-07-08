//
//  Plan.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 11/19/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "Plan.h"

@implementation Plan
@synthesize planId;
@synthesize planDescription;
@synthesize planeDate;
@synthesize planAddress;
@synthesize planGeolocation;
@synthesize planPermission;
@synthesize permittedUsers;
@synthesize permittedCircles;
@synthesize planDistance;
@synthesize planImageUrl;
@synthesize planImage;


-(id)init
{
    self=[super init];
    if (self) {
        planGeolocation=[[Geolocation alloc] init];
    }
    return self;
}

@end

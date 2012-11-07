//
//  Geotag.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 11/5/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "Geotag.h"

@implementation Geotag
@synthesize geoTagID;
@synthesize geoTagTitle;
@synthesize geoTagDescription;
@synthesize geoTagAddress;
@synthesize geoTagDistance;
@synthesize geoTagLocation;
@synthesize geoTagImageUrl;
@synthesize geoTagImage;
@synthesize frndList;
@synthesize circleList;
@synthesize permission;
@synthesize category;
@synthesize permittedUsers;
@synthesize permittedCircles;
@synthesize date;

- (id)init
{
    geoTagLocation=[[Geolocation alloc] init];
    frndList=[[NSMutableArray alloc] init];
    circleList=[[NSMutableArray alloc] init];

    return self;
}

@end

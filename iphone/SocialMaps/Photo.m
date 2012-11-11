//
//  Photo.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 10/30/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "Photo.h"

@implementation Photo
@synthesize image;
@synthesize address;
@synthesize comment;
@synthesize imageUrl;
@synthesize location;
@synthesize photoId;
@synthesize title;
@synthesize description;
@synthesize photoImage;
@synthesize permission;
@synthesize permittedUsers;
@synthesize permittedCircles;


- (id)init
{
    location=[[Geolocation alloc] init];
    permittedUsers=[[NSMutableArray alloc] init];
    permittedCircles=[[NSMutableArray alloc] init];
    return self;
}

@end

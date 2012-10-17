//
//  ShareLocation.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "ShareLocation.h"
@implementation LocationPrivacySettings
@synthesize duration;
@synthesize radius;
@end

@implementation LocationCircleSettings
@synthesize circleInfo;
@synthesize privacy;
@end

@implementation LocationCustomSettings
@synthesize circles;
@synthesize friends;
@synthesize privacy;
@end

@implementation ShareLocation

@synthesize status;
@synthesize circles;
@synthesize geoFences;
@synthesize strangers;
@synthesize custom;
@end

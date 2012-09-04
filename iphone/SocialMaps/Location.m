//
//  Location.m
//  SocialMaps
//
//  Created by Arif Shakoor on 7/24/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "Location.h"

@implementation Location
@synthesize name = _name;
@synthesize address = _address;
@synthesize type = _type;
@synthesize coordinate = _coordinate;

- (id)initWithName:(NSString*)name address:(NSString*)address type:(NSString*)type
        coordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        _name = [name copy];
        _address = [address copy];
        _type = [type copy];
        _coordinate = coordinate;
    }
    return self;
}

- (NSString *)title {
    if ([_name isKindOfClass:[NSNull class]]) 
        return @"Unknown";
    else
        return _name;
}

- (NSString *)subtitle {
    return _address;
}

@end

//
//  Location.h
//  SocialMaps
//
//  Created by Arif Shakoor on 7/24/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Location : NSObject <MKAnnotation> {
    NSString *_name;
    NSString *_address;
    NSString *_type;
    CLLocationCoordinate2D _coordinate;
}

@property (copy) NSString *name;
@property (copy) NSString *address;
@property (copy) NSString *type;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithName:(NSString*)name address:(NSString*)address type:(NSString*)type coordinate:(CLLocationCoordinate2D)coordinate;

@end
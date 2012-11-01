//
//  Geofence.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Geofence : NSObject
{
    NSString *name;
    NSString *lat;
    NSString *lng;
    NSString *radius;
}

@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *lat;
@property (nonatomic,retain) NSString *lng;
@property (nonatomic,retain) NSString *radius;

@end

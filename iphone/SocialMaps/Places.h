//
//  Places.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/16/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Geolocation.h"

@interface Places : NSObject
{
    Geolocation *location;
    Geolocation *northeast;
    Geolocation *southwest;
    NSString *icon;
    NSString *ID;
    NSString *name;
    NSString *reference;
    NSMutableArray *typeArr;
    NSString *vicinity;
}

@property(nonatomic,retain) Geolocation *location;
@property(nonatomic,retain) Geolocation *northeast;
@property(nonatomic,retain) Geolocation *southwest;
@property(nonatomic,retain) NSString *icon;
@property(nonatomic,retain) NSString *ID;
@property(nonatomic,retain) NSString *name;
@property(nonatomic,retain) NSString *reference;
@property(nonatomic,retain) NSMutableArray *typeArr;
@property(nonatomic,retain) NSString *vicinity;
@end

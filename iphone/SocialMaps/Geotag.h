//
//  Geotag.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 11/5/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Geolocation.h"
#import "Date.h"

@interface Geotag : NSObject
{
    NSString *geoTagID;
    NSString *geoTagTitle;
    NSString *geoTagDescription;
    NSString *geoTagAddress;
    NSString *geoTagDistance;
    Geolocation *geoTagLocation;
    NSString *geoTagImageUrl;
    UIImage *geoTagImage;
    NSMutableArray *frndList;
    NSMutableArray *circleList;
    NSString *permission;
    NSString *category;
    NSString *date;
    NSMutableArray *permittedUsers;
    NSMutableArray *permittedCircles;
    NSString *ownerLastName;
    NSString *ownerFirstName;    
}

@property(nonatomic,retain) NSString *geoTagID;
@property(nonatomic,retain) NSString *geoTagTitle;
@property(nonatomic,retain) NSString *geoTagDescription;
@property(nonatomic,retain) NSString *geoTagAddress;
@property(nonatomic,retain) NSString *geoTagDistance;
@property(nonatomic,retain) Geolocation *geoTagLocation;
@property(nonatomic,retain) NSString *geoTagImageUrl;
@property(nonatomic,retain) UIImage *geoTagImage;
@property(nonatomic,retain) NSMutableArray *frndList;
@property(nonatomic,retain) NSMutableArray *circleList;
@property(nonatomic,retain) NSString *permission;
@property(nonatomic,retain) NSString *category;
@property(nonatomic,retain) NSString *date;
@property(nonatomic,retain) NSMutableArray *permittedUsers;
@property(nonatomic,retain) NSMutableArray *permittedCircles;
@property(nonatomic,retain) NSString *ownerLastName;
@property(nonatomic,retain) NSString *ownerFirstName;    


@end

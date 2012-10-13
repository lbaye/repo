//
//  ShareLocation.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserCircle.h"

typedef struct _LOC_PRIVACY_SETTINGS {
    NSString    *duration;
    NSString    *radius;
} LocationPrivacySettings;

typedef struct _LOC_CIRCLE_SETTINGS {
    UserCircle  *circleInfo;
    LocationPrivacySettings privacy;
} LocationCircleSettings;

typedef struct _LOC_CUSTOM_SETTINGS {
    NSMutableArray  *circles;
    NSMutableArray  *friends;
    LocationPrivacySettings privacy;
} LocationCustomSettings;

@interface ShareLocation : NSObject
{
    NSString *status;
    NSMutableArray *permittedUsers;
    NSMutableArray *permittedCircles;
    NSString *friendDuration;
    NSString *friendRadius;
    NSString *strangersDuration;
    NSString *strangersRadius;
    
    // New design
    NSMutableArray          *circles;  // Array of LocationCircleSettings
    LocationCustomSettings  custom;
    NSMutableArray          *geoFences; // Array of GeoFence
    LocationPrivacySettings strangers;
}

@property(nonatomic,retain) NSString *status;
@property(nonatomic,retain) NSMutableArray *permittedUsers;
@property(nonatomic,retain) NSMutableArray *permittedCircles;
@property(nonatomic,retain) NSString *friendDuration;
@property(nonatomic,retain) NSString *friendRadius;
@property(nonatomic,retain) NSString *strangersDuration;
@property(nonatomic,retain) NSString *strangersRadius;
// New code
@property(nonatomic,retain) NSMutableArray *circles;
@property(nonatomic) LocationCustomSettings custom;
@property(nonatomic,retain) NSMutableArray *geoFences;
@property(nonatomic) LocationPrivacySettings strangers;
@end

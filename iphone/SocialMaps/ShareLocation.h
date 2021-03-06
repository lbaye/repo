//
//  ShareLocation.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserCircle.h"

@interface LocationPrivacySettings : NSObject {
    int    duration;
    int    radius;
}
@property(nonatomic) int duration;
@property(nonatomic) int radius;
@end

@interface LocationCircleSettings : NSObject {
    UserCircle  *circleInfo;
    LocationPrivacySettings *privacy;
}
@property(nonatomic,retain) UserCircle  *circleInfo;
@property(nonatomic,retain) LocationPrivacySettings *privacy;
@end

@interface LocationCustomSettings : NSObject {
    NSMutableArray  *circles;   // Array of Circle id
    NSMutableArray  *friends;   // Array of User id
    LocationPrivacySettings *privacy;
}
@property(nonatomic,retain) NSMutableArray  *circles;
@property(nonatomic,retain) NSMutableArray  *friends;
@property(nonatomic,retain) LocationPrivacySettings *privacy;
@end

@interface LocationPlatformSettings : NSObject {
    NSString                *platformName;
    LocationPrivacySettings *privacy;
}
@property(nonatomic,retain) NSString  *platformName;
@property(nonatomic,retain) LocationPrivacySettings *privacy;
@end

@interface ShareLocation : NSObject
{
    NSString *status;
    NSMutableArray          *circles;   // Array of LocationCircleSettings
    LocationCustomSettings  *custom;
    NSMutableArray          *geoFences; // Array of GeoFence
    LocationPrivacySettings *strangers;
    NSMutableArray          *platforms; // Array of LocationPlatformSettings
}

@property(nonatomic,retain) NSString *status;
@property(nonatomic,retain) NSMutableArray *circles;
@property(nonatomic,retain) LocationCustomSettings *custom;
@property(nonatomic,retain) NSMutableArray *geoFences;
@property(nonatomic,retain) LocationPrivacySettings *strangers;
@property(nonatomic,retain) NSMutableArray *platforms;
@end

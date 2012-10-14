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
//@public
    NSString    *duration;
    NSString    *radius;
}
@property(nonatomic,retain) NSString    *duration;
@property(nonatomic,retain) NSString    *radius;
@end

@interface LocationCircleSettings : NSObject {
//@public
    UserCircle  *circleInfo;
    LocationPrivacySettings *privacy;
}
@property(nonatomic,retain) UserCircle  *circleInfo;
@property(nonatomic,retain) LocationPrivacySettings *privacy;
@end

@interface LocationCustomSettings : NSObject {
//@public
    NSMutableArray  *circles;
    NSMutableArray  *friends;
    LocationPrivacySettings *privacy;
}
@property(nonatomic,retain) NSMutableArray  *circles;
@property(nonatomic,retain) NSMutableArray  *friends;
@property(nonatomic,retain) LocationPrivacySettings *privacy;
@end

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
    LocationCustomSettings  *custom;
    NSMutableArray          *geoFences; // Array of GeoFence
    LocationPrivacySettings *strangers;
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
@property(nonatomic,retain) LocationCustomSettings *custom;
@property(nonatomic,retain) NSMutableArray *geoFences;
@property(nonatomic,retain) LocationPrivacySettings *strangers;
@end

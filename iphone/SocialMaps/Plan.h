//
//  Plan.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 11/19/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Geolocation.h"

@interface Plan : NSObject
{
    NSString *planId;
    NSString *planDescription;
    NSString *planeDate;
    NSString *planAddress;
    Geolocation *planGeolocation;
    NSString *planPermission;
    NSMutableArray *permittedUsers;
    NSMutableArray *permittedCircles;
    NSString *planDistance;
    NSString *planImageUrl;
    UIImage *planImage;    
}

@property(nonatomic,retain) NSString *planId;
@property(nonatomic,retain) NSString *planDescription;
@property(nonatomic,retain) NSString *planeDate;
@property(nonatomic,retain) NSString *planAddress;
@property(nonatomic,retain) Geolocation *planGeolocation;
@property(nonatomic,retain) NSString *planPermission;
@property(nonatomic,retain) NSMutableArray *permittedUsers;
@property(nonatomic,retain) NSMutableArray *permittedCircles;
@property(nonatomic,retain) NSString *planDistance;
@property(nonatomic,retain) NSString *planImageUrl;
@property(nonatomic,retain) UIImage *planImage;    


@end

//
//  Geolocation.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/16/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Geolocation : NSObject
{
    NSString *latitude;
    NSString *longitude;
    NSDate   *positionTime;
}
@property(nonatomic,retain) NSString *latitude;
@property(nonatomic,retain) NSString *longitude;
@property(nonatomic,retain) NSDate   *positionTime;

@end

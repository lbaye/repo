//
//  ShareLocation.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareLocation : NSObject
{
    NSString *status;
    NSMutableArray *permittedUsers;
    NSString *permittedCircles;
    NSString *friendDuration;
    NSString *friendRadius;
    NSString *strangersDuration;
    NSString *strangersRadius;
}

@property(nonatomic,retain) NSString *status;
@property(nonatomic,retain) NSMutableArray *permittedUsers;
@property(nonatomic,retain) NSString *permittedCircles;
@property(nonatomic,retain) NSString *friendDuration;
@property(nonatomic,retain) NSString *friendRadius;
@property(nonatomic,retain) NSString *strangersDuration;
@property(nonatomic,retain) NSString *strangersRadius;

@end

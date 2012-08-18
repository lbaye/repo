//
//  People.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/16/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Date.h"

@interface People : NSObject
{
    NSString *userId;
    NSString *email;
    NSString *firstName;
    NSString *lastName;
    NSString *avatar;
    NSString *enabled;
    Date *lastLogin;    
    NSString *settingUnit;    
    NSString *currentLocationLat;
    NSString *currentLocationLng;
    Date *createDate;
    Date *updateDate;
    NSString *distance;
    NSString *gender;
    NSString *relationsipStatus;
    NSString *city;
    NSString *workStatus;
    BOOL external;
    NSString *statusMsg;
    NSString *dateOfBirth;
    NSString *age;
}

@property(nonatomic,retain) NSString *userId;
@property(nonatomic,retain) NSString *email;
@property(nonatomic,retain) NSString *firstName;
@property(nonatomic,retain) NSString *lastName;
@property(nonatomic,retain) NSString *avatar;
@property(nonatomic,retain) NSString *enabled;
@property(nonatomic,retain) Date *lastLogin;    
@property(nonatomic,retain) NSString *settingUnit;    
@property(nonatomic,retain) NSString *currentLocationLat;
@property(nonatomic,retain) NSString *currentLocationLng;
@property(nonatomic,retain) Date *createDate;
@property(nonatomic,retain) Date *updateDate;
@property(nonatomic,retain) NSString *distance;
@property(nonatomic,retain) NSString *gender;
@property(nonatomic,retain) NSString *relationsipStatus;
@property(nonatomic,retain) NSString *city;
@property(nonatomic,retain) NSString *workStatus;
@property(nonatomic) BOOL external;
@property(nonatomic,retain) NSString *statusMsg;
@property(nonatomic,retain) NSString *dateOfBirth;
@property(nonatomic,retain) NSString *age;


@end

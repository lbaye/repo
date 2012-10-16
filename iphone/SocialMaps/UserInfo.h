//
//  UserInfo.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/14/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Address.h"
#import "Date.h"

@interface UserInfo : NSObject
{
    NSString *userId;
    NSString *email;
    NSString *firstName;
    NSString *lastName;
    NSString *avatar;
    UIImage  *icon;
    NSString *deactivated;
    NSString *authToken;
    NSString *settings;
    NSString *source;
    NSDate  *dateOfBirth;
    NSString *bio;
    NSString *gender;
    NSString *username;
    NSString *interests;
    NSString *workStatus;
    NSString *relationshipStatus;
    NSString *currentLocationLat;
    NSString *currentLocationLng;    
    bool enabled;
    bool visible;
    NSString *regMedia;
    NSString *loginCount;
    NSDate *lastLogin;
    NSDate* createDate;
    NSDate* updateDate;
    NSMutableArray *blockedUsers;
    NSMutableArray *blockedBy;
    NSString *unit;
    int distance;
    int age;
    NSMutableArray *circles;
    Address *address;
    NSString *coverPhoto;
    NSString *status;
    NSString *shareLocationOption;
}
@property(nonatomic,retain) NSString *userId;
@property(nonatomic,retain) NSString *email;
@property(nonatomic,retain) NSString *firstName;
@property(nonatomic,retain) NSString *lastName;
@property(nonatomic,retain) NSString *avatar;
@property(nonatomic,retain) UIImage  *icon;
@property(nonatomic,retain) NSString *deactivated;
@property(nonatomic,retain) NSString *authToken;
@property(nonatomic,retain) NSString *settings;
@property(nonatomic,retain) NSString *source;
@property(nonatomic,retain) NSDate *dateOfBirth;
@property(nonatomic,retain) NSString *bio;
@property(nonatomic,retain) NSString *gender;
@property(nonatomic,retain) NSString *username;
@property(nonatomic,retain) NSString *interests;
@property(nonatomic,retain) NSString *workStatus;
@property(nonatomic,retain) NSString *relationshipStatus;
@property(nonatomic,retain) NSString *currentLocationLat;
@property(nonatomic,retain) NSString *currentLocationLng;    
@property(atomic) bool enabled;
@property(atomic) bool visible;
@property(nonatomic,retain) NSString *regMedia;
@property(nonatomic,retain) NSString *loginCount;
@property(nonatomic,retain) NSDate *lastLogin;
@property(nonatomic,retain) NSDate* createDate;
@property(nonatomic,retain) NSDate* updateDate;
@property(nonatomic,retain) NSMutableArray *blockedUsers;
@property(nonatomic,retain) NSMutableArray *blockedBy;
@property(nonatomic,retain) NSString *unit;
@property(atomic) int distance;
@property(atomic) int age;
@property(nonatomic,retain) NSMutableArray *circles;
@property(nonatomic,retain) Address *address;
@property(nonatomic,retain) NSString *coverPhoto;
@property(nonatomic,retain) NSString *status;
@property(nonatomic,retain) NSString *shareLocationOption;

@end

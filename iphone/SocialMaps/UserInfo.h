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
    NSString *deactivated;
    NSString *authToken;
    NSString *settings;
    NSString *source;
    NSString *dateOfBirth;
    NSString *bio;
    NSString *gender;
    NSString *username;
    NSString *interests;
    NSString *workStatus;
    NSString *relationshipStatus;
    NSString *currentLocationLat;
    NSString *currentLocationLng;    
    NSString *enabled;
    NSString *visible;
    NSString *regMedia;
    NSString *loginCount;
    NSString *lastLogin;
    Date* createDate;
    Date* updateDate;
    NSString *blockedUsers;
    NSString *blockedBy;
    NSString *unit;
    NSString *distance;
    NSString *circles;
    Address *address;
}
@property(nonatomic,retain) NSString *userId;
@property(nonatomic,retain) NSString *email;
@property(nonatomic,retain) NSString *firstName;
@property(nonatomic,retain) NSString *lastName;
@property(nonatomic,retain) NSString *avatar;
@property(nonatomic,retain) NSString *deactivated;
@property(nonatomic,retain) NSString *authToken;
@property(nonatomic,retain) NSString *settings;
@property(nonatomic,retain) NSString *source;
@property(nonatomic,retain) NSString *dateOfBirth;
@property(nonatomic,retain) NSString *bio;
@property(nonatomic,retain) NSString *gender;
@property(nonatomic,retain) NSString *username;
@property(nonatomic,retain) NSString *interests;
@property(nonatomic,retain) NSString *workStatus;
@property(nonatomic,retain) NSString *relationshipStatus;
@property(nonatomic,retain) NSString *currentLocationLat;
@property(nonatomic,retain) NSString *currentLocationLng;    
@property(nonatomic,retain) NSString *enabled;
@property(nonatomic,retain) NSString *visible;
@property(nonatomic,retain) NSString *regMedia;
@property(nonatomic,retain) NSString *loginCount;
@property(nonatomic,retain) NSString *lastLogin;
@property(nonatomic,retain) Date* createDate;
@property(nonatomic,retain) Date* updateDate;
@property(nonatomic,retain) NSString *blockedUsers;
@property(nonatomic,retain) NSString *blockedBy;
@property(nonatomic,retain) NSString *unit;
@property(nonatomic,retain) NSString *distance;
@property(nonatomic,retain) NSString *circles;
@property(nonatomic,retain) Address *address;

@end

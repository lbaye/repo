//
//  User.h
//  SocialMaps
//
//  Created by Arif Shakoor on 7/23/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject {
    NSString* id;
    NSString* firstName;
    NSString* lastName;
    NSString* email;
    NSString* password;
    NSString* gender;
    NSString* facebookId;
    NSString* facebookAuthToken;
    NSString* dateOfBirth;
    NSString* avatar;
    NSString* age;
    NSString* bio;
    NSString* street;
    NSString* city;
    NSString* state;
    NSString* postCode;
    NSString* country;
    NSString* interests;
    NSString* workStatus;
    NSString* relationshipStatus;
    NSString* authToken;
    NSString* message;
    UIImage * bg;
    //UIImage * avatar;
    bool    isOnline;
    NSString    *address;
    NSString    *friendRequest;
    NSString    *circles;
    
    NSMutableArray *friendsList;
    NSMutableArray *circleList;
    NSString *currentLocationLat;
    NSString *currentLocationLng;
}

@property (atomic, retain) NSString *id;
@property (atomic, retain) NSString *firstName;
@property (atomic, retain) NSString *lastName;
@property (atomic, retain) NSString *email;
@property (atomic, retain) NSString *password;
@property (atomic, retain) NSString *gender;
@property (atomic, retain) NSString *facebookId;
@property (atomic, retain) NSString *facebookAuthToken;
@property (atomic, retain) NSString *dateOfBirth;
@property (atomic, retain) NSString *avatar;
@property (atomic, retain) NSString *age;
@property (atomic, retain) NSString *bio;
@property (atomic, retain) NSString *street;
@property (atomic, retain) NSString *city;
@property (atomic, retain) NSString *state;
@property (atomic, retain) NSString *postCode;
@property (atomic, retain) NSString *country;
@property (atomic, retain) NSString *interests;
@property (atomic, retain) NSString *workStatus;
@property (atomic, retain) NSString *relationshipStatus;
@property (atomic, retain) NSString *authToken;
@property (atomic, retain) NSString *message;
@property (atomic, retain) UIImage  *bg;
@property (atomic) bool isOnline;
@property (atomic, retain) NSString *address;
@property (atomic, retain) NSString *friendRequest;
@property (atomic, retain) NSString *circles;

@property(nonatomic,retain) NSMutableArray *friendsList;
@property(nonatomic,retain) NSMutableArray *circleList;
@property (atomic, retain) NSString *currentLocationLat;
@property (atomic, retain) NSString *currentLocationLng;

@end
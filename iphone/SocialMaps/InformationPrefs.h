//
//  InformationPrefs.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/12/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "NewsFeed.h"

@interface InformationPrefs : NSObject
{
    User *friends;
    User *stranger;
    User *people;
    User *family;
    NewsFeed *newsFeed;
    
    NSString *firstNameStr;
    NSString *lastNameStr;
    NSString *emailStr;
    NSString *dateOfBirthStr;
    NSString *bioStr;
    NSString *interestsStr;
    NSString *workStatusStr;
    NSString *relationshipStatusStr;
    NSString *addressStr;
    NSString *friendRequestStr;
    NSString *circlesStr;
    NSString *newsfeedStr;
    NSString *avatarStr;
    NSString *usernameStr;
    NSString *nameStr;
    NSString *genderStr;
    
    NSMutableArray *firstNameFrnd;
    NSMutableArray *lastNameFrnd;
    NSMutableArray *emailFrnd;
    NSMutableArray *dateOfBirthFrnd;
    NSMutableArray *bioFrnd;
    NSMutableArray *interestsFrnd;
    NSMutableArray *workStatusFrnd;
    NSMutableArray *relationshipStatusFrnd;
    NSMutableArray *addressFrnd;
    NSMutableArray *friendRequestFrnd;
    NSMutableArray *circlesFrnd;
    NSMutableArray *newsfeedFrnd;
    NSMutableArray *avatarFrnd;
    NSMutableArray *usernameFrnd;
    NSMutableArray *nameFrnd;
    NSMutableArray *genderFrnd;
    
    NSMutableArray *firstNameCircle;
    NSMutableArray *lastNameCircle;
    NSMutableArray *emailCircle;
    NSMutableArray *dateOfBirthCircle;
    NSMutableArray *bioCircle;
    NSMutableArray *interestsCircle;
    NSMutableArray *workStatusCircle;
    NSMutableArray *relationshipStatusCircle;
    NSMutableArray *addressCircle;
    NSMutableArray *friendRequestCircle;
    NSMutableArray *circlesCircle;
    NSMutableArray *newsfeedCircle;
    NSMutableArray *avatarCircle;
    NSMutableArray *usernameCircle;
    NSMutableArray *nameCircle;
    NSMutableArray *genderCircle;
}

@property(nonatomic,retain) User *friends;
@property(nonatomic,retain) User *stranger;
@property(nonatomic,retain) User *people;
@property(nonatomic,retain) User *family;
@property(nonatomic,retain) NewsFeed *newsFeed;

@property(nonatomic,retain) NSString *firstNameStr;
@property(nonatomic,retain) NSString *lastNameStr;
@property(nonatomic,retain) NSString *emailStr;
@property(nonatomic,retain) NSString *dateOfBirthStr;
@property(nonatomic,retain) NSString *bioStr;
@property(nonatomic,retain) NSString *interestsStr;
@property(nonatomic,retain) NSString *workStatusStr;
@property(nonatomic,retain) NSString *relationshipStatusStr;
@property(nonatomic,retain) NSString *addressStr;
@property(nonatomic,retain) NSString *friendRequestStr;
@property(nonatomic,retain) NSString *circlesStr;
@property(nonatomic,retain) NSString *newsfeedStr;
@property(nonatomic,retain) NSString *avatarStr;
@property(nonatomic,retain) NSString *usernameStr;
@property(nonatomic,retain) NSString *nameStr;
@property(nonatomic,retain) NSString *genderStr;

@property(nonatomic,retain) NSMutableArray *firstNameFrnd;
@property(nonatomic,retain) NSMutableArray *lastNameFrnd;
@property(nonatomic,retain) NSMutableArray *emailFrnd;
@property(nonatomic,retain) NSMutableArray *dateOfBirthFrnd;
@property(nonatomic,retain) NSMutableArray *bioFrnd;
@property(nonatomic,retain) NSMutableArray *interestsFrnd;
@property(nonatomic,retain) NSMutableArray *workStatusFrnd;
@property(nonatomic,retain) NSMutableArray *relationshipStatusFrnd;
@property(nonatomic,retain) NSMutableArray *addressFrnd;
@property(nonatomic,retain) NSMutableArray *friendRequestFrnd;
@property(nonatomic,retain) NSMutableArray *circlesFrnd;
@property(nonatomic,retain) NSMutableArray *newsfeedFrnd;
@property(nonatomic,retain) NSMutableArray *avatarFrnd;
@property(nonatomic,retain) NSMutableArray *usernameFrnd;
@property(nonatomic,retain) NSMutableArray *nameFrnd;
@property(nonatomic,retain) NSMutableArray *genderFrnd;

@property(nonatomic,retain) NSMutableArray *firstNameCircle;
@property(nonatomic,retain) NSMutableArray *lastNameCircle;
@property(nonatomic,retain) NSMutableArray *emailCircle;
@property(nonatomic,retain) NSMutableArray *dateOfBirthCircle;
@property(nonatomic,retain) NSMutableArray *bioCircle;
@property(nonatomic,retain) NSMutableArray *interestsCircle;
@property(nonatomic,retain) NSMutableArray *workStatusCircle;
@property(nonatomic,retain) NSMutableArray *relationshipStatusCircle;
@property(nonatomic,retain) NSMutableArray *addressCircle;
@property(nonatomic,retain) NSMutableArray *friendRequestCircle;
@property(nonatomic,retain) NSMutableArray *circlesCircle;
@property(nonatomic,retain) NSMutableArray *newsfeedCircle;
@property(nonatomic,retain) NSMutableArray *avatarCircle;
@property(nonatomic,retain) NSMutableArray *usernameCircle;
@property(nonatomic,retain) NSMutableArray *nameCircle;
@property(nonatomic,retain) NSMutableArray *genderCircle;

@end

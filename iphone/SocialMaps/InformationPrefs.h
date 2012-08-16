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
}

@property(nonatomic,retain) User *friends;
@property(nonatomic,retain) User *stranger;
@property(nonatomic,retain) User *people;
@property(nonatomic,retain) User *family;
@property(nonatomic,retain) NewsFeed *newsFeed;

@end

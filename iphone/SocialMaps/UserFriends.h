//
//  UserFriends.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/7/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserFriends : NSObject
{
    NSString* userId;
    NSString* userName;
    NSString* imageUrl;
    UIImage* userProfileImage;
}
@property (atomic,retain) NSString* userId;
@property (atomic,retain) NSString* userName;
@property (atomic,retain) NSString* imageUrl;
@property(nonatomic,retain) UIImage* userProfileImage;

@end

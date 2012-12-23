//
//  EachFriendInList.h
//  SocialMaps
//
//  Created by Warif Rishi on 11/18/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file EachFriendInList.h
 * @brief Holds each friend in FriendList class.
 */

#import <Foundation/Foundation.h>

@interface EachFriendInList : NSObject
{
    NSString *friendName;
    NSString *friendId;
    NSString *friendDistance;
    NSMutableArray *friendCircle;
    NSString *friendAvater;

}

@property (nonatomic, retain) NSString *friendName;
@property (nonatomic, retain) NSString *friendId;
@property (nonatomic, retain) NSString *friendDistance;
@property (nonatomic, retain) NSMutableArray *friendCircle;
@property (nonatomic, retain) NSString *friendAvater;


@end

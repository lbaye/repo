//
//  NewsFeed.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/13/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsFeed : NSObject
{
    NSString *friends;
    NSString *strangers;
    NSString *people;
    NSString *family;
}

@property(nonatomic,retain) NSString *friends;
@property(nonatomic,retain) NSString *strangers;
@property(nonatomic,retain) NSString *people;
@property(nonatomic,retain) NSString *family;

@end

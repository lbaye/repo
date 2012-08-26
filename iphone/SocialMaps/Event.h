//
//  Event.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/23/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject
{
    NSString *title;
    NSString *description;
    NSString *duration;
    NSMutableArray *guests;
    NSString *location;
    NSString *time;
}

@property(nonatomic,retain) NSString *title;
@property(nonatomic,retain) NSString *description;
@property(nonatomic,retain) NSString *duration;
@property(nonatomic,retain) NSMutableArray *guests;
@property(nonatomic,retain) NSString *location;
@property(nonatomic,retain) NSString *time;

@end

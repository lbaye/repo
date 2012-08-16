//
//  Layer.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/12/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Layer : NSObject
{
    NSString *wikipedia;
    NSString *tripadvisor;
    NSString *foodspotting;
}

@property(nonatomic,retain)  NSString *wikipedia;
@property(nonatomic,retain)  NSString *tripadvisor;
@property(nonatomic,retain)  NSString *foodspotting;

@end
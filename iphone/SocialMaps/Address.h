//
//  Address.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/14/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Address : NSObject
{
    NSString *id;
    NSString *street;
    NSString *city;
    NSString *state;
    NSString *postCode;
    NSString *country;
}

@property(nonatomic,retain) NSString *id;
@property(nonatomic,retain) NSString *street;
@property(nonatomic,retain) NSString *city;
@property(nonatomic,retain) NSString *state;
@property(nonatomic,retain) NSString *postCode;
@property(nonatomic,retain) NSString *country;

@end


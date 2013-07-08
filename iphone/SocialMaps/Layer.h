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
    bool wikipedia;
    bool tripadvisor;
    bool foodspotting;
}

@property(atomic)  bool wikipedia;
@property(atomic)  bool tripadvisor;
@property(atomic)  bool foodspotting;

@end
//
//  EventList.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/30/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "EventList.h"

@implementation EventList
@synthesize eventListArr;
-(id)init
{
    self=[super init];
    if (self)
    {
        eventListArr=[[NSMutableArray alloc] init];
    }
    return self;
}


@end

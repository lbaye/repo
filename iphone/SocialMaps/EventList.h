//
//  EventList.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/30/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventList : NSObject
{
    NSMutableArray *eventListArr;
}

@property(readwrite, assign) NSMutableArray *eventListArr;
@end

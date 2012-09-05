//
//  Globals.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/7/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

extern NSMutableArray *userFriendslistArray;
extern NSMutableDictionary *userFriendslistIndex;
extern NSMutableArray *eventListGlobalArray;
extern NSMutableArray *friendListGlobalArray;
extern NSMutableArray *circleListGlobalArray;
extern Event *globalEvent;
extern Event *globalEditEvent;
extern BOOL editFlag;

@interface Globals : NSObject 

{
	
}

@end

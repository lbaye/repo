//
//  Globals.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/7/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "Plan.h"

extern NSMutableArray *userFriendslistArray;
extern NSMutableDictionary *userFriendslistIndex;
extern NSMutableArray *eventListGlobalArray;
extern NSMutableArray *friendListGlobalArray;
extern NSMutableArray *circleListGlobalArray;
extern NSMutableArray *circleListDetailGlobalArray;
extern Event *globalEvent;
extern Event *globalEditEvent;
extern BOOL editFlag;
extern BOOL isFromVenue;
extern BOOL useLocalData;
extern BOOL willLoadPhotoData;
extern BOOL loadGeotagServiceData;
extern BOOL showFrndsEvents;
extern NSMutableDictionary *dicImages_msg;
extern Plan *globalPlan;
extern BOOL isPlanFromVenue;
extern BOOL loadNewPlan;
extern BOOL pointOnMapFlag;

@interface Globals : NSObject 

{
	
}

@end

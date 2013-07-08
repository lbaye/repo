//
//  Globals.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/7/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//


#import "Globals.h"

@implementation Globals

NSMutableArray *userFriendslistArray;
NSMutableDictionary *userFriendslistIndex;
NSMutableArray *eventListGlobalArray;
NSMutableArray *friendListGlobalArray;
NSMutableArray *circleListGlobalArray;
NSMutableArray *circleListDetailGlobalArray;
Event *globalEvent;
Event *globalEditEvent;
BOOL editFlag;
BOOL isFromVenue;
BOOL useLocalData;
BOOL willLoadPhotoData;
BOOL loadGeotagServiceData;
BOOL showFrndsEvents;
NSMutableDictionary *dicImages_msg;
Plan *globalPlan;
BOOL isPlanFromVenue;
BOOL loadNewPlan;
BOOL pointOnMapFlag;
BOOL profileFromList;
int badgeCount;
BOOL notifBadgeFlag;
BOOL userInfoServiceLoginFlag;

@end

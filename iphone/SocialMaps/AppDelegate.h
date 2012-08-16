//
//  AppDelegate.h
//  SocialMaps
//
//  Created by Arif Shakoor on 7/22/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FBConnect.h"
#import "ViewController.h"
#import "LoginController.h"
#include "FacebookHelper.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    bool rememberLoginInfo;
    NSString    *email;
    NSString    *password;
    int         loginCount;
    UIActivityIndicatorView		*activityView;
    FacebookHelper *fbHelper;
    NSMutableArray      *savedFilters;
    UIPickerView        *pickSavedFilter;
    NSMutableArray *friendRequests;
    NSMutableArray *messages;
    NSMutableArray *notifications;
    int            ignoreCount;
    bool            msgRead;
    bool            notifRead;
    NSMutableArray *defPlatforms;
    NSMutableArray *defLayers;
    NSMutableArray *infoList;
    NSMutableArray *defInfoPref;
    NSMutableArray *peopleList;
    NSMutableArray *placeList;
    NSMutableArray *dealList;
    NSMutableArray *displayList;
    NSMutableArray *friendList;
}

@property (atomic) bool rememberLoginInfo;
@property (atomic, copy) NSString *email;
@property (atomic, copy) NSString *password;
@property (atomic) int loginCount;
@property (nonatomic, retain) FacebookHelper *fbHelper;
@property (nonatomic, retain) NSMutableArray *savedFilters;
@property (nonatomic, retain) UIPickerView *pickSavedFilter;
@property (nonatomic, retain) NSMutableArray *friendRequests;
@property (nonatomic, retain) NSMutableArray *messages;
@property (nonatomic, retain) NSMutableArray *notifications;
@property (nonatomic) int ignoreCount;
@property (nonatomic) bool msgRead;
@property (nonatomic) bool notifRead;
@property (nonatomic, retain) NSMutableArray *defPlatforms;
@property (nonatomic, retain) NSMutableArray *defLayers;
@property (nonatomic, retain)NSMutableArray *infoList;
@property (nonatomic, retain)NSMutableArray *defInfoPref;
@property (nonatomic, retain)NSMutableArray *peopleList;
@property (nonatomic, retain)NSMutableArray *placeList;
@property (nonatomic, retain)NSMutableArray *dealList;
@property (nonatomic, retain)NSMutableArray *displayList;
@property (nonatomic, retain)NSMutableArray *friendList;

@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;

- (void) hideActivityViewer;
- (void) showActivityViewer:(UIView*)sender;

@end

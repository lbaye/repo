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
#import "Platform.h"
#import "Layer.h"
#import "InformationPrefs.h"
#import "UserInfo.h"
#import "Geofence.h"
#import "ShareLocation.h"
#import "NotificationPref.h"
#import "Geolocation.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    bool rememberLoginInfo;
    NSString    *email;
    NSString    *password;
    NSString    *authToken;
    int         loginCount;
    NSString    *userId;
    NSString    *fbId;
    NSString    *fbAccessToken;
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
    NSMutableDictionary *peopleIndex;
    NSMutableArray *placeList;
    NSMutableDictionary *placeIndex;
    NSMutableArray *dealList;
    NSMutableArray *displayList;
    NSMutableArray *friendList;
    NSMutableArray *meetUpRequests;
    // Preferences
    Platform        *platformPrefs;
    Layer           *layerPrefs;
    InformationPrefs    *informationPrefs;
    UserInfo            *userAccountPrefs;
    Geofence            *geofencePrefs;
    ShareLocation       *locSharingPrefs;
    NotificationPref    *notifPrefs;
    Geolocation         *currPosition;
    Geolocation         *lastPosition;
    bool            showPeople;
    bool            showPlaces;
    bool            showDeals;
    bool            gotListing;
    bool needToCenterMap;
}

@property (atomic) bool rememberLoginInfo;
@property (atomic, copy) NSString *email;
@property (atomic, copy) NSString *password;
@property (atomic, copy) NSString *authToken;
@property (atomic) int loginCount;
@property (atomic, copy) NSString *userId;
@property (atomic, copy) NSString *fbId;
@property (atomic, copy) NSString *fbAccessToken;
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
@property (nonatomic, retain) NSMutableDictionary *peopleIndex;
@property (nonatomic, retain)NSMutableArray *placeList;
@property (nonatomic, retain) NSMutableDictionary *placeIndex;
@property (nonatomic, retain)NSMutableArray *dealList;
@property (nonatomic, retain)NSMutableArray *displayList;
@property (nonatomic, retain)NSMutableArray *friendList;
@property (nonatomic, retain)Platform        *platformPrefs;
@property (nonatomic, retain)Layer           *layerPrefs;
@property (nonatomic, retain)InformationPrefs    *informationPrefs;
@property (nonatomic, retain)UserInfo            *userAccountPrefs;
@property (nonatomic, retain)Geofence            *geofencePrefs;
@property (nonatomic, retain)ShareLocation       *locSharingPrefs;
@property (nonatomic, retain)NotificationPref    *notifPrefs;
@property (nonatomic, retain) Geolocation        *currPosition;
@property (nonatomic, retain) Geolocation        *lastPosition;
@property (nonatomic, retain) NSMutableArray    *meetUpRequests;
@property (atomic) bool showPeople;
@property (atomic) bool showPlaces;
@property (atomic) bool showDeals;
@property (atomic) bool gotListing;
@property (atomic) bool needToCenterMap;

@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;

- (void) hideActivityViewer;
- (void) showActivityViewer:(UIView*)sender;
- (void) getPreferenceSettings:(NSString*) authToken;
- (void) getUserInformation:(NSString*) token ;

@end

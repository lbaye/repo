//
//  LocationSharingPref.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/10/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CounterItem.h"
#import "RadioButtonItem.h"
#import "CustomCounter.h"

typedef enum _LOC_SHARING_PREFS_TYPES {
    LocationSharingPrefTypeTime = 0x0001,
    LocationSharingPrefTypeRadius = 0x0010,
    LocationSharingPrefTypePermission = 0x0100
} LOC_SHARING_PREFS_TYPES;

@interface LocationSharingPref : UIView<CustomCounterDelegate> {
    id          parent;
    CounterItem *timeLimit;
    CounterItem *radius;
    RadioButtonItem *permission;
    int         level;
}
@property (nonatomic, retain) id parent;
@property (nonatomic, retain) CounterItem *timeLimit;
@property (nonatomic, retain) CounterItem *radius;
@property (nonatomic, retain) RadioButtonItem *permission;
@property (nonatomic) int level;

- (id)initWithFrame:(CGRect)frame prefs:(int)prefs defRadius:(int) rad defDuration:(int) dur defPerm:(bool)perm sender:(id) sender tag:(int)tag;
- (id)initWithFrame:(CGRect)frame prefs:(int)prefs defRadius:(int) rad defDuration:(int) dur defPerm:(bool)perm sender:(id) sender tag:(int)tag level:(int)lvl;
- (void) counterValueChanged:(int)newVal sender:(id)sender;
@end

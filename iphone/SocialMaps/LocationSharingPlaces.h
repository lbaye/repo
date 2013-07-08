//
//  LocationSharingPlaces.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/11/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCounter.h"
#import "AppDelegate.h"

@interface LocationSharingPlaces : UIScrollView<CustomCounterDelegate> {
    id  parent;
    int numSections;
    AppDelegate *smAppDelegate;
}
@property (nonatomic, retain) id parent;
@property (nonatomic) int numSections;
@property (nonatomic, retain) AppDelegate *smAppDelegate;

- (LocationSharingPlaces*) initWithFrame:(CGRect)scrollFrame sender:(id)sender tag:(int)tag;
- (void) accSettingButtonClicked:(id) sender;
- (void) accSettingResetButtonClicked:(id) sender;
- (void) counterValueChanged:(int)newVal sender:(id)sender;
@end

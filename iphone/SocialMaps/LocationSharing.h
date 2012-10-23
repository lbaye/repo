//
//  LocationSharing.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/11/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectFriends.h"
#import "RadioButton.h"
#import "NewLocationItem.h"
#import "AppDelegate.h"
#import "CustomCounter.h"

@interface LocationSharing : UIScrollView<SelectFriendsDelegate, RadioButtonDelegate, NewLocationItemDelegate,
                                        CustomCounterDelegate> {
    int     rowNum;
    AppDelegate *smAppDelegate;
}
@property (nonatomic) int rowNum;
@property (nonatomic, retain) AppDelegate *smAppDelegate;

- (UIScrollView*) initWithFrame:(CGRect)scrollFrame;
- (void) accSettingButtonClicked:(id) sender;
- (void) accSettingResetButtonClicked:(id) sender;
- (void) animateTextField: (UITextField*) textField up: (BOOL) up;
- (void) newLocationCreated:(Geofence*)loc sender:(id)sender;
- (void) counterValueChanged:(int)newVal sender:(id)sender;
@end

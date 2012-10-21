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

@interface LocationSharing : UIScrollView<SelectFriendsDelegate, RadioButtonDelegate, NewLocationItemDelegate> {
    int     rowNum;
}
@property (nonatomic) int rowNum;

- (UIScrollView*) initWithFrame:(CGRect)scrollFrame;
- (void) accSettingButtonClicked:(id) sender;
- (void) accSettingResetButtonClicked:(id) sender;
- (void) animateTextField: (UITextField*) textField up: (BOOL) up;
- (void) newLocationCreated:(Geofence*)loc sender:(id)sender;
@end

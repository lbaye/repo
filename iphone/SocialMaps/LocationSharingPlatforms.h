//
//  LocationSharingPlatforms.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/11/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCounter.h"

@interface LocationSharingPlatforms : UIScrollView<CustomCounterDelegate> {
    id  parent;
    int numSections;
}
@property (nonatomic, retain) id parent;
@property (nonatomic) int numSections;

- (LocationSharingPlatforms*) initWithFrame:(CGRect)scrollFrame sender:(id)sender tag:(int)tag;
- (void) accSettingButtonClicked:(id) sender;
- (void) accSettingResetButtonClicked:(id) sender;
- (void) animateTextField: (UITextField*) textField up: (BOOL) up;
- (void) counterValueChanged:(int)newVal sender:(id)sender;
@end
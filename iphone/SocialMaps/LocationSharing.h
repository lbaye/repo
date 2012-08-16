//
//  LocationSharing.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/11/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationSharing : UIScrollView
- (UIScrollView*) initWithFrame:(CGRect)scrollFrame;
- (void) accSettingButtonClicked:(id) sender;
- (void) accSettingResetButtonClicked:(id) sender;
- (void) animateTextField: (UITextField*) textField up: (BOOL) up;

@end

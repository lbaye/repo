//
//  UITextField+Scrolling.h
//  SocialMaps
//
//  Created by Arif Shakoor on 10/17/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (Scrolling) 

@property (nonatomic) int movementDistance;

- (void) animateTextField: (UITextField*) textField up: (BOOL) up;

@end

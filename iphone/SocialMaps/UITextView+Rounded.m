//
//  UITextView+Rounded.m
//  SocialMaps
//
//  Created by Warif Rishi on 11/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "UITextView+Rounded.h"
#import <QuartzCore/QuartzCore.h>

@implementation UITextView (Rounded)

- (void) makeRoundCorner 
{
    self.layer.masksToBounds = YES;
    [self.layer setCornerRadius:7.0];
    CGColorSpaceRef cmykSpace = CGColorSpaceCreateDeviceCMYK();
    CGFloat cmykValue[] = {.38, .02, .98, .05, 1};      
    CGColorRef colorCMYK = CGColorCreate(cmykSpace, cmykValue);
    CGColorSpaceRelease(cmykSpace);
    self.layer.borderColor = [[UIColor colorWithCGColor:colorCMYK] CGColor];
    self.layer.borderWidth = 1.0;
}

@end

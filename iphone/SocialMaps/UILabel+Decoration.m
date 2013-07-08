//
//  UILabel+Decoration.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 11/19/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "UILabel+Decoration.h"
#import <QuartzCore/QuartzCore.h>

@implementation UILabel (Decoration)

- (void) setLabelGlowEffect
{
    self.layer.shadowRadius = 5.0f;
    self.layer.shadowOpacity = .9;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.masksToBounds = NO;
}

- (void) makeRoundCornerWithColor:(UIColor *)color
{
    [self.layer setCornerRadius:8.0f];
    [self.layer setBorderWidth:0.5];
    [self.layer setBorderColor:color.CGColor];
    [self.layer setMasksToBounds:YES];
}


@end

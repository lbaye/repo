//
//  UITextField+Scrolling.m
//  SocialMaps
//
//  Created by Arif Shakoor on 10/17/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//
#import <objc/runtime.h>
#import "UITextField+Scrolling.h"
#import "AppDelegate.h"

static char const * const ObjectTagKey = "ObjectTag";

@implementation UITextField (Scrolling)
@dynamic movementDistance;

- (int)movementDistance {
    NSNumber *intObj = (NSNumber*)objc_getAssociatedObject(self, ObjectTagKey);
    return [intObj intValue];
}

- (void)setMovementDistance:(int)dist {
    objc_setAssociatedObject(self, ObjectTagKey, [NSNumber numberWithInt:dist], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    CGRect newFrame = [textField convertRect:textField.bounds toView:nil];
    if (up) {
        self.movementDistance = 216 - newFrame.origin.y;// - newFrame.size.height;
        if (self.movementDistance > 0)
            self.movementDistance = 0;
    } else
        self.movementDistance = -self.movementDistance;
    
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ?    self.movementDistance : self.movementDistance);
    NSLog(@"animateTextField : movementDistance = %d, movement = %d", self.movementDistance, movement);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[appDelegate window] setFrame: CGRectOffset([[appDelegate window] frame], 0, movement)];
    [UIView commitAnimations];
}

@end

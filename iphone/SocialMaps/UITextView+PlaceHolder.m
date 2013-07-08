//
//  UITextView+PlaceHolder.m
//  SocialMaps
//
//  Created by Warif Rishi on 11/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <objc/runtime.h>
#import "UITextView+PlaceHolder.h"

static char const * const ObjectTagKey = "UITextViewTag";

@implementation UITextView (PlaceHolder)
- (NSString *) getPlaceHolderText {
    return (NSString *) objc_getAssociatedObject(self, ObjectTagKey);
}

- (void)setPlaceHolderText:(NSString *) text {
    objc_setAssociatedObject(self, ObjectTagKey, text, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setText:text];
    self.textColor = [UIColor grayColor];
}

- (void) resetPlaceHolderText {
    self.text = @"";
    self.textColor = [UIColor blackColor];
}

@end

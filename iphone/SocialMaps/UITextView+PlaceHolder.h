//
//  UITextView+PlaceHolder.h
//  SocialMaps
//
//  Created by Warif Rishi on 11/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (PlaceHolder)

- (void) setPlaceHolderText: (NSString *) text;
- (NSString *) getPlaceHolderText;
- (void) resetPlaceHolderText;

@end

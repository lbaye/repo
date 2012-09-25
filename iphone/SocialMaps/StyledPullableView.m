//
//  StyledPullableView.m
//  Pull-Down Menu
//
//  Created by Abdullah Md. Zubair on 9/25/12.
//  Copyright (c) 2012 Genweb2 Limited. All rights reserved.
//

#import "StyledPullableView.h"

@implementation StyledPullableView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
        imgView.frame = CGRectMake(0, 0, 320, 460);
        [self addSubview:imgView];
        [imgView release];
    }
    return self;
}

@end

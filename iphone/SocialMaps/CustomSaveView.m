//
//  CustomSaveView.m
//  SocialMaps
//
//  Created by Warif Rishi on 1/29/13.
//  Copyright (c) 2013 Genweb2. All rights reserved.
//

#import "CustomSaveView.h"

@implementation CustomSaveView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *sepScreenBottom = [[UIView alloc] initWithFrame:CGRectMake(0, 5, self.frame.size.width, 1)];
        sepScreenBottom.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:sepScreenBottom];
        [sepScreenBottom release];
        
        UIButton *buttonSave = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonSave.frame = CGRectMake((self.frame.size.width - 52) / 2, sepScreenBottom.frame.origin.y + 8, 52, 32);
        [buttonSave setImage:[UIImage imageNamed:@"btn_save_light.png"] forState:UIControlStateNormal];
        [buttonSave addTarget:self action:@selector(didPressSaveButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonSave];
    }
    return self;
}

- (void)didPressSaveButton:(id)sender
{
    [delegate customSaveButtonClicked:sender];
}

@end

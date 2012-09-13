//
//  MeetUpListButtonsView.m
//  SocialMaps
//
//  Created by Warif Rishi on 9/13/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "MeetUpListButtonsView.h"

@implementation MeetUpListButtonsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIButton *buttonAccept = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonAccept.frame = CGRectMake(10, 0, 70, 30);
        [buttonAccept setImage:[UIImage imageNamed:@"accept_button_a.png"] forState:UIControlStateNormal];
        [buttonAccept setImage:[UIImage imageNamed:@"accept_button_h.png"] forState:UIControlStateHighlighted];
        [buttonAccept addTarget:self action:@selector(actionAccetpButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonAccept];
        
        UIButton *buttonDecline = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonDecline.frame = CGRectMake(100, 0, 70, 30);
        [buttonDecline setImage:[UIImage imageNamed:@"decline_button_a.png"] forState:UIControlStateNormal];
        [buttonDecline setImage:[UIImage imageNamed:@"decline_button_h.png"] forState:UIControlStateHighlighted];
        [buttonDecline addTarget:self action:@selector(actionAccetpButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonDecline];
        
        UIButton *buttonIgnore = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonIgnore.frame = CGRectMake(190, 0, 70, 30);
        [buttonIgnore setImage:[UIImage imageNamed:@"ignore_button_a.png"] forState:UIControlStateNormal];
        [buttonIgnore setImage:[UIImage imageNamed:@"ignore_button_h.png"] forState:UIControlStateHighlighted];
        [buttonIgnore addTarget:self action:@selector(actionAccetpButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonIgnore];
    }
    return self;
}

- (void)actionAccetpButton:(id)sender
{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

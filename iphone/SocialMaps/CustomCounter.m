//
//  CounterView.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/10/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "CustomCounter.h"

@implementation CustomCounter
@synthesize allowNegative;
@synthesize currVal;
@synthesize countDisp;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame allowNeg:(bool)neg default:(int)def sender:(id)sender tag:(int)tag
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        allowNegative = neg;
        currVal       = def;
        self.tag      = tag;
        self.backgroundColor = [UIColor clearColor];
        
        UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"radius_field.png"]];
        [img setContentMode:UIViewContentModeScaleAspectFill];
        [self addSubview:img];
        
        CGRect btnFrame = CGRectMake(2, (self.frame.size.height-20)/2, 
                                     10, 20);
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBtn.frame = btnFrame;
        [leftBtn setImage:[UIImage imageNamed:@"radius_left_ar.png"] forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(decreaseCount:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:leftBtn];
        
        btnFrame = CGRectMake(self.frame.size.width-2-10, 
                              (self.frame.size.height-20)/2, 
                              10, 20);
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.frame = btnFrame;
        [rightBtn setImage:[UIImage imageNamed:@"radius_right_ar.png"] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(increaseCount:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rightBtn];
        
        CGSize txtSize = [@"99999999" sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
        CGRect labelFrame = CGRectMake(2+10+2, 
                                       (self.frame.size.height-txtSize.height)/2, 
                                       self.frame.size.width-4-2*10-4, txtSize.height);
        countDisp = [[UILabel alloc] initWithFrame:labelFrame];
        countDisp.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        countDisp.textAlignment = UITextAlignmentCenter;
        countDisp.textColor = [UIColor blackColor];
        countDisp.text = [NSString stringWithFormat:@"%d",currVal];
        [self addSubview:countDisp];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    countDisp.text = [NSString stringWithFormat:@"%d",currVal];
    
}

- (void) notifyDelegate:(id)sender {
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(counterValueChanged:sender:)]) {
        [self.delegate counterValueChanged:currVal sender:[sender superview]];
    }
}

- (void) increaseCount:(id)sender {
    currVal++;
    countDisp.text = [NSString stringWithFormat:@"%d",currVal];
    [self notifyDelegate:sender];
    [self setNeedsDisplay];
}

- (void) decreaseCount:(id)sender {
    if (currVal > 0) {
        currVal--;
        countDisp.text = [NSString stringWithFormat:@"%d",currVal];
        [self notifyDelegate:sender];
        [self setNeedsDisplay];
    }
}

@end

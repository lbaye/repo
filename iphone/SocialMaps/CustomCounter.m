//
//  CounterView.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/10/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "AppDelegate.h"
#import "CustomCounter.h"
#import "UITextField+Scrolling.h"

@implementation CustomCounter
@synthesize allowNegative;
@synthesize currVal;
@synthesize countDisp;
@synthesize delegate;
@synthesize parent;
@synthesize movementDistance;

- (id)initWithFrame:(CGRect)frame allowNeg:(bool)neg default:(int)def sender:(id)sender tag:(int)tag
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        allowNegative = neg;
        currVal       = def;
        self.tag      = tag;
        self.parent   = sender;
        self.backgroundColor = [UIColor clearColor];
        
        UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"radius_field.png"]];
        [img setContentMode:UIViewContentModeScaleAspectFill];
        [self addSubview:img];
        [img release];
        
        CGRect btnFrame = CGRectMake(0, 0, self.frame.size.width/4, self.frame.size.height);
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBtn.frame = btnFrame;
        [leftBtn setImage:[UIImage imageNamed:@"radius_left_ar.png"] forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(decreaseCount:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:leftBtn];
        
        btnFrame = CGRectMake(self.frame.size.width/4*3, 0, self.frame.size.width/4, self.frame.size.height);

        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.frame = btnFrame;
        [rightBtn setImage:[UIImage imageNamed:@"radius_right_ar.png"] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(increaseCount:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rightBtn];
        
        CGSize txtSize = [@"99999999" sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
        CGRect txtFrame = CGRectMake(2+10+2, 
                                       (self.frame.size.height-txtSize.height)/2, 
                                       self.frame.size.width-4-2*10-4, txtSize.height);
        countDisp = [[UITextField alloc] initWithFrame:txtFrame];
        countDisp.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        countDisp.textAlignment = UITextAlignmentCenter;
        countDisp.textColor = [UIColor blackColor];
        countDisp.text = [NSString stringWithFormat:@"%d",currVal];
        countDisp.backgroundColor = [UIColor clearColor];
        countDisp.borderStyle = UITextBorderStyleNone;
        countDisp.returnKeyType = UIReturnKeyDone;
        countDisp.textAlignment = UITextAlignmentCenter;
        countDisp.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        countDisp.autocapitalizationType = UITextAutocapitalizationTypeNone;
        countDisp.inputView = nil;
        [countDisp setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
        countDisp.delegate = self;

        [self addSubview:countDisp];
    }
    return self;
}
// UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	// When the user presses return, take focus away from the text field so that the keyboard is dismissed.
    [self endEditing:YES];
    
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField animateTextField: parent up: YES];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField animateTextField: parent up: NO];
    // Store the entered value and notify delegate
    currVal  = [countDisp.text intValue];
    [self notifyDelegate:self];
}

// UITextField Delegate end
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    countDisp.text = [NSString stringWithFormat:@"%d",currVal];
}

- (void) notifyDelegate:(id)sender {
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(counterValueChanged:sender:)]) {
        [self.delegate counterValueChanged:currVal sender:(id)self.tag];
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

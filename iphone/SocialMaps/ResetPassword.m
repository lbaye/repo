//
//  ResetPassword.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/8/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "ResetPassword.h"
#define BUTTON_WIDTH 60
#define BUTTON_HEIGHT 30
#define TEXT_HEIGHT 37
#define TEXT_WIDTH  250

@implementation ResetPassword
@synthesize password;
@synthesize passwordNew;
@synthesize passwordConfirm;
@synthesize updateBtn;
@synthesize parent;

- (id)initWithFrame:(CGRect)frame sender:(id) sender tag:(int)tag
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.parent = sender;
        self.tag    = tag;
        self.backgroundColor = [UIColor clearColor];
        CGRect viewFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 
                                      self.frame.size.width, BUTTON_HEIGHT + 15+3*(5+TEXT_HEIGHT));
        self.frame = viewFrame;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//btn_update_dark.png
- (void)drawRect:(CGRect)rect
{
    // Drawing code    
    CGRect itemFrame = CGRectMake(30, 5, TEXT_WIDTH, TEXT_HEIGHT);
    password = [[UITextField alloc] initWithFrame:itemFrame];
    password.placeholder = @"Old password...";
    password.backgroundColor = [UIColor clearColor];
    password.textColor = [UIColor blackColor];
    password.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    password.borderStyle = UITextBorderStyleRoundedRect;
    password.clearButtonMode = UITextFieldViewModeWhileEditing;
    password.returnKeyType = UIReturnKeyNext;
    password.textAlignment = UITextAlignmentLeft;
    password.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    password.tag = 2;
    password.autocapitalizationType = UITextAutocapitalizationTypeNone;
    password.delegate = parent;
    [self addSubview:password];
    
    itemFrame = CGRectMake(30, 5+TEXT_HEIGHT+5, TEXT_WIDTH, TEXT_HEIGHT);
    passwordNew = [[UITextField alloc] initWithFrame:itemFrame];
    passwordNew.placeholder = @"New password...";
    passwordNew.backgroundColor = [UIColor clearColor];
    passwordNew.textColor = [UIColor blackColor];
    passwordNew.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    passwordNew.borderStyle = UITextBorderStyleRoundedRect;
    passwordNew.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordNew.returnKeyType = UIReturnKeyNext;
    passwordNew.textAlignment = UITextAlignmentLeft;
    passwordNew.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    passwordNew.tag = 3;
    passwordNew.autocapitalizationType = UITextAutocapitalizationTypeNone;
    passwordNew.delegate = parent;
    [self addSubview:passwordNew];
    
    itemFrame = CGRectMake(30, 5+2*(TEXT_HEIGHT+5), TEXT_WIDTH, TEXT_HEIGHT);
    passwordConfirm = [[UITextField alloc] initWithFrame:itemFrame];
    passwordConfirm.placeholder = @"Retype password...";
    passwordConfirm.backgroundColor = [UIColor clearColor];
    passwordConfirm.textColor = [UIColor blackColor];
    passwordConfirm.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    passwordConfirm.borderStyle = UITextBorderStyleRoundedRect;
    passwordConfirm.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordConfirm.returnKeyType = UIReturnKeyDone;
    passwordConfirm.textAlignment = UITextAlignmentLeft;
    passwordConfirm.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    passwordConfirm.tag = 2;
    passwordConfirm.autocapitalizationType = UITextAutocapitalizationTypeNone;
    passwordConfirm.delegate = parent;
    [self addSubview:passwordConfirm];
    
    itemFrame = CGRectMake((self.frame.size.width-BUTTON_WIDTH)/2, 
                           5+3*(TEXT_HEIGHT+5), BUTTON_WIDTH, BUTTON_HEIGHT);
    updateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    updateBtn.frame = itemFrame;
    [updateBtn addTarget:self 
                 action:@selector(updateButtonClicked:)
       forControlEvents:UIControlEventTouchUpInside];
    [updateBtn setImage:[UIImage imageNamed:@"btn_update_dark.png"]
              forState:UIControlStateNormal];
    [self addSubview:updateBtn];

}

- (void) updateButtonClicked:(id)sender {
    NSLog(@"ResetPassword:updateButtonClicked called");
}

@end

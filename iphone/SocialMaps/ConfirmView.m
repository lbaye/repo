//
//  ConfirmView.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/8/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "ConfirmView.h"
#define BUTTON_WIDTH 52
#define BUTTON_HEIGHT 32

@implementation ConfirmView
@synthesize titleString;
@synthesize title;
@synthesize noButton;
@synthesize yesButton;
@synthesize btnTag;
@synthesize parent;

- (id)initWithFrame:(CGRect)frame title:(NSString*)titleStr sender:(id) sender tag:(int)tag
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        btnTag = tag;
        titleString = [NSString stringWithString:titleStr];
        parent = sender;
        self.backgroundColor = [UIColor clearColor];
        self.tag = btnTag;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.backgroundColor = [UIColor clearColor]; 
    
    CGSize titleStringSize = [titleString sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:14.0]];
    
    CGRect titleFrame = CGRectMake(10, (self.frame.size.height-titleStringSize.height)/2, titleStringSize.width, titleStringSize.height);
    title = [[UILabel alloc] initWithFrame:titleFrame];
    title.text = titleString;
    title.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    title.backgroundColor = [UIColor clearColor];
    [self addSubview:title];
    
    // Buttons
    CGRect btnFrame = CGRectMake(self.frame.size.width-10-2*(BUTTON_WIDTH+5), 
                                 (self.frame.size.height-BUTTON_HEIGHT)/2, 
                                 BUTTON_WIDTH, BUTTON_HEIGHT);
    noButton = [UIButton buttonWithType:UIButtonTypeCustom];
    noButton.frame = btnFrame;

    [noButton addTarget:self 
                 action:@selector(noButtonClicked:)
       forControlEvents:UIControlEventTouchUpInside];
    [noButton setImage:[UIImage imageNamed:@"no_button.png"]
                           forState:UIControlStateNormal];
    [self addSubview:noButton];
    
    btnFrame = CGRectMake(self.frame.size.width-10-(BUTTON_WIDTH+5), 
                                 (self.frame.size.height-BUTTON_HEIGHT)/2, 
                                 BUTTON_WIDTH, BUTTON_HEIGHT);
    yesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    yesButton.frame = btnFrame;

    [yesButton addTarget:self 
                 action:@selector(yesButtonClicked:)
       forControlEvents:UIControlEventTouchUpInside];
    [yesButton setImage:[UIImage imageNamed:@"yes_button.png"]
              forState:UIControlStateNormal];
    [self addSubview:yesButton];
}

- (void) noButtonClicked:(id)sender {
    NSLog(@"ConfirmView:noButtonClicked");
}

- (void) yesButtonClicked:(id)sender {
    NSLog(@"ConfirmView:yesButtonClicked");
}
@end

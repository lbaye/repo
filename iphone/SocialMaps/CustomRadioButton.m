//
//  CustomRadioButton.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/6/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//
#import "Constants.h"
#import "CustomRadioButton.h"

#define CELL_PADDING 30

@implementation CustomRadioButton
@synthesize numRadio;
@synthesize selIndex;
@synthesize labels;

- (id)initWithFrame:(CGRect)frame numButtons:(int)numButtons labels:(NSArray*)lbl default:(int)def sender:(id)sender tag:(int)tag
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.numRadio = numButtons;
        self.selIndex = def;
        self.labels   = lbl;
        self.backgroundColor = [UIColor clearColor];
        self.tag = tag;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
// people_checked.png
// people_unchecked.png
//
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGSize stringSize;
    CGSize radioSize = CGSizeMake(21, 21);
    CGSize lblSize;
    CGRect rectFrame;
    CGRect radioFrame;
    CGRect lblFrame;
    
    rectFrame = CGRectMake(CELL_PADDING, (self.frame.size.height-7)/2, self.frame.size.width-CELL_PADDING*2, 7);
    UIImageView *rectView = [[UIImageView alloc] initWithFrame:rectFrame];
    rectView.backgroundColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    [self addSubview:rectView];
    int offset = 0;
    if (numRadio == 1)
        offset = (self.frame.size.width-CELL_PADDING*2-radioSize.width)/2;
    int startTag = 1000;
    for (int i=0; i < numRadio; i++) {
        radioFrame = CGRectMake(offset + CELL_PADDING+i*(self.frame.size.width-CELL_PADDING*2)/(numRadio == 0 ? 1 : numRadio-1)-radioSize.width/2, (self.frame.size.height-radioSize.height)/2, radioSize.width, radioSize.height);
        
        stringSize = [[labels objectAtIndex:i] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:10.0]];
        lblSize = CGSizeMake (stringSize.width, stringSize.height+4);

        lblFrame   = CGRectMake(CELL_PADDING+i*(self.frame.size.width-CELL_PADDING*2)/numRadio, (self.frame.size.height-radioSize.height)/2+radioSize.height, 
                                lblSize.width, lblSize.height);
        
        // Radio
        UIButton *btnRadio = [UIButton buttonWithType:UIButtonTypeCustom];
        btnRadio.frame = radioFrame;
        [btnRadio addTarget:self 
                        action:@selector(buttonClicked:)
              forControlEvents:UIControlEventTouchUpInside];
        if (selIndex == i)
            [btnRadio setBackgroundImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"]
                                   forState:UIControlStateNormal];
        else
            [btnRadio setBackgroundImage:[UIImage imageNamed:@"location_bar_radio.png"]
                                   forState:UIControlStateNormal];
        btnRadio.tag = startTag+i;
        [self addSubview:btnRadio];
        //[btnRadio release];
        
        // Label
        UILabel *lblRadio = [[UILabel alloc] initWithFrame:lblFrame];
        lblRadio.backgroundColor = [UIColor clearColor];
        lblRadio.text     = [labels objectAtIndex:i];
        lblRadio.font     = [UIFont fontWithName:@"Helvetica" size:10.0];
        [self addSubview:lblRadio];
        [lblRadio release];   
        
        CGPoint center = CGPointMake(btnRadio.center.x, lblRadio.center.y);
        lblRadio.center = center;
    }
}

- (void) buttonClicked:(id)sender {
    UIButton *newSel = (UIButton*) sender;
    NSLog(@"CustomRadioButton:buttonClicked %d", newSel.tag);
    if ((newSel.tag - 1000) != selIndex) {
        UIButton *lastSel = (UIButton*) [self viewWithTag:selIndex+1000];
        selIndex = newSel.tag - 1000;
        [newSel setBackgroundImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"]
                            forState:UIControlStateNormal];
        [lastSel setBackgroundImage:[UIImage imageNamed:@"location_bar_radio.png"]
                            forState:UIControlStateNormal];
    }
}
@end

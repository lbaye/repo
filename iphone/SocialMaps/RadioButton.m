//
//  RadioButton.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/10/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "RadioButton.h"
#define CELL_PADDING 30

@implementation RadioButton
@synthesize selIndex;
@synthesize labels;
//@synthesize def;

- (id)initWithFrame:(CGRect)frame labels:(NSArray*)lbl default:(int)def sender:(id)sender tag:(int)tag
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.selIndex = def;
        self.labels   = lbl;
        self.backgroundColor = [UIColor clearColor];
        self.tag = tag;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGSize stringSize;
    CGSize radioSize = CGSizeMake(30, 30);
    CGSize smallRadioSize = CGSizeMake(20, 20);
    CGSize lblSize;
    CGRect radioFrame;
    CGRect lblFrame;
    
    stringSize = [[labels objectAtIndex:0] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:10.0]];
    lblSize = CGSizeMake (stringSize.width, stringSize.height);
    
    radioFrame = CGRectMake(2, 2 + (self.frame.size.height-6-smallRadioSize.height-lblSize.height)/2, smallRadioSize.width, smallRadioSize.height);
    
    lblFrame   = CGRectMake(2+radioSize.width/2-lblSize.width/2, 
                            self.frame.size.height-2-lblSize.height, 
                            lblSize.width, lblSize.height);
    
    // Small Radio
    UIButton *btnRadio = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRadio.frame = radioFrame;
    [btnRadio addTarget:self 
                 action:@selector(buttonClicked:)
       forControlEvents:UIControlEventTouchUpInside];
    btnRadio.tag = 1000;
    btnRadio.contentMode = UIViewContentModeScaleToFill;
    if (selIndex == 0)
        [btnRadio setBackgroundImage:[UIImage imageNamed:@"radio_checked_small.png"] forState:UIControlStateNormal];
    else
        [btnRadio setBackgroundImage:[UIImage imageNamed:@"radio_unchecked_small.png"] forState:UIControlStateNormal];
    [self addSubview:btnRadio];
    
    // Label
    UILabel *lblRadio = [[UILabel alloc] initWithFrame:lblFrame];
    lblRadio.backgroundColor = [UIColor clearColor];
    lblRadio.text     = [labels objectAtIndex:0];
    lblRadio.font     = [UIFont fontWithName:@"Helvetica" size:10.0];
    [self addSubview:lblRadio];
    [lblRadio release];   
    
    CGPoint center = CGPointMake(btnRadio.center.x, lblRadio.center.y);
    lblRadio.center = center;
    
    // Large radio    
    stringSize = [[labels objectAtIndex:1] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:10.0]];
    
    lblSize = CGSizeMake (stringSize.width, stringSize.height);
    
    radioFrame = CGRectMake(self.frame.size.width-radioSize.width-2, 
                            2 + (self.frame.size.height-6-radioSize.height-lblSize.height)/2, radioSize.width, radioSize.height);

    lblFrame   = CGRectMake(2+radioSize.width/2-lblSize.width/2, 
                            self.frame.size.height-2-lblSize.height, 
                            lblSize.width, lblSize.height);
    
    // Radio
    btnRadio = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRadio.frame = radioFrame;
    [btnRadio addTarget:self 
                 action:@selector(buttonClicked:)
       forControlEvents:UIControlEventTouchUpInside];
    btnRadio.tag = 1001;
    btnRadio.contentMode = UIViewContentModeScaleToFill;
    if (selIndex == 0)
        [btnRadio setBackgroundImage:[UIImage imageNamed:@"location_bar_radio.png"] forState:UIControlStateNormal];
    else
        [btnRadio setBackgroundImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
    [self addSubview:btnRadio];
    
    // Label
    lblRadio = [[UILabel alloc] initWithFrame:lblFrame];
    lblRadio.backgroundColor = [UIColor clearColor];
    lblRadio.text     = [labels objectAtIndex:1];
    lblRadio.font     = [UIFont fontWithName:@"Helvetica" size:10.0];
    [self addSubview:lblRadio];
    [lblRadio release];   
    
    center = CGPointMake(btnRadio.center.x, lblRadio.center.y);
    lblRadio.center = center;
}

- (void) buttonClicked:(id)sender {
    UIButton *newSel = (UIButton*) sender;
    NSLog(@"buttonClicked %d", newSel.tag);
    if ((newSel.tag - 1000) != selIndex) {
        UIButton *lastSel = (UIButton*) [self viewWithTag:selIndex+1000];
        selIndex = newSel.tag - 1000;
        UIImage *lastSelImg;
        UIImage *newSelImg;
        if (selIndex == 0) {
            // Small radio selected
            newSelImg = [UIImage imageNamed:@"radio_checked_small.png"];
            lastSelImg = [UIImage imageNamed:@"location_bar_radio.png"];
        } else {
            // Large radio button selected
            newSelImg = [UIImage imageNamed:@"radio_unchecked_small.png"];
            lastSelImg = [UIImage imageNamed:@"location_bar_radio_cheked.png"];
        }
        [newSel setBackgroundImage:newSelImg
                          forState:UIControlStateNormal];
        [lastSel setBackgroundImage:lastSelImg
                           forState:UIControlStateNormal];
    }
    [self setNeedsDisplay];
}


@end

//
//  CustomCheckbox.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/6/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "CustomCheckbox.h"
#import "Constants.h"

#define CELL_MARGIN 10

@implementation CustomCheckbox
@synthesize numBoxes;
@synthesize labels;
@synthesize checkboxState;
@synthesize delegate;
@synthesize type;

- (id)initWithFrame:(CGRect)frame boxLocType:(BOX_LOCATION)locType numBoxes:(int)num default:(NSArray*)def
             labels:(NSArray*) lbls
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.type = locType;
        self.numBoxes = num;
        self.labels   = lbls;
        checkboxState = [[NSMutableArray alloc] initWithCapacity:numBoxes];
        for (int i=0; i<num; i++) {
            NSNumber *num = (NSNumber*) [def objectAtIndex:i];
            [checkboxState insertObject:num atIndex:i];
        }
        self.backgroundColor = [UIColor clearColor];
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
    CGSize stringSize = [@"Label" sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:kLargeLabelFontSize]];
    CGSize boxSize = CGSizeMake(23.0, 23.0);
    CGSize lblSize = CGSizeMake((self.frame.size.width-2*CELL_MARGIN)/numBoxes-boxSize.width, stringSize.height);
    CGRect boxFrame;
    CGRect lblFrame;

    for (int i=0; i < numBoxes; i++) {
        if (self.type == LabelPositionRight) {
            boxFrame = CGRectMake(CELL_MARGIN+i*(lblSize.width+boxSize.width), 
                                         (self.frame.size.height-boxSize.height)/2, 
                                         boxSize.width, boxSize.height);
            lblFrame = CGRectMake(boxFrame.origin.x+boxFrame.size.width + 2, 
                                  (self.frame.size.height-lblSize.height)/2,
                                  lblSize.width, lblSize.height);
        } else {
            lblFrame = CGRectMake(CELL_MARGIN+i*(lblSize.width+boxSize.width), 
                                  (self.frame.size.height-lblSize.height)/2, 
                                  lblSize.width, lblSize.height);
            boxFrame = CGRectMake(lblFrame.origin.x+lblFrame.size.width + 2, 
                                  (self.frame.size.height-boxSize.height)/2,
                                  boxSize.width, boxSize.height);
        }
        
        // Checkbox
        UIButton *btnCheckbox = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCheckbox.frame = boxFrame;
        [btnCheckbox addTarget:self 
                        action:@selector(buttonClicked:)
              forControlEvents:UIControlEventTouchUpInside];
        NSNumber *state = (NSNumber*)[checkboxState objectAtIndex:i];
        if ([state intValue] == 0)
            [btnCheckbox setBackgroundImage:[UIImage imageNamed:@"people_unchecked.png"]
                               forState:UIControlStateNormal];
        else
            [btnCheckbox setBackgroundImage:[UIImage imageNamed:@"people_checked.png"]
                                   forState:UIControlStateNormal];
        btnCheckbox.tag = 7000+i;
        // Label
        UILabel *lblCheckbox = [[UILabel alloc] initWithFrame:lblFrame];
        lblCheckbox.backgroundColor = [UIColor clearColor];
        lblCheckbox.text     = [labels objectAtIndex:i];
        lblCheckbox.font     = [UIFont fontWithName:@"Helvetica" size:14.0];
        [self addSubview:lblCheckbox];
        [lblCheckbox release];
        

        [self addSubview:lblCheckbox];
        [self addSubview:btnCheckbox];
    }
}

- (void) buttonClicked:(id) sender {
    NSLog(@"buttonClicked pressed");
    UIButton *btn = (UIButton*) sender;
    int btnNum = btn.tag;
    int newState;
    
    NSNumber *btnState = (NSNumber*)[checkboxState objectAtIndex:btnNum-7000];
    if ([btnState intValue] == 1) {
        newState = 0;
        [checkboxState replaceObjectAtIndex:btnNum-7000 withObject:[NSNumber numberWithInt:0]];
        [btn setBackgroundImage:[UIImage imageNamed:@"people_unchecked.png"]
                               forState:UIControlStateNormal];
    } else {
        newState = 1;
        [checkboxState replaceObjectAtIndex:btnNum-7000 withObject:[NSNumber numberWithInt:1]];
        [btn setBackgroundImage:[UIImage imageNamed:@"people_checked.png"]
                               forState:UIControlStateNormal];
    }
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(checkboxClicked:withState:sender:)]) {
        [self.delegate checkboxClicked:btnNum withState:newState sender:[sender superview]];
    }
}

- (void) setState:(int)state btnNum:(int)num{
    UIButton *btn = (UIButton*) [self viewWithTag:7000+num];
    if (state == 1) {
        [checkboxState replaceObjectAtIndex:num withObject:[NSNumber numberWithInt:1]];
        [btn setBackgroundImage:[UIImage imageNamed:@"people_unchecked.png"]
                       forState:UIControlStateNormal];
    } else {
        [checkboxState replaceObjectAtIndex:num withObject:[NSNumber numberWithInt:0]];
        [btn setBackgroundImage:[UIImage imageNamed:@"people_checked.png"]
                       forState:UIControlStateNormal];
    }
}
@end

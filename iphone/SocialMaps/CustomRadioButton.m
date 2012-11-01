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
@synthesize delegate;

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
        btnRadio.userInteractionEnabled = NO;
        
        if (i == 0) {
            startDragRect = radioFrame;
        }
        
        if (selIndex == i)
        {
            imageViewDrag = [[UIImageView alloc] initWithFrame:radioFrame];
            imageViewDrag.image = [UIImage imageNamed:@"location_bar_radio_cheked"];
            [self addSubview:imageViewDrag];
            
            //[btnRadio setBackgroundImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"]
              //                     forState:UIControlStateNormal];
        }
        //else
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
    
    endDragRect = radioFrame;
    
    [self bringSubviewToFront:imageViewDrag];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //UITouch *touch = [touches anyObject];
    //[self limitMovement:touch];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
    UITouch *touch = [touches anyObject];
    [self limitMovement:touch];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
    UITouch *touch = [touches anyObject];
    
    CGRect radioFrame;
    
    for (int i=0; i < numRadio; i++) {
        radioFrame = CGRectMake(0 + CELL_PADDING+i*(self.frame.size.width-CELL_PADDING*2)/(numRadio == 0 ? 1 : numRadio-1)-21/2, (self.frame.size.height-21)/2, 21, 21);
        int diffTempX = radioFrame.origin.x - [touch locationInView:self].x;
        if (abs(diffTempX) < self.frame.size.width / numRadio / 1.5) {
            //[imageViewDrag setFrame:radioFrame];
            [self buttonClicked: [self viewWithTag: 1000 + i]];
            break;
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event 
{
    [self touchesEnded:touches withEvent:event];
}

- (void)limitMovement:(UITouch*) touch
{
    imageViewDrag.center = CGPointMake([touch locationInView:self].x, imageViewDrag.center.y);
    
    if (imageViewDrag.frame.origin.x <= startDragRect.origin.x) {
        imageViewDrag.frame = startDragRect;
        return;
    } else if (imageViewDrag.frame.origin.x >= endDragRect.origin.x) {
        imageViewDrag.frame = endDragRect;
    } 
}

- (void) gotoButton:(int)buttonNumber 
{    
    CGRect radioFrame = CGRectMake(0 + CELL_PADDING+buttonNumber*(self.frame.size.width-CELL_PADDING*2)/(numRadio == 0 ? 1 : numRadio-1)-21/2, (self.frame.size.height-21)/2, 21, 21);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [imageViewDrag setFrame:radioFrame];
    [UIView commitAnimations];
}

- (void) buttonClicked:(id)sender {

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    CGRect rect = ((UIView*)sender).frame;
    [imageViewDrag setFrame:rect];
    [UIView commitAnimations];
     
    UIButton *newSel = (UIButton*) sender;
    NSLog(@"CustomRadioButton:buttonClicked %d", newSel.tag);
    if ((newSel.tag - 1000) != selIndex) {
        //UIButton *lastSel = (UIButton*) [self viewWithTag:selIndex+1000];
        selIndex = newSel.tag - 1000;
        //[newSel setBackgroundImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"]
          //                  forState:UIControlStateNormal];
        //[lastSel setBackgroundImage:[UIImage imageNamed:@"location_bar_radio.png"]
          //                  forState:UIControlStateNormal];
        if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(radioButtonClicked:sender:)]) {
            [self.delegate radioButtonClicked:selIndex sender:[sender superview]];
        }
    }
}
@end

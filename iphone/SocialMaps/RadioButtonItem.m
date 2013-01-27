//
//  RadioButtonItem.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/10/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "RadioButtonItem.h"
#import "RadioButton.h"
#define BUTTON_WIDTH  80
#define BUTTON_HEIGHT 46
@implementation RadioButtonItem

@synthesize title;
@synthesize subTitle;
@synthesize btnTag;
@synthesize titleString;
@synthesize subtitleString;
@synthesize parent;
@synthesize labels;
@synthesize selectedBtn;

- (id)initWithFrame:(CGRect)frame title:(NSString*)titleStr subTitle:(NSString*)subTitleStr labels:(NSArray*)lbls defBtn:(int) def sender:(id) sender tag:(int)tag
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        btnTag = tag;
        titleString = [NSString stringWithString:titleStr];
        subtitleString = [NSString stringWithString:subTitleStr];
        parent = sender;
        self.backgroundColor = [UIColor clearColor];
        labels = lbls;
        selectedBtn = def;
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
    
    if (subtitleString == nil || [subtitleString isEqualToString:@""]) {
        subTitle = nil;
        CGRect titleFrame = CGRectMake(10, (self.frame.size.height-titleStringSize.height)/2, titleStringSize.width, titleStringSize.height);
        title = [[UILabel alloc] initWithFrame:titleFrame];
        title.text = titleString;
        title.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        title.backgroundColor = [UIColor clearColor];
        [self addSubview:title];
    } else {
        CGRect titleFrame = CGRectMake(10, (self.frame.size.height-titleStringSize.height*2)/2, titleStringSize.width, titleStringSize.height);
        title = [[UILabel alloc] initWithFrame:titleFrame];
        title.text = titleString;
        title.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        title.backgroundColor = [UIColor clearColor];
        
        CGSize subtitleStringSize = [subtitleString sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0]];
        CGRect subtitleFrame = CGRectMake(10, (self.frame.size.height-titleStringSize.height*2)/2+titleFrame.size.height, 
                                          subtitleStringSize.width, subtitleStringSize.height * 2);
        subTitle = [[UILabel alloc] initWithFrame:subtitleFrame];
        subTitle.text = subtitleString;
        subTitle.font = [UIFont fontWithName:@"Helvetica" size:12.0];
        subTitle.backgroundColor = [UIColor clearColor];
        subTitle.numberOfLines = 2;
        [self addSubview:title];
        [self addSubview:subTitle];
    }
    // Button
    CGRect buttonFrame = CGRectMake(self.frame.size.width-BUTTON_WIDTH-5, 
                                     (self.frame.size.height-BUTTON_HEIGHT)/2, BUTTON_WIDTH, BUTTON_HEIGHT);
    RadioButton *radio = [[RadioButton alloc] initWithFrame:buttonFrame labels:labels default:selectedBtn sender:self tag:btnTag];
    radio.delegate = parent;
    self.tag = btnTag;
    
    [self addSubview:radio];
    
}

@end

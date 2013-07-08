//
//  LocationSharingPref.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/10/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "CounterItem.h"
#import "CustomCounter.h"

#define COUNTER_WIDTH 60
#define COUNTER_HEIGHT 40

@implementation CounterItem
@synthesize title;
@synthesize subTitle;
@synthesize btnTag;
@synthesize titleString;
@synthesize subtitleString;
@synthesize parent;
@synthesize defVal;

- (id)initWithFrame:(CGRect)frame title:(NSString*)titleStr subTitle:(NSString*)subTitleStr defVal:(int)def sender:(id) sender tag:(int)tag
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        defVal = def;
        btnTag = tag;
        titleString = [NSString stringWithString:titleStr];
        subtitleString = [NSString stringWithString:subTitleStr];
        parent = sender;
        self.backgroundColor = [UIColor clearColor];
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
                                          subtitleStringSize.width, subtitleStringSize.height);
        subTitle = [[UILabel alloc] initWithFrame:subtitleFrame];
        subTitle.text = subtitleString;
        subTitle.font = [UIFont fontWithName:@"Helvetica" size:12.0];
        subTitle.backgroundColor = [UIColor clearColor];
        
        [self addSubview:title];
        [self addSubview:subTitle];
    }
    // Button
    CGRect counterFrame = CGRectMake(self.frame.size.width-COUNTER_WIDTH-5, 
                                 (self.frame.size.height-COUNTER_HEIGHT)/2, COUNTER_WIDTH, COUNTER_HEIGHT);
    CustomCounter *counter = [[CustomCounter alloc] initWithFrame:counterFrame allowNeg:FALSE default:defVal sender:self tag:btnTag];
    //btn.tag = btnTag;
    self.tag = btnTag;
    counter.delegate = parent;
    
    [self addSubview:counter];

}

@end

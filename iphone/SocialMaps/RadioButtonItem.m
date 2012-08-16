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


- (id)initWithFrame:(CGRect)frame title:(NSString*)titleStr subTitle:(NSString*)subTitleStr labels:(NSArray*)lbls sender:(id) sender tag:(int)tag
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
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.backgroundColor = [UIColor clearColor]; 
    /*UIImageView *bgImageView = [[UIImageView alloc] 
                                initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) ];
    [bgImageView setContentMode:UIViewContentModeScaleToFill];
    
    bgImageView.image = [UIImage imageNamed:@"img_settings_list_bg.png"];
    [self addSubview:bgImageView];*/
    
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
    CGRect buttonFrame = CGRectMake(self.frame.size.width-BUTTON_WIDTH-5, 
                                     (self.frame.size.height-BUTTON_HEIGHT)/2, BUTTON_WIDTH, BUTTON_HEIGHT);
    //- (id)initWithFrame:(CGRect)frame labels:(NSArray*)lbl default:(int)def sender:(id)sender tag:(int)tag
    RadioButton *radio = [[RadioButton alloc] initWithFrame:buttonFrame labels:labels default:0 sender:self tag:9000];
    //btn.tag = btnTag;
    self.tag = btnTag;
    
    [self addSubview:radio];
    
}

@end

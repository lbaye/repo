//
//  ToggleView.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/8/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "ToggleView.h"

@implementation ToggleView
@synthesize titleString;
@synthesize title;
@synthesize toggleBtn;
@synthesize btnTag;
@synthesize parent;
@synthesize labelStrings;

- (id)initWithFrame:(CGRect)frame title:(NSString*)titleStr labels:(NSArray*)labels sender:(id) sender tag:(int)tag
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        btnTag = tag;
        titleString = [NSString stringWithString:titleStr];
        parent = sender;
        labelStrings = [NSMutableArray arrayWithArray:labels];
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
    UIImageView *bgImageView = [[UIImageView alloc] 
                                initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) ];
    [bgImageView setContentMode:UIViewContentModeScaleToFill];
    
    bgImageView.image = [UIImage imageNamed:@"img_settings_list_bg.png"];
    [self addSubview:bgImageView];
    [bgImageView release];
    CGSize titleStringSize = [titleString sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:14.0]];

    CGRect titleFrame = CGRectMake(10, (self.frame.size.height-titleStringSize.height)/2, titleStringSize.width, titleStringSize.height);
    title = [[UILabel alloc] initWithFrame:titleFrame];
    title.text = titleString;
    title.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    title.backgroundColor = [UIColor clearColor];
    [self addSubview:title];
    
    // Button
    CGRect btnFrame = CGRectMake(self.frame.size.width-100, 
                                 0, 100, self.frame.size.height);
    toggleBtn = [[CustomRadioButton alloc] initWithFrame:btnFrame numButtons:2 labels:labelStrings default:0 sender:self tag:btnTag+1000];
        
    [self addSubview:toggleBtn];
    
}

@end

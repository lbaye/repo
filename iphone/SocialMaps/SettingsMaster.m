//
//  SettingsMaster.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/8/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "SettingsMaster.h"
#import "Constants.h"

#define BUTTON_WIDTH 21
#define BUTTON_HEIGHT 21

@implementation SettingsMaster
@synthesize title;
@synthesize subTitle;
@synthesize btn;
@synthesize btnTag;
@synthesize titleString;
@synthesize subtitleString;
@synthesize parent;
@synthesize bgImageName;
@synthesize settingsType;

- (id)initWithFrame:(CGRect)frame title:(NSString*)titleStr subTitle:(NSString*)subTitleStr bgImage:(NSString*)bgImgName type:(int) dispType sender:(id) sender tag:(int)tag
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        btnTag = tag;
        titleString = [NSString stringWithString:titleStr];
        subtitleString = [NSString stringWithString:subTitleStr];
        parent = sender;
        self.bgImageName = bgImgName;
        self.backgroundColor = [UIColor clearColor];
        self.settingsType = dispType;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.backgroundColor = [UIColor clearColor]; 
    if (![self.bgImageName isEqualToString:@""]) {
        UIImageView *bgImageView = [[UIImageView alloc] 
                                    initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) ];
        [bgImageView setContentMode:UIViewContentModeScaleToFill];
        
        bgImageView.image = [UIImage imageNamed:bgImageName];
        bgImageView.tag   = btnTag + 100000;
        [self addSubview:bgImageView];
    }
    
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
    CGRect btnFrame = CGRectMake(self.frame.size.width-BUTTON_WIDTH-5, 
                                 (self.frame.size.height-BUTTON_HEIGHT)/2, BUTTON_WIDTH, BUTTON_HEIGHT);
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = btnFrame;
    [btn addTarget:parent 
            action:@selector(accSettingButtonClicked:)
                forControlEvents:UIControlEventTouchUpInside];
    if (settingsType == SettingsDisplayTypeExpand)
        [btn setImage:[UIImage imageNamed:@"icon_arrow_down.png"]
             forState:UIControlStateNormal];
    else
        [btn setImage:[UIImage imageNamed:@"icon_arrow_right.png"]
             forState:UIControlStateNormal];
    //btn.tag = btnTag;
    self.tag = btnTag;
    
    [self addSubview:btn];
    
}

- (void) setState:(SETTINGS_DISPLAY_STATE)state {
    
    if (state == SettingsDisplayStateClosed) {
        [btn setImage:[UIImage imageNamed:@"icon_arrow_down.png"]
             forState:UIControlStateNormal];
        [btn removeTarget:parent action:@selector(accSettingResetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:parent action:@selector(accSettingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [btn setImage:[UIImage imageNamed:@"icon_arrow_up.png"]
             forState:UIControlStateNormal];
        [btn removeTarget:parent action:@selector(accSettingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:parent action:@selector(accSettingResetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
}
@end

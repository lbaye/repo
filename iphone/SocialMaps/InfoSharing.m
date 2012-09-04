//
//  InfoSharing.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/7/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "InfoSharing.h"
#import "SettingsController.h"
#import "SettingsMaster.h"
#import "CustomRadioButton.h"

#define ROW_HEIGHT 62
#define NUM_ITEMS  7

@implementation InfoSharing

- (UIScrollView*) initWithFrame:(CGRect)scrollFrame infoList:(NSArray*)infoList
                         defList:(NSArray*)defList sender:(id) sender {
    self = [super initWithFrame:scrollFrame];
    if (self) {
        self = [super initWithFrame:scrollFrame];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGSize contentSize = CGSizeMake(self.frame.size.width, 
                                    (ROW_HEIGHT+2)*NUM_ITEMS);
    [self setContentSize:contentSize];
    
    /*CGRect myFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 
     self.frame.size.width, (ROW_HEIGHT+2)*NUM_ITEMS);
     self.frame = myFrame;*/
    
    //self.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor colorWithRed:247.0/255.0 
                                           green:247.0/255.0 
                                            blue:247.0/255.0 
                                           alpha:1.0];
    int startTag = 2000;
    // Name
    SettingsMaster *nameView = [[SettingsMaster alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, ROW_HEIGHT) title:@"Name..." subTitle:@"" bgImage:@"img_settings_list_bg.png" type:SettingsDisplayTypeExpand sender:self tag:startTag++];
    
    // Email
    SettingsMaster *emailView = [[SettingsMaster alloc] initWithFrame:CGRectMake(0, ROW_HEIGHT+2, self.frame.size.width, ROW_HEIGHT) title:@"Email..." subTitle:@"" bgImage:@"img_settings_list_bg.png" type:SettingsDisplayTypeExpand sender:self tag:startTag++];
    
    // Gender
    SettingsMaster *genderView = [[SettingsMaster alloc] initWithFrame:CGRectMake(0, 2*(ROW_HEIGHT+2), self.frame.size.width, ROW_HEIGHT) title:@"Gender..." subTitle:@"" bgImage:@"img_settings_list_bg.png" type:SettingsDisplayTypeExpand sender:self tag:startTag++];
    
    // Date of birth
    SettingsMaster *dobView = [[SettingsMaster alloc] initWithFrame:CGRectMake(0, 3*(ROW_HEIGHT+2), self.frame.size.width, ROW_HEIGHT) title:@"Date of birth..." subTitle:@"" bgImage:@"img_settings_list_bg.png" type:SettingsDisplayTypeExpand sender:self tag:startTag++];
     
    // Biography
    SettingsMaster *bioView = [[SettingsMaster alloc] initWithFrame:CGRectMake(0, 4*(ROW_HEIGHT+2), self.frame.size.width, ROW_HEIGHT) title:@"Biography..." subTitle:@"" bgImage:@"img_settings_list_bg.png" type:SettingsDisplayTypeExpand sender:self tag:startTag++];
    
    // Address
    SettingsMaster *addressView = [[SettingsMaster alloc] initWithFrame:CGRectMake(0, 5*(ROW_HEIGHT+2), self.frame.size.width, ROW_HEIGHT) title:@"Address..." subTitle:@"" bgImage:@"img_settings_list_bg.png" type:SettingsDisplayTypeExpand sender:self tag:startTag++];
    
    // Relationship status
    SettingsMaster *relstatView = [[SettingsMaster alloc] initWithFrame:CGRectMake(0, 6*(ROW_HEIGHT+2), self.frame.size.width, ROW_HEIGHT) title:@"Relationship status..." subTitle:@"" bgImage:@"img_settings_list_bg.png" type:SettingsDisplayTypeExpand sender:self tag:startTag++];
    

    [self addSubview:nameView];
    [self addSubview:emailView];
    [self addSubview:genderView];
    [self addSubview:dobView];
    [self addSubview:bioView];
    [self addSubview:addressView];
    [self addSubview:relstatView];
}

- (void) cascadeHeightChange:(int)indx incr:(int)incr {
    NSArray* myViews = [self subviews];
    for (int i=0; i<[myViews count]; i++) {
        UIView *aview = (UIView*) [myViews objectAtIndex:i];
        int tag = aview.tag;
        if (tag > indx) {
            CGRect newRect = CGRectMake(aview.frame.origin.x, 
                                        aview.frame.origin.y+incr, 
                                        aview.frame.size.width, 
                                        aview.frame.size.height);
            aview.frame = newRect;
        }
    }
}

- (void) addCustomRadioView:(int)tag {
    SettingsMaster *aview = (SettingsMaster*) [self viewWithTag:tag];
    aview.title.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    
    CustomRadioButton *radio = [[CustomRadioButton alloc] initWithFrame:CGRectMake(0, aview.frame.size.height+7, aview.frame.size.width, ROW_HEIGHT-7) numButtons:5 labels:[NSArray arrayWithObjects:@"All users",@"Friends only",@"No one",@"Circles only",@"Custom...",nil]  default:2 sender:self tag:tag+1000];
    
    // Create the line with image line_arrow_down_left.png
    CGRect lineFrame = CGRectMake(0, aview.frame.size.height, 310, 7);
    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:lineFrame];
    lineImage.image = [UIImage imageNamed:@"line_arrow_down_left.png"];
    lineImage.tag   = tag+1001;  
    [aview addSubview:lineImage];
    
    CGRect newFrame = CGRectMake(0, aview.frame.origin.y, aview.frame.size.width, aview.frame.size.height+radio.frame.size.height+7);
    aview.frame = newFrame;
    [aview addSubview:radio];
    
    CGSize contentSize = CGSizeMake(self.contentSize.width, 
                                    self.contentSize.height+radio.frame.size.height+7);
    [self setContentSize:contentSize];
    [self cascadeHeightChange:tag incr:radio.frame.size.height+7];
    [self setNeedsLayout];
}

- (void) removeCustomRadioView:(int)tag {
    SettingsMaster *aview = (SettingsMaster*) [self viewWithTag:tag];
    aview.title.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    
    UIView *child = (UIView*) [aview viewWithTag:tag+1000];
    CGRect removedFrame = child.frame;
    [child removeFromSuperview];
    
    child = (UIView*) [aview viewWithTag:tag+1001];
    [child removeFromSuperview];
    
    CGRect newFrame = CGRectMake(0, aview.frame.origin.y, aview.frame.size.width, ROW_HEIGHT);
    aview.frame = newFrame;
    CGSize contentSize = CGSizeMake(self.contentSize.width, 
                                    self.contentSize.height-removedFrame.size.height-7);
    [self setContentSize:contentSize];
    [self cascadeHeightChange:tag incr:-(removedFrame.size.height+7)];
    [self setNeedsLayout];
}

- (void) accSettingButtonClicked:(id) sender {
    UIButton *btn = (UIButton*) sender;
    
    // Change button image
    [btn setImage:[UIImage imageNamed:@"icon_arrow_up.png"] forState:UIControlStateNormal];
    
    SettingsMaster *parent = (SettingsMaster*)[btn superview];
    NSLog(@"InfoSharing accSettingButtonClicked: tag=%d", parent.tag);
    [btn removeTarget:self action:@selector(accSettingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:@selector(accSettingResetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addCustomRadioView:parent.tag];
}

- (void) accSettingResetButtonClicked:(id) sender {
    UIButton *btn = (UIButton*) sender;
    
    [btn setImage:[UIImage imageNamed:@"icon_arrow_down.png"] forState:UIControlStateNormal];
    
    SettingsMaster *parent = (SettingsMaster*)[btn superview];
    NSLog(@"accSettingResetButtonClicked: tag=%d", parent.tag);
    [btn removeTarget:self action:@selector(accSettingResetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:@selector(accSettingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self removeCustomRadioView:parent.tag];
}


//- (UIScrollView*) initWithFrame:(CGRect)scrollFrame infoList:(NSArray*)infoList
//                         defList:(NSArray*)defList sender:(id) sender {
//    self = [super initWithFrame:scrollFrame];
//    if (self) {
//        SettingsController *settingsView = (SettingsController*) sender;
//        int itemCount = [infoList count];
//        
//        // Setup scroll view
//        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
//        CGSize contentSize = CGSizeMake(scrollView.frame.size.width, 
//                                        (INFO_SHARING_ROW_HEIGHT+2)*itemCount);
//        [scrollView setContentSize:contentSize];
//        scrollView.backgroundColor = [UIColor colorWithRed:247.0/255.0 
//                                                     green:247.0/255.0 
//                                                      blue:247.0/255.0 
//                                                     alpha:1.0];        
//        int itemViewWidth = scrollFrame.size.width;
//        // Setup the items
//        int startTag = 10000;
//        for (int i=0; i < itemCount; i++) {
//            UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(0, 
//                                        (INFO_SHARING_ROW_HEIGHT+2)*i, 
//                                        itemViewWidth,INFO_SHARING_ROW_HEIGHT)];
//            UIImageView *bgImageView = [[UIImageView alloc] 
//                                         initWithFrame:CGRectMake(0, 0, itemViewWidth, INFO_SHARING_ROW_HEIGHT) ];
//            [bgImageView setContentMode:UIViewContentModeScaleToFill];
//
//            bgImageView.image = [UIImage imageNamed:@"img_settings_list_bg.png"];
//            [itemView addSubview:bgImageView];
//            
//            CGRect chkBoxFrame = CGRectMake(0, 0, itemView.frame.size.width, 
//                                            itemView.frame.size.height);
//            CustomCheckbox *chkBoxFirst = [[CustomCheckbox alloc] initWithFrame:chkBoxFrame boxLocType:LabelPositionLeft numBoxes:1 default:[NSArray arrayWithObject:(NSNumber*) [defList objectAtIndex:i]] labels:[NSArray arrayWithObject:[infoList objectAtIndex:i]]];
//            chkBoxFirst.delegate = settingsView;
//            chkBoxFirst.tag = startTag++;
//            [itemView addSubview:chkBoxFirst];
//            [self addSubview:itemView];
//        }
//    }
//    return self;
//}
@end

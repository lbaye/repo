//
//  LocationSharingPlaces.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/11/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "LocationSharingPlaces.h"

#import "LocationSharingCircle.h"
#import "LocationSharing.h"
#import "AccountSettings.h"
#import "SettingsMaster.h"
#import "ToggleView.h"
#import "ConfirmView.h"
#import "ResetPassword.h"
#import "PersonalInformation.h"
#import "CounterItem.h"
#import "RadioButtonItem.h"
#import "LocationSharingPref.h"
#import "NewLocationItem.h"

#define ROW_HEIGHT 62

@implementation LocationSharingPlaces
@synthesize parent;

- (LocationSharingPlaces*) initWithFrame:(CGRect)scrollFrame sender:(id)sender tag:(int)tag {
    self = [super initWithFrame:scrollFrame];
    if (self) {
        //self.frame = scrollFrame;
        CGRect newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, (ROW_HEIGHT+2)*4);
        self.frame = newFrame;
        self.tag = tag;
        self.parent = sender;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.backgroundColor = [UIColor lightGrayColor];
    int startTag = 8999;
    int rowNum = 0;
    //Erase history
    // Location sharing information
    SettingsMaster *newLoc = [[SettingsMaster alloc] initWithFrame:CGRectMake(0, rowNum++*(ROW_HEIGHT+2), self.frame.size.width, ROW_HEIGHT) title:@"New location" subTitle:@"" bgImage:@"img_settings_list_bg.png" type:SettingsDisplayTypeExpand sender:self tag:startTag++]; 
    // Remove default background image
    [[newLoc viewWithTag:99999] removeFromSuperview];
    
    SettingsMaster *locOne = [[SettingsMaster alloc] initWithFrame:CGRectMake(0, rowNum++*(ROW_HEIGHT+2), self.frame.size.width, ROW_HEIGHT) title:@"Location 1" subTitle:@"" bgImage:@"img_settings_list_bg.png" type:SettingsDisplayTypeExpand sender:self tag:startTag++]; 
    // Remove default background image
    [[locOne viewWithTag:99999] removeFromSuperview];
    
    SettingsMaster *locTwo = [[SettingsMaster alloc] initWithFrame:CGRectMake(0, rowNum++*(ROW_HEIGHT+2), self.frame.size.width, ROW_HEIGHT) title:@"Location 2" subTitle:@"" bgImage:@"img_settings_list_bg.png" type:SettingsDisplayTypeExpand sender:self tag:startTag++];    
    // Remove default background image
    [[locTwo viewWithTag:99999] removeFromSuperview];
    
    SettingsMaster *locThree = [[SettingsMaster alloc] initWithFrame:CGRectMake(0, rowNum++*(ROW_HEIGHT+2), self.frame.size.width, ROW_HEIGHT) title:@"Location 3" subTitle:@"" bgImage:@"img_settings_list_bg.png" type:SettingsDisplayTypeExpand sender:self tag:startTag++];   
    // Remove default background image
    [[locThree viewWithTag:99999] removeFromSuperview];
    
    SettingsMaster *locFour = [[SettingsMaster alloc] initWithFrame:CGRectMake(0, rowNum++*(ROW_HEIGHT+2), self.frame.size.width, ROW_HEIGHT) title:@"Location 4" subTitle:@"" bgImage:@"img_settings_list_bg.png" type:SettingsDisplayTypeExpand sender:self tag:startTag++];   
    // Remove default background image
    [[locFour viewWithTag:99999] removeFromSuperview];

    
    // Setthe scrollable area size
    CGSize contentSize = CGSizeMake(self.frame.size.width, 
                                    (ROW_HEIGHT+2)*rowNum);
    [self setContentSize:contentSize];
    CGRect newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, (ROW_HEIGHT+2)*rowNum);
    self.frame = newFrame;
    
    [self addSubview:newLoc];
    [self addSubview:locOne];
    [self addSubview:locTwo];
    [self addSubview:locThree];
    [self addSubview:locFour];
}

- (void) cascadeHeightChange:(int)indx incr:(int)incr {
    NSArray* myViews = [self subviews];
    for (int i=0; i<[myViews count]; i++) {
        UIView *aview = (UIView*) [myViews objectAtIndex:i];
        int tag = aview.tag;
        if (tag >= indx) {
            if (tag == indx) {
                // My height has changed
                CGRect newFrame = CGRectMake(0, aview.frame.origin.y, aview.frame.size.width, aview.frame.size.height+incr);
                aview.frame = newFrame;
                
                newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 
                                      self.frame.size.width, self.frame.size.height+incr);
                self.frame = newFrame;
                
                CGSize contentSize = CGSizeMake(self.contentSize.width, 
                                                self.contentSize.height+incr);
                [self setContentSize:contentSize];
            } else {
                CGRect newRect = CGRectMake(aview.frame.origin.x, 
                                            aview.frame.origin.y+incr, 
                                            aview.frame.size.width, 
                                            aview.frame.size.height);
                aview.frame = newRect;
            }
        }
    }
}
- (void) addNewPlaceSharingView:(int)tag {
    SettingsMaster *aview = (SettingsMaster*) [self viewWithTag:tag];
    aview.title.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    
    NewLocationItem *locSharing = [[NewLocationItem alloc] initWithFrame:CGRectMake(0, aview.frame.size.height+7, aview.frame.size.width, ROW_HEIGHT-7) title:(NSString*)@"Location Name" sender:self tag:tag+1000];
    
    // Create the line with image line_arrow_down_left.png
    CGRect lineFrame = CGRectMake(20, aview.frame.size.height, 310, 7);
    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:lineFrame];
    lineImage.image = [UIImage imageNamed:@"line_arrow_down_left.png"];
    lineImage.tag   = tag+1001;  
    [aview addSubview:lineImage];
    
    locSharing.backgroundColor = [UIColor clearColor];
    [aview addSubview:locSharing];
    
    [self cascadeHeightChange:tag incr:locSharing.frame.size.height+7];
    [self setNeedsLayout];
}

- (void) addPlaceSharingView:(int)tag prefs:(int)prefs{
    SettingsMaster *aview = (SettingsMaster*) [self viewWithTag:tag];
    aview.title.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    
    LocationSharingPref *locSharing = [[LocationSharingPref alloc] initWithFrame:CGRectMake(0, aview.frame.size.height+7, aview.frame.size.width, ROW_HEIGHT-7) prefs:prefs defRadius:2 defDuration:60 defPerm:TRUE sender:self tag:tag+1000];
    
    // Create the line with image line_arrow_down_left.png
    CGRect lineFrame = CGRectMake(20, aview.frame.size.height, 310, 7);
    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:lineFrame];
    lineImage.image = [UIImage imageNamed:@"line_arrow_down_left.png"];
    lineImage.tag   = tag+1001;  
    [aview addSubview:lineImage];
    
    locSharing.backgroundColor = [UIColor clearColor];
    [aview addSubview:locSharing];
    
    [self cascadeHeightChange:tag incr:locSharing.frame.size.height+7];
    [self setNeedsLayout];
}

- (void) removePlaceSharingView:(int)tag {
    SettingsMaster *aview = (SettingsMaster*) [self viewWithTag:tag];
    aview.title.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    
    UIView *child = (UIView*) [aview viewWithTag:tag+1000];
    CGRect removedFrame = child.frame;
    [child removeFromSuperview];
    
    child = (UIView*) [aview viewWithTag:tag+1001];
    [child removeFromSuperview];
    
    [self cascadeHeightChange:tag incr:-(removedFrame.size.height+7)];
    [self setNeedsLayout];
}

- (void) accSettingButtonClicked:(id) sender {
    UIButton *btn = (UIButton*) sender;
    
    // Change button image
    [btn setImage:[UIImage imageNamed:@"icon_arrow_up.png"] forState:UIControlStateNormal];
    
    SettingsMaster *btnParent = (SettingsMaster*)[btn superview];
    NSLog(@"LocationSharingPlaces accSettingButtonClicked: tag=%d", btnParent.tag);
    if (btnParent.tag >= 8999 && btnParent.tag <= 9003) {
        [btn removeTarget:self action:@selector(accSettingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:self action:@selector(accSettingResetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        if (self.parent != NULL && [self.parent respondsToSelector:@selector (accSettingButtonClicked:)]) {
            [self.parent accSettingButtonClicked:self];
        }
        switch (btnParent.tag) {
            case 8999:
                // New Location
                [self addNewPlaceSharingView:btnParent.tag];
                break;
            case 9000:
                // Location 0
                //break;
            case 9001:
                // Location 1
                //break;
            case 9002:
                // Location 2
                //break;
            case 9003:
                // Location 3
                [self addPlaceSharingView:btnParent.tag prefs:LocationSharingPrefTypeRadius];
                break;
            default:
                break;
        }
    }
}

- (void) accSettingResetButtonClicked:(id) sender {
    UIButton *btn = (UIButton*) sender;
    
    [btn setImage:[UIImage imageNamed:@"icon_arrow_down.png"] forState:UIControlStateNormal];
    
    SettingsMaster *btnParent = (SettingsMaster*)[btn superview];
    NSLog(@"accSettingResetButtonClicked: tag=%d", btnParent.tag);
    if (btnParent.tag >= 9000 && btnParent.tag <= 9003)  {
        [btn removeTarget:self action:@selector(accSettingResetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:self action:@selector(accSettingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        switch (btnParent.tag) {
            case 9000:
                // Location 0
                //break;
            case 9001:
                // Location 1
                //break;
            case 9002:
                // Location 2
                //break;
            case 9003:
                // Location 3
                [self removePlaceSharingView:btnParent.tag];
                break;
            default:
                break;
        }
        if (self.parent != NULL && [self.parent respondsToSelector:@selector (accSettingResetButtonClicked:)]) {
            [self.parent accSettingResetButtonClicked:self];
        }
    }
    
}

// UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	// When the user presses return, take focus away from the text field so that the keyboard is dismissed.
    [self endEditing:YES];
    
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
    [self bringSubviewToFront:[textField superview]];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
    // Store the userid and password
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    int movementDistance = 200; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.frame = CGRectOffset(self.frame, 0, movement);
    [UIView commitAnimations];
}
@end
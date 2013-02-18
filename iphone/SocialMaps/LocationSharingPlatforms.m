//
//  LocationSharingPlatforms.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/11/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "LocationSharingPlatforms.h"
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

#define ROW_HEIGHT 62

@implementation LocationSharingPlatforms
@synthesize parent;
@synthesize numSections;

- (LocationSharingPlatforms*) initWithFrame:(CGRect)scrollFrame sender:(id)sender tag:(int)tag {
    self = [super initWithFrame:scrollFrame];
    if (self) {
        AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        numSections = smAppDelegate.locSharingPrefs.platforms.count;
        // Add facebook if empty
        if (numSections == 0) {
            LocationPlatformSettings *locPlatform = [[LocationPlatformSettings alloc] init];
            locPlatform.privacy = [[LocationPrivacySettings alloc] init];
            locPlatform.platformName = @"Facebook";
            locPlatform.privacy.radius = 2;
            locPlatform.privacy.duration = 0;
            numSections++;
            [smAppDelegate.locSharingPrefs.platforms addObject:locPlatform];
            [locPlatform release];
        }
        CGRect newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, (ROW_HEIGHT+2)*numSections);
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
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.backgroundColor = [UIColor clearColor];
    int startTag = 11000;
    int rowNum = 0;
    //Erase history
    // Location sharing information
    AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    for (int i=0; i < numSections; i++ ) {
        LocationPlatformSettings *platformLoc = (LocationPlatformSettings*) [smAppDelegate.locSharingPrefs.platforms objectAtIndex:i];
        SettingsMaster *aPlatform = [[SettingsMaster alloc] initWithFrame:CGRectMake(0, rowNum++*(ROW_HEIGHT+2), self.frame.size.width, ROW_HEIGHT) title:platformLoc.platformName subTitle:@"" bgImage:@"" type:SettingsDisplayTypeExpand sender:self tag:startTag++ level:1];

        // Remove default background image
        [[aPlatform viewWithTag:99999] removeFromSuperview];
        
        // Dividers
        if (i > 0) {
            UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x+10, 0, self.frame.size.width-10, 1)];
            sep.backgroundColor = [UIColor lightGrayColor];
            [aPlatform addSubview:sep];
            [sep release];
        }
        [self addSubview:aPlatform];
        [aPlatform release];
    }
    
    // Setthe scrollable area size
    CGSize contentSize = CGSizeMake(self.frame.size.width, 
                                    (ROW_HEIGHT+2)*rowNum);
    [self setContentSize:contentSize];
    CGRect newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, (ROW_HEIGHT+2)*rowNum);
    self.frame = newFrame;
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

- (void) addLocSharingView:(int)tag prefs:(int)prefs{
    SettingsMaster *aview = (SettingsMaster*) [self viewWithTag:tag];
    aview.title.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    
    int indx = tag - 11000;
    AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    LocationPlatformSettings *platformLoc = (LocationPlatformSettings*) [smAppDelegate.locSharingPrefs.platforms objectAtIndex:indx];
    LocationSharingPref *locSharing = [[LocationSharingPref alloc] initWithFrame:CGRectMake(0, aview.frame.size.height+7, aview.frame.size.width, ROW_HEIGHT-7) prefs:prefs defRadius:platformLoc.privacy.radius defDuration:platformLoc.privacy.duration defPerm:TRUE sender:self tag:tag+1000 level:1];
    
    // Create the line with image line_arrow_down_left.png
    CGRect lineFrame = CGRectMake(20, aview.frame.size.height, 310, 7);
    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:lineFrame];
    lineImage.image = [UIImage imageNamed:@"line_arrow_down_left.png"];
    lineImage.tag   = tag+1001;  
    [aview addSubview:lineImage];
    [lineImage release];
    
    locSharing.backgroundColor = [UIColor clearColor];
    [aview addSubview:locSharing];
    
    [self cascadeHeightChange:tag incr:locSharing.frame.size.height+7];
    [self setNeedsLayout];
    [locSharing release];
}

- (void) removeLocSharingView:(int)tag {
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
    NSLog(@"LocationSharingPlatforms accSettingButtonClicked: tag=%d", btnParent.tag);
    if (btnParent.tag >= 11000 && btnParent.tag <= (11000+numSections)) {
        [btn removeTarget:self action:@selector(accSettingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:self action:@selector(accSettingResetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        if (self.parent != NULL && [self.parent respondsToSelector:@selector (accSettingButtonClicked:)]) {
            [self.parent accSettingButtonClicked:self];
        }
        [self addLocSharingView:btnParent.tag prefs:LocationSharingPrefTypeTime|LocationSharingPrefTypeRadius];
    }
}

- (void) accSettingResetButtonClicked:(id) sender {
    UIButton *btn = (UIButton*) sender;
    
    [btn setImage:[UIImage imageNamed:@"icon_arrow_down.png"] forState:UIControlStateNormal];
    
    SettingsMaster *btnParent = (SettingsMaster*)[btn superview];
    NSLog(@"accSettingResetButtonClicked: tag=%d", btnParent.tag);
    if (btnParent.tag >= 11000 && btnParent.tag <= (11000+numSections)) {
        [btn removeTarget:self action:@selector(accSettingResetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:self action:@selector(accSettingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self removeLocSharingView:btnParent.tag];

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

// CustomCounterDelegate method
- (void) counterValueChanged:(int)newVal sender:(id)sender {
    
    NSLog(@"LocationSharingPlatforms counterValueChanged new value=%d, sender tag = %d", newVal, (int) sender);
    int offset = (int)sender - 12100;
    int itemIndex = offset / 100;
    int platformIndex  = offset % 100;
    NSLog(@"LocationSharingCircle platformIndex = %d, itemIndex = %d", platformIndex, itemIndex);
    AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    LocationPlatformSettings *platformLoc = (LocationPlatformSettings*) [smAppDelegate.locSharingPrefs.platforms objectAtIndex:platformIndex];
    if (itemIndex == 0)
        platformLoc.privacy.duration = newVal;
    else
        platformLoc.privacy.radius = newVal;

}

@end
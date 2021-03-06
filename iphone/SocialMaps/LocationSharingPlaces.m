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
#import "Globals.h"

#define ROW_HEIGHT 62

@implementation LocationSharingPlaces
@synthesize parent;
@synthesize numSections;
@synthesize smAppDelegate;

- (LocationSharingPlaces*) initWithFrame:(CGRect)scrollFrame sender:(id)sender tag:(int)tag {
    self = [super initWithFrame:scrollFrame];
    if (self) {
        smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        numSections = smAppDelegate.locSharingPrefs.geoFences.count;
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
    numSections = smAppDelegate.locSharingPrefs.geoFences.count;
    
    self.backgroundColor = [UIColor lightGrayColor];
    int startTag = 9000;
    int rowNum = 0;
    //Erase history
    // Location sharing information
    for (int i=0; i < numSections; i++ ) {
        Geofence *geoFence = (Geofence*) [smAppDelegate.locSharingPrefs.geoFences objectAtIndex:i];
        SettingsMaster *aLoc = [[SettingsMaster alloc] initWithFrame:CGRectMake(0, rowNum++*(ROW_HEIGHT+2), self.frame.size.width, ROW_HEIGHT) title:geoFence.name subTitle:@"" bgImage:@"" type:SettingsDisplayTypeExpand sender:self tag:startTag++ level:1]; 
        // Remove default background image
        [[aLoc viewWithTag:99999] removeFromSuperview];
        
        // Dividers
        if (i > 0) {
            UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x+10, 0, self.frame.size.width-10, 1)];
            sep.backgroundColor = [UIColor lightGrayColor];
            [aLoc addSubview:sep];
            [sep release];
        }

        [self addSubview:aLoc];
        [aLoc release];
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
- (void) addNewPlaceSharingView:(int)tag {
    SettingsMaster *aview = (SettingsMaster*) [self viewWithTag:tag];
    aview.title.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    
    NewLocationItem *locSharing = [[NewLocationItem alloc] initWithFrame:CGRectMake(0, aview.frame.size.height+7, aview.frame.size.width, 220) title:(NSString*)@"Location Name" sender:self tag:tag+1000];
    
    // Create the line with image line_arrow_down_left.png
    CGRect lineFrame = CGRectMake(20, aview.frame.size.height, 310, 7);
    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:lineFrame];
    lineImage.image = [UIImage imageNamed:@"line_arrow_down_left.png"];
    lineImage.tag   = tag+1001;  
    [aview addSubview:lineImage];
    [lineImage release];
    lineImage = nil;
    
    locSharing.backgroundColor = [UIColor clearColor];
    [aview addSubview:locSharing];
    
    [self cascadeHeightChange:tag incr:locSharing.frame.size.height+7];
    [self setNeedsLayout];
    [locSharing release];
    locSharing = nil;
}

- (void) addPlaceSharingView:(int)tag prefs:(int)prefs{
    SettingsMaster *aview = (SettingsMaster*) [self viewWithTag:tag];
    aview.title.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    
    int indx = tag - 9000;
    Geofence *geoFence = (Geofence*) [smAppDelegate.locSharingPrefs.geoFences objectAtIndex:indx];
    LocationSharingPref *locSharing = [[LocationSharingPref alloc] initWithFrame:CGRectMake(0, aview.frame.size.height+7, aview.frame.size.width, ROW_HEIGHT-7) prefs:prefs defRadius:[geoFence.radius intValue] defDuration:60 defPerm:TRUE sender:self tag:tag+1000 level:1];
    
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
    [lineImage release];
    [locSharing release];
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

- (void) removeNewPlaceSharingView:(int)tag {
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
    if (btnParent.tag >= 9000 && btnParent.tag <= (9000+numSections)) {
        bool newView = FALSE;
        NSObject* senderView = (NSObject*)sender;
        if ([senderView isKindOfClass:[UIButton class]]) {
            // Change button image
            [sender setImage:[UIImage imageNamed:@"icon_arrow_up.png"] forState:UIControlStateNormal];
            [sender removeTarget:self action:@selector(accSettingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [sender addTarget:self action:@selector(accSettingResetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            if (self.parent != NULL && [self.parent respondsToSelector:@selector (accSettingButtonClicked:)]) {
                [self.parent accSettingButtonClicked:self];
            }
            newView = TRUE;
        }
        if (newView)
            [self addPlaceSharingView:btnParent.tag prefs:LocationSharingPrefTypeRadius];
    }
}

- (void) accSettingResetButtonClicked:(id) sender {
    UIButton *btn = (UIButton*) sender;
    
    [btn setImage:[UIImage imageNamed:@"icon_arrow_down.png"] forState:UIControlStateNormal];
    
    SettingsMaster *btnParent = (SettingsMaster*)[btn superview];
    NSLog(@"LocationSharingPlaces accSettingResetButtonClicked: tag=%d", btnParent.tag);
    if (btnParent.tag >= 9000 && btnParent.tag <= (9000+numSections))  {
        bool newView = FALSE;
        NSObject* senderView = (NSObject*)sender;
        if ([senderView isKindOfClass:[UIButton class]]) {
            [sender setImage:[UIImage imageNamed:@"icon_arrow_down.png"] forState:UIControlStateNormal];
            [sender removeTarget:self action:@selector(accSettingResetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [sender addTarget:self action:@selector(accSettingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            if (self.parent != NULL && [self.parent respondsToSelector:@selector (accSettingResetButtonClicked:)]) {
                [self.parent accSettingResetButtonClicked:self];
            }
            newView = TRUE;
        }
        if (newView)
            [self removePlaceSharingView:btnParent.tag];

    }
    
}

// CustomCounterDelegate method
- (void) counterValueChanged:(int)newVal sender:(id)sender {
    
    NSLog(@"LocationSharingPlaces counterValueChanged new value=%d, sender tag = %d", newVal, (int) sender);
    int indx = (int)sender - 10200;
    Geofence *geoFence = (Geofence*) [smAppDelegate.locSharingPrefs.geoFences objectAtIndex:indx];
    geoFence.radius = [NSString stringWithFormat:@"%d", newVal];
}


@end
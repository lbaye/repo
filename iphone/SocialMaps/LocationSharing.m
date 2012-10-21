//
//  LocationSharing.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/11/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

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
#import "LocationSharingCircle.h"
#import "LocationSharingPlaces.h"
#import "LocationSharingPlatforms.h"
#import "SelectFriends.h"
#import "AppDelegate.h"
#import "UserCircle.h"
#import "NewLocationItem.h"

#define ROW_HEIGHT 62

@implementation LocationSharing
@synthesize rowNum;
@synthesize smAppDelegate;

- (LocationSharing*) initWithFrame:(CGRect)scrollFrame {
    self = [super initWithFrame:scrollFrame];
    if (self) {
        self.frame = scrollFrame;
        [self setScrollEnabled:TRUE];
        smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    /*CGRect myFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 
     self.frame.size.width, (ROW_HEIGHT+2)*NUM_ITEMS);
     self.frame = myFrame;*/
    
    //self.backgroundColor = [UIColor clearColor];
    [[self subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    int sharingEnabled = 0;
    if ([smAppDelegate.locSharingPrefs.status caseInsensitiveCompare:@"on"] == NSOrderedSame)
        sharingEnabled = 1;

    self.backgroundColor = [UIColor colorWithRed:247.0/255.0 
                                           green:247.0/255.0 
                                            blue:247.0/255.0 
                                           alpha:1.0];
    int startTag = 2000;
    rowNum = 0;
    //Erase history
    // Location sharing information
    RadioButtonItem *enableSharing = [[RadioButtonItem alloc] initWithFrame:CGRectMake(0, rowNum++*(ROW_HEIGHT+2), self.frame.size.width, ROW_HEIGHT) title:@"Location sharing" subTitle:@"" labels:[NSArray arrayWithObjects:@"Off", @"On", nil] defBtn:sharingEnabled sender:self tag:startTag++];
    [self addSubview:enableSharing];

    if (sharingEnabled == 1) {
        SettingsMaster *friendSharingView = [[SettingsMaster alloc] initWithFrame:CGRectMake(0, rowNum++*(ROW_HEIGHT+2), self.frame.size.width, ROW_HEIGHT) title:@"Customize for a subgroup of friends" subTitle:@"Currently 7 friends in subgroup" bgImage:@"img_settings_list_bg.png" type:SettingsDisplayTypeExpand sender:self tag:startTag++];    
        [self addSubview:friendSharingView];
        
        SettingsMaster *circleSharingView = [[SettingsMaster alloc] initWithFrame:CGRectMake(0, rowNum++*(ROW_HEIGHT+2), self.frame.size.width, ROW_HEIGHT) title:@"Customize sharing for circles" subTitle:@"" bgImage:@"img_settings_list_bg.png" type:SettingsDisplayTypeExpand sender:self tag:startTag++];  
        circleSharingView.backgroundColor = [UIColor clearColor];
        [self addSubview:circleSharingView];
        
        SettingsMaster *platformSharingView = [[SettingsMaster alloc] initWithFrame:CGRectMake(0, rowNum++*(ROW_HEIGHT+2), self.frame.size.width, ROW_HEIGHT) title:@"Customize sharing for platforms" subTitle:@"" bgImage:@"img_settings_list_bg.png" type:SettingsDisplayTypeExpand sender:self tag:startTag++];
        [self addSubview:platformSharingView];
        
        SettingsMaster *strangersSharingView = [[SettingsMaster alloc] initWithFrame:CGRectMake(0, rowNum++*(ROW_HEIGHT+2), self.frame.size.width, ROW_HEIGHT) title:@"Customize sharing for strangers" subTitle:@"" bgImage:@"img_settings_list_bg.png" type:SettingsDisplayTypeExpand sender:self tag:startTag++];
        [self addSubview:strangersSharingView];
        
        SettingsMaster *locSharingView = [[SettingsMaster alloc] initWithFrame:CGRectMake(0, rowNum++*(ROW_HEIGHT+2), self.frame.size.width, ROW_HEIGHT) title:@"Customize sharing for locations" subTitle:@"" bgImage:@"img_settings_list_bg.png" type:SettingsDisplayTypeExpand sender:self tag:startTag++];
        [self addSubview:locSharingView];
    }
    
    // Setthe scrollable area size
    CGSize contentSize = CGSizeMake(self.frame.size.width, 
                                    (ROW_HEIGHT+2)*rowNum);
    [self setContentSize:contentSize];   
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

- (void) addLocSharingPlatformView:(int)tag prefs:(int)prefs{
    SettingsMaster *aview = (SettingsMaster*) [self viewWithTag:tag];
    aview.title.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    
    LocationSharingPlatforms *locSharing = [[LocationSharingPlatforms alloc] initWithFrame:CGRectMake(0, aview.frame.size.height+7, aview.frame.size.width, ROW_HEIGHT-7) sender:self tag:tag+1000];
    
    // Create the line with image line_arrow_down_left.png
    CGRect lineFrame = CGRectMake(0, aview.frame.size.height, 310, 7);
    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:lineFrame];
    lineImage.image = [UIImage imageNamed:@"line_arrow_down_left.png"];
    lineImage.tag   = tag+1001;  
    [aview addSubview:lineImage];
    
    locSharing.backgroundColor = [UIColor clearColor];
    [aview addSubview:locSharing];
    
    [self cascadeHeightChange:tag incr:locSharing.frame.size.height+7];
    [self setNeedsLayout];
}


- (void) addLocSharingCircleView:(int)tag prefs:(int)prefs{
    SettingsMaster *aview = (SettingsMaster*) [self viewWithTag:tag];
    aview.title.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    
    LocationSharingCircle *locSharing = [[LocationSharingCircle alloc] initWithFrame:CGRectMake(0, aview.frame.size.height+7, aview.frame.size.width, ROW_HEIGHT-7) sender:self tag:tag+1000];
    
    // Create the line with image line_arrow_down_left.png
    CGRect lineFrame = CGRectMake(0, aview.frame.size.height, 310, 7);
    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:lineFrame];
    lineImage.image = [UIImage imageNamed:@"line_arrow_down_left.png"];
    lineImage.tag   = tag+1001;  
    [aview addSubview:lineImage];
    
    locSharing.backgroundColor = [UIColor clearColor];
    [aview addSubview:locSharing];
    
    [self cascadeHeightChange:tag incr:locSharing.frame.size.height+7];
    [self setNeedsLayout];
}

- (void) addLocSharingPlaceView:(int)tag prefs:(int)prefs{
    SettingsMaster *aview = (SettingsMaster*) [self viewWithTag:tag];
    aview.title.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    
    CGRect selFrame = CGRectMake(0, aview.frame.size.height+7, aview.frame.size.width, ROW_HEIGHT);
    SettingsMaster * newLocation = [[SettingsMaster alloc] initWithFrame:selFrame title:@"New Location" subTitle:@"" bgImage:@"" type:SettingsDisplayTypeDetail sender:self tag:tag+1002];
    [aview addSubview:newLocation];
    
    LocationSharingPlaces *locSharing = [[LocationSharingPlaces alloc] initWithFrame:CGRectMake(0, aview.frame.size.height+7+selFrame.size.height, aview.frame.size.width, ROW_HEIGHT-7) sender:self tag:tag+1000];
    
    // Create the line with image line_arrow_down_left.png
    CGRect lineFrame = CGRectMake(0, aview.frame.size.height, 310, 7);
    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:lineFrame];
    lineImage.image = [UIImage imageNamed:@"line_arrow_down_left.png"];
    lineImage.tag   = tag+1001;  
    [aview addSubview:lineImage];
    
    locSharing.backgroundColor = [UIColor clearColor];
    [aview addSubview:locSharing];
    
    [self cascadeHeightChange:tag incr:locSharing.frame.size.height+7+selFrame.size.height];
    [self setNeedsLayout];
}
- (void) removeLocSharingPlaceView:(int)tag {
    SettingsMaster *aview = (SettingsMaster*) [self viewWithTag:tag];
    aview.title.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    
    int removedViewHeight = 0;
    for (int i= 1000; i <= 1002; i++) {
        UIView *child = (UIView*) [aview viewWithTag:tag+i];
        removedViewHeight += child.frame.size.height;
        [child removeFromSuperview];
    }
    
    [self cascadeHeightChange:tag incr:-(removedViewHeight)];
    [self setNeedsLayout];
}


- (void) addStrangerSharingView:(int)tag prefs:(int)prefs{
    SettingsMaster *aview = (SettingsMaster*) [self viewWithTag:tag];
    aview.title.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    
    LocationSharingPref *locSharing = [[LocationSharingPref alloc] initWithFrame:CGRectMake(0, 
                                                    aview.frame.size.height+7, 
                                                    aview.frame.size.width, ROW_HEIGHT-7) prefs:prefs 
                                                    defRadius:2 defDuration:60 defPerm:TRUE sender:self tag:tag+1000];
    
    // Create the line with image line_arrow_down_left.png
    CGRect lineFrame = CGRectMake(0, aview.frame.size.height, 310, 7);
    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:lineFrame];
    lineImage.image = [UIImage imageNamed:@"line_arrow_down_left.png"];
    lineImage.tag   = tag+1001;  
    [aview addSubview:lineImage];
    
    locSharing.backgroundColor = [UIColor clearColor];
    [aview addSubview:locSharing];
    
    [self cascadeHeightChange:tag incr:locSharing.frame.size.height+7];
    [self setNeedsLayout];
}


- (void) removeStrangerSharingView:(int)tag {
    SettingsMaster *aview = (SettingsMaster*) [self viewWithTag:tag];
    aview.title.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    
    int removedViewHeight = 0;
    UIView *child = (UIView*) [aview viewWithTag:tag+1000];
    removedViewHeight += child.frame.size.height;
    [child removeFromSuperview];
    
    child = (UIView*) [aview viewWithTag:tag+1001];
    removedViewHeight += child.frame.size.height;
    [child removeFromSuperview];
    
    [self cascadeHeightChange:tag incr:-(removedViewHeight)];
    [self setNeedsLayout];
}

- (void) addLocSharingView:(int)tag prefs:(int)prefs{
    SettingsMaster *aview = (SettingsMaster*) [self viewWithTag:tag];
    aview.title.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    
    CGRect selFrame = CGRectMake(0, aview.frame.size.height+7, aview.frame.size.width, ROW_HEIGHT);
    SettingsMaster * selectFriends = [[SettingsMaster alloc] initWithFrame:selFrame title:@"Select subgroup of friends" subTitle:@"" bgImage:@"" type:SettingsDisplayTypeDetail sender:self tag:tag+1002];
    [aview addSubview:selectFriends];
    
    // Draw a line
    UIView *aline = [[UIView alloc] initWithFrame:CGRectMake(0, aview.frame.size.height+7+ROW_HEIGHT-1, 
                                                                       aview.frame.size.width, 1)];
    aline.backgroundColor = [UIColor lightGrayColor];
    aline.tag   = tag+1003;
    [aview addSubview:aline];
    
    LocationSharingPref *locSharing = [[LocationSharingPref alloc] initWithFrame:CGRectMake(0, 
                                                aview.frame.size.height+7+selFrame.size.height, 
                                                aview.frame.size.width, ROW_HEIGHT-7) prefs:prefs 
                                                defRadius:2 defDuration:60 defPerm:TRUE sender:self tag:tag+1000];
    
    // Create the line with image line_arrow_down_left.png
    CGRect lineFrame = CGRectMake(0, aview.frame.size.height, 310, 7);
    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:lineFrame];
    lineImage.image = [UIImage imageNamed:@"line_arrow_down_left.png"];
    lineImage.tag   = tag+1001;  
    [aview addSubview:lineImage];
    
    locSharing.backgroundColor = [UIColor clearColor];
    [aview addSubview:locSharing];
    
    [self cascadeHeightChange:tag incr:locSharing.frame.size.height+7+selFrame.size.height];
    [self setNeedsLayout];
}

- (void) removeLocSharingView:(int)tag {
    SettingsMaster *aview = (SettingsMaster*) [self viewWithTag:tag];
    aview.title.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    
    int removedViewHeight = 0;
    UIView *child = (UIView*) [aview viewWithTag:tag+1000];
    removedViewHeight += child.frame.size.height;
    [child removeFromSuperview];
    
    for (int i= 1001; i <= 1003; i++) {
        child = (UIView*) [aview viewWithTag:tag+i];
        removedViewHeight += child.frame.size.height;
        [child removeFromSuperview];
    }
    
    [self cascadeHeightChange:tag incr:-(removedViewHeight)];
    [self setNeedsLayout];
}

- (void) accSettingButtonClicked:(id) sender {
    UIView *senderView = (UIView*) sender;
    SettingsMaster *parent = (SettingsMaster*)[sender superview];
    NSLog(@"LocationSharing accSettingButtonClicked: tag=%d, parent tag=%d", senderView.tag, parent.tag);
    if (parent.tag >= 2000 && parent.tag <= (2000+rowNum)) {
        bool newView = FALSE;
        NSObject* senderObj = (NSObject*)sender;
        if ([senderObj isKindOfClass:[UIButton class]]) {
            // Change button image
            [sender setImage:[UIImage imageNamed:@"icon_arrow_up.png"] forState:UIControlStateNormal];
            [sender removeTarget:self action:@selector(accSettingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [sender addTarget:self action:@selector(accSettingResetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            newView = TRUE;
        }
        switch (parent.tag) {
            case 2000:
                // Enable sharing
                break;
            case 2001:
                // Friend prefs
                //[self addLocSharingView:parent.tag prefs:LocationSharingPrefTypeTime|LocationSharingPrefTypeRadius|LocationSharingPrefTypePermission];
                [self addLocSharingView:parent.tag prefs:LocationSharingPrefTypeTime|LocationSharingPrefTypeRadius];
                break;
            case 2002:
                // Circle prefs
                if (newView == TRUE)
                    //[self addLocSharingCircleView:parent.tag prefs:LocationSharingPrefTypeTime|LocationSharingPrefTypeRadius|LocationSharingPrefTypePermission];
                    [self addLocSharingCircleView:parent.tag prefs:LocationSharingPrefTypeTime|LocationSharingPrefTypeRadius];
                else
                    [self cascadeHeightChange:parent.tag incr:2*(ROW_HEIGHT)+7];
                break;
            case 2003:
                // Platform prefs
                if (newView == TRUE)
                    //[self addLocSharingPlatformView:parent.tag prefs:LocationSharingPrefTypeTime|LocationSharingPrefTypeRadius|LocationSharingPrefTypePermission];
                    [self addLocSharingPlatformView:parent.tag prefs:LocationSharingPrefTypeTime|LocationSharingPrefTypeRadius];
                else
                    [self cascadeHeightChange:parent.tag incr:2*(ROW_HEIGHT)+7];
                break;
            case 2004:
                // Stranger prefs
                 if (newView == TRUE)
                     [self addStrangerSharingView:parent.tag prefs:LocationSharingPrefTypeTime|LocationSharingPrefTypeRadius];
                 else
                     [self cascadeHeightChange:parent.tag incr:2*(ROW_HEIGHT)+7];
                break;
            case 2005:
                // Location prefs
                if (newView == TRUE)
                    [self addLocSharingPlaceView:parent.tag prefs:LocationSharingPrefTypeTime|LocationSharingPrefTypeRadius];
                else
                    [self cascadeHeightChange:parent.tag incr:1*(ROW_HEIGHT)+7];
                break;
            default:
                break;
        }
    } else {
        if (parent.tag == 3003) {
            // Show select friends view
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            NSMutableArray *circles = [[NSMutableArray alloc] init];
            for (UserCircle *aCircle in appDelegate.userAccountPrefs.circles) {
                [circles addObject:aCircle];
            }
            //SelectFriends *selFriends = [[SelectFriends alloc] initWithFrame:CGRectMake(5, 80, 310, 380) friends:appDelegate.friendList circles:circles];
            SelectFriends *selFriends = [[SelectFriends alloc] initWithFrame:CGRectMake(5, 46, 310, 480-46-20) friends:appDelegate.friendList circles:circles];
            selFriends.delegate = self;
            selFriends.backgroundColor = [UIColor colorWithRed:247.0/255.0 
                                                         green:247.0/255.0 
                                                          blue:247.0/255.0 
                                                         alpha:1.0];
            [[self superview]  addSubview:selFriends];
            [selFriends release];
            
        } else if (parent.tag == 3007) {
            // Show New Location view
            NewLocationItem *locSharing = [[NewLocationItem alloc] initWithFrame:CGRectMake(5, 46, 310, 480-46-20) title:(NSString*)@"Location Name" sender:self tag:parent.tag+1000];
            locSharing.backgroundColor = [UIColor colorWithRed:247.0/255.0 
                                                         green:247.0/255.0 
                                                          blue:247.0/255.0 
                                                         alpha:1.0];
            locSharing.delegate = self;
            [[self superview]  addSubview:locSharing];
            [locSharing release];
        }
    }
}

- (void) accSettingResetButtonClicked:(id) sender {
    UIView *senderView = (UIView*) sender;
    
    SettingsMaster *parent = (SettingsMaster*)[sender superview];
    NSLog(@"accSettingResetButtonClicked: tag=%d, parent tag=%d", senderView.tag, parent.tag);
    if (parent.tag >= 2000 && parent.tag <= (2000+rowNum)) {
        bool newView = FALSE;
        NSObject* senderObj = (NSObject*)sender;
        if ([senderObj isKindOfClass:[UIButton class]]) {
            [sender setImage:[UIImage imageNamed:@"icon_arrow_down.png"] forState:UIControlStateNormal];
            [sender removeTarget:self action:@selector(accSettingResetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [sender addTarget:self action:@selector(accSettingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            newView = TRUE;
        }
        switch (parent.tag) {
            case 2000:
                // Enable sharing
                break;
            case 2001:
                // Friend prefs
                [self removeLocSharingView:parent.tag];
                break;
            case 2002:
                // Circle prefs
                if (newView == TRUE)
                    [self removeLocSharingView:parent.tag];
                else
                    [self cascadeHeightChange:parent.tag incr:-(2*(ROW_HEIGHT)+7)];
                break;
            case 2003:
                // Platform prefs
                //[self removeLocSharingView:parent.tag];
                if (newView == TRUE)
                    [self removeLocSharingView:parent.tag];
                else
                    [self cascadeHeightChange:parent.tag incr:-(2*(ROW_HEIGHT)+7)];
                break;
                break;
            case 2004:
                // Stranger prefs
                if (newView == TRUE)
                    [self removeStrangerSharingView:parent.tag];
                else
                    [self cascadeHeightChange:parent.tag incr:-(2*(ROW_HEIGHT)+7)];
                break;
            case 2005:
                // Location prefs
                if (newView == TRUE)
                    [self removeLocSharingPlaceView:parent.tag];
                else
                    [self cascadeHeightChange:parent.tag incr:-(1*(ROW_HEIGHT)+7)];
                break;
  
            default:
                break;
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

// SelectFriends delegate methods
- (void) selectFriendsDone:(CustomSelection) selection {
    NSLog(@"LocationSharing:selectFriendsDone");
    NSLog(@"Selected friends:");
    [smAppDelegate.locSharingPrefs.custom.friends removeAllObjects];
    for (int i=0; i < selection.friends.count; i++) {
        NSString *userId = [selection.friends objectAtIndex:i];
        NSLog(@"id=%@", userId);
        [smAppDelegate.locSharingPrefs.custom.friends addObject:userId];
    }
    NSLog(@"Selected circles:");
    for (int i=0; i < selection.circles.count; i++)
        NSLog(@"id=%@", [selection.circles objectAtIndex:i]);
    
}
- (void) selectFriendsCancelled {
    NSLog(@"LocationSharing:selectFriendsCancelled");
}

// RadioButtonDelegate method
- (void) buttonSelected:(int)indx sender:(id)sender {
    NSLog(@"LocationSharing: buttonSelected index=%d", indx);
    if (indx == 1)
        smAppDelegate.locSharingPrefs.status = [NSString stringWithFormat:@"On"];
    else
        smAppDelegate.locSharingPrefs.status = [NSString stringWithFormat:@"Off"];
    [self setNeedsDisplay];
}

// NewLocationItemDelegate method
- (void) newLocationCreated:(Geofence*)loc sender:(id)sender {
    if (loc != nil) {
        NSLog(@"New location created: name=%@, lat=%@, lng=%@", loc.name, loc.lat, loc.lng);
        loc.radius = @"2";
        [smAppDelegate.locSharingPrefs.geoFences addObject:loc];
        [self cascadeHeightChange:2005 incr:1*(ROW_HEIGHT)+7];
        
        // Refresh the location sharing setting for geofences view
        SettingsMaster *locSetting = (SettingsMaster*) [self viewWithTag:2005];
        LocationSharingPlaces *placeSettings = (LocationSharingPlaces*) [locSetting viewWithTag:3005];
        [placeSettings setNeedsDisplay];
        [placeSettings setBackgroundColor:[UIColor clearColor]];        
    } else
        NSLog(@"Location creation cancelled");
}
@end

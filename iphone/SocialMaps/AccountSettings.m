//
//  AccountSettings.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/7/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "AccountSettings.h"
#import "SettingsMaster.h"
#import "ToggleView.h"
#import "ConfirmView.h"
#import "ResetPassword.h"
#import "PersonalInformation.h"
#import "CounterItem.h"
#import "RadioButtonItem.h"
#import "LocationSharingPref.h"
#import "AppDelegate.h"
#import "UITextField+Scrolling.h"

#define ROW_HEIGHT 62

@implementation AccountSettings
- (AccountSettings*) initWithFrame:(CGRect)scrollFrame {
    self = [super initWithFrame:scrollFrame];
    if (self) {
        self.frame = scrollFrame;
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
    self.backgroundColor = [UIColor colorWithRed:247.0/255.0 
                                                 green:247.0/255.0 
                                                  blue:247.0/255.0 
                                                 alpha:1.0];
    int startTag = 2000;
    int rowNum = 0;
    /*
    //Erase history
    SettingsMaster *eraseView = [[SettingsMaster alloc] initWithFrame:CGRectMake(0, rowNum++*(ROW_HEIGHT+2), self.frame.size.width, ROW_HEIGHT) title:@"Erase history" subTitle:@"Erase all the messages, notifications, etc..." bgImage:@"img_settings_list_bg.png" type:SettingsDisplayTypeExpand sender:self tag:startTag++];
    
    // Delete account
    SettingsMaster *deleteView = [[SettingsMaster alloc] initWithFrame:CGRectMake(0, rowNum++*(ROW_HEIGHT+2), self.frame.size.width, ROW_HEIGHT) title:@"Delete Account..." subTitle:@"" bgImage:@"img_settings_list_bg.png" type:SettingsDisplayTypeExpand sender:self tag:startTag++];
    */
    SettingsMaster *logoutView = [[SettingsMaster alloc] initWithFrame:CGRectMake(0, rowNum++*(ROW_HEIGHT+2), self.frame.size.width, ROW_HEIGHT) title:@"Log out of Socialmaps" subTitle:@"" bgImage:@"img_settings_list_bg.png" type:SettingsDisplayTypeExpand sender:self tag:startTag - 1];
    
    AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([smAppDelegate.fbId isEqualToString:@""]) {
        // Change password
        SettingsMaster *changePWView = [[SettingsMaster alloc] initWithFrame:CGRectMake(0, rowNum++*(ROW_HEIGHT+2), self.frame.size.width, ROW_HEIGHT) title:@"Change password..." subTitle:@"" bgImage:@"img_settings_list_bg.png" type:SettingsDisplayTypeExpand sender:self tag:startTag+2];
        [self addSubview:changePWView];
    }
   
    
    // Personal information
    SettingsMaster *infoView = [[SettingsMaster alloc] initWithFrame:CGRectMake(0, rowNum++*(ROW_HEIGHT+2), self.frame.size.width, ROW_HEIGHT) title:@"Personal information..." subTitle:@"" bgImage:@"img_settings_list_bg.png" type:SettingsDisplayTypeExpand sender:self tag:startTag+3];
    /*
    // Units
    ToggleView *unitView = [[ToggleView alloc] initWithFrame:CGRectMake(0, rowNum++*(ROW_HEIGHT+2), self.frame.size.width, ROW_HEIGHT) title:@"Units..." labels:[NSArray arrayWithObjects:@"Metric",@"Imperial", nil] sender:self tag:startTag++];
    */
    // Setthe scrollable area size
    CGSize contentSize = CGSizeMake(self.frame.size.width, 
                                    (ROW_HEIGHT+2)*rowNum);
    [self setContentSize:contentSize];
                                                                          
    //[self addSubview:eraseView];
    //[self addSubview:deleteView];
    [self addSubview:logoutView];
    
    [self addSubview:infoView];
    //[self addSubview:unitView];
    
    // Add a line at the bottom
    UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x, rowNum*(ROW_HEIGHT+2), self.frame.size.width, 1)];
    sep.backgroundColor = [UIColor lightGrayColor];
    sep.tag = 4000;
    [self addSubview:sep];
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
    
    // Move the line to the bottom of the scroll view
    CGRect newFrame = CGRectMake(self.frame.origin.x, self.contentSize.height, self.frame.size.width, 1);
    UIView *lineView = [self viewWithTag:4000];
    lineView.frame = newFrame;
}

- (void) addPersonalInfoView:(int)tag {
    SettingsMaster *aview = (SettingsMaster*) [self viewWithTag:tag];
    aview.title.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    
    PersonalInformation *info = [[PersonalInformation alloc] initWithFrame:CGRectMake(0, aview.frame.size.height+7, aview.frame.size.width, ROW_HEIGHT-7) sender:self tag:tag+1000];
    
    // Create the line with image line_arrow_down_left.png
    CGRect lineFrame = CGRectMake(0, aview.frame.size.height, 310, 7);
    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:lineFrame];
    lineImage.image = [UIImage imageNamed:@"line_arrow_down_left.png"];
    lineImage.tag   = tag+1001;  
    [aview addSubview:lineImage];
    
    CGRect newFrame = CGRectMake(0, aview.frame.origin.y, aview.frame.size.width, aview.frame.size.height+info.frame.size.height+7);
    aview.frame = newFrame;
    [aview addSubview:info];
    
    CGSize contentSize = CGSizeMake(self.contentSize.width, 
                                    self.contentSize.height+info.frame.size.height+7);
    [self setContentSize:contentSize];
    [self cascadeHeightChange:tag incr:info.frame.size.height+7];
    [self setNeedsLayout];
}

- (void) removePersonalInfoView:(int)tag {
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

- (void) addPasswordResetView:(int)tag {
    SettingsMaster *aview = (SettingsMaster*) [self viewWithTag:tag];
    aview.title.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    
    ResetPassword *resetPw = [[ResetPassword alloc] initWithFrame:CGRectMake(0, aview.frame.size.height+7, aview.frame.size.width, ROW_HEIGHT-7) sender:self tag:tag+1000];
    
     // Create the line with image line_arrow_down_left.png
    CGRect lineFrame = CGRectMake(0, aview.frame.size.height, 310, 7);
    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:lineFrame];
    lineImage.image = [UIImage imageNamed:@"line_arrow_down_left.png"];
    lineImage.tag   = tag+1001;  
    [aview addSubview:lineImage];
    
    CGRect newFrame = CGRectMake(0, aview.frame.origin.y, aview.frame.size.width, aview.frame.size.height+resetPw.frame.size.height+7);
    aview.frame = newFrame;
    [aview addSubview:resetPw];
    
    CGSize contentSize = CGSizeMake(self.contentSize.width, 
                                    self.contentSize.height+resetPw.frame.size.height+7);
    [self setContentSize:contentSize];
    [self cascadeHeightChange:tag incr:resetPw.frame.size.height+7];
    [self setNeedsLayout];
}

- (void) removeResetPwView:(int)tag {
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

- (void) addConfirmView:(int)tag msg:(NSString*)msg incr:(int)incr{
    SettingsMaster *aview = (SettingsMaster*) [self viewWithTag:tag];
    aview.title.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];

    ConfirmView *confirm = [[ConfirmView alloc] initWithFrame:CGRectMake(0, aview.frame.size.height+7, aview.frame.size.width, ROW_HEIGHT-7) title:msg sender:self tag:tag+1000];
    [aview addSubview:confirm];
    
    // Create the line with image line_arrow_down_left.png
    CGRect lineFrame = CGRectMake(0, aview.frame.size.height, 310, 7);
    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:lineFrame];
    lineImage.image = [UIImage imageNamed:@"line_arrow_down_left.png"];
    lineImage.tag   = tag+1001;  
    [aview addSubview:lineImage];

    CGRect newFrame = CGRectMake(0, aview.frame.origin.y, aview.frame.size.width, aview.frame.size.height+ROW_HEIGHT);
    aview.frame = newFrame;

    CGSize contentSize = CGSizeMake(self.contentSize.width, 
                                    self.contentSize.height+incr);
    [self setContentSize:contentSize];
    [self cascadeHeightChange:tag incr:incr];
    [self setNeedsLayout];
 
}
- (void) removeConfirmView:(int)tag incr:(int)dec{
    SettingsMaster *aview = (SettingsMaster*) [self viewWithTag:tag];
    aview.title.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    
    UIView *child = (UIView*) [aview viewWithTag:tag+1000];
    [child removeFromSuperview];
    child = (UIView*) [aview viewWithTag:tag+1001];
    [child removeFromSuperview];

    
    CGRect newFrame = CGRectMake(0, aview.frame.origin.y, aview.frame.size.width, aview.frame.size.height-ROW_HEIGHT);
    aview.frame = newFrame;
    CGSize contentSize = CGSizeMake(self.contentSize.width, self.contentSize.height-dec);
    [self setContentSize:contentSize];
    [self cascadeHeightChange:tag incr:-dec];
    [self setNeedsLayout];
}

- (void) addLocSharingView:(int)tag {
    SettingsMaster *aview = (SettingsMaster*) [self viewWithTag:tag];
    aview.title.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    
    LocationSharingPref *locSharing = [[LocationSharingPref alloc] initWithFrame:CGRectMake(0, aview.frame.size.height+7, aview.frame.size.width, ROW_HEIGHT-7) prefs:LocationSharingPrefTypeTime|LocationSharingPrefTypeRadius|LocationSharingPrefTypePermission defRadius:2 defDuration:60 defPerm:TRUE sender:self tag:tag+1000 level:1];
    
    // Create the line with image line_arrow_down_left.png
    CGRect lineFrame = CGRectMake(0, aview.frame.size.height, 310, 7);
    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:lineFrame];
    lineImage.image = [UIImage imageNamed:@"line_arrow_down_left.png"];
    lineImage.tag   = tag+1001;  
    [aview addSubview:lineImage];
    
    CGRect newFrame = CGRectMake(0, aview.frame.origin.y, aview.frame.size.width, aview.frame.size.height+locSharing.frame.size.height+7);
    aview.frame = newFrame;
    locSharing.backgroundColor = [UIColor clearColor];
    [aview addSubview:locSharing];
    
    CGSize contentSize = CGSizeMake(self.contentSize.width, 
                                    self.contentSize.height+locSharing.frame.size.height+7);
    [self setContentSize:contentSize];
    [self cascadeHeightChange:tag incr:locSharing.frame.size.height+7];
    [self setNeedsLayout];
}

- (void) removeLocSharingView:(int)tag {
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
    NSLog(@"AccountSettings accSettingButtonClicked: tag=%d", parent.tag);
    if (parent.tag >= 1999 && parent.tag <= 2004) {
        [btn removeTarget:self action:@selector(accSettingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:self action:@selector(accSettingResetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        switch (parent.tag) {
            case 1999:
                // Logout
                [self addConfirmView:parent.tag msg:[NSString stringWithFormat:@"Log out %@?", smAppDelegate.userAccountPrefs.firstName] incr:ROW_HEIGHT];
                break;
            case 2000:
                // Erase data
                [self addConfirmView:parent.tag msg:@"Confirm erase history?" incr:ROW_HEIGHT];
                break;
            case 2001:
                // Delete account
                [self addConfirmView:parent.tag msg:@"Confirm delete account?" incr:ROW_HEIGHT];
                break;
            case 2002:
                // Change password
                [self addPasswordResetView:parent.tag];
                break;
            case 2003:
                // Personal information
                [self addPersonalInfoView:parent.tag];
                 break;
            case 2004:
                // Personal information
                [self addLocSharingView:parent.tag];
                break;
            default:
                break;
        }
    }
}

- (void) accSettingResetButtonClicked:(id) sender {
    UIButton *btn = (UIButton*) sender;
    
    [btn setImage:[UIImage imageNamed:@"icon_arrow_down.png"] forState:UIControlStateNormal];

    SettingsMaster *parent = (SettingsMaster*)[btn superview];
    NSLog(@"accSettingResetButtonClicked: tag=%d", parent.tag);
    if (parent.tag >= 1999 && parent.tag <= 2004) {
        [btn removeTarget:self action:@selector(accSettingResetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:self action:@selector(accSettingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        switch (parent.tag) {
            case 1999:
                // Logout
                [self removeConfirmView:parent.tag incr:ROW_HEIGHT];
                break;
            case 2000:
                // Erase data
                [self removeConfirmView:parent.tag incr:ROW_HEIGHT];
                break;
            case 2001:
                // Delete account
                [self removeConfirmView:parent.tag incr:ROW_HEIGHT];
                break;
            case 2002:
                // Change password
                [self removeResetPwView:parent.tag];
                break;
            case 2003:
                // Personal information
                [self removePersonalInfoView:parent.tag];
                break;
            case 2004:
                // Personal information
                [self removeLocSharingView:parent.tag];
                break;    
            default:
                break;
        }
    }
}

- (void) noButtonClicked:(id)sender {
    NSLog(@"ConfirmView:noButtonClicked");
    SettingsMaster *parent = (SettingsMaster*)[[sender superview] superview];
    [self accSettingResetButtonClicked:parent.btn];
}

- (void) yesButtonClicked:(id)sender {
    NSLog(@"ConfirmView:yesButtonClicked");
    
    SettingsMaster *parent = (SettingsMaster*)((UIButton*)sender).superview.superview;
    AppDelegate *smAppDelegate;
    
    switch (parent.tag) {
        case 1999:
            // Logout
            smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [[smAppDelegate.window rootViewController] dismissModalViewControllerAnimated:NO];
            break;
        case 2000:
            // Erase data
            break;
        case 2001:
            // Delete account
            break;
        case 2002:
            // Change password
            break;
        case 2003:
            // Personal information
            break;
        case 2004:
            // Personal information
            break;    
        default:
            break;
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
    [textField animateTextField: textField up: YES];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField animateTextField: textField up: NO];
    // Store the userid and password
}

@end

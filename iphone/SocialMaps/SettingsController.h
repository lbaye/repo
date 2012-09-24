//
//  SettingsController.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/6/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCheckbox.h"
#import "AppDelegate.h"

@interface SettingsController : UIViewController<CustomCheckboxDelegate> {
    //NSMutableArray *defPlatforms;
    AppDelegate     *smAppDelegate;
    IBOutlet UILabel *totalNotifCount;
}
//@property (nonatomic, retain) NSMutableArray *defPlatforms;
@property (nonatomic, retain) AppDelegate *smAppDelegate;

@property (retain, nonatomic) IBOutlet UIScrollView *settingsScrollView;
@property (retain, nonatomic) IBOutlet UIView *platformView;
@property (retain, nonatomic) IBOutlet UIView *layersView;
@property (retain, nonatomic) IBOutlet UIView *settingsHeader;
@property (retain, nonatomic) IBOutlet UILabel *notifCount;
@property (retain, nonatomic) IBOutlet UIView *settingsMainHeader;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property(nonatomic,retain) IBOutlet UILabel *totalNotifCount;

- (IBAction)expandPlatformSettings:(id)sender;
- (IBAction)expandLayersSettings:(id)sender;
- (IBAction)setInfoSharing:(id)sender;
- (IBAction)setAccountSettings:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)setLocationSharing:(id)sender;
- (IBAction)setNotifSettings:(id)sender;
-(IBAction)gotoNotification:(id)sender;

@end

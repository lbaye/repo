//
//  SettingsController.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/6/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file SettingsController.h
 * @brief Display user defined settings through this view controller.
 */

#import <UIKit/UIKit.h>
#import "CustomCheckbox.h"
#import "AppDelegate.h"

@interface SettingsController : UIViewController<CustomCheckboxDelegate> {
    AppDelegate     *smAppDelegate;
    IBOutlet UILabel *totalNotifCount;
}
@property (nonatomic, retain) AppDelegate *smAppDelegate;
@property (retain, nonatomic) IBOutlet UIScrollView *settingsScrollView;
@property (retain, nonatomic) IBOutlet UIView *platformView;
@property (retain, nonatomic) IBOutlet UIView *layersView;
@property (retain, nonatomic) IBOutlet UIView *settingsHeader;
@property (retain, nonatomic) IBOutlet UILabel *notifCount;
@property (retain, nonatomic) IBOutlet UIView *settingsMainHeader;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property(nonatomic,retain) IBOutlet UILabel *totalNotifCount;

/**
 * @brief Expands platform preference settings
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)expandPlatformSettings:(id)sender;

/**
 * @brief Expands layer preference settings
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)expandLayersSettings:(id)sender;

/**
 * @brief Make visible information sharing option
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)setInfoSharing:(id)sender;

/**
 * @brief Make visible account setting options
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)setAccountSettings:(id)sender;

/**
 * @brief Navigate user to previous screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)goBack:(id)sender;

/**
 * @brief Make visible location sharing options
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)setLocationSharing:(id)sender;

/**
 * @brief Make visible notification options (not implemented yet)
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)setNotifSettings:(id)sender;

/**
 * @brief Navigate user to notification screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoNotification:(id)sender;

@end

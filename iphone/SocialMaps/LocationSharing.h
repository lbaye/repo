//
//  LocationSharing.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/11/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file LocationSharing.h
 * @brief Display location sharing view through this view controller.
 */

#import <UIKit/UIKit.h>
#import "SelectFriends.h"
#import "RadioButton.h"
#import "NewLocationItem.h"
#import "AppDelegate.h"
#import "CustomCounter.h"
#import "CustomSaveView.h"

@interface LocationSharing : UIScrollView<SelectFriendsDelegate, RadioButtonDelegate, NewLocationItemDelegate,
                                        CustomCounterDelegate, CustomSaveButtonDelegate> {
    int     rowNum;
    AppDelegate *smAppDelegate;
    
}

@property (nonatomic) int rowNum;
@property (nonatomic, retain) AppDelegate *smAppDelegate;
@property (nonatomic, retain) NSString *locSharingStatus;

/**
 * @brief Initialize scroll view with position and size
 * @param (CGRect) - Position and size of scroll view
 * @retval (UIScrollView) - Created scroll view
 */
- (UIScrollView*) initWithFrame:(CGRect)scrollFrame;

/**
 * @brief Performed when account setting button clicked
 * @param (id) - Action sender
 * @retval none
 */
- (void) accSettingButtonClicked:(id) sender;

/**
 * @brief Performed when account settings reset button clicked
 * @param (id) - Action sender
 * @retval none
 */
- (void) accSettingResetButtonClicked:(id) sender;

/**
 * @brief Animate text field if keyboard hides textfield
 * @param (UITextField) - Textfield in which user types
 * @param (BOOL) - Anitamtion direction, upside or downsides
 * @retval none
 */
- (void) animateTextField: (UITextField*) textField up: (BOOL) up;

/**
 * @brief Create new location with geofence
 * @param (Geofence) - Geofence location
 * @param (id) - Action sender
 * @retval none
 */
- (void) newLocationCreated:(Geofence*)loc sender:(id)sender;

/**
 * @brief Change counter value for location sharing radias and duration for privacy and strangers
 * @param (int) - Radius or duration value 
 * @param (id) - Action sender
 * @retval action
 */
- (void) counterValueChanged:(int)newVal sender:(id)sender;
@end

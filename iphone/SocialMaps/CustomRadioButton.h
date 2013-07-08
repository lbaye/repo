//
//  CustomRadioButton.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/6/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file CustomRadioButton.h
 * @brief Set the view for custom radio button group with the clicked at index delegate.
 */

#import <UIKit/UIKit.h>

@protocol CustomRadioButtonDelegate <NSObject>

/**
 * @brief Delegate method when clicked on a radio button or slide did finish
 * @param (int) - Number of button which was selected
 * @param (id) - Action sender
 * @retval none
 */
- (void) radioButtonClicked:(int)indx sender:(id)sender;

@end

@interface CustomRadioButton : UIView {
    int     numRadio;
    int     selIndex;
    NSArray *labels;
    id<CustomRadioButtonDelegate> delegate;
    UIImageView *imageViewDrag;
    CGRect endDragRect;
    CGRect startDragRect;
    UIColor *textColor;
}
@property (nonatomic) int numRadio;
@property (nonatomic) int selIndex;
@property (nonatomic, retain) NSArray *labels;
@property (nonatomic, retain) id<CustomRadioButtonDelegate> delegate;

/**
 * @brief Initialize radio button group
 * @param (CGRect) - Frame size of the group
 * @param (int) - Total number of buttons
 * @param (NSArray) - Array of all label text sequentially
 * @param (int) - Default number of button which will be selected when initialize
 * @param (id) - Action sender
 * @param (ing) - Tag number of the view
 * @retval (id) - action
 */
- (id)initWithFrame:(CGRect)frame numButtons:(int)numButtons labels:(NSArray*)lbl default:(int)def sender:(id)sender tag:(int)tag;

/**
 * @brief Select one button from the group after the initialization
 * @param (int) - Number of button which will be selected
 * @retval none
 */
- (void) gotoButton:(int)buttonNumber;

/**
 * @brief Set text color or radio buttons 
 * @param (UIColor) - Color of the text
 * @retval none
 */
- (id)initWithFrame:(CGRect)frame numButtons:(int)numButtons labels:(NSArray*)lbl default:(int)def sender:(id)sender tag:(int)tag color:(UIColor*)color;

@end

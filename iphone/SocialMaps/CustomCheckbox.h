//
//  CustomCheckbox.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/6/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _BOX_LOCATION {
    LabelPositionLeft = 0,
    LabelPositionRight
} BOX_LOCATION;

@protocol CustomCheckboxDelegate <NSObject>

/**
 * @brief Navigate user to previous screen
 * @param (int) - Action sender
 * @param (int) - Set button state 
 * @param (id) - Action sender
 * @retval none
 */
- (void) checkboxClicked:(int)indx withState:(int)clicked sender:(id)sender;

@end

@interface CustomCheckbox : UIView {
    int         numBoxes;
    NSArray     *labels;
    NSMutableArray *checkboxState;
    id<CustomCheckboxDelegate> delegate;
    BOX_LOCATION   type;
}
@property (nonatomic) int numBoxes;
@property (nonatomic, retain) NSArray *labels;
@property (nonatomic, retain) NSMutableArray * checkboxState;
@property (nonatomic, retain) id<CustomCheckboxDelegate> delegate;
@property (nonatomic) BOX_LOCATION type;

/**
 * @brief Initialize custom checkbox
 * @param (CGRect) - Action sender
 * @param (BOX_LOCATION) - Action sender
 * @param (int) - Action sender
 * @param (NSArray) - Action sender
 * @param (NSArray) - Action sender 
 * @retval (id) - returns the checkbox group
 */
- (id)initWithFrame:(CGRect)frame boxLocType:(BOX_LOCATION)locType numBoxes:(int)num default:(NSArray*)def labels:(NSArray*) lbls;

/**
 * @brief Set state of a checkbox iten
 * @param (int) - Set button state
 * @param (int) - Button number
 * @retval none
 */
- (void) setState:(int)state btnNum:(int)num;
@end

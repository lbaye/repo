//
//  CustomSaveView.h
//  SocialMaps
//
//  Created by Warif Rishi on 1/29/13.
//  Copyright (c) 2013 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomSaveButtonDelegate <NSObject>

/**
 * @brief Delegate method when clicked on a save button
 * @param (id) - Action sender
 * @retval none
 */
- (void) customSaveButtonClicked:(id)sender;

@end

@interface CustomSaveView : UIView

@property (nonatomic, retain) id<CustomSaveButtonDelegate> delegate;

@end

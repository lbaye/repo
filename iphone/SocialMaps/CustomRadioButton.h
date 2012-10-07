//
//  CustomRadioButton.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/6/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomRadioButtonDelegate <NSObject>

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
}
@property (nonatomic) int numRadio;
@property (nonatomic) int selIndex;
@property (nonatomic, retain) NSArray *labels;
@property (nonatomic, retain) id<CustomRadioButtonDelegate> delegate;

- (id)initWithFrame:(CGRect)frame numButtons:(int)numButtons labels:(NSArray*)lbl default:(int)def sender:(id)sender tag:(int)tag;
@end

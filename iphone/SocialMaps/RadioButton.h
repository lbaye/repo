//
//  RadioButton.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/10/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RadioButtonDelegate <NSObject>

- (void) buttonSelected:(int)indx sender:(id)sender;

@end

@interface RadioButton : UIView {
    int     selIndex;
    NSArray *labels;
    id<RadioButtonDelegate> delegate;
}

@property (nonatomic) int selIndex;
@property (nonatomic, retain) NSArray *labels;
@property (nonatomic, retain) id<RadioButtonDelegate> delegate;

- (id)initWithFrame:(CGRect)frame labels:(NSArray*)lbl default:(int)def sender:(id)sender tag:(int)tag;

@end

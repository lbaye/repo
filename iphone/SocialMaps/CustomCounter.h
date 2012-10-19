//
//  CounterView.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/10/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomCounterDelegate <NSObject>

- (void) counterValueChanged:(int)indx sender:(id)sender;

@end

@interface CustomCounter : UIView <UITextFieldDelegate> {
    bool        allowNegative;
    int         currVal;
    UITextField     *countDisp;
    id<CustomCounterDelegate> delegate;
    id          parent;
    int         movementDistance;
}
@property (nonatomic) bool allowNegative;
@property (nonatomic) int currVal;
@property (nonatomic, retain) UITextField *countDisp;
@property (nonatomic, retain) id<CustomCounterDelegate> delegate;
@property (nonatomic, retain) id parent;
@property (nonatomic) int movementDistance;

- (void) notifyDelegate:(id)sender;
- (id)initWithFrame:(CGRect)frame allowNeg:(bool)neg default:(int)def sender:(id)sender tag:(int)tag;

@end

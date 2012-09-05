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

@interface CustomCounter : UIView {
    bool        allowNegative;
    int         currVal;
    UILabel     *countDisp;
    id<CustomCounterDelegate> delegate;
}
@property (nonatomic) bool allowNegative;
@property (nonatomic) int currVal;
@property (nonatomic, retain) UILabel *countDisp;
@property (nonatomic, retain) id<CustomCounterDelegate> delegate;

- (void) notifyDelegate:(id)sender;
- (id)initWithFrame:(CGRect)frame allowNeg:(bool)neg default:(int)def sender:(id)sender tag:(int)tag;
@end

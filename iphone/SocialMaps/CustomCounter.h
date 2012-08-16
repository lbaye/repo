//
//  CounterView.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/10/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCounter : UIView {
    bool        allowNegative;
    int         currVal;
    UILabel     *countDisp;
}
@property (nonatomic) bool allowNegative;
@property (nonatomic) int currVal;
@property (nonatomic, retain) UILabel *countDisp;

- (id)initWithFrame:(CGRect)frame allowNeg:(bool)neg default:(int)def sender:(id)sender tag:(int)tag;
@end

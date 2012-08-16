//
//  CustomRadioButton.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/6/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomRadioButton : UIView {
    int     numRadio;
    int     selIndex;
    NSArray *labels;
}
@property (nonatomic) int numRadio;
@property (nonatomic) int selIndex;
@property (nonatomic, retain) NSArray *labels;

- (id)initWithFrame:(CGRect)frame numButtons:(int)numButtons labels:(NSArray*)lbl default:(int)def sender:(id)sender tag:(int)tag;
@end

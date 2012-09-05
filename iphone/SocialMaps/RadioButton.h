//
//  RadioButton.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/10/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RadioButton : UIView {
    int     selIndex;
    NSArray *labels;
//    int      def;
}

@property (nonatomic) int selIndex;
@property (nonatomic, retain) NSArray *labels;
//@property (nonatomic) int def;

- (id)initWithFrame:(CGRect)frame labels:(NSArray*)lbl default:(int)def sender:(id)sender tag:(int)tag;

@end

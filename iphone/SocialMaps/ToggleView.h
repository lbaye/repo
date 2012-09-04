//
//  ToggleView.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/8/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomRadioButton.h"

@interface ToggleView : UIView {
    NSString       *titleString;
    UILabel        *title;
    CustomRadioButton       *toggleBtn;
    int            btnTag;
    id              parent;
    NSMutableArray  *labelStrings;
}
@property (nonatomic, retain) NSString *titleString;
@property (nonatomic, retain) UILabel *title;
@property (nonatomic, retain) CustomRadioButton *toggleBtn;
@property (nonatomic) int btnTag;
@property (nonatomic, retain) id parent;
@property (nonatomic, retain) NSMutableArray *labelStrings;

- (id)initWithFrame:(CGRect)frame title:(NSString*)titleStr labels:(NSArray*)labels sender:(id) sender tag:(int)tag;
@end

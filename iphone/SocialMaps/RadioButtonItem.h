//
//  RadioButtonItem.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/10/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RadioButtonItem : UIView {
    NSString       *subtitleString;
    NSString       *titleString;
    UILabel        *title;
    UILabel        *subTitle;
    int            btnTag;
    id              parent;
    NSArray         *labels;
    int             selectedBtn;
}
@property (nonatomic, retain) NSString *titleString;
@property (nonatomic, retain) NSString *subtitleString;
@property (nonatomic, retain) UILabel *title;
@property (nonatomic, retain) UILabel *subTitle;
@property (nonatomic) int btnTag;
@property (nonatomic, retain) id parent;
@property (nonatomic, retain) NSArray *labels;
@property (nonatomic) int selectedBtn;


- (id)initWithFrame:(CGRect)frame title:(NSString*)titleStr subTitle:(NSString*)subTitleStr labels:(NSArray*)lbls defBtn:(int)def sender:(id) sender tag:(int)tag;



@end

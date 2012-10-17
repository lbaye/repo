//
//  LocationSharingPref.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/10/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CounterItem : UIView {
    NSString       *subtitleString;
    NSString       *titleString;
    UILabel        *title;
    UILabel        *subTitle;
    int            btnTag;
    int             defVal;
    id              parent;
}
@property (nonatomic, retain) NSString *titleString;
@property (nonatomic, retain) NSString *subtitleString;
@property (nonatomic, retain) UILabel *title;
@property (nonatomic, retain) UILabel *subTitle;
@property (nonatomic) int btnTag;
@property (nonatomic) int defVal;
@property (nonatomic, retain) id parent;

- (id)initWithFrame:(CGRect)frame title:(NSString*)titleStr subTitle:(NSString*)subTitleStr defVal:(int) def sender:(id) sender tag:(int)tag;

@end

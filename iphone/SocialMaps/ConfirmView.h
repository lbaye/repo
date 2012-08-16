//
//  ConfirmView.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/8/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfirmView : UIView {
    NSString       *titleString;
    UILabel        *title;
    UIButton       *noButton;
    UIButton       *yesButton;
    int            btnTag;
    id              parent;
}
@property (nonatomic, retain) NSString *titleString;
@property (nonatomic, retain) UILabel *title;
@property (nonatomic, retain) UIButton *noButton;
@property (nonatomic, retain) UIButton *yesButton;
@property (nonatomic) int btnTag;
@property (nonatomic, retain) id parent;

- (id)initWithFrame:(CGRect)frame title:(NSString*)titleStr sender:(id) sender tag:(int)tag;


@end

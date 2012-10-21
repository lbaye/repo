//
//  SettingsMaster.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/8/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _SETTINGS_DISPLAY_TYPE {
    SettingsDisplayTypeExpand = 0,
    SettingsDisplayTypeDetail
} SETTINGS_DISPLAY_TYPE;

typedef enum _SETTINGS_DISPLAY_STATE {
    SettingsDisplayStateOpen = 0,
    SettingsDisplayStateClosed
} SETTINGS_DISPLAY_STATE;


@interface SettingsMaster : UIView {
    NSString       *subtitleString;
    NSString       *titleString;
    UILabel        *title;
    UILabel        *subTitle;
    UIButton       *btn;
    int            btnTag;
    id              parent;
    NSString        *bgImageName;
    int             settingsType;
}
@property (nonatomic, retain) NSString *titleString;
@property (nonatomic, retain) NSString *subtitleString;
@property (nonatomic, retain) UILabel *title;
@property (nonatomic, retain) UILabel *subTitle;
@property (nonatomic, retain) UIButton *btn;
@property (nonatomic) int btnTag;
@property (nonatomic, retain) id parent;
@property (nonatomic, retain) NSString *bgImageName;
@property (nonatomic) int settingsType;

- (id)initWithFrame:(CGRect)frame title:(NSString*)titleStr subTitle:(NSString*)subTitleStr bgImage:(NSString*)bgImageName type:(int) dispType sender:(id) sender tag:(int)tag;
- (void) setState:(SETTINGS_DISPLAY_STATE)state;
@end

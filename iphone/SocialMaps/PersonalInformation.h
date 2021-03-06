//
//  PersonalInformation.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/8/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file PersonalInformation.h
 * @brief Display user's personal information through this view controller.
 */

#import <UIKit/UIKit.h>
#import "PhotoPicker.h"
#import "AppDelegate.h"

@interface PersonalInformation : UIView <PhotoPickerDelegate,UIPickerViewDataSource, 
UIPickerViewDelegate> {
    UITextField  *email;
    UITextField  *password;
    UITextField     *gender;
    UIButton        *genderBtn;
    UITextField  *firstName;
    UITextField  *lastName;
    UITextField  *userName;
    UITextField  *dobText;
    UIButton     *dateOfBirth;
    UITextField   *bio;
    UITextField  *streetAddress;
    UITextField  *city;
    UITextField  *zipCode;
    UITextField  *country;
    UITextField  *service;
    UITextField     *relationshipStatus;
    UIButton    *submitBtn;
    UIButton    *picBtn;
    id          parent;
    UIPickerView    *selGender;
    PhotoPicker *photoPicker;
    UIActionSheet *userOption;
    UIImagePickerController *picSel;
    UIView *calView;
    UIDatePicker    *datePickerView;
    UIPickerView *selMaleFemale;
    NSMutableArray         *arrayGender;
    AppDelegate     *smAppDelegate;
    bool            avatarChanged;
}
@property (nonatomic, retain) UITextField  *email;
@property (nonatomic, retain)UITextField  *password;
@property (nonatomic, retain)UITextField     *gender;
@property (nonatomic, retain) UIButton      *genderBtn;
@property (nonatomic, retain)UITextField  *firstName;
@property (nonatomic, retain)UITextField  *lastName;
@property (nonatomic, retain)UITextField  *userName;
@property (nonatomic, retain)UIButton     *dateOfBirth;
@property (nonatomic, retain)UITextField  *dobText;
@property (nonatomic, retain)UITextField   *bio;
@property (nonatomic, retain)UITextField  *streetAddress;
@property (nonatomic, retain)UITextField  *city;
@property (nonatomic, retain)UITextField  *zipCode;
@property (nonatomic, retain)UITextField  *country;
@property (nonatomic, retain)UITextField  *service;
@property (nonatomic, retain)UITextField     *relationshipStatus;
@property (nonatomic, retain)UIButton    *submitBtn;
@property (nonatomic, retain)UIButton    *picBtn;
@property (nonatomic, retain)id          parent;
@property (nonatomic, retain) UIPickerView *selGender;
@property (nonatomic, retain) PhotoPicker *photoPicker;
@property (nonatomic, retain) UIActionSheet *userOption;
@property (nonatomic, retain) UIImagePickerController *picSel;
@property (nonatomic, retain) UIView *calView;
@property (nonatomic, retain) UIDatePicker    *datePickerView;
@property (nonatomic, retain) UIPickerView    *selMaleFemale;
@property (nonatomic, retain) NSMutableArray       *arrayGender;
@property (nonatomic, retain) AppDelegate           *smAppDelegate;
@property (nonatomic) bool avatarChanged;

- (id)initWithFrame:(CGRect)frame sender:(id) sender tag:(int)tag;
- (void) photoPickerDone:(bool)status image:(UIImage*)img;
- (void)createDatePicker;
- (void) cancelDate:(id)sender;

@end

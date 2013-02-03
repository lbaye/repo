//
//  RegistrationController.h
//  SocialMaps
//
//  Created by Arif Shakoor on 7/23/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file RegistrationController.h
 * @brief User can register with user name, password and other information through this view controller.
 */

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"
#import "User.h"
#import "PhotoPicker.h"

@interface RegistrationController : UIViewController<UIPickerViewDataSource, 
UIPickerViewDelegate,
UITextFieldDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,
PhotoPickerDelegate> {
    NSMutableArray *arrayGender;
    User           *userInfo;
    UIImagePickerController *picSel;
    UIImage         *regPhoto;
    PhotoPicker *photoPicker;
    IBOutlet UIView *basicInfoView;
    IBOutlet UIView *moreInfoView;
    IBOutlet UITextField *dateOfBirthTxtField;
    IBOutlet UITextField *biographyTxtField;
    IBOutlet UITextField *interestsTxtField;
    IBOutlet UITextField *streetAdressTxtField;
    IBOutlet UITextField *cityTxtField;
    IBOutlet UITextField *zipCodeTxtField;
    IBOutlet UITextField *countryTxtField;
    IBOutlet UITextField *serviceTxtField;
    IBOutlet UITextField *relatioshipStatusTxtField;
    IBOutlet UIScrollView *registrationScrollView;
    IBOutlet UITextField *userNameTextField;
}

@property (retain, nonatomic) NSMutableArray *arrayGender;
@property (retain, nonatomic) User *userInfo;
@property (nonatomic, retain) UIImagePickerController *picSel;
@property (nonatomic, retain) UIImage *regPhoto;
@property (nonatomic, retain) PhotoPicker *photoPicker;
@property (nonatomic,retain)  IBOutlet IBOutlet UIView *basicInfoView;
@property (nonatomic,retain)  IBOutlet UIView *moreInfoView;
@property (retain, nonatomic) IBOutlet UIPickerView *selMaleFemale;
@property (retain, nonatomic) IBOutlet UITextField *regGender;
@property (retain, nonatomic) IBOutlet UITextField *regEmail;
@property (retain, nonatomic) IBOutlet UITextField *regPassword;
@property (retain, nonatomic) IBOutlet UITextField *regName;
@property (retain, nonatomic) IBOutlet UITextField *regFirstName;
@property (retain, nonatomic) IBOutlet UIButton *picSelButton;
@property(nonatomic,retain) IBOutlet UITextField *dateOfBirthTxtField;
@property(nonatomic,retain) IBOutlet UITextField *biographyTxtField;
@property(nonatomic,retain) IBOutlet UITextField *interestsTxtField;
@property(nonatomic,retain) IBOutlet UITextField *streetAdressTxtField;
@property(nonatomic,retain) IBOutlet UITextField *cityTxtField;
@property(nonatomic,retain) IBOutlet UITextField *zipCodeTxtField;
@property(nonatomic,retain) IBOutlet UITextField *countryTxtField;
@property(nonatomic,retain) IBOutlet UITextField *serviceTxtField;
@property(nonatomic,retain) IBOutlet UITextField *relatioshipStatusTxtField;
@property(nonatomic,retain) IBOutlet UIScrollView *registrationScrollView;
@property(nonatomic,retain) IBOutlet UITextField *userNameTextField;

/**
 * @brief Gender selection of an user
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)selectGender:(id)sender;

/**
 * @brief Animate textfield while editing if that is hides by keyboard
 * @param (UITextField) - Action sender
 * @param (BOOL) - Action sender
 * @retval action
 */
- (void) animateTextField: (UITextField*) textField up: (BOOL) up;

/**
 * @brief Hides the keyboard
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)hideKeyboard:(id)sender;

/**
 * @brief Select image for registration
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)selPicOption:(id)sender;

/**
 * @brief Date of  birth selection of an user
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)selectDateOfBirthAction:(id)sender;

/**
 * @brief Country selection of an user
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)selectCountryAction:(id)sender;

/**
 * @brief Select relationship satus of an user
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)selectRelStatus:(id)sender;

/**
 * @brief Creates a new accout for user
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)createAccount:(id)sender;

@end

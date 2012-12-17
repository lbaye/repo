//
//  RegistrationController.h
//  SocialMaps
//
//  Created by Arif Shakoor on 7/23/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

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
}

@property (retain, nonatomic) NSMutableArray *arrayGender;
@property (retain, nonatomic) User *userInfo;
@property (nonatomic, retain) UIImagePickerController *picSel;
@property (nonatomic, retain) UIImage *regPhoto;
@property (nonatomic, retain) PhotoPicker *photoPicker;
@property (nonatomic,retain)  IBOutlet IBOutlet UIView *basicInfoView;
@property (nonatomic,retain)  IBOutlet UIView *moreInfoView;

- (void) animateTextField: (UITextField*) textField up: (BOOL) up;
@property (retain, nonatomic) IBOutlet UIPickerView *selMaleFemale;
- (IBAction)selectGender:(id)sender;
@property (retain, nonatomic) IBOutlet UITextField *regGender;
- (IBAction)createAccount:(id)sender;
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

- (IBAction)hideKeyboard:(id)sender;
- (IBAction)selPicOption:(id)sender;
- (IBAction)selectDateOfBirthAction:(id)sender;
- (IBAction)selectCountryAction:(id)sender;
- (IBAction)selectRelStatus:(id)sender;

@end

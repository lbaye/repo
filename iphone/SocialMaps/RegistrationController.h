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
}

@property (retain, nonatomic) NSMutableArray *arrayGender;
@property (retain, nonatomic) User *userInfo;
@property (nonatomic, retain) UIImagePickerController *picSel;
@property (nonatomic, retain) UIImage *regPhoto;
@property (nonatomic, retain) PhotoPicker *photoPicker;

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

- (IBAction)hideKeyboard:(id)sender;
- (IBAction)selPicOption:(id)sender;
@end

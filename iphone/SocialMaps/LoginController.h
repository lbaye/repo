//
//  LoginController.h
//  SocialMaps
//
//  Created by Arif Shakoor on 7/22/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "Constants.h"
#import "UserInfo.h"

@class AppDelegate;

@interface LoginController : UIViewController <UITextFieldDelegate> {
    NSString *strUserID;
    NSString *strPassword;
    bool autoLogin;
    Facebook *facebook;
    AppDelegate *smAppDelegate;
    IBOutlet UIImageView *profileImageView;
}

@property (retain, nonatomic) NSString *strUserID;
@property (retain, nonatomic) NSString *strPassword;
@property (nonatomic) bool autoLogin;
@property (retain, nonatomic) Facebook *facebook;
@property (nonatomic, retain) AppDelegate *smAppDelegate;

- (void) animateTextField: (UITextField*) textField up: (BOOL) up;

@property (retain, nonatomic) IBOutlet UITextField *txtEmail;
@property (retain, nonatomic) IBOutlet UITextField *txtPassword;
@property (retain, nonatomic) IBOutlet UIButton *rememberMeSel;
@property (retain, nonatomic) IBOutlet UIButton *forgotPassword;
@property (retain, nonatomic) IBOutlet UIView *forgotPWView;
@property (retain, nonatomic) IBOutlet UITextField *txtForgotPWEmail;
@property (retain, nonatomic) IBOutlet UIView *dialogView;
@property (nonatomic,retain) IBOutlet UIImageView *profileImageView;

- (IBAction)doLogin:(id)sender;
- (IBAction)doConnectFB:(id)sender;
- (IBAction)doForgotPassword:(id)sender;
- (IBAction)doRememberMe:(id)sender;
- (IBAction)removeKeyboard:(id)sender;
- (IBAction)cancelReset:(id)sender;
- (IBAction)sendReset:(id)sender;

@end

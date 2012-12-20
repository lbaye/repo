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
    IBOutlet UIImageView *bgImgView;
    IBOutlet UIView *tapview;
}

@property (retain, nonatomic) NSString *strUserID;
@property (retain, nonatomic) NSString *strPassword;
@property (nonatomic) bool autoLogin;
@property (retain, nonatomic) Facebook *facebook;
@property (nonatomic, retain) AppDelegate *smAppDelegate;
@property (nonatomic, retain) IBOutlet UIView *tapview;

- (void) animateTextField: (UITextField*) textField up: (BOOL) up;

@property (retain, nonatomic) IBOutlet UITextField *txtEmail;
@property (retain, nonatomic) IBOutlet UITextField *txtPassword;
@property (retain, nonatomic) IBOutlet UIButton *rememberMeSel;
@property (retain, nonatomic) IBOutlet UIButton *forgotPassword;
@property (retain, nonatomic) IBOutlet UIView *forgotPWView;
@property (retain, nonatomic) IBOutlet UITextField *txtForgotPWEmail;
@property (retain, nonatomic) IBOutlet UIView *dialogView;
@property (nonatomic,retain) IBOutlet UIImageView *profileImageView;
@property (nonatomic,retain) IBOutlet UIImageView *bgImgView;

/**
 * @brief Log in an user through email address and password if successfull navigate to map view
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)doLogin:(id)sender;

/**
 * @brief Log in an user through facebook ID, if successfull navigate to map view
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)doConnectFB:(id)sender;

/**
 * @brief If user forgot the password, request password to server
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)doForgotPassword:(id)sender;

/**
 * @brief Remember the user name and password for login
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)doRememberMe:(id)sender;

/**
 * @brief Hides the keyboard
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)removeKeyboard:(id)sender;

/**
 * @brief Reset user's password
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)sendReset:(id)sender;

/**
 * @brief Cancel resetting password
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)cancelReset:(id)sender;

@end

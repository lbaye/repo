//
//  LoginController.m
//  SocialMaps
//
//  Created by Arif Shakoor on 7/22/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "LoginController.h"
#import "RestClient.h"
#import "User.h"
#import "CustomAlert.h"
#import "FacebookHelper.h"

@implementation LoginController
@synthesize txtEmail;
@synthesize txtPassword;
@synthesize rememberMeSel;
@synthesize forgotPassword;
@synthesize forgotPWView;
@synthesize txtForgotPWEmail;
@synthesize dialogView;
@synthesize strUserID;
@synthesize strPassword;
@synthesize autoLogin;
@synthesize facebook;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginDone:) name:NOTIF_LOGIN_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forgotPWDone:) name:NOTIF_FORGOT_PW_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbLoginDone:) name:NOTIF_FBLOGIN_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbRegDone:) name:NOTIF_REG_DONE object:nil];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if (appDelegate.rememberLoginInfo == TRUE) {
        [rememberMeSel setImage:[UIImage imageNamed:@"checkbox_checked.png"] forState:UIControlStateNormal];
        txtEmail.text = appDelegate.email;
        txtPassword.text = appDelegate.password;
        NSLog(@"*** email=%@,password=%@,remember=%d",txtEmail.text,txtPassword.text,appDelegate.rememberLoginInfo);
    } else {
        [rememberMeSel setImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
    }
    
    [forgotPWView.layer setCornerRadius:10.0f];
    [forgotPWView.layer setMasksToBounds:YES];
    
    [dialogView.layer setCornerRadius:10.0f];
    [dialogView.layer setMasksToBounds:YES];
    [dialogView.layer setBorderWidth:1.5f];
    [dialogView.layer setBorderColor:[UIColor lightGrayColor].CGColor];

    facebook = [[FacebookHelper sharedInstance] facebook];
}

- (void)viewDidUnload
{
    [self setTxtEmail:nil];
    [self setTxtPassword:nil];
    [self setRememberMeSel:nil];
    [self setForgotPassword:nil];
    [self setForgotPWView:nil];
    [self setTxtForgotPWEmail:nil];
    [self setDialogView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_LOGIN_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_FORGOT_PW_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_FBLOGIN_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_REG_DONE object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [txtEmail release];
    [txtPassword release];
    [rememberMeSel release];
    [forgotPassword release];
    [forgotPWView release];
    [txtForgotPWEmail release];
    [dialogView release];
    [super dealloc];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
    // Store the userid and password
    self.strUserID = txtEmail.text;
    self.strPassword = txtPassword.text;
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    int movementDistance = 80; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    if (textField == txtForgotPWEmail)
        movementDistance = 200;
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	// When the user presses return, take focus away from the text field so that the keyboard is dismissed.
    if ([theTextField isEqual:txtEmail]) {
        [txtPassword becomeFirstResponder];

    } else {
        [theTextField resignFirstResponder];
    }
    // Store the userid and password
    self.strUserID = txtEmail.text;
    self.strPassword = txtPassword.text;
    
	return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    /*UIButton *button = (UIButton *)sender;
    UIViewController *vc = [segue destinationViewController];
    vc.title = button.titleLabel.text;*/
}

- (void)loginDone:(NSNotification *)notif
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate hideActivityViewer];
    [appDelegate.window setUserInteractionEnabled:YES];
    
    User * userInfo = [notif object];
    if (userInfo != nil) {
        appDelegate.loginCount++;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];  //load NSUserDefaults
        [prefs setInteger:appDelegate.loginCount forKey:@"loginCount"];

        if (appDelegate.loginCount == 1)
            [self performSegueWithIdentifier: @"showLocSharingConsent" sender: self];
        else
            [self performSegueWithIdentifier: @"showMapView" sender: self];
    } else {
        [CustomAlert setBackgroundColor:[UIColor redColor] 
                        withStrokeColor:[UIColor redColor]];
        CustomAlert *loginAlert = [[CustomAlert alloc]
						  initWithTitle:@"Cannot Login"
						  message:@"Wrong email/password, please retry!"
						  delegate:nil
						  cancelButtonTitle:@"Done"
						  otherButtonTitles:nil];

        [loginAlert show];
        [loginAlert autorelease];
    }
    
}

- (void)forgotPWDone:(NSNotification *)notif
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate hideActivityViewer];
    [appDelegate.window setUserInteractionEnabled:YES];
    
    User * userInfo = [notif object];
    forgotPWView.hidden = TRUE;
    if (userInfo != nil) {
        [CustomAlert setBackgroundColor:[UIColor grayColor] 
                        withStrokeColor:[UIColor grayColor]];
        CustomAlert *loginAlert = [[CustomAlert alloc]
                                   initWithTitle:@"Request sent successfully."
                                   message:@"An email has been sent to your supplied address with detailed instructions."
                                   delegate:nil
                                   cancelButtonTitle:@"Done"
                                   otherButtonTitles:nil];
        
        [loginAlert show];
        [loginAlert autorelease];
    } else {
        [CustomAlert setBackgroundColor:[UIColor redColor] 
                        withStrokeColor:[UIColor redColor]];
        CustomAlert *loginAlert = [[CustomAlert alloc]
                                   initWithTitle:@"Request was not sent!"
                                   message:@"Please contact provider!"
                                   delegate:nil
                                   cancelButtonTitle:@"Done"
                                   otherButtonTitles:nil];
        
        [loginAlert show];
        [loginAlert autorelease];
    }
    
}

- (IBAction)doLogin:(id)sender {
    if ([txtEmail.text isEqualToString:@""] || [txtPassword.text isEqualToString:@""] ||
        txtEmail.text == nil || txtPassword.text == nil){
        [CustomAlert setBackgroundColor:[UIColor redColor] 
                        withStrokeColor:[UIColor redColor]];
        CustomAlert *loginAlert = [[CustomAlert alloc]
                                   initWithTitle:@"Invalid Input"
                                   message:@"Please enter email and password!"
                                   delegate:nil
                                   cancelButtonTitle:@"Done"
                                   otherButtonTitles:nil];
        
        [loginAlert show];
        [loginAlert autorelease];
        
    } else {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        if (appDelegate.rememberLoginInfo == TRUE) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];  //load NSUserDefaults
            [prefs setObject:txtEmail.text forKey:@"email"];
            [prefs setObject:txtPassword.text forKey:@"password"];
            [prefs synchronize];
        }
        RestClient *restClient = [[RestClient alloc] init];
        [restClient login:txtEmail.text password:txtPassword.text];
        [appDelegate.window setUserInteractionEnabled:NO];
        [appDelegate showActivityViewer:self.view];
    }

}

- (void)fbRegDone:(NSNotification *)notif
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate hideActivityViewer];
    [appDelegate.window setUserInteractionEnabled:YES];
    
    User * regInfo = [notif object];
    if (regInfo != nil) {
        appDelegate.loginCount++;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];  //load NSUserDefaults
        [prefs setInteger:appDelegate.loginCount forKey:@"loginCount"];
        
        if (appDelegate.loginCount == 1)
            [self performSegueWithIdentifier: @"showLocSharingConsent" sender: self];
        else
            [self performSegueWithIdentifier: @"showMapView" sender: self];
    } else {
        [CustomAlert setBackgroundColor:[UIColor redColor] 
                        withStrokeColor:[UIColor redColor]];
        CustomAlert *loginAlert = [[CustomAlert alloc]
                                   initWithTitle:@"Cannot Register"
                                   message:@"Please contact provider"
                                   delegate:nil
                                   cancelButtonTitle:@"Done"
                                   otherButtonTitles:nil];
        
        [loginAlert show];
        [loginAlert autorelease];
    }
}

- (void)fbLoginDone:(NSNotification *)notif
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
    User * userInfo = [notif object];
    if (userInfo != nil) {
        // Do registration if first login
        RestClient *restClient = [[[RestClient alloc] init] autorelease];
        [restClient registerFB:(User *)userInfo];
        
        [appDelegate.window setUserInteractionEnabled:NO];
        [appDelegate showActivityViewer:self.view];
        
        //[self performSegueWithIdentifier: @"showMapView" sender: self];
    } else {
        [appDelegate hideActivityViewer];
        [appDelegate.window setUserInteractionEnabled:YES];

        [CustomAlert setBackgroundColor:[UIColor redColor] 
                        withStrokeColor:[UIColor redColor]];
        CustomAlert *loginAlert = [[CustomAlert alloc]
                                   initWithTitle:@"Cannot Login"
                                   message:@"Wrong email/password, please retry!"
                                   delegate:nil
                                   cancelButtonTitle:@"Done"
                                   otherButtonTitles:nil];
        
        [loginAlert show];
        [loginAlert autorelease];
    }
    
}


- (IBAction)doConnectFB:(id)sender {
    if (![facebook isSessionValid]) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate showActivityViewer:self.view];
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"email",
                                @"user_likes", 
                                @"user_photos", 
                                @"publish_checkins", 
                                @"photo_upload", 
                                @"user_location",
                                @"user_birthday",
                                @"user_about_me",
                                @"publish_stream",
                                @"read_stream",
                                nil];
        [facebook authorize:permissions];
        [permissions release];
    } else {
        [self performSegueWithIdentifier: @"showMapView" sender: self];
    }
}

- (IBAction)doForgotPassword:(id)sender {
    forgotPWView.hidden = FALSE;
}

- (IBAction)doRememberMe:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];  //load NSUserDefaults
    
    if (appDelegate.rememberLoginInfo == TRUE) {
        appDelegate.rememberLoginInfo = FALSE;
        [sender setImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
    } else {
        appDelegate.rememberLoginInfo = TRUE;
        [sender setImage:[UIImage imageNamed:@"checkbox_checked.png"] forState:UIControlStateNormal];
    }
    [prefs setBool:appDelegate.rememberLoginInfo forKey:@"rememberLoginInfo"];
    [prefs synchronize];
}

- (IBAction)removeKeyboard:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)cancelReset:(id)sender {
    forgotPWView.hidden = TRUE;
}

- (IBAction)sendReset:(id)sender {
    RestClient *restClient = [[RestClient alloc] init];
    [restClient forgotPassword:txtForgotPWEmail.text];
    [self.view endEditing:YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window setUserInteractionEnabled:NO];
    [appDelegate showActivityViewer:self.view];
}
@end

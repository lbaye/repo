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
#import "AppDelegate.h"
#import "UtilityClass.h"
#import "Globals.h"
#import "MapViewController.h"

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
@synthesize smAppDelegate;
@synthesize profileImageView;
@synthesize bgImgView,tapview;
int fbRegCounter=0;

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

- (void) checkNetwork {
    if (![UtilityClass hasConnectivity]) {
        [CustomAlert setBackgroundColor:[UIColor redColor] 
                        withStrokeColor:[UIColor redColor]];
        CustomAlert *loginAlert = [[CustomAlert alloc]
                                   initWithTitle:@"No network connectivity"
                                   message:@"Please enable network and retry!"
                                   delegate:nil
                                   cancelButtonTitle:@"Done"
                                   otherButtonTitles:nil];
        
        [loginAlert show];
        [loginAlert autorelease];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    fbRegCounter=0;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginDone:) name:NOTIF_LOGIN_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forgotPWDone:) name:NOTIF_FORGOT_PW_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbLoginDone:) name:NOTIF_FBLOGIN_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbRegDone:) name:NOTIF_FB_REG_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbFriendListDone:) name:NOTIF_FBFRIENDLIST_DONE object:nil];
    
    
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if (smAppDelegate.rememberLoginInfo == TRUE) {
        [rememberMeSel setImage:[UIImage imageNamed:@"checkbox_checked.png"] forState:UIControlStateNormal];
        txtEmail.text = smAppDelegate.email;
        txtPassword.text = smAppDelegate.password;
        NSLog(@"*** email=%@,password=%@,remember=%d",txtEmail.text,txtPassword.text,smAppDelegate.rememberLoginInfo);
    } else {
        [rememberMeSel setImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
    }
    
    [forgotPWView.layer setCornerRadius:10.0f];
    [forgotPWView.layer setMasksToBounds:YES];
    
    [dialogView.layer setCornerRadius:10.0f];
    [dialogView.layer setMasksToBounds:YES];
    [dialogView.layer setBorderWidth:1.5f];
    [dialogView.layer setBorderColor:[UIColor lightGrayColor].CGColor];

    [profileImageView.layer setCornerRadius:10.0f];
    [profileImageView.layer setMasksToBounds:YES];
    [profileImageView.layer setBorderWidth:1.5f];
    [profileImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSData *data =[prefs objectForKey:@"FBProfilePic"];
    UIImage *profileImage=[NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSLog(@"profileImage %@",profileImage);
    if (profileImage==NULL)
    {
        [profileImageView setImage:[UIImage imageNamed:@"icon_facebook.png"]];
    }
    else
    {
        [profileImageView setImage:profileImage];
    }
    [prefs synchronize];

    
    facebook = [[FacebookHelper sharedInstance] facebook];
    
    bgImgView.userInteractionEnabled = YES;
    bgImgView.exclusiveTouch = YES;
    
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    UITapGestureRecognizer *tapGesture1=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];

    
    tapGesture.numberOfTapsRequired = 1;
    tapGesture1.numberOfTapsRequired = 1;
    [bgImgView addGestureRecognizer:tapGesture];
    [tapview addGestureRecognizer:tapGesture1];
    [tapGesture release];
    [tapGesture1 release];    
}

-(IBAction) handleTapGesture:(UIGestureRecognizer *)sender
{
        NSLog(@"in gesture %@",sender.view);
        [txtEmail resignFirstResponder];
        [txtPassword resignFirstResponder];
        [txtForgotPWEmail resignFirstResponder];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_FBFRIENDLIST_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_FB_REG_DONE object:nil];
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

}

- (void)loginDone:(NSNotification *)notif
{
    NSLog(@"In LoginController:loginDone %@",[notif object]);
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    
    User * userInfo = [notif object];
    if (userInfo != nil) {
        smAppDelegate.loginCount++;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];  //load NSUserDefaults
        [prefs setInteger:smAppDelegate.loginCount forKey:@"loginCount"];
        [prefs setObject:userInfo.authToken forKey:@"authToken"];
        [prefs setObject:userInfo.id forKey:@"userId"];
        [prefs synchronize];
        if (userInfo.currentLocationLat != nil && userInfo.currentLocationLng != nil &&
            [userInfo.currentLocationLat floatValue] != 0.0 &&
            [userInfo.currentLocationLng floatValue] != 0.0) {
            smAppDelegate.currPosition.latitude = userInfo.currentLocationLat;
            smAppDelegate.currPosition.longitude = userInfo.currentLocationLng;
            smAppDelegate.currPosition.positionTime = [NSDate date];
        }
        NSLog(@"userInfo.authToken: %@",userInfo.authToken);
        smAppDelegate.authToken = userInfo.authToken;
        smAppDelegate.userId = userInfo.id;
        if (userInfoServiceLoginFlag==TRUE)
        {
            [smAppDelegate getPreferenceSettings:userInfo.authToken];            
        }
    
        // Always Register device token. This takes care of multiple user using same device
        RestClient *restClient = [[RestClient alloc] init];
        [restClient setPushNotificationSettings:smAppDelegate.deviceTokenId authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
        
        if (smAppDelegate.loginCount == 1)
            [self performSegueWithIdentifier: @"showLocSharingConsent" sender: self];
        else
        {
            [self performSegueWithIdentifier: @"showMapView" sender: self];
        }
        smAppDelegate.smLogin=TRUE;
        smAppDelegate.fbId = @"";
        
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
    NSLog(@"In LoginController:forgotPWDone");
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    
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
    NSLog(@"In LoginController:doLogin");
    if (![UtilityClass hasConnectivity]) {
        [CustomAlert setBackgroundColor:[UIColor redColor] 
                        withStrokeColor:[UIColor redColor]];
        CustomAlert *loginAlert = [[CustomAlert alloc]
                                   initWithTitle:@"No network connectivity"
                                   message:@"Please enable network and retry!"
                                   delegate:nil
                                   cancelButtonTitle:@"Done"
                                   otherButtonTitles:nil];
        
        [loginAlert show];
        [loginAlert autorelease];
    } else if ([txtEmail.text isEqualToString:@""] || [txtPassword.text isEqualToString:@""] ||
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
        if (smAppDelegate.rememberLoginInfo == TRUE) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];  //load NSUserDefaults
            [prefs setObject:txtEmail.text forKey:@"email"];
            [prefs setObject:txtPassword.text forKey:@"password"];
            [prefs synchronize];
            smAppDelegate.email = txtEmail.text;
            smAppDelegate.password = txtPassword.text;
        }
        RestClient *restClient = [[RestClient alloc] init];
        [restClient login:txtEmail.text password:txtPassword.text];
        [smAppDelegate.window setUserInteractionEnabled:NO];
        [smAppDelegate showActivityViewer:self.view];
    }

}

- (void)fbFriendListDone:(NSNotification *)notif
{
    NSLog(@"In LoginController:fbFriendListDone");
    User *user = [[User alloc] init];
    user.facebookId = smAppDelegate.fbId;
    user.facebookAuthToken = smAppDelegate.fbAccessToken;

    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    [restClient loginFacebook:(User *)user];
    
}
- (void)fbRegDone:(NSNotification *)notif
{
    if ([notif.object isKindOfClass:[User class]])
    {
        NSLog(@"In LoginController:fbRegDone");
        [smAppDelegate hideActivityViewer];
        [smAppDelegate.window setUserInteractionEnabled:YES];
        if (fbRegCounter==0)
        {
            User * regInfo = [notif object];
            if (regInfo != nil) {
                smAppDelegate.loginCount++;
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];  //load NSUserDefaults
                [prefs setInteger:smAppDelegate.loginCount forKey:@"loginCount"];
                [prefs setObject:regInfo.authToken forKey:@"authToken"];
                [prefs setObject:regInfo.id forKey:@"userId"];
                [prefs synchronize];
                if (regInfo.currentLocationLat != nil && regInfo.currentLocationLng != nil &&
                    [regInfo.currentLocationLat floatValue] != 0.0 &&
                    [regInfo.currentLocationLng floatValue] != 0.0) {
                    smAppDelegate.currPosition.latitude = regInfo.currentLocationLat;
                    smAppDelegate.currPosition.longitude = regInfo.currentLocationLng;
                    smAppDelegate.currPosition.positionTime = [NSDate date];
                }
                smAppDelegate.authToken = regInfo.authToken;
                smAppDelegate.userId = regInfo.id;
                if (userInfoServiceLoginFlag==TRUE)
                {
                    [smAppDelegate getPreferenceSettings:regInfo.authToken];            
                }
                
                [smAppDelegate getUserInformation:regInfo.authToken];
                
                // Always Register device token. This takes care of multiple user using same device
                RestClient *restClient = [[RestClient alloc] init];
                [restClient setPushNotificationSettings:smAppDelegate.deviceTokenId authToken:@"Auth-Token" authTokenVal:regInfo.authToken];
                
                if (smAppDelegate.loginCount == 1)
                    [self performSegueWithIdentifier: @"showLocSharingConsent" sender: self];
                else 
                {
                    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
                    MapViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"mapViewController"];
                    [controller retain];
                    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                    [self presentModalViewController:controller animated:YES];
                }
            } else {
                if (smAppDelegate.smLogin==FALSE)
                {
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
        }
    }
    else
    {
        [smAppDelegate hideActivityViewer];
        if (fbRegCounter==0) 
        {
            [UtilityClass showAlert:@"" :@"Can not regigter/login, try again."];
        }
    }
    fbRegCounter++;
}

- (void)fbLoginDone:(NSNotification *)notif
{
    NSLog(@"In LoginController:fbLoginDone");
    User * userInfo = [notif object];
    if (userInfo != nil) {
        // Do registration if first login
        RestClient *restClient = [[[RestClient alloc] init] autorelease];
        NSLog(@"userInfo.facebookId: %@ %@",userInfo.facebookId ,userInfo.firstName);
        [restClient loginFacebook:(User *)userInfo];
        
        [smAppDelegate.window setUserInteractionEnabled:NO];
        [smAppDelegate showActivityViewer:self.view];
        
    } else {
        [smAppDelegate hideActivityViewer];
        [smAppDelegate.window setUserInteractionEnabled:YES];

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
    NSLog(@"In LoginController:doConnectFB");
    smAppDelegate.facebookLogin = TRUE;
    if (![UtilityClass hasConnectivity]) {
        [CustomAlert setBackgroundColor:[UIColor redColor] 
                        withStrokeColor:[UIColor redColor]];
        CustomAlert *loginAlert = [[CustomAlert alloc]
                                   initWithTitle:@"No network connectivity"
                                   message:@"Please enable network and retry!"
                                   delegate:nil
                                   cancelButtonTitle:@"Done"
                                   otherButtonTitles:nil];
        
        [loginAlert show];
        [loginAlert autorelease];
    } else
    {
        NSLog(@"asking FB permission");
        [smAppDelegate showActivityViewer:self.view];
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
                                @"friends_status",
                                @"user_checkins",
                                @"friends_checkins",
                                nil];
        [facebook authorize:permissions];
        [permissions release];
    } 
}

- (IBAction)doForgotPassword:(id)sender {
    [self.view endEditing:YES];
    forgotPWView.hidden = FALSE;
}

- (IBAction)doRememberMe:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];  //load NSUserDefaults
    
    if (smAppDelegate.rememberLoginInfo == TRUE) {
        smAppDelegate.rememberLoginInfo = FALSE;
        [sender setImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
    } else {
        smAppDelegate.rememberLoginInfo = TRUE;
        [sender setImage:[UIImage imageNamed:@"checkbox_checked.png"] forState:UIControlStateNormal];
    }
    [prefs setBool:smAppDelegate.rememberLoginInfo forKey:@"rememberLoginInfo"];
    [prefs synchronize];
}

- (IBAction)removeKeyboard:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)cancelReset:(id)sender {
    [self.view endEditing:YES];
    forgotPWView.hidden = TRUE;
}

- (IBAction)sendReset:(id)sender {
    RestClient *restClient = [[RestClient alloc] init];
    [restClient forgotPassword:txtForgotPWEmail.text];
    [self.view endEditing:YES];
    
    [smAppDelegate.window setUserInteractionEnabled:NO];
    [smAppDelegate showActivityViewer:self.view];
}

@end

//
//  RegistrationController.m
//  SocialMaps
//
//  Created by Arif Shakoor on 7/23/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "RegistrationController.h"
#import "ASIFormDataRequest.h"
#import "User.h"
#import "RestClient.h"
#import "CustomAlert.h"
#import "AppDelegate.h"
#import "NSData+Base64.h"
#import "UtilityClass.h"

@implementation RegistrationController
@synthesize regEmail;
@synthesize regPassword;
@synthesize regName;
@synthesize regFirstName;
@synthesize picSelButton;
@synthesize regGender;
@synthesize selMaleFemale;
@synthesize arrayGender;
@synthesize userInfo;
@synthesize picSel;
@synthesize regPhoto;
@synthesize photoPicker;

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
    arrayGender = [[NSMutableArray alloc] init];
    userInfo = [[User alloc] init];
    
    [arrayGender addObject:@"Female"];
    [arrayGender addObject:@"Male"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(regDone:) name:NOTIF_REG_DONE object:nil];
    
    self.photoPicker = [[[PhotoPicker alloc] initWithNibName:nil bundle:nil] autorelease];
    self.photoPicker.delegate = self;
    
    self.picSel = [[UIImagePickerController alloc] init];
	self.picSel.allowsEditing = YES;
	self.picSel.delegate = self;	
}


- (void)viewDidUnload
{
    [self setSelMaleFemale:nil];
    [self setRegGender:nil];
    [self setRegEmail:nil];
    [self setRegPassword:nil];
    [self setRegName:nil];
    [self setRegFirstName:nil];
    [self setPicSelButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_REG_DONE object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [selMaleFemale release];
    [regGender release];
    [regEmail release];
    [regPassword release];
    [regName release];
    [regFirstName release];
    [picSelButton release];
    [super dealloc];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    userInfo.email = regEmail.text;
    userInfo.password = regPassword.text;
    userInfo.lastName = regName.text;
    userInfo.firstName = regFirstName.text;
    userInfo.gender = regGender.text;
    [self animateTextField: textField up: NO];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 120; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	// When the user presses return, take focus away from the text field so that the keyboard is dismissed.
    if ([theTextField isEqual:regEmail]) {
        [regPassword becomeFirstResponder];
    } else if ([theTextField isEqual:regPassword]){
        [regName becomeFirstResponder];
    } else if ([theTextField isEqual:regName]){
        [regFirstName becomeFirstResponder];
    }else if ([theTextField isEqual:regFirstName]){
        [theTextField resignFirstResponder];
    }
    // Store the password
    userInfo.email = regEmail.text;
    userInfo.password = regPassword.text;
    userInfo.lastName = regName.text;
    userInfo.firstName = regFirstName.text;
    userInfo.gender = regGender.text;

	return YES;
}

- (IBAction)selectGender:(id)sender {
    selMaleFemale.hidden = FALSE;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [arrayGender count];
}
- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [arrayGender objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSLog(@"Selected Gender: %@. Index of selected color: %i", [arrayGender objectAtIndex:row], row);
    selMaleFemale.hidden = TRUE;
    regGender.text = [arrayGender objectAtIndex:row];
}
- (IBAction)createAccount:(id)sender {
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
    } else if ([userInfo.email isEqualToString:@""] || userInfo.email == nil ||
        [userInfo.password isEqualToString:@""] || userInfo.password == nil ||
        [userInfo.lastName isEqualToString:@""] || userInfo.lastName == nil ||
        [userInfo.firstName isEqualToString:@""] || userInfo.firstName == nil) {
        [CustomAlert setBackgroundColor:[UIColor redColor] 
                        withStrokeColor:[UIColor redColor]];
        CustomAlert *loginAlert = [[CustomAlert alloc]
                                   initWithTitle:@"Required information missing"
                                   message:@"Please provide all required information"
                                   delegate:nil
                                   cancelButtonTitle:@"Done"
                                   otherButtonTitles:nil];
        
        [loginAlert show];
        [loginAlert autorelease];
    } else {
        NSData *imgdata = UIImagePNGRepresentation(regPhoto);
        NSString *imgBase64Data = [imgdata base64EncodedString];
        userInfo.avatar = imgBase64Data;
        
        RestClient *restClient = [[[RestClient alloc] init] autorelease];
        [restClient register:(User *)userInfo];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.window setUserInteractionEnabled:NO];
        [appDelegate showActivityViewer:self.view];
    }
}

- (void)regDone:(NSNotification *)notif
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate hideActivityViewer];
    [appDelegate.window setUserInteractionEnabled:YES];
    
    User * regInfo = [notif object];
    if (regInfo != nil) {
        [CustomAlert setBackgroundColor:[UIColor grayColor] 
                        withStrokeColor:[UIColor grayColor]];
        CustomAlert *loginAlert = [[CustomAlert alloc]
                                   initWithTitle:@"Registration Successful"
                                   message:@"Please login using your email and password"
                                   delegate:nil
                                   cancelButtonTitle:@"Done"
                                   otherButtonTitles:nil];
        
        [loginAlert show];
        [loginAlert autorelease];
        NSLog(@"Please login using your email and password");
        
        [self performSegueWithIdentifier: @"regBackToLogin" sender: self];
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

- (IBAction)hideKeyboard:(id)sender {
    [self.view endEditing:YES];
}


- (IBAction)selPicOption:(id)sender
{
    [self.photoPicker getPhoto:self];
}

- (void) photoPickerDone:(bool)status image:(UIImage*)img {
    NSLog(@"PersonalInformation:photoPickerDone, status=%d", status);
    if (status == TRUE) {
        [picSelButton setImage:img
                forState:UIControlStateNormal];
        regPhoto = img;
    } 
    [photoPicker.view removeFromSuperview];
}
@end

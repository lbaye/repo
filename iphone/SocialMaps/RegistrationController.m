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
#import "ActionSheetPicker.h"

@implementation RegistrationController
@synthesize regEmail;
@synthesize regPassword;
@synthesize regName;
@synthesize regFirstName;
@synthesize picSelButton;
@synthesize regGender;
@synthesize arrayGender;
@synthesize userInfo;
@synthesize picSel;
@synthesize regPhoto;
@synthesize photoPicker;
@synthesize moreInfoView;
@synthesize dateOfBirthTxtField;
@synthesize biographyTxtField;
@synthesize interestsTxtField;
@synthesize streetAdressTxtField;
@synthesize cityTxtField;
@synthesize zipCodeTxtField;
@synthesize countryTxtField;
@synthesize serviceTxtField;
@synthesize relatioshipStatusTxtField;
@synthesize basicInfoView;
@synthesize registrationScrollView;
@synthesize userNameTextField;

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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(regDone:) name:NOTIF_REG_DONE object:nil];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    arrayGender = [[NSMutableArray alloc] init];
    userInfo = [[User alloc] init];
    
    [arrayGender addObject:@"Female"];
    [arrayGender addObject:@"Male"];
    
    
    [registrationScrollView setContentSize:CGSizeMake(320, basicInfoView.frame.size.height+moreInfoView.frame.size.height)];
    
    basicInfoView.frame=CGRectMake(0, 0, basicInfoView.frame.size.width, basicInfoView.frame.size.height);
    moreInfoView.frame=CGRectMake(0, basicInfoView.frame.size.height, moreInfoView.frame.size.width, moreInfoView.frame.size.height);
    
    [registrationScrollView addSubview:basicInfoView];
    [registrationScrollView addSubview:moreInfoView];
    
    photoPicker = [[PhotoPicker alloc] initWithNibName:nil bundle:nil];
    photoPicker.delegate = self;
    
    picSel = [[UIImagePickerController alloc] init];
	picSel.allowsEditing = YES;
	picSel.delegate = self;
}


- (void)viewDidUnload
{
    [self setRegGender:nil];
    [self setRegEmail:nil];
    [self setRegPassword:nil];
    [self setRegName:nil];
    [self setRegFirstName:nil];
    [self setPicSelButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidDisappear:(BOOL)animated
{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_REG_DONE object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [photoPicker release];
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
    [UtilityClass beganEditing:(UIControl *)textField];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    userInfo.email = regEmail.text;
    userInfo.password = regPassword.text;
    userInfo.firstName = regFirstName.text;
    userInfo.lastName = regName.text;
    userInfo.gender = regGender.text;
        [UtilityClass endEditing];
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
        [userNameTextField becomeFirstResponder];
    }
    else if ([theTextField isEqual:userNameTextField])
    {
        [theTextField resignFirstResponder];
    }
    else {
        [theTextField resignFirstResponder];
    }
    // Store the password
    userInfo.email = regEmail.text;
    userInfo.password = regPassword.text;
    userInfo.lastName = regName.text;
    userInfo.userName = userNameTextField.text;
    userInfo.firstName = regFirstName.text;
    userInfo.gender = regGender.text;
	return YES;
}

- (IBAction)selectDateOfBirthAction:(id)sender
{
    NSLog(@"select date");
    [self resignAllTextFields];
    [ActionSheetPicker displayActionPickerWithView:sender dateOfBirthPickerMode:UIDatePickerModeDate selectedDate:[NSDate date] target:self action:@selector(dateWasSelected::) title:@"Select date of birth"];
}

- (void)dateWasSelected:(NSDate *)selectedDate:(id)element 
{
    userInfo.dateOfBirth=[UtilityClass convertDateToDisplayFormat:selectedDate];
    dateOfBirthTxtField.text=[NSString stringWithFormat:@"%@",[UtilityClass convertDateToDisplayFormat:selectedDate]];
}

- (IBAction)selectCountryAction:(id)sender
{
    NSLog(@"select country");
}

- (IBAction)selectRelStatus:(id)sender
{
    NSLog(@"select rel status");
}

- (IBAction)selectGender:(id)sender {
        [self resignAllTextFields];
    [ActionSheetPicker displayActionPickerWithView:sender data:arrayGender selectedIndex:0 target:self action:@selector(genderWasSelected::) title:@"Select Gender"];
}

-(void)genderWasSelected:(NSNumber *)selectedIndex:(id)element 
{
    regGender.text = [arrayGender objectAtIndex:[selectedIndex intValue]];
}

- (IBAction)createAccount:(id)sender {
    userInfo.email = regEmail.text;
    userInfo.password = regPassword.text;
    userInfo.firstName = regFirstName.text;
    userInfo.lastName = regName.text;
    userInfo.gender = regGender.text;
    userInfo.userName = userNameTextField.text;
    
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
        [userInfo.password isEqualToString:@""] || ![self NSStringIsValidEmail:userInfo.email] ||
        [userInfo.userName isEqualToString:@""] || userInfo.userName == nil ||
        regPhoto == nil ||[regGender.text isEqualToString:@""])
    {
        NSMutableString *message=[[NSMutableString alloc] initWithString:@"Please provide "];        
        if (regPhoto == nil)
        {
            [message appendString:@"image, "];            
        }
        if ([self NSStringIsValidEmail:userInfo.email]==FALSE)
        {
            [message appendString:@"valid email address, "];
        }
        if ([userInfo.password isEqualToString:@""] || userInfo.password == nil)
        {
            [message appendString:@"password, "];
        }
        if ([regGender.text isEqualToString:@""])
        {
            [message appendString:@"gender, "];
        }
        if ([userInfo.userName isEqualToString:@""] || userInfo.userName == nil)
        {
            [message appendString:@"username, "];
        }
        
        [CustomAlert setBackgroundColor:[UIColor redColor]
                        withStrokeColor:[UIColor redColor]];
        CustomAlert *loginAlert = [[CustomAlert alloc]
                                   initWithTitle:@"Required information missing"
                                   message:message
                                   delegate:nil
                                   cancelButtonTitle:@"Done"
                                   otherButtonTitles:nil];
        
        [loginAlert show];
        [loginAlert release];
    } else {
        //NSData *imgdata = UIImagePNGRepresentation(regPhoto);
        NSData *imgdata = UIImageJPEGRepresentation(regPhoto, 0.6);
        NSString *imgBase64Data = [imgdata base64EncodedString];
        userInfo.avatar = imgBase64Data;
        
        userInfo.bio = biographyTxtField.text;
        userInfo.interests =interestsTxtField.text;
        userInfo.street = streetAdressTxtField.text;
        userInfo.city = cityTxtField.text;
        userInfo.postCode = zipCodeTxtField.text;
        userInfo.country = countryTxtField.text;
        userInfo.workStatus = serviceTxtField.text;
        userInfo.relationshipStatus = relatioshipStatusTxtField.text;
        
        RestClient *restClient = [[[RestClient alloc] init] autorelease];
        [restClient register:(User *)userInfo];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.window setUserInteractionEnabled:NO];
        [appDelegate showActivityViewer:self.view];
    }
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; 
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (void)regDone:(NSNotification *)notif
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate hideActivityViewer];
    [appDelegate.window setUserInteractionEnabled:YES];
    
    if ([notif.object isKindOfClass:[User class]]) {
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
    }
    }
    else if([notif.object isKindOfClass:[NSString class]])
    {
        [CustomAlert setBackgroundColor:[UIColor redColor] 
                        withStrokeColor:[UIColor redColor]];
        CustomAlert *loginAlert = [[CustomAlert alloc]
                                   initWithTitle:@"Cannot Register"
                                   message:notif.object
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

-(void)resignAllTextFields
{
    [regGender resignFirstResponder];
    [regEmail resignFirstResponder];
    [regPassword resignFirstResponder];
    [regName resignFirstResponder];
    [regFirstName resignFirstResponder];
    [dateOfBirthTxtField resignFirstResponder];
    [biographyTxtField resignFirstResponder];
    [interestsTxtField resignFirstResponder];
    [streetAdressTxtField resignFirstResponder];
    [cityTxtField resignFirstResponder];
    [zipCodeTxtField resignFirstResponder];
    [countryTxtField resignFirstResponder];
    [serviceTxtField resignFirstResponder];
    [relatioshipStatusTxtField resignFirstResponder];
    [userNameTextField resignFirstResponder];
}

- (IBAction)selPicOption:(id)sender
{
    [self resignAllTextFields];
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

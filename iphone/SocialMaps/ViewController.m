//
//  ViewController.m
//  SocialMaps
//
//  Created by Arif Shakoor on 7/22/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "ViewController.h"
#import "UtilityClass.h"
#import "UserDefault.h"
#import "CustomAlert.h"
#import "AppDelegate.h"
#import "Globals.h"
#import "MapViewController.h"
#import "RestClient.h"

@implementation ViewController
@synthesize progressView;
@synthesize privateBetaView;
@synthesize betaPassWord;

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
CGFloat animatedDistance;
UserDefault *userDef;
AppDelegate *smAppDelegate;
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    userDef=[[UserDefault alloc] init];
    smAppDelegate.authToken = [userDef readFromUserDefaults:@"authToken"];
    smAppDelegate.userId = [userDef readFromUserDefaults:@"userId"];
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([smAppDelegate.authToken isKindOfClass:[NSString class]])
    {
        NSLog(@"viewcontroller smAppDelegate.authToken: %@ %i %i",smAppDelegate.authToken,[smAppDelegate.authToken isKindOfClass:[NSString class]],[smAppDelegate.authToken isMemberOfClass:[NSNull class]]);
        [smAppDelegate getPreferenceSettings:smAppDelegate.authToken];
        RestClient *rc=[[RestClient alloc] init];
        [rc getFriendListWithAuthKey:@"Auth-Token" tokenValue:smAppDelegate.authToken andFriendId:smAppDelegate.userId];
        userInfoServiceLoginFlag=FALSE;
    }
    else
    {
        userInfoServiceLoginFlag=TRUE;
    }
	// Do any additional setup after loading the view, typically from a nib.
    progressView.progress = 0.0;
    [smAppDelegate.authToken retain];
    [smAppDelegate.userId retain];
    //[self performSelectorOnMainThread:@selector(makeMyProgressBarMoving) withObject:nil waitUntilDone:NO];
}

- (void)viewDidUnload
{
    [self setProgressView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [super viewWillAppear:animated];
    [self.privateBetaView removeFromSuperview];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self makeMyProgressBarMoving];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {
    [progressView release];
    [super dealloc];
}

- (void)makeMyProgressBarMoving {
    
    float actual = [progressView progress];
    if (actual < 1) {
        progressView.progress = actual + 0.02;
        [NSTimer scheduledTimerWithTimeInterval:0.08 target:self selector:@selector(makeMyProgressBarMoving) userInfo:nil repeats:NO];
    }
    else{
        
        if (userInfoServiceLoginFlag == TRUE)
        {
            [self performSegueWithIdentifier: @"showLogin" sender: self];
        }
        if (userInfoServiceLoginFlag == FALSE) 
        {
            NSLog(@"goto map view");
            //        [self performSegueWithIdentifier: @"showMapView" sender: self];
            UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            MapViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"mapViewController"];
            [controller retain];
            controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentModalViewController:controller animated:YES];
            
        }
    }
    
} 

-(IBAction)discoverApp:(id)sender
{
    if ([betaPassWord.text isEqualToString:@"discover2012"])
    {
        [self performSegueWithIdentifier: @"showLogin" sender: self];
        [userDef removeFromDefault:@"betaPassWord"];
        [userDef writeToUserDefaults:@"betaPassWord" withString:betaPassWord.text];
    }
    else
    {
//        [UtilityClass showAlert:@"Social Maps" :@"Enter valid password"];
        [CustomAlert setBackgroundColor:[UIColor redColor] 
                        withStrokeColor:[UIColor redColor]];
        CustomAlert *loginAlert = [[CustomAlert alloc]
                                   initWithTitle:@"Cannot Discover"
                                   message:@"Wrong beta password, please retry!"
                                   delegate:nil
                                   cancelButtonTitle:@"Done"
                                   otherButtonTitles:nil];
        
        [loginAlert show];
        [loginAlert autorelease];

    }
}

-(IBAction)requestPassword:(id)sender
{
    NSLog(@"request password...");
    NSString* launchUrl = @"http://socialmapsapp.com";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: launchUrl]];
}

-(IBAction)textFieldEntryDone:(id)sender
{
    [betaPassWord resignFirstResponder];
}


-(void)beganEditing:(UITextField *)textField
{
    //UIControl need to config here
    CGRect textFieldRect =
	[self.view.window convertRect:textField.bounds fromView:textField];
    
    CGRect viewRect =
	[self.view.window convertRect:self.view.bounds fromView:self.view];
	
	CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
	midline - viewRect.origin.y
	- MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
	(MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
	* viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
	if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
	UIInterfaceOrientation orientation =
	[[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
	CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
    
}

-(void)endEditing
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];    
    [self.view setFrame:viewFrame];    
    [UIView commitAnimations];    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self beganEditing:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self endEditing];
}

@end

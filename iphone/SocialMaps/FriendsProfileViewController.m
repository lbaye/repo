//
//  FriendsProfileViewController.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 10/18/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FriendsProfileViewController.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "RestClient.h"
#import "UserInfo.h"
#import "UIImageView+roundedCorner.h"
#import "DDAnnotation.h"
#import "DDAnnotationView.h"
#import "NotificationController.h"
#import "UtilityClass.h"
#import "ActionSheetPicker.h"
#import "UtilityClass.h"
#import "MeetUpRequestController.h"
#import "ViewEventListViewController.h"
#import "LocationItemPeople.h"
#import "DirectionViewController.h"
#import "FriendsPhotosViewController.h"
#import "PlaceListViewController.h"
#import "Globals.h"
#import "FriendListViewController.h"
#import "FriendsPlanListViewController.h"
#import "ODRefreshControl.h"

@interface FriendsProfileViewController ()

@end

@implementation FriendsProfileViewController

@synthesize coverImageView;
@synthesize profileImageView;
@synthesize nameLabl;
@synthesize statusMsgLabel;
@synthesize addressOrvenueLabel;
@synthesize distanceLabel;
@synthesize ageLabel;
@synthesize relStsLabel;
@synthesize livingPlace;
@synthesize worksLabel;
@synthesize regStatus;
@synthesize userItemScrollView;
@synthesize mapView,mapContainer,statusContainer,entityTextField;
@synthesize photoPicker,coverImage,profileImage,picSel;
@synthesize totalNotifCount;
@synthesize friendsId;
@synthesize msgView,textViewNewMsg;
@synthesize frndStatusButton;
@synthesize addFrndButton,lastSeenat,meetUpButton;
@synthesize  profileView;
@synthesize newsfeedView;
@synthesize profileScrollView;
@synthesize zoomView,fullImageView;

AppDelegate *smAppDelegate;
RestClient *rc;
UserInfo *userInfo;
NSMutableArray *nameArr;
BOOL coverImgFlag;
BOOL isDirtyFrnd=FALSE;
NSMutableArray *selectedScrollIndex;
UIImageView *lineView;
int newsFeedscrollHeight,reloadFeedCounter=0;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [statusMsgLabel.layer setCornerRadius:3.0f];
    [addressOrvenueLabel.layer setCornerRadius:3.0f];
    [distanceLabel.layer setCornerRadius:3.0f];
    selectedScrollIndex=[[NSMutableArray alloc] init];
    [self displayNotificationCount];
    self.photoPicker = [[[PhotoPicker alloc] initWithNibName:nil bundle:nil] autorelease];
    self.photoPicker.delegate = self;
    self.picSel = [[UIImagePickerController alloc] init];
	self.picSel.allowsEditing = YES;
	self.picSel.delegate = self;
    
    nameLabl.layer.shadowRadius = 5.0f;
    nameLabl.layer.shadowOpacity = .9;
    nameLabl.layer.shadowOffset = CGSizeZero;
    nameLabl.layer.masksToBounds = NO;
    
    statusMsgLabel.layer.shadowRadius = 5.0f;
    statusMsgLabel.layer.shadowOpacity = .9;
    statusMsgLabel.layer.shadowOffset = CGSizeZero;
    statusMsgLabel.layer.masksToBounds = NO;
    [textViewNewMsg.layer setCornerRadius:8.0f];
    [textViewNewMsg.layer setBorderWidth:0.5];
    [textViewNewMsg.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [textViewNewMsg.layer setMasksToBounds:YES];
    //[smAppDelegate showActivityViewer:self.view];
    [smAppDelegate.window setUserInteractionEnabled:NO];
    isBackgroundTaskRunning=TRUE;
    rc=[[RestClient alloc] init];
    userInfo=[[UserInfo alloc] init];
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:profileScrollView];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getOtherUserProfileDone:) name:NOTIF_GET_OTHER_USER_PROFILE_DONE object:nil];    
    
    NSLog(@"friendsId: %@",friendsId);
    //[rc getOtherUserProfile:@"Auth-Token":smAppDelegate.authToken:friendsId];
    nameArr=[[NSMutableArray alloc] init];
    ImgesName=[[NSMutableArray alloc] init];
    
    nameArr=[[NSMutableArray alloc] initWithObjects:@"Photos",@"Friends",@"Events",@"Places",@"Meet-up",@"Plan", nil];
    [ImgesName addObject:@"photos_icon"];
    [ImgesName addObject:@"thum"];
    [ImgesName addObject:@"events_icon"];
    [ImgesName addObject:@"places_icon"];
    [ImgesName addObject:@"sm_icon@2x"];
    [ImgesName addObject:@"sm_icon@2x"];
    
    userItemScrollView.delegate = self;
    dicImages_msg = [[NSMutableDictionary alloc] init];
    lineView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line.png"]];
    lineView.frame=CGRectMake(10, profileView.frame.size.height, 300, 1);
    [self reloadScrolview];
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    [newsfeedView reload];
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [refreshControl endRefreshing];
    });
}

-(void)viewWillAppear:(BOOL)animated
{
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];    
    isBackgroundTaskRunning=TRUE;
    [mapContainer removeFromSuperview];
    [statusContainer removeFromSuperview];
    [msgView removeFromSuperview];
    [zoomView removeFromSuperview];
    profileImageView.layer.borderColor=[[UIColor lightTextColor] CGColor];
    profileImageView.userInteractionEnabled=YES;
    profileImageView.layer.borderWidth=1.0;
    profileImageView.layer.masksToBounds = YES;
    [profileImageView.layer setCornerRadius:5.0];
    
    smAppDelegate.currentModelViewController = self;
    
    [smAppDelegate showActivityViewer:self.view];
    [rc getOtherUserProfile:@"Auth-Token":smAppDelegate.authToken:friendsId];
    
    NSString *urlStr=[NSString stringWithFormat:@"%@/%@/newsfeed.html?authToken=%@&r=%@",WS_URL,friendsId,smAppDelegate.authToken,[UtilityClass convertNSDateToUnix:[NSDate date]]];
    NSLog(@"urlStr %@",urlStr);
    [friendsId retain];
    [newsfeedView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
}

-(void)reloadProfileScrollView
{
    [profileView removeFromSuperview];
    [newsfeedView removeFromSuperview];
    [profileView setFrame:CGRectMake(0, 0, profileView.frame.size.width, profileView.frame.size.height)];
    [profileScrollView setContentSize:CGSizeMake(320, profileView.frame.size.height+newsfeedView.frame.size.height)];
    newsFeedscrollHeight=newsfeedView.frame.size.height;
    [profileScrollView addSubview:profileView];
    [profileScrollView addSubview:newsfeedView];
}

-(IBAction)editCoverButton:(id)sender
{
    isDirtyFrnd=TRUE;
    coverImgFlag=TRUE;
    [self.photoPicker getPhoto:self];
    [self.entityTextField resignFirstResponder];
}

-(IBAction)editProfilePicButton:(id)sender
{
    isDirtyFrnd=TRUE;
    coverImgFlag=FALSE;
    [self.photoPicker getPhoto:self];
    [self.entityTextField resignFirstResponder];    
}

-(IBAction)editStatusButton:(id)sender
{
    entityFlag=0;
    [self.view addSubview:statusContainer];
    entityTextField.placeholder=@"My status message...";
    entityTextField.text=userInfo.status;
}

-(IBAction)viewOnMapButton:(id)sender
{
    [self.view addSubview:mapContainer];
}

-(IBAction)closeZoomView:(id)sender
{
    CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];	
	[[self.view layer] addAnimation:animation forKey:@"layerAnimation"];
    [zoomView removeFromSuperview];
}


- (BOOL)webView: (UIWebView*)webView shouldStartLoadWithRequest: (NSURLRequest*)request navigationType: (UIWebViewNavigationType)navigationType {
    NSString *fragment, *scheme;
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [webView stopLoading];
        fragment = [[request URL] fragment];
        scheme = [[request URL] scheme];
        NSLog(@"%@ scheme",scheme);
        if ([[[request URL] absoluteString] hasPrefix:@"button://"]) {
            // Do custom code
            NSLog(@"got button %@",scheme);
            return NO;
        } 
        if ([scheme isEqualToString: @"button"] && [self respondsToSelector: NSSelectorFromString(fragment)]) {
            [self performSelector: NSSelectorFromString(fragment)];
            return NO;
        }
        
        [[UIApplication sharedApplication] openURL: [request URL]];
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    reloadFeedCounter=0;
    [smAppDelegate hideActivityViewer];
    CGRect frame = aWebView.frame;
    frame.size.height = 1;
    aWebView.frame = frame;
    CGSize fittingSize = [aWebView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    aWebView.frame = frame;
    
    NSLog(@"webview size: %f, %f", fittingSize.width, fittingSize.height);
    newsfeedView.frame=CGRectMake(0, profileView.frame.size.height,  fittingSize.width, fittingSize.height);
    [self reloadProfileScrollView];
    [newsfeedView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"];
    [newsfeedView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout = 'none'"];

}

-(IBAction)geotagButton:(id)sender
{
/*    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"GeoTagStoryboard" bundle:nil];
    UIViewController* initialHelpView = [storyboard instantiateViewControllerWithIdentifier:@"createGeotag"];
    
    initialHelpView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:initialHelpView animated:YES];
 */
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    [restClient sendFriendRequest:userInfo.userId message:@"" authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
    [frndStatusButton setTitle:@"requested" forState:UIControlStateNormal];
    [addFrndButton setTitle:@"Requested..." forState:UIControlStateNormal];
    [addFrndButton setUserInteractionEnabled:NO];
    [frndStatusButton setHidden:NO];
}

-(IBAction)uploadPhotoButton:(id)sender
{
    NSLog(@"meet up request");
    MeetUpRequestController *controller = [[MeetUpRequestController alloc] initWithNibName:@"MeetUpRequestController" bundle:nil];
    controller.selectedfriendId = userInfo.userId;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

-(IBAction)getDirection:(id)sender
{
    NSLog(@"get directions..");
    
    DirectionViewController *controller = [[DirectionViewController alloc] initWithNibName: @"DirectionViewController" bundle:nil];
    CLLocationCoordinate2D theCoordinate;
	theCoordinate.latitude = [userInfo.currentLocationLat doubleValue];
    theCoordinate.longitude = [userInfo.currentLocationLng doubleValue];
    controller.coordinateTo = theCoordinate;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

-(IBAction)closeMap:(id)sender
{
    [mapContainer removeFromSuperview];
}

-(IBAction)saveEntity:(id)sender
{
    isDirtyFrnd=TRUE;
    NSLog(@"save");
    [statusContainer removeFromSuperview];
    [entityTextField resignFirstResponder];
    if (entityFlag==0)
    {
        statusMsgLabel.text=entityTextField.text;
        userInfo.status=entityTextField.text;        
    }
    if (entityFlag==1)
    {
        ageLabel.text=entityTextField.text;
        userInfo.age=[entityTextField.text intValue];
    }
    if (entityFlag==2)
    {
        relStsLabel.text=entityTextField.text;
        userInfo.relationshipStatus=entityTextField.text;
    }
    if (entityFlag==3)
    {
        livingPlace.text=entityTextField.text;
        userInfo.address.city=entityTextField.text;        
    }
    if (entityFlag==4)
    {
        worksLabel.text=entityTextField.text;
        userInfo.workStatus=entityTextField.text;                
    }    
}

-(People *)getPeopleById:(NSString *)userId
{
    NSLog(@"[smAppDelegate.peopleList count] %d",[smAppDelegate.peopleList count]);
    for(int i=0; i<[smAppDelegate.peopleList count]; i++)
    {
        if ([((LocationItemPeople *)[smAppDelegate.peopleList objectAtIndex:i]).userInfo.userId isEqualToString:userId])
        {
            return [smAppDelegate.peopleList objectAtIndex:i];
        }
    }
    return nil;
}

-(IBAction)cancelEntity:(id)sender
{
    NSLog(@"cancel");
    [statusContainer removeFromSuperview];
    [entityTextField resignFirstResponder];
}

-(IBAction)gotoNotification:(id)sender
{
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    NotificationController *controller =[storybrd instantiateViewControllerWithIdentifier:@"notificationViewController"];
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
    
}

-(IBAction)showMsgView:(id)sender
{
    [self.view addSubview:msgView];
}

-(void) displayNotificationCount {
    int totalNotif= [UtilityClass getNotificationCount];
    if (totalNotif == 0)
        totalNotifCount.text = @"";
    else
        totalNotifCount.text = [NSString stringWithFormat:@"%d",totalNotif];
}

- (void) photoPickerDone:(bool)status image:(UIImage*)img
{
    NSLog(@"PersonalInformation:photoPickerDone, status=%d", status);
    if (coverImgFlag==TRUE) {
        if (status == TRUE) 
        {
            [coverImageView setImage:img];
            NSData *imgdata = UIImagePNGRepresentation(img);
            NSString *imgBase64Data = [imgdata base64EncodedString];
            userInfo.coverPhoto=imgBase64Data;
        } 
    }
    else
    {
        if (status == TRUE) 
        {
            [profileImageView setImage:img];
            NSData *imgdata = UIImagePNGRepresentation(img);
            NSString *imgBase64Data = [imgdata base64EncodedString];
            userInfo.avatar=imgBase64Data;
        } 
    }
    [photoPicker.view removeFromSuperview];
}

-(IBAction)backButton:(id)sender
{
    if (isDirtyFrnd==FALSE) 
    {
        [self dismissModalViewControllerAnimated:YES];
    }
    else if(isDirtyFrnd==TRUE)
    {
        [self.entityTextField resignFirstResponder];
        [smAppDelegate showActivityViewer:self.view];
        [smAppDelegate.window setUserInteractionEnabled:NO];
        [rc updateUserProfile:userInfo:@"Auth-Token":smAppDelegate.authToken];
    }
}

-(IBAction)goToZoomView:(id)sender
{
    CGFloat xpos = self.view.frame.origin.x;
    CGFloat ypos = self.view.frame.origin.y;
    zoomView.frame = CGRectMake(xpos+100,ypos+150,5,5);
    [UIView beginAnimations:@"Zoom" context:NULL];
    [UIView setAnimationDuration:0.8];
    zoomView.frame = CGRectMake(xpos, ypos-20, 320, 460);
    [UIView commitAnimations];
    [self.view addSubview:zoomView];
}

- (void)getOtherUserProfileDone:(NSNotification *)notif
{
    NSLog(@"GOT SERVICE DATA FRIENDS Profile.. :D  %@",[notif object]);
    [self performSelector:@selector(hideActivity) withObject:nil afterDelay:1.0];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    //     coverImageView.image;
    //     profileImageView.image;
    userInfo=[notif object];
    nameLabl.text=[NSString stringWithFormat:@" %@ %@",userInfo.firstName,userInfo.lastName];
    statusMsgLabel.text=@"";
    addressOrvenueLabel.text=userInfo.address.street;
        Geolocation *geoLocation=[[Geolocation alloc] init];
        geoLocation.latitude=userInfo.currentLocationLat;
        geoLocation.longitude=userInfo.currentLocationLng;
        distanceLabel.text=[UtilityClass getDistanceWithFormattingFromLocation:geoLocation];
   
    if (userInfo.age>0) {
        ageLabel.text=[NSString stringWithFormat:@"%d",userInfo.age];
    }
    else {
        ageLabel.text=@"Not found";
    }
    if (![userInfo.relationshipStatus isEqualToString:@"Select..."]) 
    {
        relStsLabel.text=userInfo.relationshipStatus;
    }
    if (userInfo.address.city) {
        livingPlace.text=userInfo.address.city;
    }
    else
    {
        if([self getPeopleById:userInfo.userId])
        livingPlace.text=((LocationItemPeople *)[self getPeopleById:userInfo.userId]).userInfo.lastSeenAt;
    }
    worksLabel.text=userInfo.workStatus;
    if (userInfo.status) 
    {
        statusMsgLabel.text=userInfo.status;
    }
    
    if ([userInfo.regMedia isEqualToString:@"fb"]) 
    {
        [regStatus setImage:[UIImage imageNamed:@"icon_facebook.png"] forState:UIControlStateNormal];
    }
    else
    {
        [regStatus setImage:[UIImage imageNamed:@"sm_icon@2x.png"] forState:UIControlStateNormal];
    }
    regStatus.layer.borderColor=[[UIColor lightTextColor] CGColor];
    regStatus.userInteractionEnabled=YES;
    regStatus.layer.borderWidth=1.0;
    regStatus.layer.masksToBounds = YES;
    [regStatus.layer setCornerRadius:5.0];
    
    [self performSelectorInBackground:@selector(loadImage) withObject:nil];
    [self performSelectorInBackground:@selector(loadImage2) withObject:nil];  
    
    //    [self performSelector:@selector(loadImage) withObject:nil afterDelay:0];
    //    [self performSelector:@selector(loadImage2) withObject:nil afterDelay:0];
    
    //add annotation to map
    [mapView removeAnnotations:[self.mapView annotations]];
    CLLocationCoordinate2D theCoordinate;
	theCoordinate.latitude = [userInfo.currentLocationLat doubleValue];
    theCoordinate.longitude = [userInfo.currentLocationLng doubleValue];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(theCoordinate, 1000, 1000);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];  
    [self.mapView setRegion:adjustedRegion animated:YES]; 
    
    NSLog(@"lat %lf ",[userInfo.currentLocationLat doubleValue]);
	DDAnnotation *annotation = [[[DDAnnotation alloc] initWithCoordinate:theCoordinate addressDictionary:nil] autorelease];
    
    if ((!userInfo.address.city) || ([userInfo.address.city isEqualToString:@""]))
    {
        annotation.title =[NSString stringWithFormat:@"Address not found"];
    }
    else 
    {
        annotation.title =[NSString stringWithFormat:@" %@",userInfo.address.city];
    }
	annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
	annotation.subtitle=[NSString stringWithFormat:@"Distance: %.2fm",((LocationItemPeople *)[self getPeopleById:userInfo.userId]).itemDistance];
    if (CLLocationCoordinate2DIsValid(annotation.coordinate)) {
        [self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
        [self.mapView addAnnotation:annotation];
    }
    if ([userInfo.friendshipStatus isEqualToString:@"none"]) 
    {
        [frndStatusButton setHidden:YES];
    }
    else
    {
        [frndStatusButton setTitle:userInfo.friendshipStatus forState:UIControlStateNormal];
        [addFrndButton setTitle:userInfo.friendshipStatus forState:UIControlStateNormal];
        [addFrndButton setUserInteractionEnabled:NO];
        NSString *friendShipStatus=userInfo.friendshipStatus;
        if ([friendShipStatus isEqualToString:@"rejected_by_me"] || [friendShipStatus isEqualToString:@"rejected_by_him"]) {
            [addFrndButton setTitle:@"Rejected" forState:UIControlStateNormal];
            [addFrndButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [addFrndButton setBackgroundImage:[UIImage imageNamed:@"btn_bg_light_small.png"] forState:UIControlStateNormal];
            [addFrndButton setImage:nil forState:UIControlStateNormal];
            addFrndButton.userInteractionEnabled = NO;
        } else if ([friendShipStatus isEqualToString:@"requested"]) {
            [addFrndButton setImage:nil forState:UIControlStateNormal];
            [addFrndButton setBackgroundImage:[UIImage imageNamed:@"btn_bg_light_small.png"] forState:UIControlStateNormal];
            [addFrndButton setTitle:@"Requested" forState:UIControlStateNormal];
            addFrndButton.userInteractionEnabled = NO;
        } else if ([friendShipStatus isEqualToString:@"pending"]) {
            [addFrndButton setImage:nil forState:UIControlStateNormal];
            [addFrndButton setTitle:@"Pending" forState:UIControlStateNormal];
            [addFrndButton setBackgroundImage:[UIImage imageNamed:@"btn_bg_light_small.png"] forState:UIControlStateNormal];
            addFrndButton.userInteractionEnabled = NO;
        }
        else if ([friendShipStatus isEqualToString:@"friend"]) {
            [addFrndButton setImage:nil forState:UIControlStateNormal];
            [addFrndButton setTitle:@"Friend" forState:UIControlStateNormal];
            [addFrndButton setBackgroundImage:[UIImage imageNamed:@"btn_bg_light_small.png"] forState:UIControlStateNormal];
            addFrndButton.userInteractionEnabled = NO;
        }
    }
    
    if (![userInfo.friendshipStatus isEqualToString:@"friend"]) 
    {
        [meetUpButton setEnabled:NO];
    }
    
}

- (void)getBasicProfileDone:(NSNotification *)notif
{
    NSLog(@"GOT SERVICE DATA BASIC Profile.. :D  %@",[notif object]);
    [self performSelector:@selector(hideActivity) withObject:nil afterDelay:1.0];
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    //     coverImageView.image;
    //     profileImageView.image;
    userInfo=[notif object];
    nameLabl.text=[NSString stringWithFormat:@" %@",userInfo.firstName];
    statusMsgLabel.text=@"";
    addressOrvenueLabel.text=userInfo.address.street;
    distanceLabel.text=[NSString stringWithFormat:@"%dm",userInfo.distance];
    ageLabel.text=[NSString stringWithFormat:@"%d",userInfo.age];
    relStsLabel.text=userInfo.relationshipStatus;
    livingPlace.text=userInfo.address.city;
    worksLabel.text=userInfo.workStatus;
    if (userInfo.status) 
    {
        statusMsgLabel.text=userInfo.status;
    }
    
    if ([userInfo.regMedia isEqualToString:@"fb"]) 
    {
        [regStatus setImage:[UIImage imageNamed:@"f_logo.png"] forState:UIControlStateNormal];
    }
    else
    {
        [regStatus setImage:[UIImage imageNamed:@"sm_icon@2x.png"] forState:UIControlStateNormal];
    }
    regStatus.layer.borderColor=[[UIColor lightTextColor] CGColor];
    regStatus.userInteractionEnabled=YES;
    regStatus.layer.borderWidth=1.0;
    regStatus.layer.masksToBounds = YES;
    [regStatus.layer setCornerRadius:5.0];
    
    //    [self performSelectorInBackground:@selector(loadImage) withObject:nil];
    //    [self performSelectorInBackground:@selector(loadImage2) withObject:nil];  
    
    [self performSelector:@selector(loadImage) withObject:nil afterDelay:0];
    [self performSelector:@selector(loadImage2) withObject:nil afterDelay:0];
    
    //add annotation to map
    [mapView removeAnnotations:[self.mapView annotations]];
    CLLocationCoordinate2D theCoordinate;
	theCoordinate.latitude = [userInfo.currentLocationLat doubleValue];
    theCoordinate.longitude = [userInfo.currentLocationLng doubleValue];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(theCoordinate, 1000, 1000);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];  
    [self.mapView setRegion:adjustedRegion animated:YES]; 
    
    NSLog(@"lat %lf ",[userInfo.currentLocationLat doubleValue]);
	DDAnnotation *annotation = [[[DDAnnotation alloc] initWithCoordinate:theCoordinate addressDictionary:nil] autorelease];
    
    if (!userInfo.address.city)
    {
        annotation.title =[NSString stringWithFormat:@"Address not found"];
    }
    else 
    {
        annotation.title =[NSString stringWithFormat:@"%@",userInfo.address.city];
    }
	annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
	annotation.subtitle=[NSString stringWithFormat:@"Distance: %.2lfm",userInfo.distance];
	[self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
    [self.mapView addAnnotation:annotation];
    
    
}

-(IBAction)ageButtonAction:(id)sender
{
    NSLog(@"age button");
    entityFlag=1;
    //    [self.view addSubview:statusContainer];
    entityTextField.placeholder=@"My age...";
    entityTextField.text=[NSString stringWithFormat:@"%d",userInfo.age];
    if (userInfo.dateOfBirth) {
        [ActionSheetPicker displayActionPickerWithView:sender dateOfBirthPickerMode:UIDatePickerModeDate selectedDate:userInfo.dateOfBirth target:self action:@selector(dateWasSelected::) title:@"Select date of birth"];
    }
    else 
    {
        [ActionSheetPicker displayActionPickerWithView:sender dateOfBirthPickerMode:UIDatePickerModeDate selectedDate:[NSDate date] target:self action:@selector(dateWasSelected::) title:@"Select date of birth"];
    }
}

-(IBAction)realstsButtonAction:(id)sender
{
    NSLog(@"relsts button");    
    entityFlag=2;
    [self.view addSubview:statusContainer];
    entityTextField.placeholder=@"My relationship status...";
    entityTextField.text=userInfo.relationshipStatus;
}

-(IBAction)liveatButtonAction:(id)sender
{
    NSLog(@"liveat button");    
    entityFlag=3;
    [self.view addSubview:statusContainer];
    entityTextField.placeholder=@"My living city...";
    entityTextField.text=userInfo.address.city;    
}

-(IBAction)workatButtonAction:(id)sender
{
    NSLog(@"work at button");
    entityFlag=4;
    [self.view addSubview:statusContainer];
    entityTextField.placeholder=@"My work place and position...";
    entityTextField.text=userInfo.workStatus;
}


-(IBAction)hideKeyboard:(id)sender
{
    [entityTextField resignFirstResponder];
}

-(void)hideActivity
{
    NSArray* subviews = [NSArray arrayWithArray: self.view.subviews];
    for (UIView* view in subviews) 
    {
        if([view isKindOfClass :[UIActivityIndicatorView class]])
        {
            [view removeFromSuperview];
        }
    }
    
    [smAppDelegate hideActivityViewer];
    NSLog(@"activity removed %@",smAppDelegate);
}

-(void)loadImage
{
    NSAutoreleasePool *pl=[[NSAutoreleasePool alloc] init];
    NSLog(@"userInfo.avatar: %@ userInfo.coverPhoto: %@",userInfo.avatar,userInfo.coverPhoto);
    UIImage *img=[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:userInfo.coverPhoto]]];
    if (img)
    {
        coverImageView.image=img;
    }
    else
    {
        coverImageView.image=[UIImage imageNamed:@"blank.png"];
    }
    
    NSLog(@"image setted after download1. %@",img);
    [pl drain];
}

-(void)loadImage2
{
    NSAutoreleasePool *pl=[[NSAutoreleasePool alloc] init];
    NSLog(@"userInfo.avatar: %@ userInfo.coverPhoto: %@",userInfo.avatar,userInfo.coverPhoto);
    //temp use
    UIImage *img2=[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:userInfo.avatar]]];
    if (img2)
    {
        profileImageView.image=img2;
        fullImageView.image=img2;
    }
    else
    {
        profileImageView.image=[UIImage imageNamed:@"sm_icon@2x.png"];
        fullImageView.image=[UIImage imageNamed:@"sm_icon@2x.png"];
    }
    
    NSLog(@"image setted after download2. %@",img2);    
    [pl drain];
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    //    NSLog(@"did scroll %f",scrollView.contentOffset.y);
//    if (scrollView==profileScrollView)
//    {
//        if (scrollView.contentOffset.y < -60 || (scrollView.contentOffset.y>(newsFeedscrollHeight+60)))
//        {
//            reloadFeedCounter++;
//            if (reloadFeedCounter==1) {
//                NSLog(@"At the top or bottom %f %d",scrollView.contentOffset.y,newsFeedscrollHeight);
//                [smAppDelegate showActivityViewer:self.view];
//                [newsfeedView reload];
//            }
//        }
//    }
//}

//handling map view
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation 
{
	
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;		
	}
	
	static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
	MKAnnotationView *draggablePinView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];
	
	if (draggablePinView) 
    {
		draggablePinView.annotation = annotation;
	}
    else 
    {
		// Use class method to create DDAnnotationView (on iOS 3) or built-in draggble MKPinAnnotationView (on iOS 4).
		draggablePinView = [DDAnnotationView annotationViewWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier mapView:self.mapView];
        
		if ([draggablePinView isKindOfClass:[DDAnnotationView class]]) 
        {
			// draggablePinView is DDAnnotationView on iOS 3.
		} else
        {
			// draggablePinView instance will be built-in draggable MKPinAnnotationView when running on iOS 4.
		}
	}		
	
	return draggablePinView;
}

//lazy scroller

-(void) reloadScrolview
{
    NSLog(@"in scroll init %d",[ImgesName count]);
    NSLog(@"isBackgroundTaskRunning %i",isBackgroundTaskRunning);
    if (isBackgroundTaskRunning==TRUE) 
    {
        NSAutoreleasePool *pl = [[NSAutoreleasePool alloc] init];
        int x=0; //declared for imageview x-axis point    
        
        NSArray* subviews = [NSArray arrayWithArray: userItemScrollView.subviews];
        for (UIView* view in subviews) 
        {
            if([view isKindOfClass :[UIView class]])
            {
                [view removeFromSuperview];
            }
            else if([view isKindOfClass :[UIImageView class]])
            {
                // [view removeFromSuperview];
            }
        }
        userItemScrollView.contentSize=CGSizeMake([ImgesName count]*65, 75);
        for(int i=0; i<[ImgesName count];i++)       
            
        {
            if(i< [ImgesName count]) 
            { 
                UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
                
                UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(x, 0, 65, 75)];
                UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(0, 60, 60, 20)];
                name.textAlignment=UITextAlignmentCenter;
                [name setFont:[UIFont fontWithName:@"Helvetica" size:10]];
                [name setNumberOfLines:0];
                
                [name setText:[nameArr objectAtIndex:i]];
                
                [name setBackgroundColor:[UIColor clearColor]];
                imgView.userInteractionEnabled = YES;           
                imgView.tag = i;
                aView.tag = i;
                imgView.image=[UIImage imageNamed:[ImgesName objectAtIndex:i]];
                imgView.exclusiveTouch = YES;           
                imgView.clipsToBounds = NO;           
                imgView.opaque = YES;   
                imgView.exclusiveTouch = YES;
                imgView.clipsToBounds = NO;
                imgView.opaque = YES;
                imgView.userInteractionEnabled=YES;
                imgView.layer.borderWidth=1.0;
                imgView.layer.masksToBounds = YES;
                [imgView.layer setCornerRadius:5.0];
                [aView addSubview:imgView];
                [aView addSubview:name];
                [userItemScrollView addSubview:aView];
                UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
                tapGesture.numberOfTapsRequired = 1;
                [aView addGestureRecognizer:tapGesture];
                [tapGesture release];  
            }       
            x+=65;   
        }
        [pl drain];
    }
}

-(void)DownLoad:(NSNumber *)path
{
    NSLog(@"in download");
    if (isBackgroundTaskRunning==TRUE) {
        //NSAutoreleasePool *pl = [[NSAutoreleasePool alloc] init];
        int index = [path intValue];
        NSString *Link = [ImgesName objectAtIndex:index];
        //Start download image from url
        UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:Link]]];
        if ((img) && ([dicImages_msg objectForKey:[ImgesName objectAtIndex:index]]==NULL))
        {
            //If download complete, set that image to dictionary
            [dicImages_msg setObject:img forKey:[ImgesName objectAtIndex:index]];
            [self reloadScrolview];
        }
        // Now, we need to reload scroll view to load downloaded image
        //[self performSelectorOnMainThread:@selector(reloadScrolview) withObject:path waitUntilDone:NO];
        //[pl release];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    isDragging_msg = FALSE;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    isDecliring_msg = FALSE;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    isDragging_msg = TRUE;
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    isDecliring_msg = TRUE;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_BASIC_PROFILE_DONE object:nil];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//handling selection from scroll view of friends selection
-(IBAction) handleTapGesture:(UIGestureRecognizer *)sender
{
    int imageIndex =((UITapGestureRecognizer *)sender).view.tag;
    NSArray* subviews = [NSArray arrayWithArray: userItemScrollView.subviews];
    if ([selectedScrollIndex containsObject:[ImgesName objectAtIndex:[sender.view tag]]])
    {
        [selectedScrollIndex removeObject:[ImgesName objectAtIndex:[sender.view tag]]];
        NSLog(@"removed %@",selectedScrollIndex);
    } 
    else 
    {
        [selectedScrollIndex addObject:[ImgesName objectAtIndex:[sender.view tag]]];
        NSLog(@"added %@",selectedScrollIndex);
    }
    for (int l=0; l<[subviews count]; l++)
    {
        UIView *im=[subviews objectAtIndex:l];
        NSArray* subviews1 = [NSArray arrayWithArray: im.subviews];
        UIImageView *im1=[subviews1 objectAtIndex:0];
        [im1 setAlpha:1.0];
        im1.layer.borderWidth=2.0;
        im1.layer.masksToBounds = YES;
        [im1.layer setCornerRadius:7.0];
        
        if ([im1.image isEqual:[UIImage imageNamed:[ImgesName objectAtIndex:imageIndex]]])
        {
            im1.layer.borderColor=[[UIColor greenColor]CGColor];
        }
        else 
        {
            im1.layer.borderColor=[[UIColor grayColor]CGColor];
        }
    }
    if (imageIndex==0) 
    {
        UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"PhotoStoryboard" bundle:nil];
        FriendsPhotosViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"friendsPhotosViewController"];
        controller.userId=userInfo.userId;
        controller.userName=[NSString stringWithFormat:@"%@ %@",userInfo.firstName,userInfo.lastName];
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:controller animated:YES];
    }
    else if (imageIndex==1)
    {       
        FriendListViewController *controller = [[FriendListViewController alloc] initWithNibName:@"FriendListViewController" bundle:nil];
        [controller selectUserId:userInfo.userId];
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:controller animated:YES];
        [controller release];  
    }
    else if (imageIndex==2)
    {
        if (![userInfo.friendshipStatus isEqualToString:@"friend"]) 
        {
            [UtilityClass showAlert:@"" :[NSString stringWithFormat:@"%@ is not in your friend list.",userInfo.firstName]];
        }
        else 
        {
            UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            ViewEventListViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"viewEventList"];
            controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            showFrndsEvents=true;
            [self presentModalViewController:controller animated:YES];            
        }
    }
    else if (imageIndex==3)
    {
        PlaceListViewController *controller = [[PlaceListViewController alloc] initWithNibName:@"PlaceListViewController" bundle:nil];
        controller.otherUserId = userInfo.userId;
        controller.placeType = OtherPeople;
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:controller animated:YES];
        [controller release];
    }
    else if (imageIndex==4)
    {
        if (![userInfo.friendshipStatus isEqualToString:@"friend"]) 
        {
            [UtilityClass showAlert:@"" :[NSString stringWithFormat:@"%@ is not in your friend list.",userInfo.firstName]];
        }
        else 
        {
            MeetUpRequestController *controller = [[MeetUpRequestController alloc] initWithNibName:@"MeetUpRequestController" bundle:nil];
            controller.selectedfriendId = userInfo.userId;
            controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentModalViewController:controller animated:YES];
            [controller release];
        }
    }
    else if (imageIndex==5)
    {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"PlanStoryboard" bundle:nil];
        FriendsPlanListViewController* initialHelpView = [storyboard instantiateViewControllerWithIdentifier:@"friendsPlanListViewController"];    
        initialHelpView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        initialHelpView.userInfo=userInfo;
        [self presentModalViewController:initialHelpView animated:YES];
    }
}

- (void) showPinOnMapView:(Place*)place 
{
    [self.presentingViewController performSelector:@selector(showPinOnMapView:) withObject:place];
    [self dismissModalViewControllerAnimated:NO];
}

- (void) showPinOnMapViewPlan:(Plan *)plan 
{
    //UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"PlanStoryboard" bundle:nil];
    //FriendsPlanListViewController* initialHelpView = [storyboard instantiateViewControllerWithIdentifier:@"friendsPlanListViewController"]; 
    if (profileFromList==TRUE)
    {
        NSLog(@"profile from list %@",plan);        
        [self.presentingViewController performSelector:@selector(showPinOnMapViewPlan:) withObject:plan];
        [self performSelector:@selector(dismissModalView) withObject:nil afterDelay:.8];
    }
    else
    {
        NSLog(@"profile from map %@",plan);        
        [self.presentingViewController performSelector:@selector(showPinOnMapViewForPlan:) withObject:plan];
        [self performSelector:@selector(dismissModalView) withObject:nil afterDelay:.3];
    }

}

- (void) dismissModalView
{
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dateWasSelected:(NSDate *)selectedDate:(id)element 
{
    isDirtyFrnd=TRUE;
    userInfo.dateOfBirth=selectedDate;
    ageLabel.text=[NSString stringWithFormat:@"%d",[UtilityClass getAgeFromBirthday:selectedDate]];
}

-(IBAction)sendMsg:(id)sender
{
    if (([textViewNewMsg.text isEqualToString:@""]) ||([textViewNewMsg.text isEqualToString:@"Your message..."]))
    {
        [UtilityClass showAlert:@"Social Maps" :@"Enter message"];
    }
    else {
        
        NSMutableArray *userIDs=[[NSMutableArray alloc] init];
        NSString *userId = userInfo.userId;
        [userIDs addObject:userId];
        NSLog(@"user id %@", userInfo.userId);
        [userIDs addObject:userId];
        RestClient *restClient = [[[RestClient alloc] init] autorelease];
        [restClient sendMessage:[NSString stringWithFormat:@"Message from %@ %@",userInfo.lastName,userInfo.firstName] content:textViewNewMsg.text recipients:userIDs authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
        [textViewNewMsg resignFirstResponder];
        [msgView resignFirstResponder];
        [textViewNewMsg resignFirstResponder];
        [msgView removeFromSuperview];
    }
}

-(IBAction)cancelMsg:(id)sender
{
    [textViewNewMsg resignFirstResponder];
    [msgView removeFromSuperview];
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (!(textView.textColor == [UIColor blackColor])) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    return YES;
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (!(textView.textColor == [UIColor lightGrayColor])) {
        textView.text = @"Your message...";
        textView.textColor = [UIColor lightGrayColor];
    }
}

@end

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
#import "NotifMessage.h"
#import "MessageListViewController.h"
#import "UserBasicProfileViewController.h"
#import "NSData+Base64.h"

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

@synthesize newsfeedImgView;
@synthesize newsfeedImgFullView;
@synthesize activeDownload;
@synthesize newsFeedImageIndicator;

AppDelegate *smAppDelegate;
RestClient *rc;
UserInfo *userInfo;
NSMutableArray *nameArr;
BOOL coverImgFlag;
BOOL isDirtyFrnd=FALSE;
NSMutableArray *selectedScrollIndex, *iconArray;
UIImageView *lineView;
int newsFeedscrollHeight,reloadFeedCounter=0, reloadFrndsProfileCounter=0;

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
    UITapGestureRecognizer *zoomTapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToZoomView:)];
    zoomTapGesture.numberOfTapsRequired = 1;
    [profileImageView addGestureRecognizer:zoomTapGesture];
    [zoomTapGesture release];
    
    [statusMsgLabel.layer setCornerRadius:3.0f];
    [addressOrvenueLabel.layer setCornerRadius:3.0f];
    [distanceLabel.layer setCornerRadius:3.0f];
    selectedScrollIndex=[[NSMutableArray alloc] init];
    photoPicker = [[[PhotoPicker alloc] initWithNibName:nil bundle:nil] autorelease];
    photoPicker.delegate = self;
    picSel = [[UIImagePickerController alloc] init];
	picSel.allowsEditing = YES;
	picSel.delegate = self;
    
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
    [smAppDelegate.window setUserInteractionEnabled:NO];
    isBackgroundTaskRunning=TRUE;
    rc=[[RestClient alloc] init];
    userInfo=[[UserInfo alloc] init];
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    ODRefreshControl *refreshControl = [[[ODRefreshControl alloc] initInScrollView:profileScrollView] autorelease];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
    NSLog(@"friendsId: %@",friendsId);
    nameArr=[[NSMutableArray alloc] init];
    ImgesName=[[NSMutableArray alloc] init];
    nameArr=[[NSMutableArray alloc] initWithObjects:@"Photos",@"Friends",@"Events",@"Places", nil];
    [ImgesName addObject:@"photos_icon"];
    [ImgesName addObject:@"friends_icon"];
    [ImgesName addObject:@"events_icon"];
    [ImgesName addObject:@"places_icon"];
    
    iconArray=[[NSMutableArray alloc] initWithObjects:@"photos_icon_small.png",@"friends_icon_small.png",@"events_icon_small.png",@"icon_48x48.png",@"icon_meetup_new.png",@"photos_icon_small.png", nil];
    
    userItemScrollView.delegate = self;
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
    [newsfeedImgFullView removeFromSuperview];
    profileImageView.layer.borderColor=[[UIColor lightTextColor] CGColor];
    profileImageView.userInteractionEnabled=YES;
    profileImageView.layer.borderWidth=1.0;
    profileImageView.layer.masksToBounds = YES;
    [profileImageView.layer setCornerRadius:5.0];
    [self displayNotificationCount];
    smAppDelegate.currentModelViewController = self;
    
    [smAppDelegate showActivityViewer:self.view];
    [rc getOtherUserProfile:@"Auth-Token":smAppDelegate.authToken:friendsId];
    
    NSString *urlStr=[NSString stringWithFormat:@"%@/%@/newsfeed.html?authToken=%@&r=%@",WS_URL,friendsId,smAppDelegate.authToken,[UtilityClass convertNSDateToUnix:[NSDate date]]];
    NSLog(@"urlStr %@",urlStr);
    [friendsId retain];
    [newsfeedView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    reloadFrndsProfileCounter=0;
    [frndStatusButton setHidden:YES];
    
    [profileView setFrame:CGRectMake(0, 0, profileView.frame.size.width, profileView.frame.size.height)];
    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(150, profileView.frame.size.height+5, 20, 20)];
    [indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [indicator setTag:123123123];
    [indicator startAnimating];
    [profileScrollView setContentSize:CGSizeMake(320, profileView.frame.size.height+30)];
    [profileScrollView addSubview:indicator];
    [profileScrollView addSubview:profileView];
    [self reloadScrolview];
    [indicator release];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self displayNotificationCount];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getOtherUserProfileDone:) name:NOTIF_GET_OTHER_USER_PROFILE_DONE object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_OTHER_USER_PROFILE_DONE object:nil];
    
    [super viewDidDisappear:animated];
}

-(void)reloadProfileScrollView
{
    [[profileScrollView viewWithTag:123123123] removeFromSuperview];
    [profileView removeFromSuperview];
    [newsfeedView removeFromSuperview];
    [profileView setFrame:CGRectMake(0, 0, profileView.frame.size.width, profileView.frame.size.height)];
    [profileScrollView setContentSize:CGSizeMake(320, profileView.frame.size.height+newsfeedView.frame.size.height)];
    newsFeedscrollHeight=newsfeedView.frame.size.height;
    [profileScrollView addSubview:profileView];
    [profileScrollView addSubview:newsfeedView];
}

-(IBAction)closeNewsfeedImgView:(id)sender
{
    CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];	
	[[self.view layer] addAnimation:animation forKey:@"layerAnimation"];
    [newsFeedImageIndicator stopAnimating];
    [newsfeedImgFullView removeFromSuperview];
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
    
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[self.view layer] addAnimation:animation forKey:@"layerAnimation"];
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
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [webView stopLoading];
        NSString *dataStr=[[request URL] absoluteString];
        NSLog(@"Data String: %@",dataStr);
        NSString *tagStr=[[dataStr componentsSeparatedByString:@":"] objectAtIndex:2];
        NSLog(@"Tag String: %@",tagStr);
        if ([tagStr isEqualToString:@"image"])
        {
            NSString *urlStr=[NSString stringWithFormat:@"%@:%@",[[dataStr componentsSeparatedByString:@":"] objectAtIndex:3],[[dataStr componentsSeparatedByString:@":"] objectAtIndex:4]];
            CGFloat xpos = self.view.frame.origin.x;
            CGFloat ypos = self.view.frame.origin.y;
            newsfeedImgFullView.frame = CGRectMake(xpos+100,ypos+150,5,5);
            [UIView beginAnimations:@"Zoom" context:NULL];
            [UIView setAnimationDuration:0.8];
            newsfeedImgFullView.frame = CGRectMake(xpos, ypos-20, 320, 460);
            [UIView commitAnimations];
            [newsfeedImgView setImage:[UIImage imageNamed:@"sm_icon@2x.png"]];
            [self.view addSubview:newsfeedImgFullView];
            [newsFeedImageIndicator startAnimating];
            [self performSelectorInBackground:@selector(loadNewsFeedImage:) withObject:urlStr];
        }
        else if ([tagStr isEqualToString:@"profile"])
        {
            NSString *userId=[[dataStr componentsSeparatedByString:@":"] objectAtIndex:3];
            NSLog(@"userID string: %@",userId);
            if ([userId isEqualToString:smAppDelegate.userId])
            {
                NSLog(@"own profile");
                UserBasicProfileViewController *controller =[[UserBasicProfileViewController alloc] init];
                controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentModalViewController:controller animated:YES];
                [controller release];

            }
            else if([userId isEqualToString:userInfo.userId])
            {
                NSLog(@"same profile");
            }
            else
            {
                FriendsProfileViewController *controller =[[FriendsProfileViewController alloc] init];
                controller.friendsId=userId;
                controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentModalViewController:controller animated:YES];
                [controller release];
            }
        }
        else if ([tagStr isEqualToString:@"geotag"])
        {
            NSString *userId=[[dataStr componentsSeparatedByString:@":"] objectAtIndex:3];
            NSLog(@"geotag string: %@",userId);
        }
        else if ([tagStr isEqualToString:@"expand"])
        {
            [self performSelector:@selector(reloadProfileScrollView) withObject:nil afterDelay:3.0];
        }
        return NO;
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

-(void)loadNewsFeedImage:(NSString *)imageUrlStr
{
    [[newsfeedImgFullView viewWithTag:12345654] removeFromSuperview];
    NSLog(@"from dic %@",[dicImages_msg objectForKey:imageUrlStr]);
    if ([dicImages_msg objectForKey:imageUrlStr])
    {
        newsfeedImgView.image=[dicImages_msg objectForKey:imageUrlStr];
        NSLog(@"load from dic");
    }
    else
    {
        NSLog(@"newsfeed image url: %@",imageUrlStr);
        UIImage *img=[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrlStr]]];
        if (img)
        {
            newsfeedImgView.image=img;
            [dicImages_msg setObject:img forKey:imageUrlStr];
        }
        else
        {
            newsfeedImgView.image=[UIImage imageNamed:@"blank.png"];
        }
        [img release];
        NSLog(@"image setted after download newsfeed image. %@",img);
    }
}

-(IBAction)friendRequestButton:(id)sender
{
    if ([userInfo.friendshipStatus isEqualToString:@"friend"]) 
    {
        [UtilityClass showAlert:@"" :[NSString stringWithFormat:@"%@ is already your friend.",userInfo.firstName]];
    }
    else
    {
        RestClient *restClient = [[[RestClient alloc] init] autorelease];
        [restClient sendFriendRequest:userInfo.userId message:@"" authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
        [addFrndButton setTitle:@"Requested..." forState:UIControlStateNormal];
        [addFrndButton setEnabled:NO];
        [frndStatusButton setHidden:YES];
    }
}

-(IBAction)uploadPhotoButton:(id)sender
{
    if (![userInfo.friendshipStatus isEqualToString:@"friend"]) 
    {
        [UtilityClass showAlert:@"" :[NSString stringWithFormat:@"%@ is not in your friend list.",userInfo.firstName]];
    }
    else
    {        
        NSLog(@"meet up request");
        MeetUpRequestController *controller = [[MeetUpRequestController alloc] initWithNibName:@"MeetUpRequestController" bundle:nil];
        controller.selectedfriendId = userInfo.userId;
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:controller animated:YES];
        [controller release];
    }
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
    // Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[self.view layer] addAnimation:animation forKey:@"layerAnimation"];

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
    NotifMessage *notifMessage = [[NotifMessage alloc] init];
    notifMessage.notifID = @"NewMsg";
    notifMessage.notifSenderId = userInfo.userId;
    NSLog(@"receipient id = %@", notifMessage.notifSenderId);
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    MessageListViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"messageList"];
    controller.selectedMessage = notifMessage;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
    [self presentModalViewController:nav animated:YES];
    nav.navigationBarHidden = YES;
    [notifMessage release];

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
    if ([notif.object isKindOfClass:[UserInfo class]]) {
    NSLog(@"GOT SERVICE DATA FRIENDS Profile.. :D  %@",[notif object]);
    [self performSelector:@selector(hideActivity) withObject:nil afterDelay:1.0];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    userInfo=[notif object];
    nameLabl.text=[NSString stringWithFormat:@" %@ %@",userInfo.firstName,userInfo.lastName];
    statusMsgLabel.text=@"";
    addressOrvenueLabel.text=userInfo.address.street;
        Geolocation *geoLocation=[[Geolocation alloc] init];
        geoLocation.latitude=userInfo.currentLocationLat;
        geoLocation.longitude=userInfo.currentLocationLng;
        distanceLabel.text=[UtilityClass getDistanceWithFormattingFromLocation:geoLocation];
        
        if (userInfo) {
            
            if (![userInfo.friendshipStatus isEqualToString:@"friend"])
            {
                meetUpButton.hidden = YES;
                meetUpImageView.hidden = YES;
            }
            
            for (LocationItemPeople *locationItemPeople in smAppDelegate.peopleList)
            {
                if ([locationItemPeople.userInfo.userId isEqualToString:userInfo.userId] && !locationItemPeople.userInfo.external) {
                    UIImageView *imageViewIsOnline = [[UIImageView alloc] initWithFrame:CGRectMake(profileImageView.frame.size.width - 20, profileImageView.frame.size.height - 20, 14, 14)];
                    if (locationItemPeople.userInfo.isOnline) {
                        NSArray *imageArray = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"online_dot.png"], [UIImage imageNamed:@"blank.png"], nil];
                        imageViewIsOnline.animationDuration = 2;
                        imageViewIsOnline.animationImages = imageArray;
                        [imageViewIsOnline startAnimating];
                        [imageArray release];
                        
                    } else {
                        imageViewIsOnline.image = [UIImage imageNamed:@"offline_dot.png"];
                        
                    }
                    [profileImageView addSubview:imageViewIsOnline];
                    [imageViewIsOnline release];
                    break;
                }
            }   
        }
    
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
        [regStatus setImage:[UIImage imageNamed:@"transparent_icon.png"] forState:UIControlStateNormal];
    }
    else
    {
        [regStatus setImage:[UIImage imageNamed:@"transparent_icon.png"] forState:UIControlStateNormal];
    }
    regStatus.layer.borderColor=[[UIColor lightTextColor] CGColor];
    regStatus.userInteractionEnabled=YES;
    regStatus.layer.borderWidth=1.0;
    regStatus.layer.masksToBounds = YES;
    [regStatus.layer setCornerRadius:5.0];
    
    [self performSelectorInBackground:@selector(loadImage) withObject:nil];
    [self performSelectorInBackground:@selector(loadImage2) withObject:nil];  
    
    //add annotation to map
    [mapView removeAnnotations:[self.mapView annotations]];
    mapContainer.layer.borderColor=[[UIColor lightTextColor] CGColor];
    mapContainer.userInteractionEnabled=YES;
    mapContainer.layer.borderWidth=1.0;
    mapContainer.layer.masksToBounds = YES;
    [mapContainer.layer setCornerRadius:5.0];

    CLLocationCoordinate2D theCoordinate;
	theCoordinate.latitude = [userInfo.currentLocationLat doubleValue];
    theCoordinate.longitude = [userInfo.currentLocationLng doubleValue];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(theCoordinate, 1000, 1000);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];  
    [self.mapView setRegion:adjustedRegion animated:YES]; 
    
    NSLog(@"lat %lf ",[userInfo.currentLocationLat doubleValue]);
	DDAnnotation *annotation = [[[DDAnnotation alloc] initWithCoordinate:theCoordinate addressDictionary:nil] autorelease];
        [geoLocation release];
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
        [addFrndButton setTitle:userInfo.friendshipStatus forState:UIControlStateNormal];
        [addFrndButton setUserInteractionEnabled:NO];
        NSString *friendShipStatus=userInfo.friendshipStatus;
        if ([friendShipStatus isEqualToString:@"rejected_by_me"] || [friendShipStatus isEqualToString:@"rejected_by_him"]) {
            [addFrndButton setTitle:@"Rejected" forState:UIControlStateNormal];
            [addFrndButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [addFrndButton setBackgroundImage:[UIImage imageNamed:@"btn_bg_light_small.png"] forState:UIControlStateNormal];
            addFrndButton.enabled = NO;
            [frndStatusButton setHidden:YES];
        } else if ([friendShipStatus isEqualToString:@"requested"]) {
            [addFrndButton setBackgroundImage:[UIImage imageNamed:@"btn_bg_light_small.png"] forState:UIControlStateNormal];
            [addFrndButton setTitle:@"Requested" forState:UIControlStateNormal];
            addFrndButton.enabled = NO;
            [frndStatusButton setHidden:YES];
        } else if ([friendShipStatus isEqualToString:@"pending"]) {
            [addFrndButton setTitle:@"Pending" forState:UIControlStateNormal];
            [addFrndButton setBackgroundImage:[UIImage imageNamed:@"btn_bg_light_small.png"] forState:UIControlStateNormal];
            addFrndButton.enabled = NO;
            [frndStatusButton setHidden:YES];
        }
        else if ([friendShipStatus isEqualToString:@"friend"]) {
            [addFrndButton setTitle:@"Friend" forState:UIControlStateNormal];
            [addFrndButton setBackgroundImage:[UIImage imageNamed:@"btn_bg_light_small.png"] forState:UIControlStateNormal];
            addFrndButton.enabled = NO;
            [frndStatusButton setHidden:NO];
        }
    }
    
    [userInfo retain];
    }
    else
    {
        if (reloadFrndsProfileCounter==0)
        {
            [self showConfirmBox];
        }
    }
    reloadFrndsProfileCounter++;
}

-(void)showConfirmBox
{    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Socialmaps" 
                                                    message:[NSString stringWithFormat:@"Network problem, reload?"]  
                                                   delegate:self 
                                          cancelButtonTitle:@"Yes"
                                          otherButtonTitles:@"No", nil];
    [alert show];
    [alert release];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"button Index %d",buttonIndex);
    if (buttonIndex==0)
    {
        [smAppDelegate showActivityViewer:self.view];
        [rc getOtherUserProfile:@"Auth-Token":smAppDelegate.authToken:friendsId];
    }
    else
    {
        [smAppDelegate hideActivityViewer];
        [smAppDelegate.window setUserInteractionEnabled:YES];
        [self dismissModalViewControllerAnimated:YES];
    }
    reloadFrndsProfileCounter=0;
}

- (void)getBasicProfileDone:(NSNotification *)notif
{
    NSLog(@"GOT SERVICE DATA BASIC Profile.. :D  %@",[notif object]);
    [self performSelector:@selector(hideActivity) withObject:nil afterDelay:1.0];
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
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
        [regStatus setImage:[UIImage imageNamed:@"transparent_icon.png"] forState:UIControlStateNormal];
    }
    else
    {
        [regStatus setImage:[UIImage imageNamed:@"transparent_icon.png"] forState:UIControlStateNormal];
    }
    regStatus.layer.borderColor=[[UIColor lightTextColor] CGColor];
    regStatus.userInteractionEnabled=YES;
    regStatus.layer.borderWidth=1.0;
    regStatus.layer.masksToBounds = YES;
    [regStatus.layer setCornerRadius:5.0];
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
	annotation.subtitle=[NSString stringWithFormat:@"Distance: %.2dm",userInfo.distance];
	[self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
    [self.mapView addAnnotation:annotation];
    
    
}

-(IBAction)ageButtonAction:(id)sender
{
    NSLog(@"age button");
    entityFlag=1;
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
    if ([dicImages_msg objectForKey:userInfo.coverPhoto])
    {
        coverImageView.image=[dicImages_msg objectForKey:userInfo.coverPhoto];
    }
    else
    {
        NSLog(@"userInfo.avatar: %@ userInfo.coverPhoto: %@",userInfo.avatar,userInfo.coverPhoto);
        UIImage *img=[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:userInfo.coverPhoto]]];
        if (img)
        {
            coverImageView.image=img;
            if (img && userInfo.coverPhoto)
            {
                [dicImages_msg setObject:img forKey:userInfo.coverPhoto];                
            }
        }
        else
        {
            coverImageView.image=[UIImage imageNamed:@"blank.png"];
        }
        
        NSLog(@"image setted after download1. %@",img);
        [img release];
    }
}

-(void)loadImage2
{
    if ([dicImages_msg objectForKey:userInfo.avatar])
    {
        profileImageView.image=[dicImages_msg objectForKey:userInfo.avatar];
        fullImageView.image=[dicImages_msg objectForKey:userInfo.avatar];
    }
    else
    {
        NSLog(@"userInfo.avatar: %@ userInfo.coverPhoto: %@",userInfo.avatar,userInfo.coverPhoto);
        //temp use
        UIImage *img2=[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:userInfo.avatar]]];
        if (img2)
        {
            profileImageView.image=img2;
            fullImageView.image=img2;
            if (img2 && userInfo.avatar)
            [dicImages_msg setObject:img2 forKey:userInfo.avatar];
        }
        else
        {
            fullImageView.image=[UIImage imageNamed:@"sm_icon@2x.png"];
            profileImageView.image=[UIImage imageNamed:@"sm_icon@2x.png"];
        }
        
        NSLog(@"image setted after download2. %@",img2);
        [img2 release];
    }
}


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
        int x = 28; //declared for imageview x-axis point
        
        NSArray* subviews = [NSArray arrayWithArray: userItemScrollView.subviews];
        for (UIView* view in subviews) 
        {
            if([view isKindOfClass :[UIView class]])
            {
                [view removeFromSuperview];
            }
            else if([view isKindOfClass :[UIImageView class]])
            {
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
                imgView.contentMode=UIViewContentModeScaleAspectFit;
                imgView.layer.borderWidth=1.0;
                imgView.layer.masksToBounds = YES;
                [imgView.layer setCornerRadius:5.0];
                imgView.layer.borderColor=[[UIColor lightTextColor]CGColor];
                UIImageView *iconview=[[UIImageView alloc] initWithFrame:CGRectMake(5, 42, 15, 15)];
                iconview.contentMode=UIViewContentModeScaleAspectFit;                
                [iconview setImage:[UIImage imageNamed:[iconArray objectAtIndex:i]]];
                [aView addSubview:imgView];
                [aView addSubview:iconview];
                [aView addSubview:name];
                [userItemScrollView addSubview:aView];
                UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
                tapGesture.numberOfTapsRequired = 1;
                [aView addGestureRecognizer:tapGesture];
                [tapGesture release];
                [aView release];
                [name release];
                [iconview release];
                [imgView release];
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
        int index = [path intValue];
        NSString *Link = [ImgesName objectAtIndex:index];
        //Start download image from url
        UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:Link]]];
        if ((img) && ([dicImages_msg objectForKey:[ImgesName objectAtIndex:index]]==NULL))
        {
            [self reloadScrolview];
        }
        // Now, we need to reload scroll view to load downloaded image
        [img release];
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
    [buttonZoomView release];
    buttonZoomView = nil;
    [meetUpImageView release];
    meetUpImageView = nil;
    [super viewDidUnload];
    
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
        im1.layer.borderWidth=1.0;
        im1.layer.masksToBounds = YES;
        [im1.layer setCornerRadius:7.0];
        
        if ([im1.image isEqual:[UIImage imageNamed:[ImgesName objectAtIndex:imageIndex]]])
        {
            im1.layer.borderColor=[[UIColor greenColor]CGColor];
        }
        else 
        {
            im1.layer.borderColor=[[UIColor lightTextColor]CGColor];
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
        controller.labelUserName.text = [NSString stringWithFormat:@"%@'s friend list ", userInfo.firstName];
        [controller release];  
    }
    else if (imageIndex==2)
    {
        /*if (![userInfo.friendshipStatus isEqualToString:@"friend"])
        {
            [UtilityClass showAlert:@"" :[NSString stringWithFormat:@"%@ is not in your friend list.",userInfo.firstName]];
        }
        else*/ 
        {
            UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            ViewEventListViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"viewEventList"];
            controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            showFrndsEvents=true;
            controller.userInfo = userInfo;
            [self presentModalViewController:controller animated:YES];            
        }
    }
    else if (imageIndex==3)
    {
        PlaceListViewController *controller = [[PlaceListViewController alloc] initWithNibName:@"PlaceListViewController" bundle:nil];
        controller.otherUserId = userInfo.userId;
        controller.placeType = OtherPeople;
        controller.userName = userInfo.firstName;
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
        [userIDs release];
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

- (void)dealloc {
    [buttonZoomView release];
    [meetUpImageView release];
    [super dealloc];
}
@end

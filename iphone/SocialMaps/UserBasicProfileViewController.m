//
//  UserBasicProfileViewController.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 9/11/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UserBasicProfileViewController.h"
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
#import "PlaceListViewController.h"
#import "FriendListViewController.h"
#import "Globals.h"
#import "ODRefreshControl.h"
#import "FriendsProfileViewController.h"
#import "NSData+Base64.h"

@interface UserBasicProfileViewController ()

@end

@implementation UserBasicProfileViewController

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
@synthesize totalNotifCount,lastSeenat,nameButton,newsfeedView,newsFeedImageIndicator;
@synthesize profileView,profileScrollView,zoomView,fullImageView,newsfeedImgView,newsfeedImgFullView,activeDownload;

AppDelegate *smAppDelegate;
RestClient *rc;
UserInfo *userInfo;
NSMutableArray *nameArr;
BOOL coverImgFlag;
BOOL isDirty=FALSE;
NSMutableArray *selectedScrollIndex, *iconArray;
UIImageView *lineView;
int scrollHeight,reloadCounter=0, reloadProfileCounter=0;

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
    [self displayNotificationCount];
    photoPicker = [[PhotoPicker alloc] initWithNibName:nil bundle:nil];
    photoPicker.delegate = self;
    picSel = [[UIImagePickerController alloc] init];
	picSel.allowsEditing = YES;
	picSel.delegate = self;
    nameButton.titleLabel.layer.shadowRadius = 5.0f;
    nameButton.titleLabel.layer.shadowOpacity = .9;
    nameButton.titleLabel.layer.shadowOffset = CGSizeZero;
    nameButton.titleLabel.layer.masksToBounds = NO;

    statusMsgLabel.layer.shadowRadius = 5.0f;
    statusMsgLabel.layer.shadowOpacity = .9;
    statusMsgLabel.layer.shadowOffset = CGSizeZero;
    statusMsgLabel.layer.masksToBounds = NO;

    [smAppDelegate showActivityViewer:self.view];
    [smAppDelegate.window setUserInteractionEnabled:NO];
    isBackgroundTaskRunning=TRUE;
    rc=[[RestClient alloc] init];
    userInfo=[[UserInfo alloc] init];
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBasicProfileDone:) name:NOTIF_GET_BASIC_PROFILE_DONE object:nil];    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBasicProfileDone:) name:NOTIF_UPDATE_BASIC_PROFILE_DONE object:nil];
    
    [rc getUserProfile:@"Auth-Token":smAppDelegate.authToken];
    nameArr=[[NSMutableArray alloc] init];
    ImgesName=[[NSMutableArray alloc] init];
    ODRefreshControl *refreshControl = [[[ODRefreshControl alloc] initInScrollView:profileScrollView] autorelease];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    nameArr=[[NSMutableArray alloc] initWithObjects:@"Photos",@"Friends",@"Events",@"Places",@"Meet-up",@"Plan", nil];
    [ImgesName addObject:@"photos_icon"];
    [ImgesName addObject:@"friends_icon"];
    [ImgesName addObject:@"events_icon"];
    [ImgesName addObject:@"places_icon"];
    [ImgesName addObject:@"meet_up_icon"];
    [ImgesName addObject:@"sm_icon@2x"];
    
    iconArray=[[NSMutableArray alloc] initWithObjects:@"photos_icon_small.png",@"friends_icon_small.png",@"events_icon_small.png",@"icon_48x48.png",@"icon_meetup_new.png",@"photos_icon_small.png", nil];
    
    userItemScrollView.delegate = self;
    lineView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line.png"]];
    lineView.frame=CGRectMake(10, profileView.frame.size.height, 300, 1);
    reloadProfileCounter=0;
    
    [profileView setFrame:CGRectMake(0, 0, profileView.frame.size.width, profileView.frame.size.height)];
    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(150, profileView.frame.size.height, 20, 20)];
    [indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [indicator setTag:123123123];
    [indicator startAnimating];
    [profileScrollView setContentSize:CGSizeMake(320, profileView.frame.size.height+30)];
    [profileScrollView addSubview:indicator];
    [profileScrollView addSubview:profileView];
    [self reloadScrolview];
    [indicator release];
}

-(void)reloadProfileScrollView
{
    [[profileScrollView viewWithTag:123123123] removeFromSuperview];
    [profileView removeFromSuperview];
    [newsfeedView removeFromSuperview];
    [profileView setFrame:CGRectMake(0, 0, profileView.frame.size.width, profileView.frame.size.height)];
    [profileScrollView setContentSize:CGSizeMake(320, profileView.frame.size.height+newsfeedView.frame.size.height)];
    scrollHeight=newsfeedView.frame.size.height;
    [profileScrollView addSubview:profileView];
    [profileScrollView addSubview:newsfeedView];
    [profileView addSubview:lineView];
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
    [newsfeedImgFullView removeFromSuperview];
    [zoomView removeFromSuperview];
    NSString *urlStr=[NSString stringWithFormat:@"%@/%@/newsfeed.html?authToken=%@&t=%@",WS_URL,smAppDelegate.userId,smAppDelegate.authToken,[UtilityClass convertNSDateToUnix:[NSDate date]]];
    NSLog(@"urlStr %@",urlStr);
    
    [newsfeedView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    profileImageView.layer.borderColor=[[UIColor lightTextColor] CGColor];
    profileImageView.userInteractionEnabled=YES;
    profileImageView.layer.borderWidth=1.0;
    profileImageView.layer.masksToBounds = YES;
    [profileImageView.layer setCornerRadius:5.0];
    [self displayNotificationCount];
    
    smAppDelegate.currentModelViewController = self;

}

#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Set appIcon with activeDownload and clear temporary data/image

}

-(IBAction)editCoverButton:(id)sender
{
    isDirty=TRUE;
    coverImgFlag=TRUE;
    [self.photoPicker getPhoto:self];
    [self.entityTextField resignFirstResponder];
}

-(IBAction)editProfilePicButton:(id)sender
{
    isDirty=TRUE;
    coverImgFlag=FALSE;
    [self.photoPicker getPhoto:self];
    [self.entityTextField resignFirstResponder];    
}

-(IBAction)editStatusButton:(id)sender
{
    CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[self.view layer] addAnimation:animation forKey:@"layerAnimation"];

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

-(IBAction)geotagButton:(id)sender
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"GeoTagStoryboard" bundle:nil];
    UIViewController* initialHelpView = [storyboard instantiateViewControllerWithIdentifier:@"createGeotag"];
    
    initialHelpView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:initialHelpView animated:YES];
}

-(IBAction)uploadPhotoButton:(id)sender
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"PhotoStoryboard" bundle:nil];
    UIViewController* initialHelpView = [storyboard instantiateViewControllerWithIdentifier:@"myPhotosViewController"];
    
    initialHelpView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:initialHelpView animated:YES];
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
    // Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[self.view layer] addAnimation:animation forKey:@"layerAnimation"];
    isDirty=TRUE;
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
    if (entityFlag==5)
    {
        [nameButton setTitle:entityTextField.text forState:UIControlStateNormal];
        userInfo.firstName=entityTextField.text;                
    }    

}

-(IBAction)cancelEntity:(id)sender
{
    // Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[self.view layer] addAnimation:animation forKey:@"layerAnimation"];

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

-(void) displayNotificationCount {
    int totalNotif= [UtilityClass getNotificationCount];
    if (totalNotif == 0)
        totalNotifCount.text = @"";
    else
        totalNotifCount.text = [NSString stringWithFormat:@"%d",totalNotif];
}

-(IBAction)goToZoomView:(id)sender;
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

-(IBAction)closeZoomView:(id)sender
{
    CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];	
	[[self.view layer] addAnimation:animation forKey:@"layerAnimation"];
    [zoomView removeFromSuperview];
}


- (void) photoPickerDone:(bool)status image:(UIImage*)img
{
    NSLog(@"PersonalInformation:photoPickerDone, status=%d", status);
    if (coverImgFlag==TRUE) {
        if (status == TRUE) 
        {
            [coverImageView setImage:img];
            //NSData *imgdata = UIImagePNGRepresentation(img);
            NSData *imgdata = UIImageJPEGRepresentation(img, 0.6);
            NSString *imgBase64Data = [imgdata base64EncodedString];
            userInfo.coverPhoto=imgBase64Data;
        } 
    }
    else
    {
        if (status == TRUE) 
        {
            [profileImageView setImage:img];
            //NSData *imgdata = UIImagePNGRepresentation(img);
            NSData *imgdata = UIImageJPEGRepresentation(img, 0.6);
            NSString *imgBase64Data = [imgdata base64EncodedString];
            userInfo.avatar=imgBase64Data;
        } 
    }
    [photoPicker.view removeFromSuperview];
}

-(IBAction)closeNewsfeedImgView:(id)sender
{
    CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];	
	[[self.view layer] addAnimation:animation forKey:@"layerAnimation"];
    [newsFeedImageIndicator stopAnimating];
    [newsfeedImgFullView removeFromSuperview];
}

-(IBAction)backButton:(id)sender
{
    NSLog(@"isDirty %i",[[NSNumber numberWithBool:isDirty] intValue]);
    if (isDirty==FALSE) 
    {
        [self dismissModalViewControllerAnimated:YES];
    }
    else if(isDirty==TRUE)
    {
        [self.entityTextField resignFirstResponder];
        [smAppDelegate showActivityViewer:self.view];
        [smAppDelegate.window setUserInteractionEnabled:NO];
        [rc updateUserProfile:userInfo:@"Auth-Token":smAppDelegate.authToken];
    }
}

- (void)getBasicProfileDone:(NSNotification *)notif
{
    if ([notif.object isKindOfClass:[UserInfo class]]) {
        NSLog(@"GOT SERVICE DATA BASIC Profile.. :D  %@",[notif object]);
        [smAppDelegate hideActivityViewer];
        [smAppDelegate.window setUserInteractionEnabled:YES];
        userInfo=[notif object];
        nameLabl.text=[NSString stringWithFormat:@" %@",userInfo.userFirstName];
        [nameButton setTitle:[NSString stringWithFormat:@" %@",userInfo.userFirstName] forState:UIControlStateNormal];
        statusMsgLabel.text=@"";
        
        addressOrvenueLabel.text=userInfo.address.street;
        distanceLabel.text=@"";
        if (userInfo.age>0) {
            ageLabel.text=[NSString stringWithFormat:@"%d",userInfo.age];
        }
        else {
            ageLabel.text=@"Not found";
        }
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
        
        [self performSelectorInBackground:@selector(loadImage) withObject:nil];
        [self performSelectorInBackground:@selector(loadImage2) withObject:nil];  
        
        //add annotation to map
        [mapView removeAnnotations:[self.mapView annotations]];
        CLLocationCoordinate2D theCoordinate;
        theCoordinate.latitude = [userInfo.currentLocationLat doubleValue];
        theCoordinate.longitude = [userInfo.currentLocationLng doubleValue];
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(theCoordinate, 1000, 1000);
        MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];  
        [self.mapView setRegion:adjustedRegion animated:YES]; 
        mapContainer.layer.borderColor=[[UIColor lightTextColor] CGColor];
        mapContainer.userInteractionEnabled=YES;
        mapContainer.layer.borderWidth=1.0;
        mapContainer.layer.masksToBounds = YES;
        [mapContainer.layer setCornerRadius:5.0];

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
        if (CLLocationCoordinate2DIsValid(annotation.coordinate))
        {
            [self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
            [self.mapView addAnnotation:annotation];        
        }
    }
    else
    {
        if (reloadProfileCounter==0)
        {
            [smAppDelegate hideActivityViewer];
            [smAppDelegate.window setUserInteractionEnabled:YES];
            [self showConfirmBox];
        }
    }
    reloadProfileCounter++;
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
        [rc getUserProfile:@"Auth-Token":smAppDelegate.authToken];
    }
    else
    {
        [smAppDelegate hideActivityViewer];
        [smAppDelegate.window setUserInteractionEnabled:YES];
        [self dismissModalViewControllerAnimated:YES];
    }

    reloadProfileCounter=0;
}

- (void)updateBasicProfileDone:(NSNotification *)notif
{
    NSLog(@"profile update complete.");
    NSLog(@"GOT SERVICE DATA BASIC Profile.. :D  %@",[notif object]);
    [self performSelector:@selector(hideActivity) withObject:nil afterDelay:1.0];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    [smAppDelegate hideActivityViewer];
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)ageButtonAction:(id)sender
{
    CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[self.view layer] addAnimation:animation forKey:@"layerAnimation"];
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
    
    CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[self.view layer] addAnimation:animation forKey:@"layerAnimation"];

    NSLog(@"relsts button");    
    entityFlag=2;
    [self.view addSubview:statusContainer];
    entityTextField.placeholder=@"My relationship status...";
    entityTextField.text=userInfo.relationshipStatus;
}

-(IBAction)liveatButtonAction:(id)sender
{
    CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[self.view layer] addAnimation:animation forKey:@"layerAnimation"];

    NSLog(@"liveat button");    
    entityFlag=3;
    [self.view addSubview:statusContainer];
    entityTextField.placeholder=@"My living city...";
    entityTextField.text=userInfo.address.city;    
}

-(IBAction)workatButtonAction:(id)sender
{
    CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[self.view layer] addAnimation:animation forKey:@"layerAnimation"];

    NSLog(@"work at button");
    entityFlag=4;
    [self.view addSubview:statusContainer];
    entityTextField.placeholder=@"My work place and position...";
    entityTextField.text=userInfo.workStatus;
}

-(IBAction)nameButtonAction:(id)sender
{
    CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[self.view layer] addAnimation:animation forKey:@"layerAnimation"];

    entityFlag=5;
    [self.view addSubview:statusContainer];
    entityTextField.placeholder=@"Enter first name...";
    entityTextField.text=userInfo.userFirstName;    
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
    NSLog(@"from dic %@",[dicImages_msg objectForKey:userInfo.coverPhoto]);
    if ([dicImages_msg objectForKey:userInfo.coverPhoto])
    {
        coverImageView.image=[dicImages_msg objectForKey:userInfo.coverPhoto];
        NSLog(@"load from dic");
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
    NSLog(@"from dic %@",[dicImages_msg objectForKey:userInfo.avatar]);
    if ([dicImages_msg objectForKey:userInfo.avatar])
    {
        profileImageView.image=[dicImages_msg objectForKey:userInfo.avatar];
        fullImageView.image=[dicImages_msg objectForKey:userInfo.avatar];
        NSLog(@"load from dic");
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
        
        NSLog(@"image setted after download newsfeed image. %@",img);
        [img release];
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
    reloadCounter=0;
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
    [smAppDelegate hideActivityViewer];
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
                imgView.layer.borderColor=[[UIColor lightTextColor]CGColor];
                
                imgView.contentMode=UIViewContentModeScaleAspectFit;
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
                [imgView release];
                [iconview release];
                [name release];
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
            //If download complete, set that image to dictionary
            [self reloadScrolview];
        }
        [img release];
        // Now, we need to reload scroll view to load downloaded image
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_UPDATE_BASIC_PROFILE_DONE object:nil];
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
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"PhotoStoryboard" bundle:nil];
        UIViewController* initialHelpView = [storyboard instantiateViewControllerWithIdentifier:@"myPhotosViewController"];
        
        initialHelpView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:initialHelpView animated:YES];

    }
    else if (imageIndex==1)
    {
        FriendListViewController *controller = [[FriendListViewController alloc] initWithNibName:@"FriendListViewController" bundle:nil];
        [controller selectUserId:smAppDelegate.userId];
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:controller animated:YES];
        controller.labelUserName.text = @"My friend list";
        [controller release];         
    }
    else if (imageIndex==2)
    {
        UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        ViewEventListViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"viewEventList"];
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:controller animated:YES];
    }
    else if (imageIndex==3)
    {
        PlaceListViewController *controller = [[PlaceListViewController alloc] initWithNibName:@"PlaceListViewController" bundle:nil];
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:controller animated:YES];
        [controller release];        
    }
    else if (imageIndex==4)
    {
        MeetUpRequestController *controller = [[MeetUpRequestController alloc] initWithNibName:@"MeetUpRequestController" bundle:nil];
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:controller animated:YES];
        [controller release];

    }
    else if (imageIndex==5)
    {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"PlanStoryboard" bundle:nil];
        UIViewController* initialHelpView = [storyboard instantiateViewControllerWithIdentifier:@"planListViewController"];    
        initialHelpView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:initialHelpView animated:YES];
    }
}

- (void) showPinOnMapViewPlan:(Plan *)plan 
{
    NSLog(@"profile %@",plan);
    if (profileFromList==TRUE) {
        [self.presentingViewController performSelector:@selector(showPinOnMapViewPlan:) withObject:plan];
        [self performSelector:@selector(dismissModalView) withObject:nil afterDelay:.8];
    }
    else {
        [self.presentingViewController performSelector:@selector(showPinOnMapViewForPlan:) withObject:plan];
        [self performSelector:@selector(dismissModalView) withObject:nil afterDelay:.5];
    }
}

- (void) dismissModalView {
    
    [self dismissModalViewControllerAnimated:NO];
}

- (void) showPinOnMapView:(Place*)place 
{
    [self.presentingViewController performSelector:@selector(showPinOnMapView:) withObject:place];
    [self dismissModalViewControllerAnimated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dateWasSelected:(NSDate *)selectedDate:(id)element 
{
    isDirty=TRUE;
    userInfo.dateOfBirth=selectedDate;
    ageLabel.text=[NSString stringWithFormat:@"%d",[UtilityClass getAgeFromBirthday:selectedDate]];
}

-(void)viewDidDisappear:(BOOL)animated
{
    isDirty=FALSE;
}

@end

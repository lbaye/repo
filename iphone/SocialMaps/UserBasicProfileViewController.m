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

AppDelegate *smAppDelegate;
RestClient *rc;
UserInfo *userInfo;
NSMutableArray *nameArr;
BOOL coverImgFlag;

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
    
    self.photoPicker = [[[PhotoPicker alloc] initWithNibName:nil bundle:nil] autorelease];
    self.photoPicker.delegate = self;
    self.picSel = [[UIImagePickerController alloc] init];
	self.picSel.allowsEditing = YES;
	self.picSel.delegate = self;
    
    isBackgroundTaskRunning=TRUE;
    rc=[[RestClient alloc] init];
    userInfo=[[UserInfo alloc] init];
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBasicProfileDone:) name:NOTIF_GET_BASIC_PROFILE_DONE object:nil];    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBasicProfileDone:) name:NOTIF_UPDATE_BASIC_PROFILE_DONE object:nil];    
    
    [rc getUserProfile:@"Auth-Token":smAppDelegate.authToken];
    nameArr=[[NSMutableArray alloc] init];
    ImgesName=[[NSMutableArray alloc] init];
    
    nameArr=[[NSMutableArray alloc] initWithObjects:@"Photos",@"Friends",@"Events",@"Places",@"Meet-up", nil];
    for (int i=0; i<[nameArr count]; i++)
    {
        [ImgesName addObject:@"http://www.cnewsvoice.com/C_NewsImage/NI00005461.jpg"];
    }
//            [ImgesName addObject:[[NSBundle mainBundle] pathForResource:@"event_item_bg" ofType:@"png"]];
    userItemScrollView.delegate = self;
    dicImages_msg = [[NSMutableDictionary alloc] init];
    [self reloadScrolview];
}

-(void)viewWillAppear:(BOOL)animated
{
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];    
    isBackgroundTaskRunning=TRUE;
    [mapContainer removeFromSuperview];
    [statusContainer removeFromSuperview];
    [smAppDelegate showActivityViewer:self.view];
    
    profileImageView.layer.borderColor=[[UIColor lightTextColor] CGColor];
    profileImageView.userInteractionEnabled=YES;
    profileImageView.layer.borderWidth=1.0;
    profileImageView.layer.masksToBounds = YES;
    [profileImageView.layer setCornerRadius:5.0];

}

-(IBAction)editCoverButton:(id)sender
{
    coverImgFlag=TRUE;
    [self.photoPicker getPhoto:self];
    [self.entityTextField resignFirstResponder];
}

-(IBAction)editProfilePicButton:(id)sender
{
    coverImgFlag=FALSE;
    [self.photoPicker getPhoto:self];
    [self.entityTextField resignFirstResponder];    
}

-(IBAction)editStatusButton:(id)sender
{
    [self.view addSubview:statusContainer];
}

-(IBAction)viewOnMapButton:(id)sender
{
    [self.view addSubview:mapContainer];
}

-(IBAction)geotagButton:(id)sender
{
}

-(IBAction)uploadPhotoButton:(id)sender
{
}

-(IBAction)closeMap:(id)sender
{
    [mapContainer removeFromSuperview];
}

-(IBAction)saveEntity:(id)sender
{
    NSLog(@"save");
    statusMsgLabel.text=entityTextField.text;
    userInfo.status=entityTextField.text;
    [statusContainer removeFromSuperview];
    [entityTextField resignFirstResponder];
}

-(IBAction)cancelEntity:(id)sender
{
    NSLog(@"cancel");
    [statusContainer removeFromSuperview];
    [entityTextField resignFirstResponder];
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
    [self.entityTextField resignFirstResponder];
    [rc updateUserProfile:userInfo:@"Auth-Token":smAppDelegate.authToken];
}

- (void)getBasicProfileDone:(NSNotification *)notif
{
    NSLog(@"GOT SERVICE DATA BASIC Profile.. :D  %@",[notif object]);
    [self performSelector:@selector(hideActivity) withObject:nil afterDelay:1.0];
    [smAppDelegate.window setUserInteractionEnabled:YES];
//     coverImageView.image;
//     profileImageView.image;
    userInfo=[notif object];
     nameLabl.text=[NSString stringWithFormat:@"Firstname %@",userInfo.firstName];
     statusMsgLabel.text=@"It's a beautiful day";
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

- (void)updateBasicProfileDone:(NSNotification *)notif
{
    NSLog(@"profile update complete.");
    NSLog(@"GOT SERVICE DATA BASIC Profile.. :D  %@",[notif object]);
    [self performSelector:@selector(hideActivity) withObject:nil afterDelay:1.0];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    userInfo=[notif object];
    [self dismissModalViewControllerAnimated:YES];
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
    NSLog(@"userInfo.avatar: %@ userInfo.coverPhoto: %@",userInfo.avatar,userInfo.coverPhoto);
    //temp use
//    userInfo.coverPhoto=@"http://www.cnewsvoice.com/C_NewsImage/NI00005461.jpg";
    UIImage *img=[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:userInfo.coverPhoto]]];
    if (img)
    {
        coverImageView.image=img;
    }
    else
    {
        coverImageView.image=[UIImage imageNamed:@"event_item_bg.png"];
    }

    NSLog(@"image setted after download1. %@",img);

}

-(void)loadImage2
{
    NSLog(@"userInfo.avatar: %@ userInfo.coverPhoto: %@",userInfo.avatar,userInfo.coverPhoto);
    //temp use
//    userInfo.avatar=@"http://www.cnewsvoice.com/C_NewsImage/NI00005461.jpg";
    UIImage *img2=[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:userInfo.avatar]]];
    if (img2)
    {
        profileImageView.image=img2;
    }
    else
    {
        profileImageView.image=[UIImage imageNamed:@"Photo-0.png"];
    }
    
    NSLog(@"image setted after download2. %@",img2);    
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
                if([dicImages_msg valueForKey:[ImgesName objectAtIndex:i]]) 
                { 
                    //If image available in dictionary, set it to imageview 
                    imgView.image = [dicImages_msg valueForKey:[ImgesName objectAtIndex:i]]; 
                } 
                else 
                { 
                    if(!isDragging_msg && !isDecliring_msg) 
                        
                    {
                        //If scroll view moves set a placeholder image and start download image. 
                        [dicImages_msg setObject:[UIImage imageNamed:@"thum.png"] forKey:[ImgesName objectAtIndex:i]]; 
                        [self performSelectorInBackground:@selector(DownLoad:) withObject:[NSNumber numberWithInt:i]];  
                    }
                    else 
                    { 
                        // Image is not available, so set a placeholder image                    
                        imgView.image = [UIImage imageNamed:@"thum.png"];                   
                    }               
                }
                UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(x, 0, 65, 75)];
                UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(0, 60, 60, 20)];
                name.textAlignment=UITextAlignmentCenter;
                [name setFont:[UIFont fontWithName:@"Helvetica" size:10]];
                [name setNumberOfLines:0];
                
                [name setText:[nameArr objectAtIndex:i]];
                
                [name setBackgroundColor:[UIColor clearColor]];
                imgView.userInteractionEnabled = YES;           
                imgView.tag = i;           
                imgView.exclusiveTouch = YES;           
                imgView.clipsToBounds = NO;           
                imgView.opaque = YES;   
                imgView.exclusiveTouch = YES;
                imgView.clipsToBounds = NO;
                imgView.opaque = YES;
                imgView.layer.borderColor=[[UIColor lightGrayColor] CGColor];
                imgView.userInteractionEnabled=YES;
                imgView.layer.borderWidth=1.0;
                imgView.layer.masksToBounds = YES;
                [imgView.layer setCornerRadius:5.0];
                [aView addSubview:imgView];
                [aView addSubview:name];
                [userItemScrollView addSubview:aView];           
            }       
            x+=65;   
        }
        [pl drain];
    }
}

-(void)DownLoad:(NSNumber *)path
{
    if (isBackgroundTaskRunning==TRUE) {
        NSAutoreleasePool *pl = [[NSAutoreleasePool alloc] init];
        int index = [path intValue];
        NSString *Link = [ImgesName objectAtIndex:index];
        //Start download image from url
        UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:Link]]];
        if(img)
        {
            //If download complete, set that image to dictionary
            [dicImages_msg setObject:img forKey:[ImgesName objectAtIndex:index]];
        }
        // Now, we need to reload scroll view to load downloaded image
        [self performSelectorOnMainThread:@selector(reloadScrolview) withObject:path waitUntilDone:NO];
        [pl release];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

//
//  ViewEventDetailViewController.m
//  Event
//
//  Created by Abdullah Md. Zubair on 8/23/12.
//  Copyright (c) 2012 Genweb2 Limited. All rights reserved.
//

#import "ViewEventDetailViewController.h"
#import "Globals.h"
#import "RestClient.h"
#import "AppDelegate.h"
#import "UtilityClass.h"
#import "DDAnnotationView.h"
#import "DDAnnotation.h"
#import "UserFriends.h"
#import <QuartzCore/QuartzCore.h>
#import "NotificationController.h"

@implementation ViewEventDetailViewController
@synthesize eventName,eventDate,eventShortDetail,eventAddress,eventDistance;    
@synthesize yesButton,noButton,maybeButton,descriptionView,guestScrollView,rsvpView,detailView;
@synthesize mapContainer,mapView,eventImgView;
@synthesize editEventButton;
@synthesize deleteEventButton;    
@synthesize inviteEventButton,totalNotifCount;               
@synthesize addressScollview,imagesName,results;

NSMutableArray *imageArr, *nameArr, *idArr;
bool menuOpen=NO;
AppDelegate *smAppDelegate;
int notfCounter=0;
int detNotfCounter=0;
BOOL isBackgroundTaskRunning=FALSE;
CustomRadioButton *radio;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    RestClient *rc=[[RestClient alloc] init];
    NSLog(@"globalEvent %@ %@",globalEvent,globalEvent.eventID);
    [rc getEventDetailById:globalEvent.eventID:@"Auth-Token":smAppDelegate.authToken];


}

-(void)initView
{
    
    descriptionView.text=globalEvent.eventDescription;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults]; 
    smAppDelegate.authToken=[prefs stringForKey:@"authToken"];
    NSLog(@"smAppDelegate.userId: %@",smAppDelegate.userId);
    [smAppDelegate showActivityViewer:self.view];
    [smAppDelegate.window setUserInteractionEnabled:NO];
    Event *aEvent=[[Event alloc] init];
    aEvent=globalEvent;
    NSLog(@"aEvent.eventID: %@  smAppDelegate.authToken: %@",aEvent.eventID,smAppDelegate.authToken);
    
    isBackgroundTaskRunning=TRUE;
    
    
    smAppDelegate=[[AppDelegate alloc] init];
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    eventName.text=globalEvent.eventName;
    eventDate.text=[UtilityClass getCurrentTimeOrDate:globalEvent.eventDate.date];
//    eventDate.text=globalEvent.eventDate.date;
    eventShortDetail.text=globalEvent.eventShortSummary;
    CGSize lblStringSize = [globalEvent.eventAddress sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:11.0f]];
    eventAddress.frame=CGRectMake(eventAddress.frame.origin.x, eventAddress.frame.origin.y, lblStringSize.width, lblStringSize.height);
    addressScollview.contentSize=eventAddress.frame.size;
    eventAddress.text=globalEvent.eventAddress;
    eventDistance.text = [UtilityClass getDistanceWithFormattingFromLocation:globalEvent.eventLocation];
    descriptionView.text=globalEvent.eventDescription;
    NSLog(@"event prop: %@ %i  %@",globalEvent.owner,globalEvent.isInvited,globalEvent.guestList);
    

    
    //mapview data
    if ([self.mapView.annotations count]>0)
    {
        [self.mapView removeAnnotations:[self.mapView annotations]];
    }
    
    [mapView removeAnnotations:[self.mapView annotations]];
    aEvent=[[Event alloc] init];
    aEvent=globalEvent;
    CLLocationCoordinate2D theCoordinate;
	theCoordinate.latitude = [aEvent.eventLocation.latitude doubleValue];
    theCoordinate.longitude = [aEvent.eventLocation.longitude doubleValue];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(theCoordinate, 1000, 1000);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];  
    [self.mapView setRegion:adjustedRegion animated:YES]; 
    
    NSLog(@"lat %lf ",[aEvent.eventLocation.latitude doubleValue]);
	DDAnnotation *annotation = [[[DDAnnotation alloc] initWithCoordinate:theCoordinate addressDictionary:nil] autorelease];
    
    if (!aEvent.eventAddress)
    {
        aEvent.eventAddress=@"Address not found";
    }
	annotation.title =[NSString stringWithFormat:@"%@",aEvent.eventAddress];
//	annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
//	annotation.subtitle=[NSString stringWithFormat:@"Distance: %.2lfm",[aEvent.eventDistance doubleValue]];
    annotation.subtitle = [UtilityClass getDistanceWithFormattingFromLocation:globalEvent.eventLocation];

	[self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
    [self.mapView addAnnotation:annotation];
    
    //scroll view data
    //set scroll view content size.
    NSLog(@"setting scroll size.");
    [self reloadScrolview]; 
    
    
    //my response & image
    
    if ((globalEvent.eventImageUrl)&&(!globalEvent.eventImage))
    {
        [self performSelector:@selector(loadImageView) withObject:nil afterDelay:0.1];
        NSLog(@"globalEvent.eventImageUrl %@ globalEvent.eventImage %@",globalEvent.eventImageUrl,globalEvent.eventImage);
    }
    else if(globalEvent.eventImage)
    {
        eventImgView.image=globalEvent.eventImage;
        NSLog(@"globalEvent.eventImage %@",globalEvent.eventImage);
    }
    
    if([smAppDelegate.userId isEqualToString:aEvent.owner])
    {
        
        [deleteEventButton setHidden:NO];
        [editEventButton setHidden:NO];
        [inviteEventButton setHidden:NO];
        
        [yesButton setUserInteractionEnabled:NO];
        [noButton setUserInteractionEnabled:NO];
        [maybeButton setUserInteractionEnabled:NO];
        [radio gotoButton:0];
        [radio setUserInteractionEnabled:NO];
        [yesButton setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
        [noButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
        [maybeButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    }
    else
    {
        [deleteEventButton setHidden:YES];
        [editEventButton setHidden:YES];
        [inviteEventButton setHidden:YES];
        
        [yesButton setUserInteractionEnabled:YES];
        [noButton setUserInteractionEnabled:YES];
        [maybeButton setUserInteractionEnabled:YES];
        
        NSLog(@"aEvent.myResponse %@",aEvent.myResponse);
        if ([aEvent.myResponse isEqualToString:@"yes"])
        {
            [radio gotoButton:0];
        }
        else if([aEvent.myResponse isEqualToString:@"no"]) 
        {
            [radio gotoButton:1];        }
        else
        {
            [radio gotoButton:2];        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self displayNotificationCount];
    [self.mapContainer removeFromSuperview];
    detNotfCounter=0;
    imagesName = [[NSMutableArray alloc] init];
    nameArr=[[NSMutableArray alloc] init];
    idArr=[[NSMutableArray alloc] init];
    smAppDelegate.currentModelViewController = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"globalEvent det %@",globalEvent.eventID);
    radio = [[CustomRadioButton alloc] initWithFrame:CGRectMake(140, 3, 170, 43) numButtons:3 labels:[NSArray arrayWithObjects:@"Yes",@"No",@"May be",nil]  default:0 sender:self tag:20001];
    radio.delegate = self;
    [rsvpView addSubview:radio];
    
    notfCounter=0;
    detNotfCounter=0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getEventDetailDone:) name:NOTIF_GET_EVENT_DETAIL_DONE object:nil];
    
    guestScrollView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteEventDone:) name:NOTIF_DELETE_EVENT_DONE object:nil];
    
    if (globalEvent.isInvited==FALSE)
    {
        rsvpView.hidden=YES;
    }
    else
        rsvpView.hidden=NO;
    
    //reloading scrollview to start asynchronous download.
    NSLog(@"before reload.");
    [self initView];
    
}

- (void) radioButtonClicked:(int)indx sender:(id)sender {
    NSLog(@"radioButtonClicked index = %d %d", indx,[sender tag]);
    RestClient *rc=[[RestClient alloc] init];
    
    [smAppDelegate hideActivityViewer];
    //    [smAppDelegate.window setUserInteractionEnabled:NO];
    
    if ([sender tag] == 20001) 
    {
        switch (indx) 
        {
            case 2:
                NSLog(@"may be");
                globalEvent.myResponse=@"maybe";
                NSLog(@"eventID %@",globalEvent.eventID);
                [rc setEventRsvp:globalEvent.eventID:@"maybe":@"Auth-Token":smAppDelegate.authToken];
                break;
            case 1:
                NSLog(@"no");
                globalEvent.myResponse=@"no";
                NSLog(@"eventID %@",globalEvent.eventID);
                [rc setEventRsvp:globalEvent.eventID:@"no":@"Auth-Token":smAppDelegate.authToken];
                break;
            case 0:
                NSLog(@"yes");
                globalEvent.myResponse=@"yes";
                NSLog(@"eventID %@",globalEvent.eventID);
                [rc setEventRsvp:globalEvent.eventID:@"yes":@"Auth-Token":smAppDelegate.authToken];
                break;
            default:
                break;
        }
    }
}

-(void)loadImageView
{
    if ([dicImages_msg objectForKey:globalEvent.eventID])
    {
        eventImgView.image=[dicImages_msg objectForKey:globalEvent.eventID];
    }
    else
    {
    UIImage *img=[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:globalEvent.eventImageUrl]]];
    if (img)
    {
        eventImgView.image=img;
        [dicImages_msg setObject:img forKey:globalEvent.eventID];
    }
    else
    {
        eventImgView.image=[UIImage imageNamed:@"blank.png"];
    }
    NSLog(@"image setted after download. %@",img);
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)viewMapButton:(id)sender
{
    NSLog(@"view map button....");
    [self.view addSubview:mapContainer];
}

-(IBAction)yesAttendAction:(id)sender
{
    [self resetButton:0];
    RestClient *rc=[[RestClient alloc] init];
    
    [rc setEventRsvp:globalEvent.eventID:@"yes":@"Auth-Token":smAppDelegate.authToken];
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:NO];

}

-(IBAction)noAttendAction:(id)sender
{
    [self resetButton:1];    
    RestClient *rc=[[RestClient alloc] init];
    
    [rc setEventRsvp:globalEvent.eventID:@"no":@"Auth-Token":smAppDelegate.authToken];
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:NO];

}

-(IBAction)maybeAttendAction:(id)sender
{
    [self resetButton:2];    
    RestClient *rc=[[RestClient alloc] init];
    
    [rc setEventRsvp:globalEvent.eventID:@"maybe":@"Auth-Token":smAppDelegate.authToken];
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:NO];

}

-(IBAction)closeMap:(id)sender
{
    [self.mapContainer removeFromSuperview];
}

-(IBAction)backButton:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
//    [self viewDidUnload];
//    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//    ViewEventDetailViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"viewEventList"];
//    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    [self presentModalViewController:controller animated:YES];
}

-(void)resetButton:(int)index
{
    if (index==0)
    {
        [yesButton setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];        
        [noButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
        [maybeButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
        NSLog(@"0");
    }
    else if (index==1) 
    {
        [yesButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];        
        [noButton setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
        [maybeButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
                NSLog(@"1");
    }
    else if (index==2)
    {
        [yesButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
        [noButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
        [maybeButton setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
                NSLog(@"2");
    }
}

-(IBAction)guestList:(id)sender
{
    NSLog(@"guest list");
}

-(IBAction)invitePeople:(id)sender
{
    detNotfCounter=0;
    NSLog(@"invite people");    
    globalEditEvent=globalEvent;
    editFlag=true;
    isFromVenue=FALSE;
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    ViewEventDetailViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"createEvent"];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
}

-(IBAction)deleteEvent:(id)sender
{
    NSLog(@"delete event");
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults]; 
    smAppDelegate.authToken=[prefs stringForKey:@"authToken"];
    
    [smAppDelegate showActivityViewer:self.view];    
    [smAppDelegate.window setUserInteractionEnabled:NO];

    RestClient *rc=[[RestClient alloc] init];
    Event *aEvent=[[Event alloc] init];
    aEvent=globalEvent;
    NSLog(@"aEvent.eventID: %@  smAppDelegate.authToken: %@",aEvent.eventID,smAppDelegate.authToken);
    [rc deleteEventById:aEvent.eventID:@"Auth-Token":smAppDelegate.authToken];
}

-(IBAction)editEvent:(id)sender
{
    detNotfCounter=0;
    NSLog(@"edit event");
    globalEditEvent=globalEvent;
    editFlag=true;
    isFromVenue=FALSE;
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    ViewEventDetailViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"createEvent"];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
}

- (void)deleteEventDone:(NSNotification *)notif
{
    notfCounter++;
    if (notfCounter==1)
    {
        [smAppDelegate hideActivityViewer];
        [smAppDelegate.window setUserInteractionEnabled:YES];
        NSLog(@"dele %@",[notif object]);
        [UtilityClass showAlert:@"Social Maps" :@"Event Deleted"];
        [self dismissModalViewControllerAnimated:YES];
    }
}

-(void)loadScrollView
{
//    guestScrollView.contentSize=CGSizeMake(600, 60);
    for (int i=0; i<[imageArr count]; i++)
    {
        UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(i*60, 0, 60, 65)];
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
        [imgView setImage:[UIImage imageNamed:@""]];
        UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(0, 45, 60, 20)];
        [name setFont:[UIFont fontWithName:@"Helvetica" size:10]];
        [name setNumberOfLines:0];
        [name setText:@"Bonolota Sen"];
        [name setBackgroundColor:[UIColor clearColor]];
        [aView addSubview:imgView];
        [aView addSubview:name];
        [guestScrollView addSubview:aView];
        NSLog(@" :%d",i*60);
    }
}

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
    if ([animationID isEqualToString:@"slideMenu"])
    {
        UIView *sq = (UIView *) context;
        [sq removeFromSuperview];
        [sq release];
    }
}

- (IBAction)menuTapped 
{
    NSLog(@"Menu tapped");
    CGRect frame = self.rsvpView.frame;
    CGRect detframe = self.detailView.frame;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector( animationDidStop:finished:context: )];
    [UIView beginAnimations:@"slideMenu" context:self.rsvpView];    
    if(menuOpen) 
    {
        frame.origin.y = -80;
        detframe.origin.y=171;
        menuOpen = NO;
    }
    else
    {
        frame.origin.y = 171;
        detframe.origin.y=214;
        menuOpen = YES;
    }    
    self.rsvpView.frame = frame;
    self.detailView.frame=detframe;
    [UIView commitAnimations];
}

//lazy scroller

-(void) reloadScrolview
{
    NSLog(@"event detail in scroll init %d",[imagesName count]);
    if (isBackgroundTaskRunning==TRUE)  
    {
    NSLog(@"event detail isBackgroundTaskRunning %i",isBackgroundTaskRunning);
//    NSAutoreleasePool *pl = [[NSAutoreleasePool alloc] init];
    int x=0; //declared for imageview x-axis point    
    
    NSArray* subviews = [NSArray arrayWithArray: guestScrollView.subviews];
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
    guestScrollView.contentSize=CGSizeMake([imagesName count]*65, 65);
    for(int i=0; i<[imagesName count];i++)       
        
    {
        if(i< [imagesName count]) 
        { 
            UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
            if([dicImages_msg objectForKey:[imagesName objectAtIndex:i]]) 
            { 
                //If image available in dictionary, set it to imageview 
                imgView.image = [dicImages_msg objectForKey:[imagesName objectAtIndex:i]]; 
            } 
            else 
            { 
                if((!isDragging_msg && !isDecliring_msg) &&([dicImages_msg objectForKey:[imagesName objectAtIndex:i]]==nil))
                    
                {
                    NSLog(@"downloading called");
                    //If scroll view moves set a placeholder image and start download image. 
                    [self performSelectorInBackground:@selector(DownLoad:) withObject:[NSNumber numberWithInt:i]];  
//                    [self performSelector:@selector(DownLoad:) withObject:[NSNumber numberWithInt:i] afterDelay:0.1];
//                    [dicImages_msg setObject:[UIImage imageNamed:@"thum.png"] forKey:[imagesName objectAtIndex:i]]; 
                    imgView.image = [UIImage imageNamed:@""];
                }
                else 
                { 
                    // Image is not available, so set a placeholder image                    
                    imgView.image = [UIImage imageNamed:@""];                   
                }               
            }
            UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(x, 0, 65, 65)];
            UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(0, 45, 60, 20)];
            [name setFont:[UIFont fontWithName:@"Helvetica" size:10]];
            [name setNumberOfLines:0];
            
            if ([nameArr count]-1>=i) {
                [name setText:[nameArr objectAtIndex:i]];
            }
            
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
            if ([globalEvent.yesArr containsObject:[idArr objectAtIndex:i]] ||[[idArr objectAtIndex:i] isEqualToString:globalEvent.owner])
            {
            imgView.layer.borderColor=[[UIColor greenColor] CGColor];
            }
            else if([globalEvent.noArr containsObject:[idArr objectAtIndex:i]]) 
            {
            imgView.layer.borderColor=[[UIColor redColor] CGColor];
            }
            else
            {
            imgView.layer.borderColor=[[UIColor lightGrayColor] CGColor];
            }
            imgView.userInteractionEnabled=YES;
            imgView.layer.borderWidth=1.5;
            imgView.layer.masksToBounds = YES;
            [imgView.layer setCornerRadius:7.0];
            [aView addSubview:imgView];
            [aView addSubview:name];
            [guestScrollView addSubview:aView];           
        }       
            x+=65;   
    }
//    [pl drain];
    }
}

-(void)DownLoad:(NSNumber *)path
{
    if (isBackgroundTaskRunning==TRUE) 
    {
    NSAutoreleasePool *pl = [[NSAutoreleasePool alloc] init];
    int index = [path intValue];
    NSString *Link = [imagesName objectAtIndex:index];
    //Start download image from url
        UIImage *img;
        if ([Link isEqual:[NSNull null]]) {
            img = [UIImage imageNamed:@"blank.png"];
        }
        else {
            img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:Link]]];
        }
    if((img) && ([dicImages_msg objectForKey:[imagesName objectAtIndex:index]]==NULL))
    {
        //If download complete, set that image to dictionary
        [dicImages_msg setObject:img forKey:[imagesName objectAtIndex:index]];
        NSLog(@"img: %@    %@",img,[imagesName objectAtIndex:index]);
        [self reloadScrolview];
//        [self performSelectorOnMainThread:@selector(reloadScrolview) withObject:path waitUntilDone:NO];
        
    }
//    else
//    {
//        [dicImages_msg setObject:[UIImage imageNamed:@"thum.png"] forKey:[ImgesName objectAtIndex:index]];
//    }
    // Now, we need to reload scroll view to load downloaded image
//    [self performSelectorOnMainThread:@selector(reloadScrolview) withObject:path waitUntilDone:NO];
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

- (void)getEventDetailDone:(NSNotification *)notif
{
    detNotfCounter++;
    globalEvent=[notif object];
    NSLog(@"Detail globalEvent: %@ %@",globalEvent.eventID,globalEvent.eventDate.date);
    
    NSLog(@"[globalEvent.guestList count] %d",[globalEvent.guestList count]);
        
    if (detNotfCounter==1)
    {
        UserFriends *frnd;
        [imagesName removeAllObjects];
        [nameArr removeAllObjects];
        [idArr removeAllObjects];
        
        for (int i=0; i<[globalEvent.guestList count]; i++)
        {
            frnd=[[UserFriends alloc] init];
            frnd=[globalEvent.guestList objectAtIndex:i];
            NSLog(@"UserFriendsImg %@ frnd %@",frnd.imageUrl,frnd);
            if ((frnd.imageUrl==NULL)||[frnd.imageUrl isEqual:[NSNull null]])
            {
                //            frnd.imageUrl=[[NSBundle mainBundle] pathForResource:@"thum" ofType:@"png"];
                NSLog(@"img url null %d",i);
            }
            else
            {
                NSLog(@"img url not null %d",i);            
            }
            [imagesName addObject:frnd.imageUrl];
            [nameArr addObject:frnd.userName];
            [idArr addObject:frnd.userId];
        }

        NSLog(@"reloading view");
        [self initView];
        [self reloadScrolview];
    }
//    [self.view setNeedsDisplay];
    NSLog(@"detNotfCounter: %d  globalEvent.guestList: %@ %d",detNotfCounter, globalEvent.guestList,[imagesName count]);
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    [self hideActivity];
    NSLog(@"guestScrollView size %@ %@",NSStringFromCGSize(guestScrollView.contentSize),imagesName);
//    [self reloadScrolview];    
}

-(void)loadScrollData
{
    UserFriends *frnd;
    [imagesName removeAllObjects];
    [nameArr removeAllObjects];
    [idArr removeAllObjects];
    
    for (int i=0; i<[globalEvent.guestList count]; i++)
    {
        frnd=[[UserFriends alloc] init];
        frnd=[globalEvent.guestList objectAtIndex:i];
        NSLog(@"UserFriendsImg %@ frnd %@",frnd.imageUrl,frnd);
        if ((frnd.imageUrl==NULL)||[frnd.imageUrl isEqual:[NSNull null]])
        {
            //            frnd.imageUrl=[[NSBundle mainBundle] pathForResource:@"thum" ofType:@"png"];
            NSLog(@"img url null %d",i);
        }
        else
        {
            NSLog(@"img url not null %d",i);            
        }
        [imagesName addObject:frnd.imageUrl];
        [nameArr addObject:frnd.userName];
        [idArr addObject:frnd.userId];
    }

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

-(void)viewWillDisappear:(BOOL)animated
{
    isBackgroundTaskRunning=FALSE;
//    [self viewDidUnload];
//    dicImages_msg=nil;
//    imagesName=nil;
//    nameArr=nil;
//    guestScrollView=nil;
    detNotfCounter=0;
}

@end

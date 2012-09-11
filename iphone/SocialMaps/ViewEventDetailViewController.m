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

@implementation ViewEventDetailViewController
@synthesize eventName,eventDate,eventShortDetail,eventAddress,eventDistance;    
@synthesize yesButton,noButton,maybeButton,descriptionView,guestScrollView,rsvpView,detailView;
@synthesize mapContainer,mapView,eventImgView;
@synthesize editEventButton;
@synthesize deleteEventButton;    
@synthesize inviteEventButton;        


NSMutableArray *imageArr, *nameArr;
bool menuOpen=NO;
AppDelegate *smAppDelegate;
int notfCounter=0;

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
    notfCounter=0;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults]; 
    smAppDelegate.authToken=[prefs stringForKey:@"authToken"];
    NSLog(@"smAppDelegate.userId: %@",smAppDelegate.userId);
    [smAppDelegate showActivityViewer:self.view];
    [smAppDelegate.window setUserInteractionEnabled:NO];
    RestClient *rc=[[RestClient alloc] init];
    Event *aEvent=[[Event alloc] init];
    aEvent=globalEvent;
    NSLog(@"aEvent.eventID: %@  smAppDelegate.authToken: %@",aEvent.eventID,smAppDelegate.authToken);
    [rc getEventDetailById:aEvent.eventID:@"Auth-Token":smAppDelegate.authToken];

    isBackgroundTaskRunning=TRUE;
    
    
    smAppDelegate=[[AppDelegate alloc] init];
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    eventName.text=globalEvent.eventName;
    eventDate.text=globalEvent.eventDate.date;
    eventShortDetail.text=globalEvent.eventShortSummary;
    eventAddress.text=globalEvent.eventAddress;
    eventDistance.text=[NSString stringWithFormat:@"%.2lfm",[globalEvent.eventDistance doubleValue]];
    descriptionView.text=globalEvent.eventDescription;
    NSLog(@"event prop: %@ %i  %@",globalEvent.owner,globalEvent.isInvited,globalEvent.guestList);
    
    if (globalEvent.isInvited==FALSE)
    {
        rsvpView.hidden=YES;
    }

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
	annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
	annotation.subtitle=[NSString stringWithFormat:@"Distance: %.2lfm",[aEvent.eventDistance doubleValue]];
	[self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
    [self.mapView addAnnotation:annotation];

    //scroll view data
    //set scroll view content size.
    NSLog(@"setting scroll size.");
    [self reloadScrolview]; 

    
    //my response & image
    NSLog(@"aEvent.myResponse %@",aEvent.myResponse);
    if ([aEvent.myResponse isEqualToString:@"yes"])
    {
        [yesButton setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
        [noButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
        [maybeButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    }
    else if([aEvent.myResponse isEqualToString:@"no"]) 
    {
        [yesButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
        [noButton setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
        [maybeButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    }
    else
    {
        [yesButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
        [noButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
        [maybeButton setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
    }
    
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
        
        [deleteEventButton setEnabled:YES];
        [editEventButton setEnabled:YES];
        [inviteEventButton setEnabled:YES];
        
        [yesButton setUserInteractionEnabled:NO];
        [noButton setUserInteractionEnabled:NO];
        [maybeButton setUserInteractionEnabled:NO];
        
        [yesButton setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
        [noButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
        [maybeButton setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    }
    else
    {
        [deleteEventButton setEnabled:NO];
        [editEventButton setEnabled:NO];
        [inviteEventButton setEnabled:NO];
        
        [yesButton setUserInteractionEnabled:YES];
        [noButton setUserInteractionEnabled:YES];
        [maybeButton setUserInteractionEnabled:YES];

    }

}

-(void)viewWillAppear:(BOOL)animated
{
    [self.mapContainer removeFromSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"globalEvent det %@",globalEvent.eventID);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getEventDetailDone:) name:NOTIF_GET_EVENT_DETAIL_DONE object:nil];
    
    guestScrollView.delegate = self;
    dicImages_msg = [[NSMutableDictionary alloc] init];
    nameArr=[[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteEventDone:) name:NOTIF_DELETE_EVENT_DONE object:nil];
    
    //reloading scrollview to start asynchronous download.
    NSLog(@"before reload.");
    
}

-(void)loadImageView
{
    UIImage *img=[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:globalEvent.eventImageUrl]]];
    if (img)
    {
        eventImgView.image=img;
    }
    else
    {
        eventImgView.image=[UIImage imageNamed:@"event_item_bg.png"];
    }
    NSLog(@"image setted after download. %@",img);
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
    NSLog(@"invite people");    
    globalEditEvent=globalEvent;
    editFlag=true;
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
    NSLog(@"edit event");
    globalEditEvent=globalEvent;
    editFlag=true;
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
        [imgView setImage:[UIImage imageNamed:@"girl.png"]];
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
    NSLog(@"in scroll init %d",[ImgesName count]);
    NSLog(@"isBackgroundTaskRunning %i",isBackgroundTaskRunning);
    if (isBackgroundTaskRunning==TRUE) 
    {
    NSAutoreleasePool *pl = [[NSAutoreleasePool alloc] init];
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
    guestScrollView.contentSize=CGSizeMake([ImgesName count]*65, 65);
    for(int i=0; i<[ImgesName count];i++)       
        
    {
        if(i< [ImgesName count]) 
        { 
            UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
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
                    [dicImages_msg setObject:[UIImage imageNamed:@"girl.png"] forKey:[ImgesName objectAtIndex:i]]; 
                    [self performSelectorInBackground:@selector(DownLoad:) withObject:[NSNumber numberWithInt:i]];  
                }
                else 
                { 
                    // Image is not available, so set a placeholder image                    
                    imgView.image = [UIImage imageNamed:@"girl.png"];                   
                }               
            }
            UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(x, 0, 65, 65)];
            UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(0, 45, 60, 20)];
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
            imgView.layer.borderColor=[[UIColor greenColor] CGColor];
            imgView.userInteractionEnabled=YES;
            imgView.layer.borderWidth=2.0;
            imgView.layer.masksToBounds = YES;
            [imgView.layer setCornerRadius:7.0];
            [aView addSubview:imgView];
            [aView addSubview:name];
            [guestScrollView addSubview:aView];           
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
//    else
//    {
//        [dicImages_msg setObject:[NSNull null] forKey:[ImgesName objectAtIndex:index]];
//    }
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

- (void)getEventDetailDone:(NSNotification *)notif
{
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    globalEvent=[notif object];
    
    NSLog(@"Detail globalEvent: %@ %@",globalEvent.eventID,globalEvent.eventDate.date);
    ImgesName = [[NSMutableArray alloc] init];   
    
    NSLog(@"[globalEvent.guestList count] %d",[globalEvent.guestList count]);
    UserFriends *frnd;
    for (int i=0; i<[globalEvent.guestList count]; i++)
    {
        frnd=[[UserFriends alloc] init];
        frnd=[globalEvent.guestList objectAtIndex:i];
        NSLog(@"UserFriendsImg %@ frnd %@",frnd.imageUrl,frnd);
        [ImgesName addObject:frnd.imageUrl];
        [nameArr addObject:frnd.userName];
    }

    [self reloadScrolview];
    ////    [self performSegueWithIdentifier:@"eventDetail" sender:self];
    //    ViewEventDetailViewController *modalViewControllerTwo = [[ViewEventDetailViewController alloc] init];
    ////    modalViewControllerTwo.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //    [self presentModalViewController:modalViewControllerTwo animated:YES];
    //    NSLog(@"GOT SERVICE DATA.. :D");
    
//    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//    ViewEventDetailViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"eventDetail"];
//    [self presentModalViewController:controller animated:YES];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    isBackgroundTaskRunning=FALSE;
    [self viewDidUnload];
    dicImages_msg=nil;
    ImgesName=nil;
    nameArr=nil;
    guestScrollView=nil;
    
}

@end

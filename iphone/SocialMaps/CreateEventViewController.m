//
//  CreateEventViewController.m
//  Event
//
//  Created by Abdullah Md. Zubair on 8/28/12.
//  Copyright (c) 2012 Genweb2 Limited. All rights reserved.
//

#import "CreateEventViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ActionSheetPicker.h"
#import "DDAnnotationView.h"
#import "DDAnnotation.h"
#import "UtilityClass.h"
#import "RestClient.h"
#import "AppDelegate.h"
#import "Event.h"
#import "Globals.h"
#import "UserCircle.h"

@interface CreateEventViewController ()
- (void)coordinateChanged_:(NSNotification *)notification;
@end

@implementation CreateEventViewController

@synthesize curLoc;
@synthesize myPlace;    
@synthesize neamePlace;
@synthesize pointOnMap;    

@synthesize nameButton;
@synthesize summaryButton;    
@synthesize descriptionButton;
@synthesize dateButton;    
@synthesize photoButton;
@synthesize deleteButton,eventImagview,friendSearchbar;
@synthesize friends,degreeFriends,people,custom,guestCanInviteButton,frndListScrollView;
@synthesize createView,photoPicker,eventImage,picSel,entryTextField,mapView,mapContainerView,addressLabel;

__strong NSMutableArray *friendsNameArr, *friendsIDArr, *friendListArr, *filteredList, *circleList;
bool searchFlag;
__strong int checkCount;
__strong NSString *searchTexts, *dateString;


static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

AppDelegate *smAppDelegate;
Event *event;
int entityFlag=0;
DDAnnotation *annotation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)loadDummydata
{
    circleList=[[NSMutableArray alloc] initWithObjects:@"Friends",@"Family",@"Collegue",@"Close Friends",@"Relatives", nil];
    [circleList removeAllObjects];
    UserCircle *circle=[[UserCircle alloc]init];
    
    for (int i=0; i<[circleListGlobalArray count]; i++)
    {
        circle=[circleListGlobalArray objectAtIndex:i];
        [circleList addObject:circle.circleName];
    }
    UserFriends *frnds=[[UserFriends alloc] init];
    ImgesName = [[NSMutableArray alloc] initWithObjects:   
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005482.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005457.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005461.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005470.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005463.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005465.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005466.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005469.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005472.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005475.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005479.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005484.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005483.jpg",nil ];    
    
    searchTexts=[[NSString alloc] initWithString:@""];
    friendsNameArr=[[NSMutableArray alloc] initWithObjects:@"karin",@"foyzul",@"dulal",@"abbas",@"gafur",@"fuad",@"robi",@"karim",@"tinki",@"suma",@"tilok",@"babu",@"imran", nil];
    friendsIDArr=[[NSMutableArray alloc] initWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13", nil];
    filteredList=[[NSMutableArray alloc] init];
    friendListArr=[[NSMutableArray alloc] init];

    for (int i=0; i<[friendListGlobalArray count]; i++)
    {
        frnds=[[UserFriends alloc] init];
//        frnds.userName=[friendsNameArr objectAtIndex:i];
//        frnds.userId=[friendsIDArr objectAtIndex:i];
//        frnds.imageUrl=[ImgesName objectAtIndex:i];
        frnds=[friendListGlobalArray objectAtIndex:i];
        [friendListArr addObject:frnds];
    }
    filteredList=[friendListArr mutableCopy];
    NSLog(@"smAppDelegate.placeList %@",smAppDelegate.placeList);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.photoPicker = [[[PhotoPicker alloc] initWithNibName:nil bundle:nil] autorelease];
    self.photoPicker.delegate = self;
    self.picSel = [[UIImagePickerController alloc] init];
	self.picSel.allowsEditing = YES;
	self.picSel.delegate = self;	
    
    frndListScrollView.delegate = self;
    dicImages_msg = [[NSMutableDictionary alloc] init];
    friendListArr=[[NSMutableArray alloc] init];
    filteredList=[[NSMutableArray alloc] init];
    smAppDelegate=[[AppDelegate alloc] init];
    event=[[Event alloc] init];
    //set scroll view content size.
    [self loadDummydata];
    
    selectedFriendsIndex=[[NSMutableArray alloc] init];
    //reloading scrollview to start asynchronous download.
    [self reloadScrolview]; 
    [self.mapContainerView  removeFromSuperview];
    //load map data
    CLLocationCoordinate2D theCoordinate;
	theCoordinate.latitude = [smAppDelegate.currPosition.latitude doubleValue];
    theCoordinate.longitude = [smAppDelegate.currPosition.longitude doubleValue];
	
	annotation = [[[DDAnnotation alloc] initWithCoordinate:theCoordinate addressDictionary:nil] autorelease];
	annotation.title = @"Drag to Move Pin";
	annotation.subtitle = [NSString	stringWithFormat:@"Current Location"];
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = annotation.coordinate.latitude;
    newRegion.center.longitude = annotation.coordinate.longitude;
    newRegion.span.latitudeDelta = 1.112872;
    newRegion.span.longitudeDelta = 1.109863;
    
    [self.mapView setRegion:newRegion animated:YES];

	[self.mapView setCenterCoordinate:annotation.coordinate];
    
	[self.mapView addAnnotation:annotation];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults]; 
    smAppDelegate.authToken=[prefs stringForKey:@"authToken"];    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createEventDone:) name:NOTIF_CREATE_EVENT_DONE object:nil];    
//    [self.mapView setCenter:annotation.region];
}

- (void)viewWillAppear:(BOOL)animated 
{
	
	[super viewWillAppear:animated];
	
	// NOTE: This is optional, DDAnnotationCoordinateDidChangeNotification only fired in iPhone OS 3, not in iOS 4.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coordinateChanged_:) name:@"DDAnnotationCoordinateDidChangeNotification" object:nil];
    
    [self performSelector:@selector(getCurrentAddress) withObject:nil afterDelay:0.1];
}

-(void)getCurrentAddress
{
    addressLabel.text=[UtilityClass getAddressFromLatLon:[smAppDelegate.currPosition.latitude doubleValue] withLongitude:[smAppDelegate.currPosition.longitude doubleValue]];
}

-(void)getAddressFromMap
{
    addressLabel.text=[UtilityClass getAddressFromLatLon:annotation.coordinate.latitude withLongitude:annotation.coordinate.longitude];
}

- (void)viewWillDisappear:(BOOL)animated {
	
	[super viewWillDisappear:animated];
	
	// NOTE: This is optional, DDAnnotationCoordinateDidChangeNotification only fired in iPhone OS 3, not in iOS 4.
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"DDAnnotationCoordinateDidChangeNotification" object:nil];	
}


- (void) photoPickerDone:(bool)status image:(UIImage*)img {
    NSLog(@"PersonalInformation:photoPickerDone, status=%d", status);
    if (status == TRUE) 
    {
        [eventImagview setImage:img];
        eventImage = img;
        NSData *imgdata = UIImagePNGRepresentation(eventImage);
        NSString *imgBase64Data = [imgdata base64EncodedString];
        event.eventImageUrl=imgBase64Data;
    } 
    [photoPicker.view removeFromSuperview];
}

//event info entry starts

-(IBAction)nameButtonAction
{
    [createView setHidden:NO];
    entityFlag=0;
    entryTextField.text=@"";
    entryTextField.placeholder=@"Name...";
}

-(IBAction)summaryButtonAction
{
    [createView setHidden:NO];    
    entityFlag=1;
    entryTextField.text=@"";
    entryTextField.placeholder=@"Summary...";
}    

-(IBAction)descriptionButtonAction
{
    [createView setHidden:NO];    
    entityFlag=2;
    entryTextField.text=@"";
    entryTextField.placeholder=@"Description...";
}

-(IBAction)dateButtonAction:(id)sender
{
    [ActionSheetPicker displayActionPickerWithView:sender datePickerMode:UIDatePickerModeDateAndTime selectedDate:[NSDate date] target:self action:@selector(dateWasSelected::) title:@"Date"]; 
}

-(IBAction)photoButtonAction
{
    [self.photoPicker getPhoto:self];
}

-(IBAction)deleteButtonAction
{
    self.eventImagview.image=[UIImage imageNamed:@"banner_bar.png"];
}

//event info entry ends

//share with radio button starts
-(IBAction)friendsButtonAction
{
    [friends setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
    [degreeFriends setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [people setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [custom setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
}

-(IBAction)degreeFriendsButtonAction
{
    [friends setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [degreeFriends setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
    [people setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [custom setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];    
}

-(IBAction)peopleButtonAction
{
    [friends setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [degreeFriends setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [people setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
    [custom setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];

}

-(IBAction)customButtonAction
{
    [friends setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [degreeFriends setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [people setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [custom setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
}
//share with radio button ends up

//location with radio button starts
-(IBAction)curLocButtonAction
{
    [curLoc setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
    [myPlace setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [neamePlace setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [pointOnMap setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [self performSelector:@selector(getCurrentAddress) withObject:nil afterDelay:0.1];

}

-(IBAction)myPlaceButtonAction
{
    [curLoc setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [myPlace setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
    [neamePlace setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [pointOnMap setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal]; 
    [UtilityClass showAlert:@"Social Maps" :@"You have no saved places."];
}

-(IBAction)neamePlaceButtonAction
{
    [curLoc setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [myPlace setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [neamePlace setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
    [pointOnMap setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];    

}

-(IBAction)pointOnMapButtonAction
{
    [curLoc setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [myPlace setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [neamePlace setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [pointOnMap setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];    
    [self.view addSubview:mapContainerView];
}
////location with radio button ends

//show circle
-(IBAction)showCircle:(id)sender
{
    [ActionSheetPicker displayActionPickerWithView:sender data:circleList selectedIndex:2 target:self action:@selector(circleWasSelected::) title:@"Circle"];
}

-(IBAction)guestCanInvite:(id)sender
{
    checkCount++;
    if (checkCount%2!=0)
    {
        [guestCanInviteButton setImage:[UIImage imageNamed:@"list_checked.png"] forState:UIControlStateNormal];
        event.guestCanInvite=true;
    }
    else
    {
        [guestCanInviteButton setImage:[UIImage imageNamed:@"list_uncheck.png"] forState:UIControlStateNormal];
        event.guestCanInvite=false;
    }
}

-(IBAction)unSelectAll:(id)sender
{
    [selectedFriendsIndex removeAllObjects];
    [self reloadScrolview];
}

-(IBAction)addAll:(id)sender
{
    for (int i=0; i<[filteredList count]; i++)
    {
        [selectedFriendsIndex addObject:[NSString stringWithFormat:@"%d",i]];
    }
    [self reloadScrolview];
}

-(IBAction)createEvent:(id)sender
{
    [smAppDelegate showActivityViewer:self.view];
    RestClient *rc=[[RestClient alloc] init];
    UserFriends *frnd;
    NSMutableArray *userIDs=[[NSMutableArray alloc] init];
    for (int i=0; i<[selectedFriendsIndex count]; i++)
    {
        frnd=[[UserFriends alloc] init];
        frnd=[selectedFriendsIndex objectAtIndex:i];
        [userIDs addObject:frnd.userId];
    }
    event.guestList=userIDs;
    event.eventLocation.latitude=[NSString stringWithFormat:@"%lf",annotation.coordinate.latitude];
    event.eventLocation.longitude=[NSString stringWithFormat:@"%lf",annotation.coordinate.longitude];
    event.eventAddress=annotation.subtitle;
    
    [rc createEvent:event:@"Auth-Token":smAppDelegate.authToken];
    NSLog(@"event.eventName %@ event.eventDescription %@ event.eventShortSummary %@  guests: %@ event.eventImageUrl %@ event.eventDate %@",event.eventName,event.eventDescription,event.eventShortSummary,event.guestList,event.eventImageUrl,event.eventDate.date);
}

-(IBAction)cancelEvent:(id)sender
{
}

-(IBAction)saveEntity:(id)sender
{
    [createView setHidden:YES];
    [entryTextField resignFirstResponder];
    if (entityFlag==0)
    {
        event.eventName=entryTextField.text;
    }
    else if (entityFlag==1)
    {
        event.eventShortSummary=entryTextField.text;
    }
    else if (entityFlag==2)
    {
        event.eventDescription=entryTextField.text;
    }
}

-(IBAction)cancelEntity:(id)sender
{
    [createView setHidden:YES];    
    [entryTextField resignFirstResponder];    
}

- (void)circleWasSelected:(NSNumber *)selectedIndex:(id)element 
{
	//Selection was made
	int selectedCircleIndex = [selectedIndex intValue];
}

- (void)dateWasSelected:(NSDate *)selectedDate:(id)element 
{
    NSDate *date =selectedDate;
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    event.eventDate.date=[UtilityClass convertNSDateToUnix:date];
    dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh.mm"];    
    dateString = [dateFormatter stringFromDate:date];
    event.eventDate.date=[[NSString alloc] initWithString:dateString];
    dateButton.titleLabel.text=dateString;
    //selectedDate=dateString 2012-09-12 08.50;
    NSLog(@"Selected Date: %@  %@ %@",dateString, event.eventDate.date,[UtilityClass convertNSDateToUnix:selectedDate]);
}


//touch on map handling

-(IBAction)saveMapLoc:(id)sender
{
    [mapContainerView removeFromSuperview];
    [self performSelector:@selector(getAddressFromMap) withObject:nil afterDelay:0.1];
}

-(IBAction)cancelMapLoc:(id)sender
{
    [mapContainerView removeFromSuperview];    
}

#pragma mark -
#pragma mark DDAnnotationCoordinateDidChangeNotification

// NOTE: DDAnnotationCoordinateDidChangeNotification won't fire in iOS 4, use -mapView:annotationView:didChangeDragState:fromOldState: instead.
- (void)coordinateChanged_:(NSNotification *)notification
{	
	annotation = notification.object;
	annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
    annotation.subtitle=[UtilityClass getAddressFromLatLon:annotation.coordinate.latitude withLongitude:annotation.coordinate.longitude];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState 
{
	
	if (oldState == MKAnnotationViewDragStateDragging) 
    {
		annotation = (DDAnnotation *)annotationView.annotation;
		annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];		
        annotation.subtitle=[UtilityClass getAddressFromLatLon:annotation.coordinate.latitude withLongitude:annotation.coordinate.longitude];
	}
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
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

//reload map
-(void) reloadMap:(DDAnnotation *)annotation
{
//    =[UtilityClass getAddressFromLatLon:annotation.coordinate.latitude withLongitude:annotation.coordinate.longitude];
    [self performSelector:@selector(getLoc:) withObject:annotation afterDelay:0];
    [self.mapView setRegion:mapView.region animated:TRUE];
}

-(void)getLoc:(DDAnnotation *)annotation
{
    [UtilityClass getAddressFromLatLon:annotation.coordinate.latitude withLongitude:annotation.coordinate.longitude];
}

//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation 
//{
//    
//    self.currentLocation = newLocation;
//    self.currentLat =  newLocation.coordinate.latitude; 
//    self.currentLong =  newLocation.coordinate.longitude; 
//}

//draggable annotations changed

//lazy scroller

-(void) reloadScrolview
{
    int x=0; //declared for imageview x-axis point    
    NSArray* subviews = [NSArray arrayWithArray: frndListScrollView.subviews];
    UIImageView *imgView;
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
    frndListScrollView.contentSize=CGSizeMake([filteredList count]*65, 65);

    for(int i=0; i<[filteredList count];i++)               
    {
        if(i< [filteredList count]) 
        { 
            UserFriends *userFrnd=[[UserFriends alloc] init];
            userFrnd=[filteredList objectAtIndex:i];
            imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
            if([dicImages_msg valueForKey:userFrnd.imageUrl]) 
            { 
                //If image available in dictionary, set it to imageview 
                imgView.image = [dicImages_msg valueForKey:userFrnd.imageUrl]; 
            } 
            else 
            { 
                if(!isDragging_msg && !isDecliring_msg) 
                    
                {
                    //If scroll view moves set a placeholder image and start download image. 
                    [dicImages_msg setObject:[UIImage imageNamed:@"girl.png"] forKey:userFrnd.imageUrl]; 
                    [self performSelectorInBackground:@selector(DownLoad:) withObject:[NSNumber numberWithInt:i]];  
                    imgView.image = [UIImage imageNamed:@"girl.png"];                   
                }
                else 
                { 
                    // Image is not available, so set a placeholder image
                    imgView.image = [UIImage imageNamed:@"girl.png"];                   
                }               
            }
//            NSLog(@"userFrnd.imageUrl: %@",userFrnd.imageUrl);
            UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(x, 0, 65, 65)];
            UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(0, 45, 60, 20)];
            [name setFont:[UIFont fontWithName:@"Helvetica-Light" size:10]];
            [name setNumberOfLines:0];
            [name setText:userFrnd.userName];
            [name setBackgroundColor:[UIColor clearColor]];
            imgView.userInteractionEnabled = YES;
            imgView.tag = i;
            aView.tag=i;
            imgView.exclusiveTouch = YES;
            imgView.clipsToBounds = NO;
            imgView.opaque = YES;
            imgView.layer.borderColor=[[UIColor clearColor] CGColor];
            imgView.userInteractionEnabled=YES;
            imgView.layer.borderWidth=2.0;
            imgView.layer.masksToBounds = YES;
            [imgView.layer setCornerRadius:7.0];

            imgView.layer.borderColor=[[UIColor lightGrayColor] CGColor];                    
            for (int c=0; c<[selectedFriendsIndex count]; c++)
            {
                if ([[filteredList objectAtIndex:i] isEqual:[selectedFriendsIndex objectAtIndex:c]]) 
                {
                    imgView.layer.borderColor=[[UIColor greenColor] CGColor];
                    NSLog(@"found selected: %@",[selectedFriendsIndex objectAtIndex:c]);
                }
                else
                {
                }

            }
            [aView addSubview:imgView];
            [aView addSubview:name];
            UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
            tapGesture.numberOfTapsRequired = 1;
            [aView addGestureRecognizer:tapGesture];
            [tapGesture release];

            [frndListScrollView addSubview:aView];
        }
        x+=65;
    }
}

-(void)DownLoad:(NSNumber *)path
{
    NSAutoreleasePool *pl = [[NSAutoreleasePool alloc] init];
    int index = [path intValue];
    UserFriends *userFrnd=[[UserFriends alloc] init];
    userFrnd=[filteredList objectAtIndex:index];

    NSString *Link = userFrnd.imageUrl;
    //Start download image from url
    UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:Link]]];
    if(img)
    {
        //If download complete, set that image to dictionary
        [dicImages_msg setObject:img forKey:userFrnd.imageUrl];
    }
    // Now, we need to reload scroll view to load downloaded image
    [self performSelectorOnMainThread:@selector(reloadScrolview) withObject:path waitUntilDone:NO];
    [pl release];
}

//handling selection from scroll view of friends selection
-(IBAction) handleTapGesture:(UIGestureRecognizer *)sender
{
    int imageIndex =((UITapGestureRecognizer *)sender).view.tag;
    NSArray* subviews = [NSArray arrayWithArray: frndListScrollView.subviews];
    if ([selectedFriendsIndex containsObject:[filteredList objectAtIndex:[sender.view tag]]])
    {
        [selectedFriendsIndex removeObject:[friendListArr objectAtIndex:[sender.view tag]]];
    } 
    else 
    {
        [selectedFriendsIndex addObject:[friendListArr objectAtIndex:[sender.view tag]]];
    }
    NSLog(@"selectedFriendsIndex2 : %@",selectedFriendsIndex);
    for (int l=0; l<[subviews count]; l++)
    {
        if (l==imageIndex)
        {
            UIView *im=[subviews objectAtIndex:l];
            NSArray* subviews1 = [NSArray arrayWithArray: im.subviews];
            UIImageView *im1=[subviews1 objectAtIndex:0];
            [im1 setAlpha:1.0];
            im1.layer.borderWidth=2.0;
            im1.layer.masksToBounds = YES;
            [im1.layer setCornerRadius:7.0];
            im1.layer.borderColor=[[UIColor greenColor]CGColor];
        }
//        else
//        {
//            UIView *im1=[subviews objectAtIndex:l];
//            NSArray* subviews2 = [NSArray arrayWithArray: im1.subviews];
//            UIImageView *im2=[subviews2 objectAtIndex:0];
//            [im2 setAlpha:0.4];
//            im2.layer.borderWidth=2.0;
//            im2.layer.borderColor=[[UIColor lightGrayColor]CGColor];
//        }
    }
    [self reloadScrolview];
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

//lazy load method ends


//search bar delegate method starts
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText 
{
    // We don't want to do anything until the user clicks 
    // the 'Search' button.
    // If you wanted to display results as the user types 
    // you would do that here.
    //[self loadFriendListsData]; TODO: commented this
    searchText=friendSearchbar.text;
    
    if ([searchText length]>0) 
    {
        [self performSelector:@selector(searchResult) withObject:nil afterDelay:0.1];
        searchFlag=true;
        NSLog(@"searchText  %@",searchText);
    }
    else
    {
        searchText=@"";
        //[self loadFriendListsData]; TODO: commented this
        [filteredList removeAllObjects];
        filteredList = [[NSMutableArray alloc] initWithArray: friendListArr];
        [self reloadScrolview];
    }
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar 
{
    // searchBarTextDidBeginEditing is called whenever 
    // focus is given to the UISearchBar
    // call our activate method so that we can do some 
    // additional things when the UISearchBar shows.
    searchTexts=friendSearchbar.text;
    [UIView beginAnimations:@"FadeIn" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView commitAnimations];
    [self beganEditing];
    NSLog(@"2");    
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar 
{
    // searchBarTextDidEndEditing is fired whenever the 
    // UISearchBar loses focus
    // We don't need to do anything here.
//    [self.eventListTableView reloadData];
    [self endEditing];
    [friendSearchbar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // Clear the search text
    // Deactivate the UISearchBar
    friendSearchbar.text=@"";
    searchTexts=@"";
    
    [filteredList removeAllObjects];
    filteredList = [[NSMutableArray alloc] initWithArray: friendListArr];
    [self reloadScrolview];
    [friendSearchbar resignFirstResponder];
    NSLog(@"3");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar 
{
    // Do the search and show the results in tableview
    // Deactivate the UISearchBar
    // You'll probably want to do this on another thread
    // SomeService is just a dummy class representing some 
    // api that you are using to do the search
    
    NSLog(@"Search button clicked");
    searchTexts=friendSearchbar.text;
    searchFlag=false;
    [self searchResult];
    [friendSearchbar resignFirstResponder];    
}

-(void)searchResult
{
    [self loadDummydata];
    searchTexts = friendSearchbar.text;
    NSLog(@"in search method..");
    NSLog(@"filteredList99 %@ %@  %d  %d  imageDownloadsInProgress: %@",filteredList,friendListArr,[filteredList count],[friendListArr count], dicImages_msg);

    [filteredList removeAllObjects];
    
    if ([searchTexts isEqualToString:@""])
    {
        NSLog(@"null string");
        friendSearchbar.text=@"";
        filteredList = [[NSMutableArray alloc] initWithArray: friendListArr];
    }
    else
    {
        NSLog(@"filteredList999 %@ %@  %d  %d  imageDownloadsInProgress: %@",filteredList,friendListArr,[filteredList count],[friendListArr count], dicImages_msg);

        for (UserFriends *sTemp in friendListArr)
        {
            NSRange titleResultsRange = [sTemp.userName rangeOfString:searchTexts options:NSCaseInsensitiveSearch];		
            NSLog(@"sTemp.userName: %@",sTemp.userName);
            if (titleResultsRange.length > 0)
            {
                [filteredList addObject:sTemp];
                NSLog(@"filtered friend: %@", sTemp.userName);            
            }
            else
            {
            }
        }
    }
    searchFlag=false;    
    
    NSLog(@"filteredList %@ %@  %d  %d  imageDownloadsInProgress: %@",filteredList,friendListArr,[filteredList count],[friendListArr count], dicImages_msg);
    [self reloadScrolview];
}
//searchbar delegate method end

//keyboard hides input fields deleget methods

-(void)beganEditing
{
    //UIControl need to config here
    CGRect textFieldRect =
	[self.view.window convertRect:friendSearchbar.bounds fromView:friendSearchbar];
    
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
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

- (void)createEventDone:(NSNotification *)notif
{
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    NSLog(@"dele %@",[notif object]);
    ////    [self performSegueWithIdentifier:@"eventDetail" sender:self];
    //    ViewEventDetailViewController *modalViewControllerTwo = [[ViewEventDetailViewController alloc] init];
    ////    modalViewControllerTwo.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //    [self presentModalViewController:modalViewControllerTwo animated:YES];
    //    NSLog(@"GOT SERVICE DATA.. :D");
    
    //    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    //    ViewEventDetailViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"eventDetail"];
    //    [self presentModalViewController:controller animated:YES];
    [UtilityClass showAlert:@"Social Maps" :[notif object]];
    [self dismissModalViewControllerAnimated:YES];
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

@end

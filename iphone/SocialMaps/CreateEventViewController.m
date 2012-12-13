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
#import "LocationItemPlace.h"
#import "SelectCircleTableCell.h"
#import <Foundation/Foundation.h> 
#import "NotificationController.h"

@interface CreateEventViewController ()
- (void)coordinateChanged_:(NSNotification *)notification;
-(void)DownLoad:(NSNumber *)path;
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
@synthesize createView,photoPicker,eventImage,picSel,entryTextField,mapView,mapContainerView,addressLabel,segmentControl;
@synthesize createButton,createLabel,circleView,circleTableView,customSelectionView;

@synthesize customScrollView;
@synthesize customSearchBar;
@synthesize customTableView;
@synthesize private;

@synthesize totalNotifCount;

@synthesize upperView;
@synthesize lowerView;
@synthesize viewContainerScrollView;
@synthesize venueAddress,geolocation;

__strong NSMutableArray *friendsNameArr, *friendsIDArr, *friendListArr, *filteredList1, *filteredList2, *circleList;
bool searchFlag;
__strong int checkCount;
__strong NSString *searchTexts, *dateString;
int locationFlag=0;
CustomRadioButton *radio;
CustomRadioButton *radio1;

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

AppDelegate *smAppDelegate;
Event *event;
int entityFlag=0;
DDAnnotation *annotation;
bool isBackgroundTaskRunning;
int createNotf=0;
int updateNotf=0;
NSMutableArray*   neearMeAddressArr, *selectedCircleCheckArr, *selectedCustomCircleCheckArr;
NSMutableArray *permittedUserArr, *permittedCircleArr, *userCircleArr;
NSMutableArray *guestListIdArr, *myPlaceArr, *placeNameArr;

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
    
    circleList=[[NSMutableArray alloc] init];
    
    [circleList removeAllObjects];
    
    UserCircle *circle=[[UserCircle alloc]init];
    guestListIdArr=[[NSMutableArray alloc] init];
    
    
    for (int i=0; i<[circleListGlobalArray count]; i++)
        
    {
        
        circle=[circleListGlobalArray objectAtIndex:i];
        
        [circleList addObject:circle.circleName];
        
    }
    
    UserFriends *frnds=[[UserFriends alloc] init];
    
    ImgesName = [[NSMutableArray alloc] init];    
    
    
    
    searchTexts=[[NSString alloc] initWithString:@""];
    
    friendsNameArr=[[NSMutableArray alloc] init];
    
    friendsIDArr=[[NSMutableArray alloc] init];
    
    filteredList1=[[NSMutableArray alloc] init];
    
    friendListArr=[[NSMutableArray alloc] init];
    
    NSLog(@"event.guestList: %@",event.guestList);
    
    if (editFlag==true)
    {
        
        event=globalEditEvent;
        for (int j=0; j<[event.guestList count]; j++) 
        {
            UserFriends *guest=[event.guestList objectAtIndex:j];
            NSLog(@"guest.userId %@",guest.userId);
            [guestListIdArr addObject:guest.userId];
        }
    }

    
    for (int i=0; i<[friendListGlobalArray count]; i++)
        
    {
        
        frnds=[[UserFriends alloc] init];
        
        frnds=[friendListGlobalArray objectAtIndex:i];
        
        if ((frnds.imageUrl==NULL)||[frnds.imageUrl isEqual:[NSNull null]])
            
        {
            
            frnds.imageUrl=[[NSBundle mainBundle] pathForResource:@"blank" ofType:@"png"];
            
            NSLog(@"img url null %d",i);
            
        }
        
        else
            
        {
            
            NSLog(@"img url not null %d",i);            
            
        }
        
        NSLog(@"guestListIdArr %@  frnds.userId %@",guestListIdArr,frnds.userId);
        if (![guestListIdArr containsObject:frnds.userId])
        {
            [friendListArr addObject:frnds];
            NSLog(@"non invited added %@",frnds.userName);
//        [friendListArr replaceObjectAtIndex:i withObject:frnds];
//
        }
                
        
        NSLog(@"frnds.imageUrl %@  frnds.userName %@ frnds.userId %@",frnds.imageUrl,frnds.userName,frnds.userId);
        
    }
    
    filteredList1=[friendListArr mutableCopy];
    filteredList2=[friendListArr mutableCopy];
    //    NSLog(@"smAppDelegate.placeList %@",smAppDelegate.placeList);
    
}

- (id)init
{
    self.geolocation=[[Geolocation alloc] init];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isBackgroundTaskRunning=true;
	// Do any additional setup after loading the view.
    self.photoPicker = [[[PhotoPicker alloc] initWithNibName:nil bundle:nil] autorelease];
    self.photoPicker.delegate = self;
    self.picSel = [[UIImagePickerController alloc] init];
	self.picSel.allowsEditing = YES;
	self.picSel.delegate = self;	
    [upperView removeFromSuperview];
    [lowerView removeFromSuperview];
    [segmentControl setSelectedSegmentIndex:1];
    upperView.frame=CGRectMake(0, 0, upperView.frame.size.width, upperView.frame.size.height);

    lowerView.frame=CGRectMake(0, upperView.frame.size.height, lowerView.frame.size.width, lowerView.frame.size.height);
    viewContainerScrollView.contentSize=CGSizeMake(320, upperView.frame.size.height+lowerView.frame.size.height);    
    [viewContainerScrollView addSubview:upperView];
    [viewContainerScrollView addSubview:lowerView];
    
    NSArray *subviews = [friendSearchbar subviews];
    UIButton *cancelButton = [subviews objectAtIndex:2];
    cancelButton.tintColor = [UIColor darkGrayColor];
    
    frndListScrollView.delegate = self;
    customScrollView.delegate=self;
    friendListArr=[[NSMutableArray alloc] init];
    filteredList1=[[NSMutableArray alloc] init];
    filteredList2=[[NSMutableArray alloc] init];
    selectedCircleCheckArr=[[NSMutableArray alloc] init];
    selectedCustomCircleCheckArr=[[NSMutableArray alloc] init];
    permittedUserArr=[[NSMutableArray alloc] init]; 
    permittedCircleArr=[[NSMutableArray alloc] init];
    userCircleArr=[[NSMutableArray alloc] init];
    smAppDelegate=[[AppDelegate alloc] init];
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    event=[[Event alloc] init];
    neearMeAddressArr=[[NSMutableArray alloc] init];
    myPlaceArr=[[NSMutableArray alloc] init];
    placeNameArr=[[NSMutableArray alloc] init];
    for (int i=0; i<[smAppDelegate.placeList count]; i++)
    {
        LocationItemPlace *aPlaceItem = (LocationItemPlace*)[smAppDelegate.placeList objectAtIndex:i];
        [neearMeAddressArr addObject:aPlaceItem.placeInfo.name];
        NSLog(@"aPlaceItem.placeInfo.name %@  %@ %@",aPlaceItem.placeInfo.name,aPlaceItem.placeInfo.location.latitude,aPlaceItem.placeInfo.location.longitude);
    }

    //set scroll view content size.
    [self loadDummydata];
    
    selectedFriendsIndex=[[NSMutableArray alloc] init];
    customSelectedFriendsIndex=[[NSMutableArray alloc] init];
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

    if (editFlag==FALSE) 
    {
        event.permission=@"private";
    }
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(theCoordinate, 1000, 1000);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];  
    [self.mapView setRegion:adjustedRegion animated:YES];

	[self.mapView setCenterCoordinate:annotation.coordinate];
    
	[self.mapView addAnnotation:annotation];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults]; 
    smAppDelegate.authToken=[prefs stringForKey:@"authToken"];    

    radio = [[CustomRadioButton alloc] initWithFrame:CGRectMake(10, 45, 300, 47) numButtons:5 labels:[NSArray arrayWithObjects:@"Private",@"Friends",@"Circle",@"Public",@"Custom",nil]  default:0 sender:self tag:20001];
    radio.delegate = self;
    [lowerView addSubview:radio];
    
    radio1 = [[CustomRadioButton alloc] initWithFrame:CGRectMake(11, 69, 297, 49) numButtons:4 labels:[NSArray arrayWithObjects:@"Current location",@"My places",@"Places near to me",@"Point on map",nil]  default:0 sender:self tag:20002];
    radio1.delegate = self;
    [upperView addSubview:radio1];
    RestClient *rc = [[RestClient alloc] init];
    [rc getMyPlaces:@"Auth-Token" :smAppDelegate.authToken];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createEventDone:) name:NOTIF_CREATE_EVENT_DONE object:nil];    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateEventDone:) name:NOTIF_UPDATE_EVENT_DONE object:nil];
}

- (void)viewWillAppear:(BOOL)animated 
{
     createNotf=0;
     updateNotf=0;

    [self displayNotificationCount];
	isBackgroundTaskRunning=true;
	[super viewWillAppear:animated];
    [customSelectionView removeFromSuperview];
	[circleView removeFromSuperview];
    if (editFlag==true)
    {
        if (event.guestCanInvite) {
            [guestCanInviteButton setImage:[UIImage imageNamed:@"people_checked.png"] forState:UIControlStateNormal];
        }
        else
        {
            [guestCanInviteButton setImage:[UIImage imageNamed:@"list_uncheck.png"] forState:UIControlStateNormal];        
        }
        event=globalEditEvent;
        [private setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
        [friends setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
        [degreeFriends setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
        [people setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
        [custom setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];    
        if ([event.permission isEqualToString:@"public"])
        {
            [people setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
        }
        else if ([event.permission isEqualToString:@"private"])
        {
            [private setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
        }
        else if ([event.permission isEqualToString:@"friends"])
        {
            [friends setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
        }
        else if ([event.permission isEqualToString:@"circles"])
        {
            [degreeFriends setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
        }
        else if ([event.permission isEqualToString:@"custom"])
        {
            [custom setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];    
        }
        addressLabel.text=event.eventAddress;
        
    }
    else
    {
        event=[[Event alloc] init];
    }
    
    if (editFlag==true)
    {
        [createButton setTitle:@"Update" forState:UIControlStateNormal];
        [createLabel setText:@"Update Event"];

    }
    else
    {
        [createButton setTitle:@"Create" forState:UIControlStateNormal];
        [createLabel setText:@"Create Event"];
    }
    
	// NOTE: This is optional, DDAnnotationCoordinateDidChangeNotification only fired in iPhone OS 3, not in iOS 4.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coordinateChanged_:) name:@"DDAnnotationCoordinateDidChangeNotification" object:nil];
    
    if (isFromVenue==TRUE) 
    {
        event.eventLocation=self.geolocation;
        event.eventAddress=venueAddress;
        NSLog(@"geolocation: %@",self.geolocation);
        NSLog(@"globalEvent.eventName %@ globalEvent.eventLocation.latitude %@,globalEvent.eventLocation.longitude %@",event.eventAddress,event.eventLocation.latitude,event.eventLocation.longitude);
//        [self performSelector:@selector(getCurrentAddress) withObject:nil afterDelay:0.1];
        [self eventFromVenue];
    }
    else if (editFlag==TRUE)
    {
        addressLabel.text=event.eventAddress;
        [annotation setCoordinate:(CLLocationCoordinate2DMake([event.eventLocation.latitude doubleValue], [event.eventLocation.longitude doubleValue]))];
        [radio1 gotoButton:3];
    }
    else
    {
        [self performSelector:@selector(getCurrentAddress) withObject:nil afterDelay:0.1];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMyPlaces:) name:NOTIF_GET_MY_PLACES_DONE object:nil];
    

    smAppDelegate.currentModelViewController = self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (editFlag==true)
    {
        if (event.guestCanInvite) {
            [guestCanInviteButton setImage:[UIImage imageNamed:@"people_checked.png"] forState:UIControlStateNormal];
        }
        else
        {
            [guestCanInviteButton setImage:[UIImage imageNamed:@"list_uncheck.png"] forState:UIControlStateNormal];        
        }
        event=globalEditEvent;
        [private setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
        [friends setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
        [degreeFriends setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
        [people setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
        [custom setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];    
        if ([event.permission isEqualToString:@"public"])
        {
            [people setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
        }
        else if ([event.permission isEqualToString:@"private"])
        {
            [private setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
        }
        else if ([event.permission isEqualToString:@"friends"])
        {
            [friends setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
        }
        else if ([event.permission isEqualToString:@"circles"])
        {
            [degreeFriends setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
        }
        else if ([event.permission isEqualToString:@"custom"])
        {
            [custom setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];    
        }
        addressLabel.text=event.eventAddress;
        
    }
}

-(void)getCurrentAddress
{
    addressLabel.text = @"Loading current address...";
    annotation.subtitle=addressLabel.text;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        addressLabel.text=[UtilityClass getAddressFromLatLon:[smAppDelegate.currPosition.latitude doubleValue] withLongitude:[smAppDelegate.currPosition.longitude doubleValue]];
        dispatch_async(dispatch_get_main_queue(), ^{
            annotation.subtitle=addressLabel.text;
            NSLog(@"get current address.");
        });
    });
}

-(void)getAddressFromMap
{
    addressLabel.text=[UtilityClass getAddressFromLatLon:annotation.coordinate.latitude withLongitude:annotation.coordinate.longitude];
}

- (void)viewWillDisappear:(BOOL)animated
{
	
	[super viewWillDisappear:animated];
	isBackgroundTaskRunning=false;
	// NOTE: This is optional, DDAnnotationCoordinateDidChangeNotification only fired in iPhone OS 3, not in iOS 4.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_MY_PLACES_DONE object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"DDAnnotationCoordinateDidChangeNotification" object:nil];
    globalEditEvent=NULL;
    editFlag=false;
    ImgesName=nil;
    frndListScrollView=nil;

//    [self viewDidUnload];
}

-(void)myPlacesWasSelected:(NSNumber *)selectedIndex:(id)element
{
    int selectedLocation= [selectedIndex intValue];
    NSLog(@"sel ind %d %@",[selectedIndex intValue],[myPlaceArr objectAtIndex:selectedLocation]);
    Places *place=[myPlaceArr objectAtIndex:selectedLocation];
    addressLabel.text=place.name;
    event.eventAddress=place.name;
    event.eventLocation.latitude=place.location.latitude;
    event.eventLocation.longitude=place.location.longitude;
}

- (void)getMyPlaces:(NSNotification *)notif
{
    myPlaceArr=[notif object];
    for (int i=0; i<[myPlaceArr count]; i++)
    {
        Places *place=[myPlaceArr objectAtIndex:i];
        [placeNameArr addObject:place.name];
    }
}

- (void) radioButtonClicked:(int)indx sender:(id)sender {
    NSLog(@"radioButtonClicked index = %d %d", indx,[sender tag]);
    
    [smAppDelegate hideActivityViewer];
    //    [smAppDelegate.window setUserInteractionEnabled:NO];
    
    if ([sender tag] == 20001) 
    {
        switch (indx) 
        {
            case 4:
                NSLog(@"custom");
                event.permission=@"custom";
                [self.view addSubview:customSelectionView];
                break;
            case 3:
                NSLog(@"public");
                event.permission=@"public";
                break;
            case 2:
                NSLog(@"circles");
                event.permission=@"circles";
                break;
            case 1:
                NSLog(@"friends");
                event.permission=@"friends";
                break;
            case 0:
                NSLog(@"private");
                event.permission=@"private";
                break;
            default:
                break;
        }
    }
    if ([sender tag] == 20002) 
    {
        switch (indx) 
        {
            case 3:
                NSLog(@"point on map");
                [self.view addSubview:mapContainerView];
                break;
            case 2:
                NSLog(@"near me location");
                if (isFromVenue==TRUE) 
                {
                    [ActionSheetPicker displayActionPickerWithView:sender data:neearMeAddressArr selectedIndex:[self eventFromVenue] target:self action:@selector(placeWasSelected::) title:@"Near Me Location"];
                }
                else {
                    [ActionSheetPicker displayActionPickerWithView:sender data:neearMeAddressArr selectedIndex:0 target:self action:@selector(placeWasSelected::) title:@"Near Me Location"];
                }
                NSLog(@"neearMeAddressArr: %@",neearMeAddressArr);
                break;
            case 1:
                NSLog(@"my places");
                if ([placeNameArr count]==0)
                {
                    [UtilityClass showAlert:@"Social Maps" :@"You have no saved places."];
                }
                else
                {
                    [ActionSheetPicker displayActionPickerWithView:sender data:placeNameArr selectedIndex:0 target:self action:@selector(myPlacesWasSelected::) title:@"My places"];
                }
                break;
            case 0:
                NSLog(@"POM");
                [self performSelector:@selector(getCurrentAddress) withObject:nil afterDelay:0.1];
                break;
            default:
                break;
        }
    }
}

- (void) photoPickerDone:(bool)status image:(UIImage*)img
{
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
    entryTextField.text=event.eventName;
    entryTextField.placeholder=@"Name...";
}

-(IBAction)summaryButtonAction
{
    [createView setHidden:NO];    
    entityFlag=1;
    entryTextField.text=event.eventShortSummary;
    entryTextField.placeholder=@"Summary...";
}    

-(IBAction)descriptionButtonAction
{
    [createView setHidden:NO];    
    entityFlag=2;
    entryTextField.text=event.eventDescription;
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
    self.eventImagview.image=[UIImage imageNamed:@"blank.png"];
}

//event info entry ends

//share with radio button starts
-(IBAction)privateButtonAction
{
    [private setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
    [friends setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [degreeFriends setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [people setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [custom setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    event.permission=@"private";
    
}

-(IBAction)friendsButtonAction
{
    [private setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [friends setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
    [degreeFriends setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [people setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [custom setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    event.permission=@"friends";
}

-(IBAction)degreeFriendsButtonAction
{
    [private setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [friends setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [degreeFriends setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
    [people setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [custom setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];    
    event.permission=@"circles";
}

-(IBAction)peopleButtonAction
{
    [private setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [friends setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [degreeFriends setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [people setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
    [custom setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    event.permission=@"public";
}

-(IBAction)customButtonAction
{
    [private setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [friends setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [degreeFriends setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [people setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [custom setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
    event.permission=@"custom";
    [self.view addSubview:customSelectionView];
}
//share with radio button ends up

-(IBAction)saveCustom:(id)sender
{
    [permittedUserArr removeAllObjects]; 
    [permittedCircleArr removeAllObjects]; 
    for (int i=0; i<[selectedCustomCircleCheckArr count]; i++) 
    {
       NSLog(@" %@",((UserCircle *)[circleListGlobalArray objectAtIndex:((NSIndexPath *)[selectedCustomCircleCheckArr objectAtIndex:i]).row]).circleName) ;
        NSLog(@"selectedCustomCircleCheckArr %@ circleList %@",selectedCustomCircleCheckArr,circleListGlobalArray);
        
        [permittedCircleArr addObject:((UserCircle *)[circleListGlobalArray objectAtIndex:((NSIndexPath *)[selectedCustomCircleCheckArr objectAtIndex:i]).row]).circleID];
    }
    
    for (int i=0; i<[customSelectedFriendsIndex count]; i++)
    {
//        ((UserFriends *)[customSelectedFriendsIndex objectAtIndex:i]).userId;
        [permittedUserArr addObject:((UserFriends *)[customSelectedFriendsIndex objectAtIndex:i]).userId];
    }
    NSLog(@"permittedCircleArr %@ permittedUserArr %@",permittedCircleArr,permittedUserArr);
    event.permittedUsers=permittedUserArr;
    event.circleList=permittedCircleArr;
    [customSelectionView removeFromSuperview];
}

-(IBAction)cancelCustom:(id)sender
{
    [selectedCustomCircleCheckArr removeAllObjects];
    [customSelectedFriendsIndex removeAllObjects];
    [customSelectionView removeFromSuperview];
}

-(IBAction)customSegment:(id)sender
{
    NSLog(@"segmentControl.selectedSegmentIndex: %d",segmentControl.selectedSegmentIndex);
    if (segmentControl.selectedSegmentIndex==0)
    {
        [customTableView setHidden:YES];
        [customScrollView setHidden:NO];
        [customSearchBar setHidden:NO];
    }
    else
    {
        [customTableView setHidden:NO];
        [customScrollView setHidden:YES];
        [customSearchBar setHidden:YES];        
    }
}

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

-(IBAction)neamePlaceButtonAction:(id)sender
{
    [curLoc setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [myPlace setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [neamePlace setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
    [pointOnMap setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    if (isFromVenue==TRUE) 
    {
        [ActionSheetPicker displayActionPickerWithView:sender data:neearMeAddressArr selectedIndex:[self eventFromVenue] target:self action:@selector(placeWasSelected::) title:@"Near Me Location"];
    }
    else {
        [ActionSheetPicker displayActionPickerWithView:sender data:neearMeAddressArr selectedIndex:0 target:self action:@selector(placeWasSelected::) title:@"Near Me Location"];
    }
    NSLog(@"neearMeAddressArr: %@",neearMeAddressArr);
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
//    [ActionSheetPicker displayActionPickerWithView:sender data:circleList selectedIndex:2 target:self action:@selector(circleWasSelected::) title:@"Circle"];
    [self.view addSubview:circleView];
}

-(IBAction)saveCircle:(id)sender
{
    [circleView removeFromSuperview];
}

-(IBAction)cancelCircle:(id)sender
{
    [circleView removeFromSuperview];
}

-(IBAction)guestCanInvite:(id)sender
{
    checkCount++;
    if (checkCount%2!=0)
    {
        [guestCanInviteButton setImage:[UIImage imageNamed:@"people_checked.png"] forState:UIControlStateNormal];
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
    for (int i=0; i<[filteredList1 count]; i++)
    {
        [selectedFriendsIndex addObject:[filteredList1 objectAtIndex:i]];
    }
    [self reloadScrolview];
}

-(IBAction)createEvent:(id)sender
{
    //title*, description*,eventShortSummary,eventImage, guests[], address, lat, lng*, time* , 
    NSMutableString *msg=[[NSMutableString alloc] init];
    [msg appendString:@"Please enter "];
    bool validationFlag=false;
    NSLog(@"event.eventName %@ event.eventDescription %@ event.eventShortSummary %@  guests: %@ event.eventImageUrl %@ event.eventDate %@ event.permission %@",event.eventName,event.eventDescription,event.eventShortSummary,event.guestList,event.eventImageUrl,event.eventDate.date,event.permission);
    NSLog(@"event.eventAddress %@ ,event.eventLocation.latitude %@",event.eventAddress,event.eventLocation.latitude);
    if (event.eventName==NULL)
    {
        [msg appendString:@"name, "];
        validationFlag=true;
    }
    
    if (event.eventDescription==NULL)
    {
        [msg appendString:@"description, "];
            validationFlag=true;
    }
    if (event.eventShortSummary==NULL)
    {
        [msg appendString:@"short summary, "];
                validationFlag=true;
    }
//    if (event.eventLocation.longitude==NULL)
//    {
//        [msg appendString:@"event location, "];
//                validationFlag=true;
//    }
    if (event.eventDate.date==NULL)
    {
        [msg appendString:@"date"];
        validationFlag=true;
    }
    
    if (validationFlag==true) 
    {
        [UtilityClass showAlert:@"Social Maps" :msg];
    }
    else
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
            event.guestList=userIDs;
            
        }
        if ((locationFlag!=1) && (isFromVenue==false))
        {
            event.eventLocation.latitude=[NSString stringWithFormat:@"%lf",annotation.coordinate.latitude];
            event.eventLocation.longitude=[NSString stringWithFormat:@"%lf",annotation.coordinate.longitude];
            event.eventAddress=annotation.subtitle;
        }
        [userCircleArr removeAllObjects];
        for (int i=0; i<[selectedCircleCheckArr count]; i++) 
        {
            NSLog(@" %@",((UserCircle *)[circleListGlobalArray objectAtIndex:((NSIndexPath *)[selectedCircleCheckArr objectAtIndex:i]).row]).circleName) ;            
            [userCircleArr addObject:((UserCircle *)[circleListGlobalArray objectAtIndex:((NSIndexPath *)[selectedCircleCheckArr objectAtIndex:i]).row]).circleID];
        }
        event.circleList=userCircleArr;
        if (isFromVenue==TRUE)
        {
            useLocalData=FALSE;
        }
        if (editFlag==true)
        {
            [event.guestList addObjectsFromArray:guestListIdArr];
            [rc updateEvent:event.eventID:event:@"Auth-Token":smAppDelegate.authToken];
        }
        else
        {
            [rc createEvent:event:@"Auth-Token":smAppDelegate.authToken];
        }
        NSLog(@"event.eventName %@ event.eventDescription %@ event.eventShortSummary %@  guests: %@ event.eventImageUrl %@ event.eventDate %@",event.eventName,event.eventDescription,event.eventShortSummary,event.guestList,event.eventImageUrl,event.eventDate.date);

    }
    
}

-(IBAction)cancelEvent:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
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

-(IBAction)backButton:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)circleWasSelected:(NSNumber *)selectedIndex:(id)element 
{
	//Selection was made
//	int selectedCircleIndex = [selectedIndex intValue];
}

-(void)placeWasSelected:(NSNumber *)selectedIndex:(id)element 
{
    locationFlag=1;
    int selectedLocation=[selectedIndex intValue];
    NSLog(@"selectedLocation %d",selectedLocation);
    LocationItemPlace *aPlaceItem = (LocationItemPlace*)[smAppDelegate.placeList objectAtIndex:selectedLocation];
    NSLog(@"aPlaceItem.placeInfo.name %@  %@ %@",aPlaceItem.placeInfo.name,aPlaceItem.placeInfo.location.latitude,aPlaceItem.placeInfo.location.longitude);
    event.eventLocation.latitude=aPlaceItem.placeInfo.location.latitude;
    event.eventLocation.longitude=aPlaceItem.placeInfo.location.longitude;
    event.eventAddress=aPlaceItem.placeInfo.name;
    addressLabel.text=aPlaceItem.placeInfo.name;
}

-(int)eventFromVenue
{
    if (isFromVenue==TRUE) 
    {
        NSLog(@"venueAddress: %@",venueAddress);
        addressLabel.text=venueAddress;
        LocationItemPlace *locItemPlace;
        for (int i=0; i<[smAppDelegate.placeList count]; i++)
        {
            if ([((LocationItemPlace *)[smAppDelegate.placeList objectAtIndex:i]).itemAddress isEqualToString:venueAddress])
            {
                locItemPlace = (LocationItemPlace *)[smAppDelegate.placeList objectAtIndex:i];
                [curLoc setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
                [myPlace setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
                [neamePlace setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
                [pointOnMap setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
                return i;
            }
        }
        [radio gotoButton:2];
    }
    return 0;
}

- (void)dateWasSelected:(NSDate *)selectedDate:(id)element 
{
    NSDate *date =selectedDate;
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    event.eventDate.date=[UtilityClass convertNSDateToUnix:date];
    dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH.mm Z"];    
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

//table view delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [circleList count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"circleTableCell";
    static NSString *CustomCellIdentifier = @"customCircleTableCell";
            
    SelectCircleTableCell *cell = [circleTableView
                                dequeueReusableCellWithIdentifier:CellIdentifier];
    
    SelectCircleTableCell *customCell = [customTableView
                                   dequeueReusableCellWithIdentifier:CustomCellIdentifier];

    if (cell == nil)
    {
            cell = [[SelectCircleTableCell alloc]
                    initWithStyle:UITableViewCellStyleDefault 
                    reuseIdentifier:CellIdentifier];
        
        customCell = [[SelectCircleTableCell alloc]
                initWithStyle:UITableViewCellStyleDefault 
                reuseIdentifier:CustomCellIdentifier];
    }
    
    // Configure the cell...
    if ([[circleList objectAtIndex:indexPath.row] isEqual:[NSNull null]]) 
    {
        cell.circrcleName.text=[NSString stringWithFormat:@"Custom (%d)",[((UserCircle *)[circleListGlobalArray objectAtIndex:indexPath.row]).friends count]] ;
        customCell.circrcleName.text=[NSString stringWithFormat:@"Custom (%d)",[((UserCircle *)[circleListGlobalArray objectAtIndex:indexPath.row]).friends count]] ;
    }
    else 
    {
        [((UserCircle *)[circleListGlobalArray objectAtIndex:indexPath.row]).friends count];
        cell.circrcleName.text=[NSString stringWithFormat:@"%@ (%d)",[circleList objectAtIndex:indexPath.row],[((UserCircle *)[circleListGlobalArray objectAtIndex:indexPath.row]).friends count]] ;
        customCell.circrcleName.text=[NSString stringWithFormat:@"%@ (%d)",[circleList objectAtIndex:indexPath.row],[((UserCircle *)[circleListGlobalArray objectAtIndex:indexPath.row]).friends count]] ;        
    }
    
    if ([selectedCircleCheckArr containsObject:indexPath]) 
    {
        [cell.circrcleCheckbox setImage:[UIImage imageNamed:@"people_checked.png"] forState:UIControlStateNormal];
    }
    else
    {
        [cell.circrcleCheckbox setImage:[UIImage imageNamed:@"list_uncheck.png"] forState:UIControlStateNormal];
    }

    if ([selectedCustomCircleCheckArr containsObject:indexPath]) 
    {
        [customCell.circrcleCheckbox setImage:[UIImage imageNamed:@"people_checked.png"] forState:UIControlStateNormal];
    }
    else
    {
        [customCell.circrcleCheckbox setImage:[UIImage imageNamed:@"list_uncheck.png"] forState:UIControlStateNormal];
    }
    
    [cell.circrcleCheckbox addTarget:self action:@selector(handleTableViewCheckbox:) forControlEvents:UIControlEventTouchUpInside];

    [customCell.circrcleCheckbox addTarget:self action:@selector(handleCustomTableViewCheckbox:) forControlEvents:UIControlEventTouchUpInside];
    
    if (tableView==customTableView)
    {
        return customCell;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)handleTableViewCheckbox:(id)sender
{
    SelectCircleTableCell *clickedCell = (SelectCircleTableCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.circleTableView indexPathForCell:clickedCell];
//    [clickedCell.9 setImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
    if ([selectedCircleCheckArr containsObject:clickedButtonPath])
    {
        [selectedCircleCheckArr removeObject:clickedButtonPath];
        [clickedCell.circrcleCheckbox setImage:[UIImage imageNamed:@"list_uncheck.png"] forState:UIControlStateNormal];
    }
    else
    {
        [selectedCircleCheckArr addObject:clickedButtonPath];
        [clickedCell.circrcleCheckbox setImage:[UIImage imageNamed:@"people_checked.png"] forState:UIControlStateNormal];
    }
    NSLog(@"selectedCircleCheckArr: %@",selectedCircleCheckArr);    
}

-(void)handleCustomTableViewCheckbox:(id)sender
{
    SelectCircleTableCell *clickedCell = (SelectCircleTableCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.customTableView indexPathForCell:clickedCell];
    //    [clickedCell.9 setImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
    if ([selectedCustomCircleCheckArr containsObject:clickedButtonPath])
    {
        [selectedCustomCircleCheckArr removeObject:clickedButtonPath];
        [clickedCell.circrcleCheckbox setImage:[UIImage imageNamed:@"list_uncheck.png"] forState:UIControlStateNormal];
    }
    else
    {
        [selectedCustomCircleCheckArr addObject:clickedButtonPath];
        [clickedCell.circrcleCheckbox setImage:[UIImage imageNamed:@"people_checked.png"] forState:UIControlStateNormal];
    }
    NSLog(@"selectedCircleCheckArr: %@",selectedCustomCircleCheckArr);    
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState 
{
	
	if (oldState == MKAnnotationViewDragStateDragging) 
    {
		annotation = (DDAnnotation *)annotationView.annotation;
//        annotation.coordinate.latitude=[smAppDelegate.currPosition.latitude doubleValue];
//        annotation.coordinate.longitude=[smAppDelegate.currPosition.longitude doubleValue];
        
		annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];		
        annotation.subtitle=[UtilityClass getAddressFromLatLon:annotation.coordinate.latitude withLongitude:annotation.coordinate.longitude];
	}
}

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
    NSLog(@"event create scroll init %@",dicImages_msg);
    if (isBackgroundTaskRunning==true)
    {
        int x=0; //declared for imageview x-axis point    
        int x2=0; //declared for imageview x-axis point            
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
       NSArray* subviews1 = [[NSArray arrayWithArray: customScrollView.subviews] mutableCopy];
        for (UIView* view in subviews1) 
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
        
        frndListScrollView.contentSize=CGSizeMake([filteredList1 count]*80, 100);
        customScrollView.contentSize=CGSizeMake([filteredList2 count]*65, 65);
        
        NSLog(@"event create isBackgroundTaskRunning %i",isBackgroundTaskRunning);
        for(int i=0; i<[filteredList1 count];i++)               
        {
            if(i< [filteredList1 count]) 
            { 
                UserFriends *userFrnd=[[UserFriends alloc] init];
                userFrnd=[filteredList1 objectAtIndex:i];
                imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
                
                if ((userFrnd.imageUrl==NULL)||[userFrnd.imageUrl isEqual:[NSNull null]])
                {
                    imgView.image = [UIImage imageNamed:@"blank.png"];
                } 
                else if([dicImages_msg valueForKey:userFrnd.imageUrl]) 
                { 
                    //If image available in dictionary, set it to imageview 
                    imgView.image = [dicImages_msg valueForKey:userFrnd.imageUrl]; 
                } 
                else 
                { 
                    NSLog(@"[dicImages_msg objectForKey:userFrnd.imageUrl] %@",[dicImages_msg objectForKey:userFrnd.imageUrl]);
                    if((!isDragging_msg && !isDecliring_msg)&&([dicImages_msg objectForKey:userFrnd.imageUrl]==NULL))
                        
                    {
                        //If scroll view moves set a placeholder image and start download image. 
                        [dicImages_msg setObject:[UIImage imageNamed:@"blank.png"] forKey:userFrnd.imageUrl]; 
                        [self performSelectorInBackground:@selector(DownLoad:) withObject:[NSNumber numberWithInt:i]];  
                        imgView.image = [UIImage imageNamed:@"blank.png"];             
                        NSLog(@"create downloading called");
                    }
                    else 
                    { 
                        // Image is not available, so set a placeholder image
                        imgView.image = [UIImage imageNamed:@"blank.png"];                   
                    }               
                }
                //            NSLog(@"userFrnd.imageUrl: %@",userFrnd.imageUrl);
                UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(x, 0, 80, 80)];
//                UIView *secView=[[UIView alloc] initWithFrame:CGRectMake(x, 0, 65, 65)];
                UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(0, 70, 80, 20)];
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
                    if ([[filteredList1 objectAtIndex:i] isEqual:[selectedFriendsIndex objectAtIndex:c]]) 
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
            x+=80;
        }
        
        //handling custom scroller
        for(int i=0; i<[filteredList2 count];i++)               
        {
            if(i< [filteredList2 count]) 
            { 
                UserFriends *userFrnd=[[UserFriends alloc] init];
                userFrnd=[filteredList2 objectAtIndex:i];
                imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
                if (userFrnd.imageUrl == nil) 
                {
                    imgView.image = [UIImage imageNamed:@"blank.png"];
                } 
                else if([dicImages_msg valueForKey:userFrnd.imageUrl]) 
                { 
                    //If image available in dictionary, set it to imageview 
                    imgView.image = [dicImages_msg valueForKey:userFrnd.imageUrl]; 
                } 
                else 
                { 
                    if((!isDragging_msg && !isDecliring_msg)&&([dicImages_msg objectForKey:userFrnd.imageUrl]==nil)) 
                        
                    {
                        //If scroll view moves set a placeholder image and start download image. 
                        [dicImages_msg setObject:[UIImage imageNamed:@"blank.png"] forKey:userFrnd.imageUrl]; 
                        [self performSelectorInBackground:@selector(DownLoad:) withObject:[NSNumber numberWithInt:i]];  
                        imgView.image = [UIImage imageNamed:@"blank.png"];                   
                    }
                    else 
                    { 
                        // Image is not available, so set a placeholder image
                        imgView.image = [UIImage imageNamed:@"blank.png"];                   
                    }               
                }
                //            NSLog(@"userFrnd.imageUrl: %@",userFrnd.imageUrl);
                UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(x2, 0, 65, 65)];
//                UIView *secView=[[UIView alloc] initWithFrame:CGRectMake(x2, 0, 65, 65)];
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
                for (int c=0; c<[customSelectedFriendsIndex count]; c++)
                {
                    if ([[filteredList2 objectAtIndex:i] isEqual:[customSelectedFriendsIndex objectAtIndex:c]]) 
                    {
                        imgView.layer.borderColor=[[UIColor greenColor] CGColor];
                        NSLog(@"found selected: %@",[customSelectedFriendsIndex objectAtIndex:c]);
                    }
                    else
                    {
                    }
                }
                [aView addSubview:imgView];
                [aView addSubview:name];
                UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(customScrollhandleTapGesture:)];
                tapGesture.numberOfTapsRequired = 1;
                [aView addGestureRecognizer:tapGesture];
                [tapGesture release];           
                [customScrollView addSubview:aView];
            }        
            x2+=65;
        }
    }
}

-(void)DownLoad:(NSNumber *)path
{
    if (isBackgroundTaskRunning==true)
    {
//    NSAutoreleasePool *pl = [[NSAutoreleasePool alloc] init];
    int index = [path intValue];
    UserFriends *userFrnd=[[UserFriends alloc] init];
    userFrnd=[filteredList1 objectAtIndex:index];

    NSString *Link = userFrnd.imageUrl;
    //Start download image from url
    UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:Link]]];
    if(img)
    {
        //If download complete, set that image to dictionary
        [dicImages_msg setObject:img forKey:userFrnd.imageUrl];
        [self reloadScrolview];
    }
    // Now, we need to reload scroll view to load downloaded image
//    [self performSelectorOnMainThread:@selector(reloadScrolview) withObject:path waitUntilDone:NO];
//    [pl release];
    }
}

//handling selection from scroll view of friends selection
-(IBAction) handleTapGesture:(UIGestureRecognizer *)sender
{
//    int imageIndex =((UITapGestureRecognizer *)sender).view.tag;
    NSArray* subviews = [NSArray arrayWithArray: frndListScrollView.subviews];
    if ([selectedFriendsIndex containsObject:[filteredList1 objectAtIndex:[sender.view tag]]])
    {
        [selectedFriendsIndex removeObject:[filteredList1 objectAtIndex:[sender.view tag]]];
    } 
    else 
    {
        [selectedFriendsIndex addObject:[filteredList1 objectAtIndex:[sender.view tag]]];
    }
    UserFriends *frnds=[[UserFriends alloc] init];
    frnds=[filteredList1 objectAtIndex:[sender.view tag]];
    NSLog(@"selectedFriendsIndex2 : %@",selectedFriendsIndex);
    for (int l=0; l<[subviews count]; l++)
    {
        UIView *im=[subviews objectAtIndex:l];
        NSArray* subviews1 = [NSArray arrayWithArray: im.subviews];
        UIImageView *im1=[subviews1 objectAtIndex:0];

        if ([im1.image isEqual:frnds.userProfileImage])
        {
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

//handling selection from custom scroll view of friends selection
-(IBAction) customScrollhandleTapGesture:(UIGestureRecognizer *)sender
{
//    int imageIndex =((UITapGestureRecognizer *)sender).view.tag;
    NSArray* subviews = [NSArray arrayWithArray: customScrollView.subviews];
    if ([customSelectedFriendsIndex containsObject:[filteredList2 objectAtIndex:[sender.view tag]]])
    {
        [customSelectedFriendsIndex removeObject:[filteredList2 objectAtIndex:[sender.view tag]]];
    } 
    else 
    {
        [customSelectedFriendsIndex addObject:[filteredList2 objectAtIndex:[sender.view tag]]];
    }
    UserFriends *frnds=[[UserFriends alloc] init];
    frnds=[filteredList2 objectAtIndex:[sender.view tag]];
    NSLog(@"selectedFriendsIndex2 : %@",selectedFriendsIndex);
    for (int l=0; l<[subviews count]; l++)
    {
        UIView *im=[subviews objectAtIndex:l];
        NSArray* subviews1 = [NSArray arrayWithArray: im.subviews];
        UIImageView *im1=[subviews1 objectAtIndex:0];
        
        if ([im1.image isEqual:frnds.userProfileImage])
        {
            [im1 setAlpha:1.0];
            im1.layer.borderWidth=2.0;
            im1.layer.masksToBounds = YES;
            [im1.layer setCornerRadius:7.0];
            im1.layer.borderColor=[[UIColor greenColor]CGColor];
        }        
    }
    [self reloadScrolview];
}

//scroll view delegate method
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
    if (searchBar==customSearchBar)
    {
        searchText=customSearchBar.text;
        
        if ([searchText length]>0) 
        {
            [self performSelector:@selector(searchResultCustom) withObject:nil afterDelay:0.1];
            searchFlag=true;
            NSLog(@"searchText  %@",searchText);
        }
        else
        {
            searchText=@"";
            //[self loadFriendListsData]; TODO: commented this
            [filteredList2 removeAllObjects];
            filteredList2 = [[NSMutableArray alloc] initWithArray: friendListArr];
            [self reloadScrolview];
        }
        

    }
    else
    {
        
    }
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
        [filteredList1 removeAllObjects];
        filteredList1 = [[NSMutableArray alloc] initWithArray: friendListArr];
        [self reloadScrolview];
    }
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar 
{
    // searchBarTextDidBeginEditing is called whenever 
    // focus is given to the UISearchBar
    // call our activate method so that we can do some 
    // additional things when the UISearchBar shows.
    if (searchBar==customSearchBar)
    {
        searchTexts=customSearchBar.text;
        [self beganEditing:customSearchBar];
    }
    else
    {
    searchTexts=friendSearchbar.text;
    [self beganEditing:friendSearchbar];

    }
    [UIView beginAnimations:@"FadeIn" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView commitAnimations];
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
    [customSearchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // Clear the search text
    // Deactivate the UISearchBar
    if (searchBar==customSearchBar)
    {
        customSearchBar.text=@"";
        searchTexts=@"";        
        [filteredList2 removeAllObjects];
        filteredList2 = [[NSMutableArray alloc] initWithArray: friendListArr];
        [self reloadScrolview];
        [customSearchBar resignFirstResponder];
        NSLog(@"3");        
    }
    else
    {
    friendSearchbar.text=@"";
    searchTexts=@"";    
    [filteredList1 removeAllObjects];
    filteredList1 = [[NSMutableArray alloc] initWithArray: friendListArr];
    [self reloadScrolview];
    [friendSearchbar resignFirstResponder];
    NSLog(@"3");
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar 
{
    // Do the search and show the results in tableview
    // Deactivate the UISearchBar
    // You'll probably want to do this on another thread
    // SomeService is just a dummy class representing some 
    // api that you are using to do the search
    if (searchBar==customSearchBar)
    {
        NSLog(@"Search button clicked");
        searchTexts=customSearchBar.text;
        searchFlag=false;
        [self searchResultCustom];
        [customSearchBar resignFirstResponder];    

    }
    else
    {
        NSLog(@"Search button clicked");
        searchTexts=friendSearchbar.text;
        searchFlag=false;
        [self searchResult];
        [friendSearchbar resignFirstResponder];    

    }
}

-(void)searchResult
{
    [self loadDummydata];
    searchTexts = friendSearchbar.text;
    NSLog(@"in search method..");
    NSLog(@"filteredList99 %@ %@  %d  %d  imageDownloadsInProgress: %@",filteredList1,friendListArr,[filteredList1 count],[friendListArr count], dicImages_msg);

    [filteredList1 removeAllObjects];
    
    if ([searchTexts isEqualToString:@""])
    {
        NSLog(@"null string");
        friendSearchbar.text=@"";
        filteredList1 = [[NSMutableArray alloc] initWithArray: friendListArr];
    }
    else
    {
        NSLog(@"filteredList999 %@ %@  %d  %d  imageDownloadsInProgress: %@",filteredList1,friendListArr,[filteredList1 count],[friendListArr count], dicImages_msg);

        for (UserFriends *sTemp in friendListArr)
        {
            NSRange titleResultsRange = [sTemp.userName rangeOfString:searchTexts options:NSCaseInsensitiveSearch];		
            NSLog(@"sTemp.userName: %@",sTemp.userName);
            if (titleResultsRange.length > 0)
            {
                [filteredList1 addObject:sTemp];
                NSLog(@"filtered friend: %@", sTemp.userName);            
            }
            else
            {
            }
        }
    }
    searchFlag=false;    
    
    NSLog(@"filteredList %@ %@  %d  %d  imageDownloadsInProgress: %@",filteredList1,friendListArr,[filteredList1 count],[friendListArr count], dicImages_msg);
    [self reloadScrolview];
}

-(void)searchResultCustom
{
    [self loadDummydata];
    searchTexts = customSearchBar.text;
    NSLog(@"in search method..");
    NSLog(@"filteredList99 %@ %@  %d  %d  imageDownloadsInProgress: %@",filteredList2,friendListArr,[filteredList2 count],[friendListArr count], dicImages_msg);
    
    [filteredList2 removeAllObjects];
    
    if ([searchTexts isEqualToString:@""])
    {
        NSLog(@"null string");
        customSearchBar.text=@"";
        filteredList2 = [[NSMutableArray alloc] initWithArray: friendListArr];
    }
    else
    {
        NSLog(@"filteredList999 %@ %@  %d  %d  imageDownloadsInProgress: %@",filteredList2,friendListArr,[filteredList2 count],[friendListArr count], dicImages_msg);
        
        for (UserFriends *sTemp in friendListArr)
        {
            NSRange titleResultsRange = [sTemp.userName rangeOfString:searchTexts options:NSCaseInsensitiveSearch];		
            NSLog(@"sTemp.userName: %@",sTemp.userName);
            if (titleResultsRange.length > 0)
            {
                [filteredList2 addObject:sTemp];
                NSLog(@"filtered friend: %@", sTemp.userName);            
            }
            else
            {
            }
        }
    }
    searchFlag=false;    
    
    NSLog(@"filteredList %@ %@  %d  %d  imageDownloadsInProgress: %@",filteredList2,friendListArr,[filteredList2 count],[friendListArr count], dicImages_msg);
    [self reloadScrolview];
}

//searchbar delegate method end

//keyboard hides input fields deleget methods

-(void)beganEditing:(UISearchBar *)searchBar
{
    //UIControl need to config here
    CGRect textFieldRect =
	[self.view.window convertRect:friendSearchbar.bounds fromView:searchBar];
    
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
    createNotf++;
    if (createNotf==1)
    {
    ////    [self performSegueWithIdentifier:@"eventDetail" sender:self];
    //    ViewEventDetailViewController *modalViewControllerTwo = [[ViewEventDetailViewController alloc] init];
    //    modalViewControllerTwo.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //    [self presentModalViewController:modalViewControllerTwo animated:YES];
    //    NSLog(@"GOT SERVICE DATA.. :D");
    
    //    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    //    ViewEventDetailViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"eventDetail"];
    //    [self presentModalViewController:controller animated:YES];
    [UtilityClass showAlert:@"Social Maps" :@"Event Created."];
    }
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    NSLog(@"dele %@",[notif object]);
//    if (isFromVenue==TRUE)
//    {
//        [eventListGlobalArray addObject:event];
//    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)updateEventDone:(NSNotification *)notif
{
    updateNotf++;
    if (updateNotf==1) 
    {
    NSLog(@"dele %@",[notif object]);
    ////    [self performSegueWithIdentifier:@"eventDetail" sender:self];
    //    ViewEventDetailViewController *modalViewControllerTwo = [[ViewEventDetailViewController alloc] init];
    ////    modalViewControllerTwo.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //    [self presentModalViewController:modalViewControllerTwo animated:YES];
    //    NSLog(@"GOT SERVICE DATA.. :D");
    
    //    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    //    ViewEventDetailViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"eventDetail"];
    //    [self presentModalViewController:controller animated:YES];
    [UtilityClass showAlert:@"Social Maps" :@"Event updated."];
    }
    globalEvent=[notif object];
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    [self dismissModalViewControllerAnimated:YES];
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

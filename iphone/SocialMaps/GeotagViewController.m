//
//  GeotagViewController.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 10/11/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "GeotagViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ActionSheetPicker.h"
#import "DDAnnotationView.h"
#import "DDAnnotation.h"
#import "UtilityClass.h"
#import "RestClient.h"
#import "AppDelegate.h"
#import "Geotag.h"
#import "Globals.h"
#import "UserCircle.h"
#import "LocationItemPlace.h"
#import "SelectCircleTableCell.h"
#import <Foundation/Foundation.h> 
#import "NotificationController.h"
#import "CustomRadioButton.h"
#import "Places.h"

@interface GeotagViewController ()
- (void)coordinateChanged_:(NSNotification *)notification;
-(void)DownLoad:(NSNumber *)path;
@end

@implementation GeotagViewController

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
@synthesize viewContainerScrollView,commentsView,line,photoScrollView;
@synthesize saveButton;
@synthesize cancelButton;
@synthesize deletePhotoButton;
@synthesize uploadPhotoButton,zoomView,nextButton,prevButton,largePhotoScroller,titleTextField;

__strong NSMutableArray *friendsNameArr, *friendsIDArr, *friendListArr, *filteredList1, *filteredList2, *circleList, *photoFilterList1, *photoFilterList2;
bool searchFlag;
__strong int checkCount;
__strong NSString *searchTexts, *dateString;
int geoLocationFlag=0;

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

AppDelegate *smAppDelegate;
Geotag *geotag;
int geoEntityFlag=0;
DDAnnotation *annotation;
bool isBackgroundTaskRunning;
int geoCreateNotf=0;
int geoUpdateNotf=0;
int zoomIndex=0;
NSMutableArray*   neearMeAddressArr, *selectedCircleCheckArr, *selectedCustomCircleCheckArr;
NSMutableArray *permittedUserArr, *permittedCircleArr, *userCircleArr;
NSMutableArray *guestListIdArr;
NSMutableArray *myPlaceArr, *placeNameArr, *categoryName;
int selectedCatetoryIndex=0;
RestClient *rc;
int geoCounter=0;

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

    for (int i=0; i<[friendListGlobalArray count]; i++)
        
    {
        
        frnds=[[UserFriends alloc] init];
        
        frnds=[friendListGlobalArray objectAtIndex:i];
        
        if ((frnds.imageUrl==NULL)||[frnds.imageUrl isEqual:[NSNull null]])
            
        {
            
            frnds.imageUrl=[[NSBundle mainBundle] pathForResource:@"thum" ofType:@"png"];
            
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [smAppDelegate.window setUserInteractionEnabled:NO];
    [smAppDelegate showActivityViewer:self.view];
    rc=[[RestClient alloc] init];
    [rc getGeotagPhotos:@"Auth-Token" :smAppDelegate.authToken :smAppDelegate.userId];
    [rc getMyPlaces:@"Auth-Token" :smAppDelegate.authToken];
    isBackgroundTaskRunning=true;
	// Do any additional setup after loading the view.
    self.photoPicker = [[[PhotoPicker alloc] initWithNibName:nil bundle:nil] autorelease];
    self.photoPicker.delegate = self;
    self.picSel = [[UIImagePickerController alloc] init];
	self.picSel.allowsEditing = YES;
	self.picSel.delegate = self;	
    [upperView removeFromSuperview];
    [lowerView removeFromSuperview];
    
    upperView.frame=CGRectMake(0, 0, upperView.frame.size.width, upperView.frame.size.height);
    
    lowerView.frame=CGRectMake(0, upperView.frame.size.height, lowerView.frame.size.width, lowerView.frame.size.height);
    viewContainerScrollView.contentSize=CGSizeMake(320, upperView.frame.size.height+lowerView.frame.size.height);    
    [viewContainerScrollView addSubview:upperView];
    [viewContainerScrollView addSubview:lowerView];
    
    NSArray *subviews = [friendSearchbar subviews];
    UIButton *cancelButton1 = [subviews objectAtIndex:2];
    cancelButton1.tintColor = [UIColor darkGrayColor];
    
    frndListScrollView.delegate = self;
    customScrollView.delegate=self;
    dicImages_msg = [[NSMutableDictionary alloc] init];
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
    geotag=[[Geotag alloc] init];
    neearMeAddressArr=[[NSMutableArray alloc] init];
    myPlaceArr=[[NSMutableArray alloc] init]; 
    placeNameArr=[[NSMutableArray alloc] init]; 
    CustomRadioButton *radio = [[CustomRadioButton alloc] initWithFrame:CGRectMake(20, 130, 280, 21) numButtons:4 labels:[NSArray arrayWithObjects:@"Current location",@"My places",@"Places near to me",@"Point on map",nil]  default:0 sender:self tag:2001];
    radio.delegate = self;
    [upperView addSubview:radio];
    
    for (int i=0; i<[smAppDelegate.placeList count]; i++)
    {
        LocationItemPlace *aPlaceItem = (LocationItemPlace*)[smAppDelegate.placeList objectAtIndex:i];
        [neearMeAddressArr addObject:aPlaceItem.placeInfo.name];
        NSLog(@"aPlaceItem.placeInfo.name %@  %@ %@",aPlaceItem.placeInfo.name,aPlaceItem.placeInfo.location.latitude,aPlaceItem.placeInfo.location.longitude);
    }
    
    //set scroll view content size.
    [self loadDummydata];
    [line setImage:[UIImage imageNamed:@"line_arrow_up_left.png"] forState:UIControlStateNormal];
    selectedFriendsIndex=[[NSMutableArray alloc] init];
    customSelectedPhotoIndex=[[NSMutableArray alloc] init];
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
    
    geotag.permission=@"private";
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(theCoordinate, 1000, 1000);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];  
    [self.mapView setRegion:adjustedRegion animated:YES];
    
    //    [self.mapView setRegion:newRegion animated:YES];
    
	[self.mapView setCenterCoordinate:annotation.coordinate];
    
	[self.mapView addAnnotation:annotation];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults]; 
    smAppDelegate.authToken=[prefs stringForKey:@"authToken"];    
    [self hidePhotoScroller:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getPhotoForGeoTagDone:) name:NOTIF_GET_PHOTO_FOR_GEOTAG object:nil];  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createGeoTagDone:) name:NOTIF_CREATE_GEOTAG_DONE object:nil];  
    [commentsView.layer setCornerRadius:8.0f];
    [commentsView.layer setBorderWidth:0.5];
    [commentsView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [commentsView.layer setMasksToBounds:YES];

    [circleView.layer setCornerRadius:8.0f];
    [circleView.layer setBorderWidth:0.5];
    [circleView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [circleView.layer setMasksToBounds:YES];
    
    [self loadCategoryData];
}

-(void)loadCategoryData
{
    categoryName = [[NSMutableArray alloc] initWithObjects:@"Accounting",
                    @"Airport",
                    @"Amusement park",
                    @"Aquarium",
                    @"Art gallery",
                    @"ATM",
                    @"Bakery",
                    @"Bank",
                    @"Bar",
                    @"Beauty salon",
                    @"Bicycle store",
                    @"Book store",
                    @"Bowling alley",
                    @"Bus station",
                    @"Cafe",
                    @"Campground",
                    @"Car dealer",
                    @"Car rental",
                    @"Car repair",
                    @"Car wash",
                    @"Casino",
                    @"Cemetery",
                    @"Church",
                    @"City hall",
                    @"Clothing store",
                    @"Convenience store",
                    @"Courthouse",
                    @"Dentist",
                    @"Department store",
                    @"Doctor",
                    @"Electrician",
                    @"Electronics store",
                    @"Embassy",
                    @"Establishment",
                    @"Finance",
                    @"Fire station",
                    @"Florist",
                    @"Food",
                    @"Funeral home",
                    @"Furniture store",
                    @"Gas station",
                    @"General contractor",
                    @"Grocery or supermarket",
                    @"Gym",
                    @"Hair care",
                    @"Hardware store",
                    @"Health",
                    @"Hindu temple",
                    @"Home goods store",
                    @"Hospital",
                    @"Insurance agency",
                    @"Jewelry store",
                    @"Laundry",
                    @"Lawyer",
                    @"Library",
                    @"Liquor store",
                    @"Local government office",
                    @"Locksmith",
                    @"Lodging",
                    @"Meal delivery",
                    @"Meal takeaway",
                    @"Mosque",
                    @"Movie rental",
                    @"Movie theater",
                    @"Moving company",
                    @"Museum",
                    @"Night club",
                    @"Painter",
                    @"Park",
                    @"Parking",
                    @"Pet store",
                    @"Pharmacy",
                    @"Physiotherapist",
                    @"Place of worship",
                    @"Plumber",
                    @"Police",
                    @"Post office",
                    @"Real estate agency",
                    @"Restaurant",
                    @"Roofing contractor",
                    @"Rv park",
                    @"School",
                    @"Shoe store",
                    @"Shopping mall",
                    @"Spa",
                    @"Stadium",
                    @"Storage",
                    @"Store",
                    @"Subway station",
                    @"Synagogue",
                    @"Taxi stand",
                    @"Train station",
                    @"Travel agency",
                    @"University",
                    @"Veterinary care",
                    @"Zoo",nil];
}

- (void)viewWillAppear:(BOOL)animated 
{
    geoCreateNotf=0;
    geoUpdateNotf=0;
    
    [self displayNotificationCount];
	isBackgroundTaskRunning=true;
	[super viewWillAppear:animated];
    [customSelectionView removeFromSuperview];
	[circleView removeFromSuperview];
    
    if (editFlag==true)
    {
        [createButton setTitle:@"Update" forState:UIControlStateNormal];
        [createLabel setText:@"Update Geotag"];
        
    }
    else
    {
        [createButton setTitle:@"Create" forState:UIControlStateNormal];
        [createLabel setText:@"Create Geotag"];
    }
    
	// NOTE: This is optional, DDAnnotationCoordinateDidChangeNotification only fired in iPhone OS 3, not in iOS 4.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coordinateChanged_:) name:@"DDAnnotationCoordinateDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMyPlaces:) name:NOTIF_GET_MY_PLACES_DONE object:nil];

    [self performSelector:@selector(getCurrentAddress) withObject:nil afterDelay:0.1];
    
    smAppDelegate.currentModelViewController = self;
}

-(void)getCurrentAddress
{
    addressLabel.text = @"";
    annotation.subtitle=addressLabel.text;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        addressLabel.text=[UtilityClass getAddressFromLatLon:[smAppDelegate.currPosition.latitude doubleValue] withLongitude:[smAppDelegate.currPosition.longitude doubleValue]];
        dispatch_async(dispatch_get_main_queue(), ^{
            annotation.subtitle=addressLabel.text;
            geotag.geoTagAddress=addressLabel.text;
            geotag.geoTagLocation.latitude=smAppDelegate.currPosition.latitude;
            geotag.geoTagLocation.longitude=smAppDelegate.currPosition.longitude;
        });
    });
}

-(void)getAddressFromMap
{
    addressLabel.text=[UtilityClass getAddressFromLatLon:annotation.coordinate.latitude withLongitude:annotation.coordinate.longitude];
    geotag.geoTagAddress=addressLabel.text;
    geotag.geoTagLocation.latitude=[NSString stringWithFormat:@"%lf",annotation.coordinate.latitude];
    geotag.geoTagLocation.longitude=[NSString stringWithFormat:@"%lf",annotation.coordinate.longitude];
}

- (void)viewWillDisappear:(BOOL)animated
{
	
	[super viewWillDisappear:animated];
	isBackgroundTaskRunning=false;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_MY_PLACES_DONE object:nil];
	// NOTE: This is optional, DDAnnotationCoordinateDidChangeNotification only fired in iPhone OS 3, not in iOS 4.
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"DDAnnotationCoordinateDidChangeNotification" object:nil];
    globalEditEvent=NULL;
    editFlag=false;
    dicImages_msg=nil;
    ImgesName=nil;
    frndListScrollView=nil;
    
    //    [self viewDidUnload];
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
        geotag.geoTagImageUrl=imgBase64Data;
    } 
    [photoPicker.view removeFromSuperview];
}

//event info entry starts

-(IBAction)nameButtonAction
{
    [line setImage:[UIImage imageNamed:@"line_arrow_up_left.png"] forState:UIControlStateNormal];
    [self hideCommentsView:NO];
    [self hidePhotoScroller:YES];
    [commentsView resignFirstResponder];
}

-(IBAction)dateButtonAction:(id)sender
{
    [ActionSheetPicker displayActionPickerWithView:sender datePickerMode:UIDatePickerModeDateAndTime selectedDate:[NSDate date] target:self action:@selector(dateWasSelected::) title:@"Date"]; 
}

-(IBAction)photoButtonAction
{
    [line setImage:[UIImage imageNamed:@"line_arrow_up_right.png"] forState:UIControlStateNormal];
    [self hideCommentsView:YES];
    [self hidePhotoScroller:NO];
    [commentsView resignFirstResponder];
//    [self.photoPicker getPhoto:self];
}

-(IBAction)deleteButtonAction
{
    self.eventImagview.image=[UIImage imageNamed:@"event_item_bg.png"];
}

-(IBAction)saveComments:(id)sender
{
}

-(IBAction)cancelComments:(id)sender
{
}

-(IBAction)savePhoto:(id)sender
{
}

-(IBAction)cancelPhoto:(id)sender
{
}

-(IBAction)categoriesButtonAction:(id)sender
{
    [commentsView resignFirstResponder];
    [ActionSheetPicker displayActionPickerWithView:self.view data:categoryName selectedIndex:selectedCatetoryIndex target:self action:@selector(didSelectCategory::) title:@"Select a category"];
}

-(void)didSelectCategory:(NSNumber *)selectedIndex:(id)element 
{
        selectedCatetoryIndex = [selectedIndex intValue];        
        geotag.category = [[[categoryName objectAtIndex:selectedCatetoryIndex] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        NSLog(@"geo.category = %@", geotag.category);
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
    geotag.permission=@"private";
    
}

-(IBAction)friendsButtonAction
{
    [private setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [friends setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
    [degreeFriends setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [people setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [custom setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    geotag.permission=@"friends";
}

-(IBAction)degreeFriendsButtonAction
{
    [private setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [friends setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [degreeFriends setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
    [people setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [custom setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];    
    geotag.permission=@"circles";
}

-(IBAction)peopleButtonAction
{
    [private setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [friends setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [degreeFriends setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [people setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
    [custom setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    geotag.permission=@"public";
}

-(IBAction)customButtonAction
{
    [private setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [friends setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [degreeFriends setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [people setImage:[UIImage imageNamed:@"location_bar_radio_none.png"] forState:UIControlStateNormal];
    [custom setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
    geotag.permission=@"custom";
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
    
    for (int i=0; i<[customSelectedPhotoIndex count]; i++)
    {
        //        ((UserFriends *)[customSelectedFriendsIndex objectAtIndex:i]).userId;
        [permittedUserArr addObject:((UserFriends *)[customSelectedPhotoIndex objectAtIndex:i]).userId];
    }
    NSLog(@"permittedCircleArr %@ permittedUserArr %@",permittedCircleArr,permittedUserArr);
    geotag.permittedUsers=permittedUserArr;
    geotag.circleList=permittedCircleArr;
    [customSelectionView removeFromSuperview];
}

-(IBAction)cancelCustom:(id)sender
{
    [selectedCustomCircleCheckArr removeAllObjects];
    [customSelectedPhotoIndex removeAllObjects];
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
-(void)curLocButtonAction
{
    [self performSelector:@selector(getCurrentAddress) withObject:nil afterDelay:0.1];    
}

-(void)myPlaceButtonAction
{
    [UtilityClass showAlert:@"Social Maps" :@"You have no saved places."];
}

-(void)nearmePlaceButtonAction
{
    [ActionSheetPicker displayActionPickerWithView:self.view data:neearMeAddressArr selectedIndex:0 target:self action:@selector(placeWasSelected::) title:@"Near Me Location"];
    NSLog(@"neearMeAddressArr: %@",neearMeAddressArr);
}

-(void)pointOnMapButtonAction
{
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
    [commentsView resignFirstResponder];
    [titleTextField resignFirstResponder];
    //title*, description*,eventShortSummary,eventImage, guests[], address, lat, lng*, time* , 
    NSMutableString *msg=[[NSMutableString alloc] initWithString:@"Please select"];
    
    
    if ([addressLabel.text length]==0)
    {
        [msg appendString:@" address,"];
    }

    if ([titleTextField.text length]==0)
    {
        [msg appendString:@" title,"];
    }
    
    if (([commentsView.text length]==0)||([commentsView.text isEqualToString:@"Geotag description..."]))
    {
        [msg appendString:@" comments,"];
    }
    
    if ([customSelectedPhotoIndex count]==0)
    {
        [msg appendString:@" photo,"];
    }
    
    if ([geotag.category length]==0)
    {
        [msg appendString:@" category,"];
    }
    
    if ([msg length]<=13) {
    geotag.geoTagDescription=commentsView.text;
    NSData *imgdata;
    if ([customSelectedPhotoIndex count]>0) {
        imgdata = UIImagePNGRepresentation([dicImages_msg objectForKey:((Photo *)[customSelectedPhotoIndex objectAtIndex:0]).imageUrl]);        
        NSString *imgBase64Data = [imgdata base64EncodedString];
        geotag.geoTagImageUrl=imgBase64Data;
    }
    for (int i=0; i<[selectedFriendsIndex count]; i++) 
    {
        [geotag.frndList addObject:((UserFriends *)[selectedFriendsIndex objectAtIndex:i]).userId];
    }
    
    for (int i=0; i<[selectedCircleCheckArr count]; i++) 
    {
        UserCircle *circle=[circleListGlobalArray objectAtIndex:((NSIndexPath *)[selectedCircleCheckArr objectAtIndex:i]).row];
        NSString *circleId=circle.circleID;
        [geotag.circleList addObject:circleId];
    }
    
    [smAppDelegate showActivityViewer:self.view];
    [smAppDelegate.window setUserInteractionEnabled:NO];
    [rc createGeotag:geotag :@"Auth-Token" :smAppDelegate.authToken];
    }
    else
    {
        [UtilityClass showAlert:@"Social Maps" :msg];
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//    [commentsView resignFirstResponder];
    [UtilityClass beganEditing:(UIControl *)textField];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [UtilityClass endEditing];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
        NSLog(@"textview did begin");
//    [titleTextField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//    [commentsView resignFirstResponder];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [titleTextField resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    else
        return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSLog(@"textview should begin");
//    [titleTextField resignFirstResponder];
    [UtilityClass beganEditing:(UIControl *)textView];
    if (!(textView.textColor == [UIColor blackColor])) 
    {
        if ([textView.text isEqualToString:@"Geotag description..."]) {
                textView.text = @"";
        }
        textView.textColor = [UIColor blackColor];
    }
    return YES;
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
    [UtilityClass endEditing];
    if (!(textView.textColor == [UIColor lightGrayColor])) {
        //        textView.text = @"Your comments...";
        textView.textColor = [UIColor lightGrayColor];
    }
    geotag.geoTagDescription=commentsView.text;
    [commentsView resignFirstResponder];
}

-(IBAction)cancelEvent:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)saveEntity:(id)sender
{
    
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
    geoLocationFlag=1;
    int selectedLocation=[selectedIndex intValue];
    NSLog(@"selectedLocation %d",selectedLocation);
    LocationItemPlace *aPlaceItem = (LocationItemPlace*)[smAppDelegate.placeList objectAtIndex:selectedLocation];
    NSLog(@"aPlaceItem.placeInfo.name %@  %@ %@",aPlaceItem.placeInfo.name,aPlaceItem.placeInfo.location.latitude,aPlaceItem.placeInfo.location.longitude);
    geotag.geoTagLocation.latitude=aPlaceItem.placeInfo.location.latitude;
    geotag.geoTagLocation.longitude=aPlaceItem.placeInfo.location.longitude;
    geotag.geoTagAddress=aPlaceItem.placeInfo.name;
    addressLabel.text=aPlaceItem.placeInfo.name;
}

-(void)myPlacesWasSelected:(NSNumber *)selectedIndex:(id)element
{
    int selectedLocation= [selectedIndex intValue];
    NSLog(@"sel ind %d %@",[selectedIndex intValue],[myPlaceArr objectAtIndex:selectedLocation]);
    Places *place=[myPlaceArr objectAtIndex:selectedLocation];
    addressLabel.text=place.name;
    geotag.geoTagAddress=place.name;
    geotag.geoTagLocation.latitude=place.location.latitude;
    geotag.geoTagLocation.longitude=place.location.longitude;
}

- (void)dateWasSelected:(NSDate *)selectedDate:(id)element 
{
    NSDate *date =selectedDate;
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh.mm"];    
    dateString = [dateFormatter stringFromDate:date];    
    dateButton.titleLabel.text=dateString;
    //selectedDate=dateString 2012-09-12 08.50;
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
    
//    int nodeCount = [filteredList1 count];
    
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
    }
    else 
    {
        cell.circrcleName.text=[NSString stringWithFormat:@"%@ (%d)",[circleList objectAtIndex:indexPath.row],[((UserCircle *)[circleListGlobalArray objectAtIndex:indexPath.row]).friends count]] ;
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
    NSLog(@"event create scroll init");
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
                    imgView.image = [UIImage imageNamed:@"thum.png"];
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
                        [dicImages_msg setObject:[UIImage imageNamed:@"thum.png"] forKey:userFrnd.imageUrl]; 
                        [self performSelectorInBackground:@selector(DownLoad:) withObject:[NSNumber numberWithInt:i]];  
                        imgView.image = [UIImage imageNamed:@"thum.png"];                   
                    }
                    else 
                    { 
                        // Image is not available, so set a placeholder image
                        imgView.image = [UIImage imageNamed:@"thum.png"];                   
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
    if ([customSelectedPhotoIndex containsObject:[photoFilterList1 objectAtIndex:[sender.view tag]]])
    {
        [customSelectedPhotoIndex removeObject:[photoFilterList1 objectAtIndex:[sender.view tag]]];
    } 
    else 
    {
        [customSelectedPhotoIndex addObject:[photoFilterList1 objectAtIndex:[sender.view tag]]];
    }
    Photo *photo=[[Photo alloc] init];
    photo=[photoFilterList1 objectAtIndex:[sender.view tag]];
    NSLog(@"selectedFriendsIndex2 : %@",selectedFriendsIndex);
    for (int l=0; l<[subviews count]; l++)
    {
        UIView *im=[subviews objectAtIndex:l];
        NSArray* subviews1 = [NSArray arrayWithArray: im.subviews];
        UIImageView *im1=[subviews1 objectAtIndex:0];
        
        if ([im1.image isEqual:photo.photoImage])
        {
            [im1 setAlpha:1.0];
            im1.layer.borderWidth=2.0;
            im1.layer.masksToBounds = YES;
            [im1.layer setCornerRadius:7.0];
            im1.layer.borderColor=[[UIColor greenColor]CGColor];
        }        
    }
    [self reloadPhotoScrolview];
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


- (void)scrollViewDidScroll:(UIScrollView *)sender 
{
    if (sender==largePhotoScroller) {
        CGFloat pageWidth = largePhotoScroller.frame.size.width;
        int page = floor((largePhotoScroller.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        zoomIndex=page;
        if (page==0) 
        {
            [nextButton setHidden:NO];
            [prevButton setHidden:YES];
        }
        else if (page==[photoFilterList2 count]-1) {
            [nextButton setHidden:YES];
            [prevButton setHidden:NO];
        }
        else {
            [prevButton setHidden:NO];
            [nextButton setHidden:NO];
        }
    }
    else if (sender==viewContainerScrollView)
    {
        [titleTextField resignFirstResponder];
        [commentsView resignFirstResponder];
    }
    // Switch the indicator when more than 50% of the previous/next page is visible
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    // A possible optimization would be to unload the views+controllers which are no longer visible
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

//Photo scroller starts

-(void) reloadPhotoScrolview
{
    NSLog(@"photo scroll init");
    if (isBackgroundTaskRunning==true)
    {
        int x=0; //declared for imageview x-axis point    
        int x2=0; //declared for imageview x-axis point
        int y=0;
        NSArray* subviews = [NSArray arrayWithArray:photoScrollView.subviews];
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
        NSArray* subviews1 = [[NSArray arrayWithArray: largePhotoScroller.subviews] mutableCopy];
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
        
        photoScrollView.contentSize=CGSizeMake(320,(ceilf([photoFilterList1 count]/4.0))*90);
        largePhotoScroller.contentSize=CGSizeMake([photoFilterList2 count]*320, 460);
        
        NSLog(@"event create isBackgroundTaskRunning %i",isBackgroundTaskRunning);
        for(int i=0; i<[photoFilterList1 count];i++)               
        {
            if(i< [photoFilterList1 count]) 
            { 
                Photo *photo=[[Photo alloc] init];
                photo=[photoFilterList1 objectAtIndex:i];
                imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
                
                if ((photo.imageUrl==NULL)||[photo.imageUrl isEqual:[NSNull null]])
                {
                    imgView.image = [UIImage imageNamed:@"blank.png"];
                } 
                else if([dicImages_msg valueForKey:photo.imageUrl]) 
                { 
                    //If image available in dictionary, set it to imageview 
                    imgView.image = [dicImages_msg valueForKey:photo.imageUrl]; 
                } 
                else 
                { 
                    if((!isDragging_msg && !isDecliring_msg)&&([dicImages_msg objectForKey:photo.imageUrl]==nil))
                        
                    {
                        //If scroll view moves set a placeholder image and start download image. 
                        [dicImages_msg setObject:[UIImage imageNamed:@"blank.png"] forKey:photo.imageUrl]; 
                        [self performSelectorInBackground:@selector(DownLoadPhoto:) withObject:[NSNumber numberWithInt:i]];  
                        imgView.image = [UIImage imageNamed:@"blank.png"];                   
                    }
                    else 
                    { 
                        // Image is not available, so set a placeholder image
                        imgView.image = [UIImage imageNamed:@"blank.png"];                   
                    }               
                }
                x=(i%4)*80;
                y=(i/4)*90;
                UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(x+5, y, 80, 80)];
                UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(0, 70, 80, 20)];
                name.textAlignment=UITextAlignmentCenter;
                UIButton *zoomButton= [UIButton buttonWithType:UIButtonTypeCustom];;
                zoomButton.tag=i;
                zoomButton.frame=CGRectMake(45, 45, 20, 20);
                [zoomButton setBackgroundImage:[UIImage imageNamed:@"zoom_icon.png"] forState:UIControlStateNormal];
                [zoomButton addTarget:self action:@selector(gotoZoomView:) forControlEvents:UIControlEventTouchUpInside];
                [name setFont:[UIFont fontWithName:@"Helvetica-Light" size:10]];
                [name setNumberOfLines:0];
                [name setText:photo.description];
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
                for (int c=0; c<[customSelectedPhotoIndex count]; c++)
                {
                    if ([[photoFilterList1 objectAtIndex:i] isEqual:[customSelectedPhotoIndex objectAtIndex:c]]) 
                    {
                        imgView.layer.borderColor=[[UIColor greenColor] CGColor];
                        NSLog(@"found selected: %@",[customSelectedPhotoIndex objectAtIndex:c]);
                    }
                    else
                    {
                    }
                }
                [aView addSubview:imgView];
                [aView addSubview:zoomButton];
                [aView addSubview:name];
                UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePhotoTapGesture:)];
                tapGesture.numberOfTapsRequired = 1;
                [imgView addGestureRecognizer:tapGesture];
                [tapGesture release];           
                [photoScrollView addSubview:aView];
            }        
        }
        
        //handling custom scroller
        for(int i=0; i<[photoFilterList2 count];i++)               
        {
            if(i< [photoFilterList2 count]) 
            { 
                Photo *photo=[[Photo alloc] init];
                photo=[photoFilterList2 objectAtIndex:i];
                imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
                if (photo.imageUrl == nil) 
                {
                    imgView.image = [UIImage imageNamed:@"blank.png"];
                } 
                else if([dicImages_msg valueForKey:photo.imageUrl]) 
                { 
                    //If image available in dictionary, set it to imageview 
                    imgView.image = [dicImages_msg valueForKey:photo.imageUrl]; 
                } 
                else 
                { 
                    if((!isDragging_msg && !isDecliring_msg)&&([dicImages_msg objectForKey:photo.imageUrl]==nil)) 
                        
                    {
                        //If scroll view moves set a placeholder image and start download image. 
                        [dicImages_msg setObject:[UIImage imageNamed:@"blank.png"] forKey:photo.imageUrl]; 
                        [self performSelectorInBackground:@selector(DownLoadPhoto:) withObject:[NSNumber numberWithInt:i]];  
                        imgView.image = [UIImage imageNamed:@"blank.png"];                   
                    }
                    else 
                    { 
                        // Image is not available, so set a placeholder image
                        imgView.image = [UIImage imageNamed:@"blank.png"];                   
                    }               
                }
                //            NSLog(@"userFrnd.imageUrl: %@",userFrnd.imageUrl);
                UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(x2, 0, 320, 460)];
                //                UIView *secView=[[UIView alloc] initWithFrame:CGRectMake(x2, 0, 65, 65)];
                UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(0, 45, 60, 20)];
                [name setFont:[UIFont fontWithName:@"Helvetica-Light" size:10]];
                [name setNumberOfLines:0];
                [name setText:photo.description];
                [name setBackgroundColor:[UIColor clearColor]];
                imgView.userInteractionEnabled = YES;
                imgView.tag = i;
                aView.tag=i;
                imgView.exclusiveTouch = YES;
                imgView.clipsToBounds = NO;
                imgView.opaque = YES;
                imgView.contentMode=UIViewContentModeScaleAspectFit;
                imgView.layer.borderColor=[[UIColor clearColor] CGColor];
                imgView.userInteractionEnabled=YES;
                imgView.layer.borderWidth=2.0;
                imgView.layer.masksToBounds = YES;
                [imgView.layer setCornerRadius:7.0];
                imgView.layer.borderColor=[[UIColor lightGrayColor] CGColor];                    
                [aView addSubview:imgView];
                [largePhotoScroller addSubview:aView];
            }        
            x2+=320;
        }
    }
}

-(IBAction)gotoZoomView:(id)sender
{
    [self scrollToPage:[sender tag]:NO];
    CGFloat xpos = self.view.frame.origin.x;
    CGFloat ypos = self.view.frame.origin.y;
    zoomView.frame = CGRectMake(xpos+100,ypos+150,5,5);
    [UIView beginAnimations:@"Zoom" context:NULL];
    [UIView setAnimationDuration:0.8];
    zoomView.frame = CGRectMake(xpos, ypos-20, 320, 460);
    [UIView commitAnimations];
    [self.view addSubview:zoomView];
    NSLog(@"tag: %d",[sender tag]);
}

-(IBAction)closeZoomView:(id)sender
{
    [UIView beginAnimations:@"FadeIn" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView commitAnimations];
    [zoomView removeFromSuperview];
}

-(IBAction)viewPrevImage:(id)sender
{
    NSLog(@"view previous img");
    [self scrollToPage:zoomIndex-1:YES];
}

-(IBAction)viewNextImage:(id)sender
{
    NSLog(@"view next img %d",zoomIndex);
    [self scrollToPage:zoomIndex+1:YES];
}

-(void)scrollToPage:(int)page:(BOOL)animated
{
    CGRect frame = largePhotoScroller.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [largePhotoScroller scrollRectToVisible:frame animated:animated];
}

-(void)loadData:(NSMutableArray *)photoListArr
{
    Photo *photo=[[Photo alloc] init];
    photoFilterList1=[[NSMutableArray alloc] init];
    //    for (int i=0; i<[photoListArr count]; i++)
    //    {
    //        photo=[[Photo alloc] init];
    //        [photoListArr addObject:photo];
    //        NSLog(@"photo.imageUrl %@  photo.desc %@ photo.imgId %@",photo.imageUrl,photo.description,photo.photoId);
    //    }
    photoFilterList1=[photoListArr mutableCopy];
    photoFilterList2=[photoListArr mutableCopy];
    [self reloadPhotoScrolview];
    NSLog(@"photoFilterList1 count: %d",[photoFilterList1 count]);
}

-(void)DownLoadPhoto:(NSNumber *)path
{
    if (isBackgroundTaskRunning==true)
    {
        //    NSAutoreleasePool *pl = [[NSAutoreleasePool alloc] init];
        int index = [path intValue];
        Photo *photo=[[Photo alloc] init];
        photo=[photoFilterList1 objectAtIndex:index];
        
        NSString *Link = photo.imageUrl;
        //Start download image from url
        UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:Link]]];
        if(img)
        {
            //If download complete, set that image to dictionary
            [dicImages_msg setObject:img forKey:photo.imageUrl];
            [self reloadPhotoScrolview];
        }
        // Now, we need to reload scroll view to load downloaded image
        //    [self performSelectorOnMainThread:@selector(reloadScrolview) withObject:path waitUntilDone:NO];
        //    [pl release];
    }
}

//handling selection from scroll view of friends selection
-(IBAction) handlePhotoTapGesture:(UIGestureRecognizer *)sender
{
    NSArray* subviews = [NSArray arrayWithArray: photoScrollView.subviews];
    if ([customSelectedPhotoIndex containsObject:[photoFilterList1 objectAtIndex:[sender.view tag]]])
    {
        [customSelectedPhotoIndex removeObject:[photoFilterList1 objectAtIndex:[sender.view tag]]];
    } 
    else 
    {
        [customSelectedPhotoIndex removeAllObjects];
        [customSelectedPhotoIndex addObject:[photoFilterList1 objectAtIndex:[sender.view tag]]];
    }
    Photo *photo=[[Photo alloc] init];
    photo=[photoFilterList1 objectAtIndex:[sender.view tag]];
    NSLog(@"selectedFriendsIndex2 : %@",customSelectedPhotoIndex);
    for (int l=0; l<[subviews count]; l++)
    {
        UIView *im=[subviews objectAtIndex:l];
        NSArray* subviews1 = [NSArray arrayWithArray: im.subviews];
        UIImageView *im1=[subviews1 objectAtIndex:0];
        
        if ([im1.image isEqual:photo.photoImage])
        {
            [im1 setAlpha:1.0];
            im1.layer.borderWidth=2.0;
            im1.layer.masksToBounds = YES;
            [im1.layer setCornerRadius:7.0];
            im1.layer.borderColor=[[UIColor greenColor]CGColor];
        }
    }
    [self reloadPhotoScrolview];
}

//Photo scrollers ends
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

- (void) radioButtonClicked:(int)indx sender:(id)sender {
    NSLog(@"radioButtonClicked index = %d %d", indx,[sender tag]);
    
    if ([sender tag] == 2001) {
        switch (indx) {
            case 3:
                [self pointOnMapButtonAction];
                break;
            case 2:
                [ActionSheetPicker displayActionPickerWithView:sender data:neearMeAddressArr selectedIndex:0 target:self action:@selector(placeWasSelected::) title:@"Places near to me"];
                break;
            case 1:
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
                [self performSelector:@selector(getCurrentAddress) withObject:nil afterDelay:0];
                break;
            default:
                break;
        }
    }
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

- (void)getPhotoForGeoTagDone:(NSNotification *)notif
{
    [smAppDelegate.window setUserInteractionEnabled:YES];
    [smAppDelegate hideActivityViewer];
    [self loadData:[notif object]];
    [self reloadPhotoScrolview];
}

- (void)createGeoTagDone:(NSNotification *)notif
{
    geoCounter++;
    loadGeotagServiceData=true;
    [smAppDelegate.window setUserInteractionEnabled:YES];
    [smAppDelegate hideActivityViewer];
    if (geoCounter==1)
    {
        [UtilityClass showAlert:@"Social Maps" :@"Geo-tag created"];
    }
    [self dismissModalViewControllerAnimated:YES];
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

-(void)hidePhotoScroller:(BOOL)isHidden
{
    [deletePhotoButton setHidden:isHidden];
    [uploadPhotoButton setHidden:isHidden];
    [photoScrollView setHidden:isHidden];
}

-(void)hideCommentsView:(BOOL)isHidden
{
    [saveButton setHidden:isHidden];
    [cancelButton setHidden:isHidden];
    [commentsView setHidden:isHidden];
}

-(IBAction)hideKeyboard:(id)sender
{
    [commentsView resignFirstResponder];
    [titleTextField resignFirstResponder];
    geotag.geoTagTitle=titleTextField.text;
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

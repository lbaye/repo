//
//  CreatePlanViewController.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 11/19/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CreatePlanViewController.h"
#import "UITextView+Rounded.h"
#import "CustomRadioButton.h"
#import "ActionSheetPicker.h"
#import "UtilityClass.h"
#import "AppDelegate.h"
#import "LocationItemPlace.h"
#import "DDAnnotationView.h"
#import "DDAnnotation.h"
#import "RestClient.h"
#import "UserCircle.h"
#import "UserFriends.h"
#import "Globals.h"
#import "SelectCircleTableCell.h"
#import "NotificationController.h"
#import "UIImageView+Cached.h"

@interface CreatePlanViewController ()

@end

@implementation CreatePlanViewController
@synthesize descriptionTextView,addressLabel,dateLabel,dateButton,customView,mapView,mapContainerView;
@synthesize circleTableView;
@synthesize frndsScrollView;
@synthesize segmentControl,friendSearchbar,plan,totalNotifCount,planEditFlag,editIndexPath,titleLabel,saveButton;

NSMutableArray *neearMeAddressArr, *myPlaceArr, *placeNameArr;
AppDelegate *smAppDelegate;
DDAnnotation *annotation;
RestClient *rc;
NSMutableArray *permittedUserArr; 
NSMutableArray *permittedCircleArr;
NSMutableArray *selectedCustomCircleCheckArr;
NSMutableArray *customSelectedFriendsIndex;
NSMutableArray *FriendList, *circleList, *selectedFriends, *selectedCircleCheckArr;
BOOL isBgDlRunning;

NSMutableArray *ImgesName;    
NSString *searchTexts;
NSMutableArray *friendsNameArr;
NSMutableArray *friendsIDArr;
NSMutableArray *friendListArr;
CustomRadioButton *radio;
CustomRadioButton *shareRadio;
int createCounter=0, updateCounter=0;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    plan=[[Plan alloc] init];
    neearMeAddressArr=[[NSMutableArray alloc] init];
    myPlaceArr=[[NSMutableArray alloc] init];
    placeNameArr=[[NSMutableArray alloc] init];
    permittedUserArr = [[NSMutableArray alloc] init]; 
    permittedCircleArr = [[NSMutableArray alloc] init]; 
    selectedCustomCircleCheckArr=[[NSMutableArray alloc] init];
    customSelectedFriendsIndex =[[NSMutableArray alloc] init];
    FriendList=[[NSMutableArray alloc] init];
    circleList=[[NSMutableArray alloc] init];
    selectedFriends=[[NSMutableArray alloc] init]; 
    selectedCircleCheckArr=[[NSMutableArray alloc] init];
    ImgesName = [[NSMutableArray alloc] init];    
    searchTexts=[[NSString alloc] initWithString:@""];
    friendsNameArr=[[NSMutableArray alloc] init];
    friendsIDArr=[[NSMutableArray alloc] init];
    FriendList=[[NSMutableArray alloc] init];
    friendListArr=[[NSMutableArray alloc] init];
    [customView.layer setCornerRadius:8.0f];
    [customView.layer setBorderWidth:1.0];
    [customView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [customView.layer setMasksToBounds:YES];
    [self loadDummydata];
    [self reloadScrollview];
    smAppDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [descriptionTextView makeRoundCornerWithColor:[UIColor lightTextColor]];
    radio = [[CustomRadioButton alloc] initWithFrame:CGRectMake(20, 115, 280, 21) numButtons:4 labels:[NSArray arrayWithObjects:@"Current location",@"My places",@"Places near to me",@"Point on map",nil]  default:0 sender:self tag:200000];
    radio.delegate = self;
    
    shareRadio = [[CustomRadioButton alloc] initWithFrame:CGRectMake(25, 387, 280, 21) numButtons:5 labels:[NSArray arrayWithObjects:@"Private",@"Friends",@"Circles",@"Public",@"Custom",nil]  default:0 sender:self tag:2001];
    shareRadio.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coordinateChanged_:) name:@"DDAnnotationCoordinateDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMyPlaces:) name:NOTIF_GET_MY_PLACES_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createPlanDone:) name:NOTIF_CREATE_PLAN_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePlanDone:) name:NOTIF_UPDATE_PLANS_DONE object:nil];
    
    rc=[[RestClient alloc] init];
    [self.view addSubview:radio];
    [self.view addSubview:shareRadio];
    CLLocationCoordinate2D theCoordinate;
	theCoordinate.latitude = [smAppDelegate.currPosition.latitude doubleValue];
    theCoordinate.longitude = [smAppDelegate.currPosition.longitude doubleValue];
    annotation = [[[DDAnnotation alloc] initWithCoordinate:theCoordinate addressDictionary:nil] autorelease];
    isBgDlRunning=TRUE;
	annotation.title = @"Drag to Move Pin";
	annotation.subtitle = [NSString	stringWithFormat:@"Current Location"];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(theCoordinate, 1000, 1000);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];  
    [self.mapView setRegion:adjustedRegion animated:YES];
    
	[self.mapView setCenterCoordinate:annotation.coordinate];
    
	[self.mapView addAnnotation:annotation];
    
    [rc getMyPlaces:@"Auth-Token" :smAppDelegate.authToken];
    
    for (int i=0; i<[smAppDelegate.placeList count]; i++)
    {
        LocationItemPlace *aPlaceItem = (LocationItemPlace*)[smAppDelegate.placeList objectAtIndex:i];
        [neearMeAddressArr addObject:aPlaceItem.placeInfo.name];
        NSLog(@"aPlaceItem.placeInfo.name %@  %@ %@",aPlaceItem.placeInfo.name,aPlaceItem.placeInfo.location.latitude,aPlaceItem.placeInfo.location.longitude);
    }
    if (isPlanFromVenue==TRUE)
    {
        NSLog(@"plan.planAddress %@",globalPlan.planAddress);
        [self setPlanAddress:globalPlan];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self displayNotificationCount];
    [customView removeFromSuperview];
    [mapContainerView removeFromSuperview];
    [circleTableView setHidden:YES];
    [frndsScrollView setHidden:NO];
    [friendSearchbar setHidden:NO];
    isBgDlRunning=TRUE;
    if ([planEditFlag isEqualToString:@"yes"])
    {
        [self setAddressDateShare:globalPlan];
    }
}

- (void) radioButtonClicked:(int)indx sender:(id)sender {
    NSLog(@"radioButtonClicked index = %d %d", indx,[sender tag]);
    [descriptionTextView resignFirstResponder];
    
    if ([sender tag] == 200000) {
        switch (indx) {
            case 3:
                [self.view addSubview:mapContainerView];
                break;
            case 1:
                if ([placeNameArr count]==0) {
                    [UtilityClass showAlert:@"Social Maps" :@"You have no saved place"];
                }
                else
                {
                [ActionSheetPicker displayActionPickerWithView:sender data:placeNameArr selectedIndex:0 target:self action:@selector(myPlacesWasSelected::) title:@"My places"];
                }
                break;
            case 2:
                [ActionSheetPicker displayActionPickerWithView:sender data:neearMeAddressArr selectedIndex:0 target:self action:@selector(placeWasSelected::) title:@"Places near to me"];
                break;
            case 0:
                [self performSelector:@selector(getCurrentAddress) withObject:nil afterDelay:0];
                break;
            default:
                break;
        }
    }
    else if ([sender tag]==2001) 
    {
        switch (indx) {
            case 4:
                NSLog(@"index %d",indx);
                plan.planPermission=@"custom";
                [self.view addSubview:customView];
                break;
            case 3:
                NSLog(@"index %d",indx);
                plan.planPermission=@"public";
                break;
            case 2:
                NSLog(@"index %d",indx);
                plan.planPermission=@"circles";                
                break;
            case 1:
                NSLog(@"index %d",indx);
                plan.planPermission=@"friends";                
                break;
            case 0:
                NSLog(@"index %d",indx);
                plan.planPermission=@"private";                
                break;
            default:
                break;
        }
    }
}

- (void) setAddressFromLatLon:(double)pdblLatitude withLongitude:(double)pdblLongitude forAnnotation:(DDAnnotation*)annotation
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:pdblLatitude longitude:pdblLongitude];
    
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark =  [placemarks objectAtIndex:0];
        NSString *cityName = (placemark.locality) ? [NSString stringWithFormat:@", %@ ", placemark.locality] : @"";
        NSString *countryName = (placemark.country) ? [NSString stringWithFormat:@", %@", placemark.country] : @"";
        annotation.subtitle = [NSString stringWithFormat:@"%@%@%@", placemark.name, cityName, countryName];
        [location release];
        [geoCoder release];
    }];
}

-(void)getCurrentAddress
{
    addressLabel.text = @"";
    annotation.subtitle=addressLabel.text;
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    //    addressLabel.text=
    [UtilityClass getAddressFromLatLon:[smAppDelegate.currPosition.latitude doubleValue] withLongitude:[smAppDelegate.currPosition.longitude doubleValue] andLabel:addressLabel];
        //dispatch_async(dispatch_get_main_queue(), ^{
    //        annotation.subtitle =
    [self setAddressFromLatLon:[smAppDelegate.currPosition.latitude doubleValue] withLongitude:[smAppDelegate.currPosition.longitude doubleValue] forAnnotation:annotation];
            plan.planAddress=addressLabel.text;
            plan.planGeolocation.latitude=smAppDelegate.currPosition.latitude;
            plan.planGeolocation.longitude=smAppDelegate.currPosition.longitude;
        //});
    //});
}

-(void)getAddressFromMap
{
    [UtilityClass getAddressFromLatLon:annotation.coordinate.latitude withLongitude:annotation.coordinate.longitude andLabel:addressLabel];
}

-(IBAction)saveMapLocation:(id)sender
{
    [mapContainerView removeFromSuperview];
    [self performSelector:@selector(getAddressFromMap) withObject:nil afterDelay:0.1];
}

-(IBAction)cancelMapLocation:(id)sender
{
    [mapContainerView removeFromSuperview];
}

-(IBAction)savePlan:(id)sender
{
    plan.planAddress=addressLabel.text;
    
    NSMutableString *validation=[[NSMutableString alloc] initWithString:@"Please select"];
    if ([dateLabel.text isEqualToString:@""])
    {
        [validation appendString:@" date,"];
    }
    
    if ([addressLabel.text isEqualToString:@""])
    {
        [validation appendString:@" address,"];
    }
    
    if ([descriptionTextView.text isEqualToString:@"Plan description..."] || [descriptionTextView.text isEqualToString:@""]) 
    {
        [validation appendString:@" description,"];
    }
    
    if ([validation length]<=13)
    {
        loadNewPlan=TRUE;
        if ([planEditFlag isEqualToString:@"yes"])
        {
            plan.planId=globalPlan.planId;
            plan.planDescription=descriptionTextView.text;
            [rc updatePlan:plan :@"Auth-Token" :smAppDelegate.authToken];
            [smAppDelegate showActivityViewer:self.view];
            [smAppDelegate.window setUserInteractionEnabled:NO];
        }
        else 
        {
            [rc createPlan:plan :@"Auth-Token" :smAppDelegate.authToken];
            [smAppDelegate showActivityViewer:self.view];
            [smAppDelegate.window setUserInteractionEnabled:NO];
        }
    }
    else
    {
        [UtilityClass showAlert:@"" :validation];
    }
    [validation release];
}

-(IBAction)cancelPlan:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];    
}

-(IBAction)saveCustom:(id)sender
{
    [permittedUserArr removeAllObjects]; 
    [permittedCircleArr removeAllObjects]; 
    for (int i=0; i<[selectedCircleCheckArr count]; i++) 
    {
        NSLog(@" %@",((UserCircle *)[circleListGlobalArray objectAtIndex:((NSIndexPath *)[selectedCircleCheckArr objectAtIndex:i]).row]).circleName) ;
        NSLog(@"selectedCustomCircleCheckArr %@ circleList %@",selectedCircleCheckArr,circleListGlobalArray);
        
        [permittedCircleArr addObject:((UserCircle *)[circleListGlobalArray objectAtIndex:((NSIndexPath *)[selectedCircleCheckArr objectAtIndex:i]).row]).circleID];
    }
    
    for (int i=0; i<[selectedFriends count]; i++)
    {
        [permittedUserArr addObject:((UserFriends *)[selectedFriends objectAtIndex:i]).userId];
    }
    NSLog(@"permittedCircleArr %@ permittedUserArr %@",permittedCircleArr,permittedUserArr);
    plan.permittedUsers=permittedUserArr;
    plan.permittedCircles=permittedCircleArr;
    [customView removeFromSuperview];
}

-(IBAction)cancelCustom:(id)sender
{
    [selectedCustomCircleCheckArr removeAllObjects];
    [customSelectedFriendsIndex removeAllObjects];
    [customView removeFromSuperview];
}

-(IBAction)selecDate:(id)sender
{
    [descriptionTextView resignFirstResponder];
    [ActionSheetPicker displayActionPickerWithView:sender datePickerMode:UIDatePickerModeDateAndTime selectedDate:[NSDate date] target:self action:@selector(dateWasSelected::) title:@"Date"]; 

}

-(IBAction)back:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)placeWasSelected:(NSNumber *)selectedIndex:(id)element 
{
    int selectedLocation=[selectedIndex intValue];
    NSLog(@"selectedLocation %d",selectedLocation);
    LocationItemPlace *aPlaceItem = (LocationItemPlace*)[smAppDelegate.placeList objectAtIndex:selectedLocation];
    NSLog(@"aPlaceItem.placeInfo.name %@  %@ %@",aPlaceItem.placeInfo.name,aPlaceItem.placeInfo.location.latitude,aPlaceItem.placeInfo.location.longitude);
    addressLabel.text=[NSString stringWithFormat:@"%@, %@",aPlaceItem.placeInfo.name,aPlaceItem.placeInfo.vicinity];
    plan.planGeolocation.latitude=aPlaceItem.placeInfo.location.latitude;
    plan.planGeolocation.longitude=aPlaceItem.placeInfo.location.longitude;
    plan.planAddress=addressLabel.text;
}

-(void) displayNotificationCount {
    int totalNotif= [UtilityClass getNotificationCount];
    if (totalNotif == 0)
        totalNotifCount.text = @"";
    else
        totalNotifCount.text = [NSString stringWithFormat:@"%d",totalNotif];
}

-(void)myPlacesWasSelected:(NSNumber *)selectedIndex:(id)element
{
    int selectedLocation= [selectedIndex intValue];
    NSLog(@"sel ind %d %@",[selectedIndex intValue],[myPlaceArr objectAtIndex:selectedLocation]);
    Places *place=[myPlaceArr objectAtIndex:selectedLocation];
    addressLabel.text=[NSString stringWithFormat:@"%@, %@",place.name,place.address];;
    plan.planAddress=addressLabel.text;
    plan.planGeolocation.latitude=place.location.latitude;
    plan.planGeolocation.longitude=place.location.longitude;
}

-(void)setPlanAddress:(Plan *)aPlan
{
    addressLabel.text=aPlan.planAddress;
    plan.planAddress=aPlan.planAddress;
    plan.planGeolocation.latitude=aPlan.planGeolocation.latitude;
    plan.planGeolocation.longitude=aPlan.planGeolocation.longitude;
    [radio gotoButton:2];
    NSLog(@"[placeNameArr indexOfObject:aPlan.planAddress] %d",[placeNameArr indexOfObject:aPlan.planAddress]);
}

-(void)setAddressDateShare:(Plan *)aPlan
{
    descriptionTextView.text=aPlan.planDescription;
    [self setPlanAddress:aPlan];
    if ([aPlan.planPermission isEqualToString: @"private"])
    {
        [shareRadio gotoButton:0];
        plan.planPermission=@"private";
    } 
    else if ([aPlan.planPermission isEqualToString: @"friends"])
    {
        [shareRadio gotoButton:1];
        plan.planPermission=@"friends";
    }
    else if ([aPlan.planPermission isEqualToString: @"circles"])
    {
        [shareRadio gotoButton:2];
        plan.planPermission=@"circles";
    }
    else if ([aPlan.planPermission isEqualToString: @"public"])
    {
        [shareRadio gotoButton:3];
        plan.planPermission=@"public";
    }
    else if ([aPlan.planPermission isEqualToString: @"custom"])            
    {
        [shareRadio gotoButton:4];
        plan.planPermission=@"custom";
    }
    plan.planeDate=globalPlan.planeDate;
    dateLabel.text=globalPlan.planeDate;
    titleLabel.text=@"Update plan";
    [saveButton setTitle:@"Update" forState:UIControlStateNormal];
}

- (void)dateWasSelected:(NSDate *)selectedDate:(id)element 
{
    NSString *dateString;
    NSDate *date =selectedDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH.mm Z"];    
    dateString = [dateFormatter stringFromDate:date];        
    plan.planeDate=dateString;
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH.mm"];    
    dateString = [dateFormatter stringFromDate:date];            
    dateLabel.text=dateString;
    [dateFormatter release];
}

// NOTE: DDAnnotationCoordinateDidChangeNotification won't fire in iOS 4, use -mapView:annotationView:didChangeDragState:fromOldState: instead.
- (void)coordinateChanged_:(NSNotification *)notification
{	
	annotation = notification.object;
	annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
    //annotation.subtitle=
    [self setAddressFromLatLon:annotation.coordinate.latitude withLongitude:annotation.coordinate.longitude forAnnotation:annotation];
}

- (void)getMyPlaces:(NSNotification *)notif
{
    myPlaceArr=[notif object];
    for (int i=0; i<[myPlaceArr count]; i++)
    {
        Places *place=[myPlaceArr objectAtIndex:i];
        [placeNameArr addObject:place.name];
    }
    NSLog(@"got all places %@",placeNameArr);
}

- (void)createPlanDone:(NSNotification *)notif
{
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    if (createCounter==0)
    {
        [UtilityClass showAlert:@"" :@"Plan created successfuly"];
    }
    createCounter++;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)updatePlanDone:(NSNotification *)notif
{
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    updateCounter++;
    if (updateCounter==1) 
    {
        NSLog(@"update counter: %d",updateCounter);
        [UtilityClass showAlert:@"" :@"Plan updated successfully"];
    }
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)gotoNotification:(id)sender
{
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    NotificationController *controller =[storybrd instantiateViewControllerWithIdentifier:@"notificationViewController"];
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
    
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSLog(@"textview should begin");
    [UtilityClass beganEditing:(UIControl *)textView];
    if (!(textView.textColor == [UIColor blackColor])) 
    {
        if ([textView.text isEqualToString:@"Plan description..."]) {
            textView.text = @"";
        }
        textView.textColor = [UIColor blackColor];
    }
    return YES;
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

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [UtilityClass endEditing];
    if (!(textView.textColor == [UIColor lightGrayColor])) {
        textView.textColor = [UIColor lightGrayColor];
    }
    plan.planDescription=descriptionTextView.text;
    [descriptionTextView resignFirstResponder];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState 
{
	
	if (oldState == MKAnnotationViewDragStateDragging) 
    {
		annotation = (DDAnnotation *)annotationView.annotation;
		annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
        //annotation.subtitle=
        [self setAddressFromLatLon:annotation.coordinate.latitude withLongitude:annotation.coordinate.longitude forAnnotation:annotation];
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
    //[self performSelector:@selector(getLoc:) withObject:annotation afterDelay:0];
    [self.mapView setRegion:mapView.region animated:TRUE];
}
/*
-(void)getLoc:(DDAnnotation *)annotation
{
    [UtilityClass getAddressFromLatLon:annotation.coordinate.latitude withLongitude:annotation.coordinate.longitude];
}
*/
-(IBAction)segmentChanged:(id)sender
{
    if (segmentControl.selectedSegmentIndex==0) {
        [circleTableView setHidden:YES];
        [frndsScrollView setHidden:NO];
        [friendSearchbar setHidden:NO];
    }
    else if (segmentControl.selectedSegmentIndex==1) {
        [circleTableView setHidden:NO];
        [frndsScrollView setHidden:YES];
        [friendSearchbar setHidden:YES];
    }
}








-(void) reloadScrollview
{
    NSLog(@"upload create scroll init %i, %d",isBgDlRunning,[FriendList count]);
    if (isBgDlRunning==TRUE)
    {
        int x=0; //declared for imageview x-axis point    
        NSArray* subviews = [NSArray arrayWithArray: frndsScrollView.subviews];
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
        
        frndsScrollView.contentSize=CGSizeMake([FriendList count]*80, 100);        
        NSLog(@"event create isBgTaskRunning %i, %d",isBgDlRunning,[FriendList count]);
        for(int i=0; i<[FriendList count];i++)               
        {
            if(i< [FriendList count]) 
            { 
                UserFriends *userFrnd=[FriendList objectAtIndex:i];
                imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
                
                if(!isDragging_msg && !isDecliring_msg)
                    [imgView loadFromURL:[NSURL URLWithString:userFrnd.imageUrl]];
                
                UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(x, 0, 80, 80)];
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
                for (int c=0; c<[selectedFriends count]; c++)
                {
                    if ([[FriendList objectAtIndex:i] isEqual:[selectedFriends objectAtIndex:c]]) 
                    {
                        imgView.layer.borderColor=[[UIColor greenColor] CGColor];
                        NSLog(@"found selected: %@",[selectedFriends objectAtIndex:c]);
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
                [frndsScrollView addSubview:aView];
                [aView release];
                [imgView release];
                [name release];
            }        
            x+=80;
        }
    }
}

//handling selection from scroll view of friends selection
-(IBAction) handleTapGesture:(UIGestureRecognizer *)sender
{
    NSArray* subviews = [NSArray arrayWithArray: frndsScrollView.subviews];
    if ([selectedFriends containsObject:[FriendList objectAtIndex:[sender.view tag]]])
    {
        [selectedFriends removeObject:[FriendList objectAtIndex:[sender.view tag]]];
    } 
    else 
    {
        [selectedFriends addObject:[FriendList objectAtIndex:[sender.view tag]]];
    }
    UserFriends *frnds=[FriendList objectAtIndex:[sender.view tag]];
    NSLog(@"selectedFriends : %@ %@",selectedFriends,frndsScrollView);
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
    [self reloadScrollview];
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
    
    SelectCircleTableCell *cell = [circleTableView
                                   dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if ([[circleList objectAtIndex:indexPath.row] isEqual:[NSNull null]]) 
    {
        cell.circrcleName.text=[NSString stringWithFormat:@"Custom (%d)",[((UserCircle *)[circleListGlobalArray objectAtIndex:indexPath.row]).friends count]] ;
    }
    else 
    {
        [((UserCircle *)[circleListGlobalArray objectAtIndex:indexPath.row]).friends count];
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
    
    [cell.circrcleCheckbox addTarget:self action:@selector(handleTableViewCheckbox:) forControlEvents:UIControlEventTouchUpInside];
    
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

-(void)loadDummydata
{
    isBgDlRunning=TRUE;
    circleList=[[NSMutableArray alloc] init];
    [circleList removeAllObjects];
    UserCircle *circle;
    for (int i=0; i<[circleListGlobalArray count]; i++)
    {
        circle=[circleListGlobalArray objectAtIndex:i];
        [circleList addObject:circle.circleName];
    }
    UserFriends *frnds;
    ImgesName = [[NSMutableArray alloc] init];    
    searchTexts=[[NSString alloc] initWithString:@""];
    friendsNameArr=[[NSMutableArray alloc] init];
    friendsIDArr=[[NSMutableArray alloc] init];
    FriendList=[[NSMutableArray alloc] init];
    friendListArr=[[NSMutableArray alloc] init];
    
    for (int i=0; i<[friendListGlobalArray count]; i++)
    {
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
        NSLog(@"frnds.imageUrl %@  frnds.userName %@ frnds.userId %@",frnds.imageUrl,frnds.userName,frnds.userId);
        [friendListArr addObject:frnds];
    }    
    FriendList=[friendListArr mutableCopy];
    NSLog(@"frnd count %d",[FriendList count]);
    
}

//search bar delegate method starts
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText 
{
    // We don't want to do anything until the user clicks 
    // the 'Search' button.
    // If you wanted to display results as the user types 
    // you would do that here.
    if (searchBar==friendSearchbar)
    {
        searchText=friendSearchbar.text;
        
        if ([searchText length]>0) 
        {
            [self performSelector:@selector(searchResult) withObject:nil afterDelay:0.1];
            NSLog(@"searchText  %@",searchText);
        }
        else
        {
            searchTexts=@"";
            [FriendList removeAllObjects];
            FriendList = [[NSMutableArray alloc] initWithArray: friendListArr];
            [self reloadScrollview];
        }
        
        
    }
    else
    {
        
    }
    searchText=friendSearchbar.text;
    
    if ([searchText length]>0) 
    {
        [self performSelector:@selector(searchResult) withObject:nil afterDelay:0.1];
        NSLog(@"searchText  %@",searchText);
    }
    else
    {
        searchTexts=@"";
        [FriendList removeAllObjects];
        FriendList = [[NSMutableArray alloc] initWithArray: friendListArr];
        [self reloadScrollview];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar 
{
    // searchBarTextDidBeginEditing is called whenever 
    // focus is given to the UISearchBar
    // call our activate method so that we can do some 
    
    searchTexts=friendSearchbar.text;
    [UtilityClass beganEditing:(UIControl *)friendSearchbar];
    
    
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
    [UtilityClass endEditing];
    [friendSearchbar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // Clear the search text
    // Deactivate the UISearchBar
    friendSearchbar.text=@"";
    searchTexts=@"";    
    [FriendList removeAllObjects];
    FriendList = [[NSMutableArray alloc] initWithArray: friendListArr];
    [self reloadScrollview];
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
    {
        NSLog(@"Search button clicked");
        searchTexts=friendSearchbar.text;
        [self searchResult];
        [friendSearchbar resignFirstResponder];    
    }
}

-(void)searchResult
{
    [self loadDummydata];
    searchTexts = friendSearchbar.text;
    NSLog(@"in search method..");
    
    [FriendList removeAllObjects];
    
    if ([searchTexts isEqualToString:@""])
    {
        NSLog(@"null string");
        friendSearchbar.text=@"";
        FriendList = [[NSMutableArray alloc] initWithArray: friendListArr];
    }
    else
    {
        for (UserFriends *sTemp in friendListArr)
        {
            NSRange titleResultsRange = [sTemp.userName rangeOfString:searchTexts options:NSCaseInsensitiveSearch];		
            NSLog(@"sTemp.userName: %@",sTemp.userName);
            if (titleResultsRange.length > 0)
            {
                [FriendList addObject:sTemp];
                NSLog(@"filtered friend: %@", sTemp.userName);            
            }
            else
            {
            }
        }
    }
 
    [self reloadScrollview];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_MY_PLACES_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_UPDATE_PLANS_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_CREATE_PLAN_DONE object:nil];
	// NOTE: This is optional, DDAnnotationCoordinateDidChangeNotification only fired in iPhone OS 3, not in iOS 4.
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"DDAnnotationCoordinateDidChangeNotification" object:nil];
    isBgDlRunning=FALSE;
    isPlanFromVenue=FALSE;
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

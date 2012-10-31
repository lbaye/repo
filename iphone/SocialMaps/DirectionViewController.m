//
//  DirectionViewController.m
//  SocialMaps
//
//  Created by Warif Rishi on 10/29/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "DirectionViewController.h"
#import "NotificationController.h"
#import <QuartzCore/QuartzCore.h>
#import "LocationItemPlace.h"
#import "DDAnnotationView.h"
#import "DDAnnotation.h"
#import "UtilityClass.h"
#import "AppDelegate.h"
#import "RestClient.h"
#import "Places.h"


#define     TAG_MY_PLACES           1002
#define     TAG_PLACES_NEAR         1003
#define     TAG_CURRENT_LOCATION    1004


@implementation DirectionViewController

@synthesize currentAddress;
@synthesize coordinateTo;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    scrollViewMain.contentSize = CGSizeMake(320, 745);
    
    CustomRadioButton *radioFrom = [[CustomRadioButton alloc] initWithFrame:CGRectMake(17, 82, self.view.frame.size.width - 28, 41) numButtons:4 labels:[NSArray arrayWithObjects:@"Current location",@"My places",@"Places near to me",@"Point on map",nil]  default:0 sender:self tag:2000];
    radioFrom.delegate = self;
    [scrollViewMain addSubview:radioFrom];
    [radioFrom release];
    
    CustomRadioButton *radioTo = [[CustomRadioButton alloc] initWithFrame:CGRectMake(17, 350, self.view.frame.size.width - 28, 41) numButtons:4 labels:[NSArray arrayWithObjects:@"Current location",@"My places",@"Places near to me",@"Point on map",nil]  default:3 sender:self tag:4000];
    radioTo.delegate = self;
    [self radioButtonClicked:3 sender:radioTo];
    [scrollViewMain addSubview:radioTo];
    [radioTo release];
    
    for (int i = 0; i < 4; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((i+1) * 12 + 65 * i, 12, 65, 65)];
        NSString *imageName = [NSString stringWithFormat:@"transport%d.png", i + 1];
        imageView.image = [UIImage imageNamed:imageName];
        [scrollViewTransport addSubview:imageView];
        imageView.layer.masksToBounds = YES;
        [imageView.layer setCornerRadius:7.0];
        
        // test kCGColorSpaceDeviceCMYK
        CGColorSpaceRef cmykSpace = CGColorSpaceCreateDeviceCMYK();
        CGFloat cmykValue[] = {.38, .02, .98, .05, 1};      // blue
        CGColorRef colorCMYK = CGColorCreate(cmykSpace, cmykValue);
        CGColorSpaceRelease(cmykSpace);
        NSLog(@"colorCMYK: %@", colorCMYK);
        
        // color with CGColor, uicolor will just retain it
        imageView.layer.borderColor = [[UIColor colorWithCGColor:colorCMYK] CGColor];
        imageView.layer.borderWidth = 1.0;
        if (i == 1) {
            imageView.layer.borderWidth = 4.0;
        }
        
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        tapGesture.numberOfTapsRequired = 1;
        [imageView addGestureRecognizer:tapGesture];
        [tapGesture release];
        imageView.tag = i + 1;
        imageView.userInteractionEnabled = YES;
        [imageView release];
    }
    
    labelAddressFrom.backgroundColor = [UIColor colorWithWhite:.5 alpha:.7];
    labelAddressTo.backgroundColor = [UIColor colorWithWhite:.5 alpha:.7];
    
    [self displayNotificationCount];
    
    //tableView setup
    tableViewPlacesFrom.dataSource = self;
    tableViewPlacesFrom.delegate = self;
    tableViewPlacesFrom.tag = TAG_CURRENT_LOCATION;
    tableViewPlacesTo.dataSource = self;
    tableViewPlacesTo.delegate = self;
    tableViewPlacesTo.tag = TAG_CURRENT_LOCATION;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMyPlaces:) name:NOTIF_GET_MY_PLACES_DONE object:nil];
    
    smAppDelegate = [[UIApplication sharedApplication] delegate];
    
    //load map data
    CLLocationCoordinate2D theCoordinate;
	theCoordinate.latitude = [smAppDelegate.currPosition.latitude doubleValue];
    theCoordinate.longitude = [smAppDelegate.currPosition.longitude doubleValue];
	
	annotationFrom = [[[DDAnnotation alloc] initWithCoordinate:theCoordinate addressDictionary:nil] autorelease];
    
	annotationFrom.title = @"Drag to Move Pin";
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(theCoordinate, 1000, 1000);
    MKCoordinateRegion adjustedRegion = [pointOnMapViewFrom regionThatFits:viewRegion];  
    [pointOnMapViewFrom setRegion:adjustedRegion animated:NO];
    
	[pointOnMapViewFrom addAnnotation:annotationFrom];
    
    annotationTo = [[[DDAnnotation alloc] initWithCoordinate:self.coordinateTo addressDictionary:nil] autorelease];
    
	annotationTo.title = @"Drag to Move Pin";
    
    MKCoordinateRegion viewRegionTo = MKCoordinateRegionMakeWithDistance(self.coordinateTo, 1000, 1000);
    MKCoordinateRegion adjustedRegionTo = [pointOnMapViewFrom regionThatFits:viewRegionTo]; 
     
    [pointOnMapViewTo setRegion:adjustedRegionTo animated:NO];
    
	[pointOnMapViewTo addAnnotation:annotationTo];
    
    [self setAddressLabelFromLatLon:annotationTo];
    
    self.currentAddress = @"";
    selectedPlaceIndexFrom = 1;
    selectedPlaceIndexTo = 0;
    transportMode = 2;
}

-(void) displayNotificationCount 
{
    int totalNotif= [UtilityClass getNotificationCount];
    if (totalNotif == 0)
        totalNotifCount.text = @"";
    else
        totalNotifCount.text = [NSString stringWithFormat:@"%d",totalNotif];
}

- (void)viewDidUnload
{
    [scrollViewMain release];
    scrollViewMain = nil;
    [scrollViewTransport release];
    scrollViewTransport = nil;
    [labelAddressTo release];
    labelAddressTo = nil;
    [labelAddressFrom release];
    labelAddressFrom = nil;
    [totalNotifCount release];
    totalNotifCount = nil;
    [tableViewPlacesFrom release];
    tableViewPlacesFrom = nil;
    [tableViewPlacesTo release];
    tableViewPlacesTo = nil;
    [pointOnMapViewFrom release];
    pointOnMapViewFrom = nil;
    [pointOnMapViewTo release];
    pointOnMapViewTo = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) radioButtonClicked:(int)indx sender:(id)sender {
    NSLog(@"radioButtonClicked index = %d sender.tag = %d", indx, [sender tag]);
    
    UITableView     *tableViewPlaces;
    DDAnnotation    *annotation;
    MKMapView       *pointOnMapView;
    int             *selectedPlaceIndex;
    
    switch ([sender tag]) {
        case 2000:
            tableViewPlaces = tableViewPlacesFrom;
            annotation = annotationFrom;
            pointOnMapView = pointOnMapViewFrom;
            selectedPlaceIndex = &selectedPlaceIndexFrom;
            break;
            
        default:
            tableViewPlaces = tableViewPlacesTo;
            annotation = annotationTo;
            pointOnMapView = pointOnMapViewTo;
            selectedPlaceIndex = &selectedPlaceIndexTo;
            break;
    }
    
    switch (indx) {
        case 3:
            tableViewPlaces.hidden = YES;
            CLLocationCoordinate2D theCoordinate;
            theCoordinate.latitude = annotation.coordinate.latitude;
            theCoordinate.longitude =annotation.coordinate.longitude;
            [pointOnMapView setCenterCoordinate:annotation.coordinate];
            [self performSelector:@selector(setAddressLabelFromLatLon:) withObject:annotation afterDelay:.3];
            break;
        case 2:
            tableViewPlaces.hidden = NO;
            tableViewPlaces.tag = TAG_PLACES_NEAR;
            *selectedPlaceIndex = 0;
            [tableViewPlaces reloadData];
            break;
        case 1:
            tableViewPlaces.hidden = NO;
            tableViewPlaces.tag = TAG_MY_PLACES;
            *selectedPlaceIndex = 0;
            [tableViewPlaces reloadData];
            RestClient *restClient = [[[RestClient alloc] init] autorelease];
            [restClient getMyPlaces:@"Auth-Token" :smAppDelegate.authToken];
            break;
        case 0:
            tableViewPlaces.hidden = NO;
            tableViewPlaces.tag = TAG_CURRENT_LOCATION;
            *selectedPlaceIndex = 0;
            [tableViewPlaces reloadData];
            break;
        default:
            break;
    }
    
}

- (void)setAddressLabelFromLatLon:(DDAnnotation*)annotation
{
    if (annotation) {
        if (annotation == annotationFrom) 
            labelAddressFrom.text = @"Retrieving address ...";
        else 
            labelAddressTo.text = @"Retrieving address ...";
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            if (annotation == annotationFrom) {
                labelAddressFrom.text = [UtilityClass getAddressFromLatLon:annotation.coordinate.latitude withLongitude:annotation.coordinate.longitude];
            } else {
                NSLog(@"to annotation %@", annotation);
                labelAddressTo.text=[UtilityClass getAddressFromLatLon:annotation.coordinate.latitude withLongitude:annotation.coordinate.longitude];
            }
            
        });
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [scrollViewMain release];
    [scrollViewTransport release];
    [labelAddressTo release];
    [labelAddressFrom release];
    [totalNotifCount release];
    [tableViewPlacesFrom release];
    [tableViewPlacesTo release];
    [pointOnMapViewFrom release];
    [pointOnMapViewTo release];
    [super dealloc];
}
- (IBAction)actionBackMe:(id)sender 
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)gotoNotification:(id)sender 
{
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    NotificationController *controller =[storybrd instantiateViewControllerWithIdentifier:@"notificationViewController"];
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
}

- (IBAction)actionCancelButton:(id)sender 
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)actionOkButton:(id)sender 
{
    //Use r for transit, b for bicycle, d for driving, h for avoid highways, t for avoid tolls.
    
    NSString *selectedTransportMode;
    
    switch (transportMode) {
        case 1:
            selectedTransportMode = @"r";
            break;
        case 2:
            selectedTransportMode = @"d";
            break;
        case 3:
            selectedTransportMode = @"b";
            break;
        case 4:
            selectedTransportMode = @"w";
            break;
        default:
            break;
    }
    
    //close our app and open map app installed in iPhone
    NSString *urlString=[NSString stringWithFormat:@"http://maps.google.com/?saddr=%f,%f&daddr=%f,%f&dirflg=%@", annotationFrom.coordinate.latitude, annotationFrom.coordinate.longitude, annotationTo.coordinate.latitude, annotationTo.coordinate.longitude, selectedTransportMode];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    
}

#pragma mark -
#pragma mark DDAnnotationCoordinateDidChangeNotification

// NOTE: DDAnnotationCoordinateDidChangeNotification won't fire in iOS 4, use -mapView:annotationView:didChangeDragState:fromOldState: instead.
- (void)coordinateChanged_:(NSNotification *)notification
{	
	//annotation = notification.object;
    [self performSelector:@selector(setAddressLabelFromLatLon:) withObject:notification.object afterDelay:.3];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState 
{
	
	if (oldState == MKAnnotationViewDragStateDragging) 
    {
		//annotation = (DDAnnotation *)annotationView.annotation;
        [self performSelector:@selector(setAddressLabelFromLatLon:) withObject:annotationView.annotation afterDelay:.3];
	}
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;		
	}
	
	static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
	MKAnnotationView *draggablePinView = [mapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];
	
	if (draggablePinView) 
    {
		draggablePinView.annotation = annotation;
	}
    else 
    {
		// Use class method to create DDAnnotationView (on iOS 3) or built-in draggble MKPinAnnotationView (on iOS 4).
		draggablePinView = [DDAnnotationView annotationViewWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier mapView:mapView];
        
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

#pragma mark -
#pragma mark TableviewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"placeList"];
    
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"placeList"] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        UIButton *buttonSelectPlace = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonSelectPlace.frame = CGRectMake(320-35, 18-10, 21, 21);
        [buttonSelectPlace setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateSelected];
        [buttonSelectPlace setImage:[UIImage imageNamed:@"location_bar_radio.png"] forState:UIControlStateNormal];
        //[buttonSelectPlace addTarget:self action:@selector(actionSelectPlaceButton:) forControlEvents:UIControlEventTouchUpInside];
        buttonSelectPlace.userInteractionEnabled = NO;
        
        [cell.contentView addSubview:buttonSelectPlace];
        
        UILabel *labelPlaceName = [[UILabel alloc] initWithFrame:CGRectMake(12, 18 - 10, 263, 21)];
        [labelPlaceName setFont:[UIFont fontWithName:kFontName size:kMediumLabelFontSize]];
        labelPlaceName.tag = 1001;
        [cell.contentView addSubview:labelPlaceName];
    } 
    
    UILabel *labelPlaceName = (UILabel*)[cell.contentView viewWithTag:1001];
    
    if (tableView.tag == TAG_MY_PLACES) {
        Places *aPlaceItem = (Places*)[myPlacesArray objectAtIndex:indexPath.row];
        labelPlaceName.text = aPlaceItem.name;
    } else if (tableView.tag == TAG_CURRENT_LOCATION) {
        if ([self.currentAddress isEqualToString:@""] || !self.currentAddress) {
            labelPlaceName.text = @"Retrieving address ...";
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                self.currentAddress = [UtilityClass getAddressFromLatLon:[smAppDelegate.currPosition.latitude doubleValue] withLongitude:[smAppDelegate.currPosition.longitude doubleValue]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    labelPlaceName.text = self.currentAddress;
                });
            });
        } else {
            labelPlaceName.text = self.currentAddress;
        }
        NSLog(@"current address = %@", self.currentAddress);
            
    } else {
        LocationItemPlace *aPlaceItem = (LocationItemPlace*)[smAppDelegate.placeList objectAtIndex:indexPath.row];
        labelPlaceName.text = aPlaceItem.placeInfo.name;
    }
    
    
    UIButton *selectBtn;
    
    for (UIView *eachView in [cell.contentView subviews]) {
        if ([eachView isKindOfClass:[UIButton class]]) {
            selectBtn = (UIButton*)eachView;
            break;
        }
    }
    
    int selectedPlaceIndex;
    
    if (tableView == tableViewPlacesFrom) {
        selectedPlaceIndex = selectedPlaceIndexFrom;
    } else {
        selectedPlaceIndex = selectedPlaceIndexTo;
    }
    
    NSLog(@"selectedPlaceIndes %d", selectedPlaceIndex);
    selectBtn.tag = indexPath.row + 1;
    
    if (selectBtn.tag == selectedPlaceIndex) {
        selectBtn.selected = YES;
    } else {
        selectBtn.selected = NO;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    NSLog(@"tableView cell selected %d", indexPath.row);    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UILabel         *labelAddress;
    DDAnnotation    *annotation;
    int             *selectedPlaceIndex;
    
    if (tableView == tableViewPlacesFrom) {
        labelAddress = labelAddressFrom;
        annotation = annotationFrom;
        selectedPlaceIndex = &selectedPlaceIndexFrom;
    } else {
        labelAddress = labelAddressTo;
        annotation = annotationTo;
        selectedPlaceIndex = &selectedPlaceIndexTo;
    }
    
    *selectedPlaceIndex = indexPath.row + 1;
    [tableView reloadData];
    
    if (tableView.tag == TAG_MY_PLACES) {
        Places *aPlaceItem = (Places*)[myPlacesArray objectAtIndex:indexPath.row];
        labelAddress.text = aPlaceItem.name;
        CLLocationCoordinate2D theCoordinate;
        theCoordinate.latitude = [aPlaceItem.location.latitude doubleValue];
        theCoordinate.longitude = [aPlaceItem.location.longitude doubleValue];
        annotation.coordinate = theCoordinate;
        
    } else if (tableView.tag == TAG_CURRENT_LOCATION) {
        CLLocationCoordinate2D theCoordinate;
        theCoordinate.latitude = [smAppDelegate.currPosition.latitude doubleValue];
        theCoordinate.longitude = [smAppDelegate.currPosition.longitude doubleValue];
        annotation.coordinate = theCoordinate;
        [self setAddressLabelFromLatLon:annotation];
        
    } else {
        LocationItemPlace *aPlaceItem = (LocationItemPlace*)[smAppDelegate.placeList objectAtIndex:indexPath.row];
        labelAddress.text = aPlaceItem.placeInfo.name;
        annotation.coordinate = aPlaceItem.coordinate;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView.tag == TAG_MY_PLACES) {
        return [myPlacesArray count];
    } else if (tableView.tag == TAG_CURRENT_LOCATION) {
        return 1;
    }  
    
    return [smAppDelegate.placeList count];
}

////friends List code
//handling selection from scroll view of friends selection
-(void) handleTapGesture:(UIGestureRecognizer *)sender
{
    NSLog(@"handleTapGesture sender.tag = %d", [sender.view tag]);
    transportMode = sender.view.tag;
    
    for (UIView *view in [scrollViewTransport subviews]) {
        if ([view isKindOfClass:[UIImageView class]]) {
            if (transportMode == view.tag) {
                view.layer.borderWidth=4.0;
            } else {
                view.layer.borderWidth = 1.0;
            }
        }
    }
}

- (void)getMyPlaces:(NSNotification *)notif {
    
    NSLog(@"gotMyPlaces");
    
    myPlacesArray = [notif object];
    NSLog(@"Places Array %@", myPlacesArray);
    
    if (tableViewPlacesFrom.tag == TAG_MY_PLACES)
        [tableViewPlacesFrom reloadData];
    if (tableViewPlacesTo.tag == TAG_MY_PLACES)
        [tableViewPlacesTo reloadData];
}

@end

//
//  MeetUpRequestController.m
//  SocialMaps
//
//  Created by Warif Rishi on 9/8/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "MeetUpRequestController.h"
#import "CustomRadioButton.h"
#import "CustomCheckbox.h"
#import <QuartzCore/QuartzCore.h>
#import "UserFriends.h"
#import "UserCircle.h"
#import "Globals.h"
#import "AppDelegate.h"
#import "DDAnnotationView.h"
#import "DDAnnotation.h"
#import "UtilityClass.h"
#import "LocationItemPlace.h"
#import "RestClient.h"
#import "LocationItemPlace.h"
#import "NotificationController.h"

#define     kOFFSET_FOR_KEYBOARD    215
#define     TAG_MY_PLACES           1002
#define     TAG_PLACES_NEAR         1003
#define     TAG_CURRENT_LOCATION    1004


static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;

bool searchFlag;
__strong NSMutableArray *filteredList,*friendListArr, *circleList;
__strong NSString *searchTexts;
NSMutableDictionary *imageDownloadsInProgress, *friendsNameArr, *friendsIDArr;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;


@implementation MeetUpRequestController

@synthesize currentAddress;
@synthesize selectedfriendId;
@synthesize selectedLocatonItem;
@synthesize totalNotifCount;

DDAnnotation *annotation;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    CustomRadioButton *radio = [[CustomRadioButton alloc] initWithFrame:CGRectMake(10, 93, self.view.frame.size.width - 20, 41) numButtons:4 labels:[NSArray arrayWithObjects:@"Current location",@"My places",@"Places near to me",@"Point on map",nil]  default:0 sender:self tag:2000];
//    radio.delegate = self;
//    [self.view addSubview:radio];
    
    
    NSArray *def    = [NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil];
    NSArray *layers = [NSArray arrayWithObjects:@"Send direction", nil];
    
    CustomCheckbox *chkBox = [[CustomCheckbox alloc] initWithFrame:CGRectMake(184, 314, 140, 20) boxLocType:LabelPositionRight numBoxes:1 default:def labels:layers];
    chkBox.tag = 1003;
    chkBox.backgroundColor = [UIColor clearColor];
    //chkBox.delegate = self;
    [self.view addSubview:chkBox];
    
    //friends list
    frndListScrollView.delegate = self;
    selectedFriendsIndex=[[NSMutableArray alloc] init];
    filteredList=[[NSMutableArray alloc] init];
    friendListArr=[[NSMutableArray alloc] init];
    //dicImages_msg = [[NSMutableDictionary alloc] init];
    imageDownloadsInProgress = [NSMutableDictionary dictionary];
    [imageDownloadsInProgress retain];
    
    //set scroll view content size.
    [self loadDummydata];
    
    //reloading scrollview to start asynchronous download.
    //[self reloadScrolview]; 
    
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   
//    //load map data
//    CLLocationCoordinate2D theCoordinate;
//	theCoordinate.latitude = [smAppDelegate.currPosition.latitude doubleValue];
//    theCoordinate.longitude = [smAppDelegate.currPosition.longitude doubleValue];
//	
//	annotation = [[[DDAnnotation alloc] initWithCoordinate:theCoordinate addressDictionary:nil] autorelease];
//    
//	annotation.title = @"Drag to Move Pin";
//    
//    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(theCoordinate, 1000, 1000);
//    MKCoordinateRegion adjustedRegion = [pointOnMapView regionThatFits:viewRegion];  
//    [pointOnMapView setRegion:adjustedRegion animated:NO];
//    
//	[pointOnMapView addAnnotation:annotation];
    
    //tableView setup
    tableViewPlaces.dataSource = self;
    tableViewPlaces.delegate = self;
    tableViewPlaces.tag = TAG_CURRENT_LOCATION;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMyPlaces:) name:NOTIF_GET_MY_PLACES_DONE object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sentMeetUpRequest:) name:NOTIF_SEND_MEET_UP_REQUEST_DONE object:nil];
    
    [textViewPersonalMsg.layer setCornerRadius:8.0f];
    [textViewPersonalMsg.layer setBorderWidth:0.5];
    [textViewPersonalMsg.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [textViewPersonalMsg.layer setMasksToBounds:YES];
    
    labelAddress.backgroundColor = [UIColor colorWithWhite:.5 alpha:.7];
    
    self.currentAddress = @"";
    selectedPlaceIndex = 0;
    
    NSArray *subviews = [friendSearchbar subviews];
    UIButton *cancelButton = [subviews objectAtIndex:3];
    cancelButton.tintColor = [UIColor darkGrayColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self displayNotificationCount];
    
    //load map data
    CLLocationCoordinate2D theCoordinate;
	theCoordinate.latitude = [smAppDelegate.currPosition.latitude doubleValue];
    theCoordinate.longitude = [smAppDelegate.currPosition.longitude doubleValue];
	
	annotation = [[[DDAnnotation alloc] initWithCoordinate:theCoordinate addressDictionary:nil] autorelease];
    
	annotation.title = @"Drag to Move Pin";
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(theCoordinate, 1000, 1000);
    MKCoordinateRegion adjustedRegion = [pointOnMapView regionThatFits:viewRegion];  
    [pointOnMapView setRegion:adjustedRegion animated:NO];
    
	[pointOnMapView addAnnotation:annotation];
    
    int selectedRadioButtonIndex = 0;
    
    if (self.selectedfriendId) {
        for (int i = 0; i < [filteredList count]; i++) {
            if ([((UserFriends*)[filteredList objectAtIndex:i]).userId isEqualToString:self.selectedfriendId]) {
                [selectedFriendsIndex addObject:[NSString stringWithFormat:@"%d",i]];
            }
        }
    } else if (self.selectedLocatonItem) {
        [self radioButtonClicked:2 sender:nil];
        for (int i = 0; i < [smAppDelegate.placeList count]; i++) {
            LocationItemPlace *aPlaceItem = (LocationItemPlace*)[smAppDelegate.placeList objectAtIndex:i];
            if ([self.selectedLocatonItem isEqual:aPlaceItem]) {
                NSLog(@"select table row %d", i);
                selectedPlaceIndex = i + 1;
                selectedRadioButtonIndex = 2;
                labelAddress.text = self.selectedLocatonItem.placeInfo.name;
                annotation.coordinate = self.selectedLocatonItem.coordinate;
                [tableViewPlaces reloadData];
            }
        }
        
    }
    
    CustomRadioButton *radio = [[CustomRadioButton alloc] initWithFrame:CGRectMake(17, 93, self.view.frame.size.width - 28, 41) numButtons:4 labels:[NSArray arrayWithObjects:@"Current location",@"My places",@"Places near to me",@"Point on map",nil]  default:selectedRadioButtonIndex sender:self tag:2000];
    radio.delegate = self;
    [self.view addSubview:radio];
    
    /*
    for (int i = 0; i < [selectedFriendsIndex count]; i++) {
        NSString *userId = ((UserFriends*)[filteredList objectAtIndex:[[selectedFriendsIndex objectAtIndex:i] intValue]]).userId;
        [userIDs addObject:userId];
    }
     */
    [self reloadScrolview];
}

- (void) viewDidDisappear:(BOOL)animated
{
    NSArray *allDownloads = [imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_MY_PLACES_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_SEND_MEET_UP_REQUEST_DONE object:nil];
    
    [pointOnMapView release];
    pointOnMapView = nil;
    [labelAddress release];
    labelAddress = nil;
    [tableViewPlaces release];
    tableViewPlaces = nil;
    [textViewPersonalMsg release];
    textViewPersonalMsg = nil;
    [viewComposePersonalMsg release];
    viewComposePersonalMsg = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // terminate all pending download connections
    NSArray *allDownloads = [imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)actionBackMe:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)actionMeetUpReqButton:(id)sender {
    
    if ([selectedFriendsIndex count] == 0) {
        [UtilityClass showAlert:@"" :@"Select at least one friend"];
        return;
    }
    
    if ([labelAddress.text isEqualToString:@" "]) {
        [UtilityClass showAlert:@"" :@"Select an address"];
        return;
    }
    
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    
    NSMutableArray *userIDs=[[NSMutableArray alloc] init];
    
    for (int i = 0; i < [selectedFriendsIndex count]; i++) {
        NSString *userId = ((UserFriends*)[filteredList objectAtIndex:[[selectedFriendsIndex objectAtIndex:i] intValue]]).userId;
        [userIDs addObject:userId];
    }
    
    NSLog(@"user id %@", userIDs);
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    dateString = [dateFormatter stringFromDate:[UtilityClass convertDate:dateString tz_type:@"3" tz:@"UTC"]];
    
    [restClient sendMeetUpRequest:[NSString stringWithFormat:@"%@ has invited you to meet up at ", smAppDelegate.userAccountPrefs.username] description:textViewPersonalMsg.text latitude:[NSString stringWithFormat:@"%lf",annotation.coordinate.latitude] longitude:[NSString stringWithFormat:@"%lf",annotation.coordinate.longitude] address:labelAddress.text time:dateString recipients:userIDs authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
}

- (IBAction)actionSelectAll:(id)sender {
    ((UIButton*)sender).selected = !((UIButton*)sender).selected;
    if (((UIButton*)sender).selected) {
        [self selectAll:sender];
    } else {
        [self unSelectAll:sender];
    }
}

- (IBAction)actionCancelButton:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)actionAddPersonalMsgBtn:(id)sender {
    viewComposePersonalMsg.hidden = !viewComposePersonalMsg.hidden;
    if (!viewComposePersonalMsg.hidden) {
        [textViewPersonalMsg becomeFirstResponder];
    }
}

- (IBAction)actionSavePersonalMsgBtn:(id)sender {
    [textViewPersonalMsg resignFirstResponder];
    viewComposePersonalMsg.hidden = YES;
}

- (void) radioButtonClicked:(int)indx sender:(id)sender {
    NSLog(@"radioButtonClicked index = %d", indx);
    switch (indx) {
        case 3:
            tableViewPlaces.hidden = YES;
            CLLocationCoordinate2D theCoordinate;
            theCoordinate.latitude = annotation.coordinate.latitude;
            theCoordinate.longitude =annotation.coordinate.longitude;
//            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(theCoordinate, 1000, 1000);
//            MKCoordinateRegion adjustedRegion = [pointOnMapView regionThatFits:viewRegion];  
//            [pointOnMapView setRegion:adjustedRegion animated:YES]; 
            [pointOnMapView setCenterCoordinate:annotation.coordinate];
            [self performSelector:@selector(setAddressLabelFromLatLon) withObject:nil afterDelay:.3];
            break;
        case 2:
            tableViewPlaces.hidden = NO;
            tableViewPlaces.tag = TAG_PLACES_NEAR;
            selectedPlaceIndex = 0;
            [tableViewPlaces reloadData];
            break;
        case 1:
            tableViewPlaces.hidden = NO;
            tableViewPlaces.tag = TAG_MY_PLACES;
            selectedPlaceIndex = 0;
            [tableViewPlaces reloadData];
            RestClient *restClient = [[[RestClient alloc] init] autorelease];
            [restClient getMyPlaces:@"Auth-Token" :smAppDelegate.authToken];
            break;
        case 0:
            tableViewPlaces.hidden = NO;
            tableViewPlaces.tag = TAG_CURRENT_LOCATION;
            selectedPlaceIndex = 0;
            [tableViewPlaces reloadData];
            break;
        default:
            break;
    }
}

- (void)setAddressLabelFromLatLon
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        labelAddress.text=[UtilityClass getAddressFromLatLon:annotation.coordinate.latitude withLongitude:annotation.coordinate.longitude];
        //dispatch_async(dispatch_get_main_queue(), ^{
            //annotation.subtitle=addressLabel.text;
        //});
    });
    
    //labelAddress.text = [UtilityClass getAddressFromLatLon:annotation.coordinate.latitude withLongitude:annotation.coordinate.longitude];
}

- (void)getMyPlaces:(NSNotification *)notif {
    
    NSLog(@"gotMyPlaces");
    
    myPlacesArray = [notif object];
    NSLog(@"Places Array %@", myPlacesArray);
    [tableViewPlaces reloadData];
}

- (void)sentMeetUpRequest:(NSNotification *)notif {
    [self dismissModalViewControllerAnimated:YES];
}

-(void) displayNotificationCount {
    int totalNotif= [UtilityClass getNotificationCount];
    if (totalNotif == 0)
        totalNotifCount.text = @"";
    else
        totalNotifCount.text = [NSString stringWithFormat:@"%d",totalNotif];
}

-(IBAction)gotoNotification:(id)sender
{
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    NotificationController *controller =[storybrd instantiateViewControllerWithIdentifier:@"notificationViewController"];
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
    
}

// Tableview stuff
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
        [buttonSelectPlace addTarget:self action:@selector(actionSelectPlaceButton:) forControlEvents:UIControlEventTouchUpInside];
        buttonSelectPlace.userInteractionEnabled = NO;
        
        [cell.contentView addSubview:buttonSelectPlace];
        
        UILabel *labelPlaceName = [[UILabel alloc] initWithFrame:CGRectMake(12, 18 - 10, 263, 21)];
        [labelPlaceName setFont:[UIFont fontWithName:kFontName size:kMediumLabelFontSize]];
        labelPlaceName.tag = 1001;
        [cell.contentView addSubview:labelPlaceName];
    } 

    UILabel *labelPlaceName = (UILabel*)[cell.contentView viewWithTag:1001];
    
    if (tableViewPlaces.tag == TAG_MY_PLACES) {
        Places *aPlaceItem = (Places*)[myPlacesArray objectAtIndex:indexPath.row];
        labelPlaceName.text = aPlaceItem.name;
    } else if (tableViewPlaces.tag == TAG_CURRENT_LOCATION) {
        if ([self.currentAddress isEqual:@""]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                self.currentAddress = [UtilityClass getAddressFromLatLon:[smAppDelegate.currPosition.latitude doubleValue] withLongitude:[smAppDelegate.currPosition.longitude doubleValue]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    labelPlaceName.text = self.currentAddress;
                });
            });
            //self.currentAddress = [UtilityClass getAddressFromLatLon:[smAppDelegate.currPosition.latitude doubleValue] withLongitude:[smAppDelegate.currPosition.longitude doubleValue]];
        }
        NSLog(@"current address = %@", self.currentAddress);
        labelPlaceName.text = self.currentAddress;
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

    NSLog(@"selectedPlaceIndes %d", selectedPlaceIndex);
    selectBtn.tag = indexPath.row + 1;
        
    if (selectBtn.tag == selectedPlaceIndex) {
        selectBtn.selected = YES;
    } else {
        selectBtn.selected = NO;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    NSLog(@"tableView cell selected %d", indexPath.row);    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    selectedPlaceIndex = indexPath.row + 1;
    [tableViewPlaces reloadData];
    
    if (tableViewPlaces.tag == TAG_MY_PLACES) {
        Places *aPlaceItem = (Places*)[myPlacesArray objectAtIndex:indexPath.row];
        labelAddress.text = aPlaceItem.name;
        CLLocationCoordinate2D theCoordinate;
        theCoordinate.latitude = [aPlaceItem.location.latitude doubleValue];
        theCoordinate.longitude = [aPlaceItem.location.longitude doubleValue];
        annotation.coordinate = theCoordinate;
        
    } else if (tableViewPlaces.tag == TAG_CURRENT_LOCATION) {
        CLLocationCoordinate2D theCoordinate;
        theCoordinate.latitude = [smAppDelegate.currPosition.latitude doubleValue];
        theCoordinate.longitude = [smAppDelegate.currPosition.longitude doubleValue];
        annotation.coordinate = theCoordinate;
        [self setAddressLabelFromLatLon];
        
    } else {
        LocationItemPlace *aPlaceItem = (LocationItemPlace*)[smAppDelegate.placeList objectAtIndex:indexPath.row];
        labelAddress.text = aPlaceItem.placeInfo.name;
        annotation.coordinate = aPlaceItem.coordinate;
    }
    /*
    CLLocationCoordinate2D theCoordinate;
	theCoordinate.latitude = annotation.coordinate.latitude;
    theCoordinate.longitude =annotation.coordinate.longitude;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(theCoordinate, 1000, 1000);
    MKCoordinateRegion adjustedRegion = [pointOnMapView regionThatFits:viewRegion];  
    [pointOnMapView setRegion:adjustedRegion animated:NO]; 

	[pointOnMapView setCenterCoordinate:annotation.coordinate];
    */
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableViewPlaces.tag == TAG_MY_PLACES) {
        return [myPlacesArray count];
    } else if (tableViewPlaces.tag == TAG_CURRENT_LOCATION) {
        return 1;
    }  
    
    return [smAppDelegate.placeList count];
}

////friends List code
//handling selection from scroll view of friends selection
-(IBAction) handleTapGesture:(UIGestureRecognizer *)sender
{
    int imageIndex =((UITapGestureRecognizer *)sender).view.tag;
    NSArray* subviews = [NSArray arrayWithArray: frndListScrollView.subviews];
    if ([selectedFriendsIndex containsObject:[NSString stringWithFormat:@"%d",[sender.view tag]]])
    {
        [selectedFriendsIndex removeObject:[NSString stringWithFormat:@"%d",[sender.view tag]]];
    } 
    else 
    {
        [selectedFriendsIndex addObject:[NSString stringWithFormat:@"%d",[sender.view tag]]];
        
    }
    
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
    }
    [self reloadScrolview];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    isDragging_msg = TRUE;
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    isDecliring_msg = TRUE;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    isDecliring_msg = FALSE;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    isDragging_msg = FALSE;
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
        [selectedFriendsIndex removeAllObjects];
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
    [selectedFriendsIndex removeAllObjects];
    [self reloadScrolview];
    [friendSearchbar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar 
{
    // Do the search and show the results in tableview
    // Deactivate the UISearchBar
    // You'll probably want to do this on another thread
    // SomeService is just a dummy class representing some 
    // api that you are using to do the search
    
    searchTexts=friendSearchbar.text;
    searchFlag=false;
    [self searchResult];
    [friendSearchbar resignFirstResponder];    
}

-(void)searchResult
{
    //[self loadDummydata];
    searchTexts = friendSearchbar.text;
    
    //NSLog(@"filteredList99 %@ %@  %d  %d  imageDownloadsInProgress: %@",filteredList,friendListArr,[filteredList count],[friendListArr count], dicImages_msg);
    
    [filteredList removeAllObjects];
    
    if ([searchTexts isEqualToString:@""])
    {
        friendSearchbar.text=@"";
        filteredList = [[NSMutableArray alloc] initWithArray: friendListArr];
    }
    else
    {
        for (UserFriends *sTemp in friendListArr)
        {
            NSRange titleResultsRange = [sTemp.userName rangeOfString:searchTexts options:NSCaseInsensitiveSearch];		
            
            if (titleResultsRange.length > 0)
            {
                [filteredList addObject:sTemp];
            }
            else
            {
            }
        }
    }
    searchFlag=false;    
    
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

//lazy scroller

-(void) reloadScrolview
{
    int x=7; //declared for imageview x-axis point    
    NSArray* subviews = [NSArray arrayWithArray: frndListScrollView.subviews];
    UIImageView *imgView;
    for (UIView* view in subviews) 
    {
        if([view isKindOfClass :[UIView class]])
        {
            [view removeFromSuperview];
        }
    }
    frndListScrollView.contentSize=CGSizeMake([filteredList count] * 51, 45);
    
    for(int i=0; i<[filteredList count];i++)               
    {
        if(i< [filteredList count]) 
        { 
            //UserFriends *userFrnd=[[UserFriends alloc] init];
            UserFriends *userFrnd=[filteredList objectAtIndex:i];
            imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
            
            IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:userFrnd.userId];
            
            if (iconDownloader && iconDownloader.userFriends.userProfileImage.size.height > 5){
                imgView.image = iconDownloader.userFriends.userProfileImage; 
            }
            
            else 
            { 
                //if(!isDragging_msg && !isDecliring_msg) 
                if(!isDragging_msg && !isDecliring_msg)// && ([dicImages_msg objectForKey:[ImgesName objectAtIndex:i]]==nil))    
                {
                    //If scroll view moves set a placeholder image and start download image. 
                    //[dicImages_msg setObject:[UIImage imageNamed:@"NO_IMAGE"] forKey:userFrnd.imageUrl]; 
                    //[dicImages_msg setObject:[[UIImage alloc] init] forKey:userFrnd.imageUrl]; 
                    //[dicImages_msg setObject:@"NO_OBJECT" forKey:userFrnd.imageUrl]; 
                    //[self performSelectorInBackground:@selector(DownLoad:) withObject:[NSNumber numberWithInt:i]];  
                    //imgView.image = [UIImage imageNamed:@"girl.png"];   
                    
                    if (!iconDownloader) {
                        iconDownloader = [[IconDownloader alloc] init];
                    }
                    //
                    iconDownloader.userFriends = userFrnd;
                    iconDownloader.delegate = self;
                    //imgView.image = [[UIImage alloc] init];
                    iconDownloader.scrollSubViewTag = 420 + i;// [[frndListScrollView subviews] count];
                    [iconDownloader startDownload];
                    
                }
                   /*
                else 
                { 
                    // Image is not available, so set a placeholder image
                    //imgView.image = [UIImage imageNamed:@"girl.png"];                   
                }    
                    */
            }
            
            UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(x, 0, 45, 45)];
            UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(2, 28, 45 - 4, 15)];
            [name setFont:[UIFont fontWithName:@"Helvetica" size:10]];
            [name setNumberOfLines:1];
            [name setTextColor:[UIColor whiteColor]];
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
                if (i==[[selectedFriendsIndex objectAtIndex:c] intValue]) 
                {
                    imgView.layer.borderColor=[[UIColor greenColor] CGColor];
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
        x+=50;
    }
}

-(void)unSelectAll:(id)sender
{
    [selectedFriendsIndex removeAllObjects];
    [self reloadScrolview];
}

-(void)selectAll:(id)sender
{
    for (int i=0; i<[filteredList count]; i++)
    {
        [selectedFriendsIndex addObject:[NSString stringWithFormat:@"%d",i]];
    }
    [self reloadScrolview];
}
                   
- (void)appImageDidLoadForScrollView:(UserFriends*)userFriends:(UIImage*)image:(int)scrollSubViewTag
{
    NSLog(@"appImageDidLoadForScrollView");
    
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:userFriends.userId];
    if (iconDownloader) {
        [imageDownloadsInProgress setObject:iconDownloader forKey:userFriends.userId];
    } else {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.userFriends = userFriends;
        [imageDownloadsInProgress setObject:iconDownloader forKey:userFriends.userId];
        [iconDownloader release];
    }
    
    //[dicImages_msg setObject:image forKey:userFriends.imageUrl];
    
    int tag = scrollSubViewTag - 420;
    
    if (tag == 0) {
        for (UIView *view in [frndListScrollView subviews]) {
            if (view.tag == 0) {
                for (UIImageView *imageView in [view subviews]) {
                    if ([imageView isKindOfClass:[UIImageView class]]) {
                        imageView.image = image;
                        break;
                    }
                }
            }
        }
    } else {
        for (UIImageView *imageView in [[frndListScrollView viewWithTag:tag] subviews]) {
            if ([imageView isKindOfClass:[UIImageView class]]) {
                imageView.image = image;
                break;
            }
        }
    }
}

/*
-(void)DownLoad:(NSNumber *)path
{
    NSLog(@"in Download");
    //NSAutoreleasePool *pl = [[NSAutoreleasePool alloc] init];
    int index = [path intValue];
    UserFriends *userFrnd=[[UserFriends alloc] init];
    userFrnd=[filteredList objectAtIndex:index];
    
    NSString *Link = userFrnd.imageUrl;
    //Start download image from url
    UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:Link]]];
    if ((img) && ([dicImages_msg objectForKey:[ImgesName objectAtIndex:index]]==NULL))
    {
        //If download complete, set that image to dictionary
        [dicImages_msg setObject:img forKey:userFrnd.imageUrl];
        [self reloadScrolview];
    }
    // Now, we need to reload scroll view to load downloaded image
    //[self performSelectorOnMainThread:@selector(reloadScrolview) withObject:path waitUntilDone:NO];
    //[pl release];
}
*/
-(void)loadDummydata
{
    UserFriends *frnds=[[UserFriends alloc] init];
    
    for (int i=0; i<[friendListGlobalArray count]; i++)
    {
        frnds=[[UserFriends alloc] init];
        frnds=[friendListGlobalArray objectAtIndex:i];
        if ((frnds.imageUrl==NULL)||[frnds.imageUrl isEqual:[NSNull null]])
        {
            frnds.imageUrl=[[NSBundle mainBundle] pathForResource:@"thum" ofType:@"png"];
            NSLog(@"img url null %d",i);
        }
        [friendListArr addObject:frnds];
    }
    filteredList=[friendListArr mutableCopy];
}

#pragma mark -
#pragma mark DDAnnotationCoordinateDidChangeNotification

// NOTE: DDAnnotationCoordinateDidChangeNotification won't fire in iOS 4, use -mapView:annotationView:didChangeDragState:fromOldState: instead.
- (void)coordinateChanged_:(NSNotification *)notification
{	
	annotation = notification.object;
    [self performSelector:@selector(setAddressLabelFromLatLon) withObject:nil afterDelay:.3];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState 
{
	
	if (oldState == MKAnnotationViewDragStateDragging) 
    {
		annotation = (DDAnnotation *)annotationView.annotation;
        [self performSelector:@selector(setAddressLabelFromLatLon) withObject:nil afterDelay:.3];
	}
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;		
	}
	
	static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
	MKAnnotationView *draggablePinView = [pointOnMapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];
	
	if (draggablePinView) 
    {
		draggablePinView.annotation = annotation;
	}
    else 
    {
		// Use class method to create DDAnnotationView (on iOS 3) or built-in draggble MKPinAnnotationView (on iOS 4).
		draggablePinView = [DDAnnotationView annotationViewWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier mapView:pointOnMapView];
        
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

- (void)dealloc {
    [tableViewPlaces release];
    [textViewPersonalMsg release];
    [viewComposePersonalMsg release];
    [super dealloc];
}
@end

//
//  MapViewController.m
//  SocialMaps
//
//  Created by Arif Shakoor on 7/23/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//
#import "TargetConditionals.h"
#import "MapViewController.h"
#import "Location.h"
#import "NotifMessage.h"
#import "TagNotification.h"
#import "NotificationController.h"
#import "AppDelegate.h"
#import "Globals.h"
#import "UserFriends.h"
#import "FacebookHelper.h"
#import "UserDefault.h"
#import "UtilityClass.h"
#import "RestClient.h"
#import "Platform.h"
#import "NotificationPref.h"
#import "Geofence.h"
#import "LocationItemPeople.h"
#import "LocationItemPlace.h"
#import "RestClient.h"
#import "SearchLocation.h"
#import "MapAnnotationPeople.h"
#import "MapAnnotationPlace.h"
#import "Places.h"
#import "MessageListViewController.h"
#import "MeetUpRequestController.h"
#import "UserBasicProfileViewController.h"
#import "Globals.h"
#import "ViewCircleListViewController.h"
#import "ViewEventListViewController.h"

@interface MapViewController ()

- (void)startIconDownload:(UserFriends *)userFriends forIndexPath:(NSIndexPath *)indexPath;

@end

@implementation MapViewController
@synthesize mapView = _mapView;
@synthesize locationManager;
@synthesize mapPulldown = _mapPulldown;
@synthesize shareAllButton = _shareAllButton;
@synthesize shareFriendsButton = _shareFriendsButton;
@synthesize shareNoneButton = _shareNoneButton;
@synthesize shareCircleButton = _shareCircleButton;
@synthesize shareCustomButton = _shareCustomButton;
@synthesize showPeopleButton = _showPeopleButton;
@synthesize showPlacesButton = _showPlacesButton;
@synthesize showDealsButton = _showDealsButton;
@synthesize mapNotifBubble = _mapNotifBubble;
@synthesize mapNotifCount = _mapNotifCount;
@synthesize selSavedFilter = _selSavedFilter;
@synthesize selectedFilter = _selectedFilter;
@synthesize mapPullupMenu = _mapPullupMenu;
@synthesize selSharingType;
@synthesize savedFilters;
@synthesize pickSavedFilter;
@synthesize inviteFriendView;
@synthesize inviteFrndTableView;
@synthesize friendSearchBar;
@synthesize smAppDelegate;
@synthesize mapAnno;
@synthesize mapAnnoPeople;
@synthesize mapAnnoPlace;
@synthesize filteredList;
@synthesize selectedAnno;

UserFriends *afriend;
NSMutableDictionary *imageDownloadsInProgress;
NSMutableArray *userFriendsInviteIdArr;
__strong NSString *searchText;
bool searchFlag=FALSE;
FacebookHelper *fbHelper;
UserDefault *userDefault;

// Button event handler
typedef struct {
    LocationItemPeople *locItem;
    UITextView         *txtView;
} ButtonClickCallbackData;
ButtonClickCallbackData callBackData;

// UITextView delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        return FALSE;
    }
    return TRUE;
}

// End UITextView delegate

- (MKAnnotationView *)mapView:(MKMapView *)newMapView viewForAnnotation:(id <MKAnnotation>)newAnnotation {
    LocationItem * locItem = (LocationItem*) newAnnotation;
    
    MKAnnotationView *pin = nil;
    
    if ([locItem isKindOfClass:[LocationItemPeople class]])
        pin = [mapAnnoPeople mapView:_mapView viewForAnnotation:newAnnotation item:locItem];
    else if ([locItem isKindOfClass:[LocationItemPlace class]])
        pin = [mapAnnoPlace mapView:_mapView viewForAnnotation:newAnnotation item:locItem];
    else {//if (smAppDelegate.userAccountPrefs.icon != nil) {
        //pin = [mapAnno mapView:_mapView viewForAnnotation:newAnnotation item:locItem];
        pin = nil;
    }
    return pin;
}

- (void)drawRect:(CGRect)rect {
    NSLog(@"MapViewController:drawRect");
}

- (void) cancelRequest:(id)sender {
    [[sender superview] removeFromSuperview];
}
// Send the message out
- (void) sendMessage:(id)sender {
    [[sender superview] removeFromSuperview];
    
    NSString * subject = [NSString stringWithFormat:@"Message from %@ %@", smAppDelegate.userAccountPrefs.firstName,
                           smAppDelegate.userAccountPrefs.lastName];
    NSLog(@"Message to Name:%@, from %@ %@", callBackData.locItem.userInfo.firstName, subject, 
          
          
          callBackData.txtView.text);

    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    [restClient sendMessage:subject content:callBackData.txtView.text recipients:[NSArray arrayWithObject:callBackData.locItem.userInfo.userId] authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
}

-(void)saveFBProfileImage
{
    NSString *profileImageUrl=[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=normal",smAppDelegate.fbId];
    UIImage *profileImage=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profileImageUrl]]];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:@"FBProfilePic"];
    NSLog(@"profileImageUrl is %@  %@", profileImageUrl, profileImage );
    [prefs setObject:[NSKeyedArchiver archivedDataWithRootObject:profileImage] forKey:@"FBProfilePic"];
    [prefs synchronize];
}

// Send the friend request out
- (void) sendRequest:(id)sender {
    NSLog(@"Name:%@, tag=%@", callBackData.locItem.userInfo.firstName, callBackData.txtView.text);
    [[sender superview] removeFromSuperview];
    
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    [restClient sendFriendRequest:callBackData.locItem.userInfo.userId message:callBackData.txtView.text authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
}

- (void) addFriendSelected:(id <MKAnnotation>)anno {
    NSLog(@"MapViewController:addFriendSelected");
    LocationItemPeople *locItem = (LocationItemPeople*) anno;
    
    UIView *messageView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, 
                                                                  self.view.frame.origin.y+40, 
                                                                  self.view.frame.size.width, 
                                                                   (self.view.frame.size.height-90)/2)];
    messageView.backgroundColor = [UIColor blackColor];

    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, messageView.frame.size.width-20, 
                                                                        messageView.frame.size.height-45)];
    [textView.layer setCornerRadius:10.0f];
    [textView.layer setMasksToBounds:YES];
    textView.backgroundColor = [UIColor whiteColor];
    textView.delegate = self;
    textView.tag = 20000;
    [textView setReturnKeyType: UIReturnKeyDone];
    [messageView addSubview:textView];
    
    // BUttons
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.backgroundColor = [UIColor clearColor];
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelRequest:) forControlEvents:UIControlEventTouchUpInside];
    CGRect cancelFrame = CGRectMake(messageView.frame.size.width/2-80, messageView.frame.size.height-5-30, 60, 30);
    cancelBtn.frame = cancelFrame;
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIImageView *sep = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"sp.png"]];
    CGRect sepFrame = CGRectMake(messageView.frame.size.width/2, messageView.frame.size.height-5-30, 
                                 1, 30);
    sep.frame = sepFrame;
    [messageView addSubview:sep];
    [sep release];
    
    callBackData.locItem = locItem;
    callBackData.txtView = textView;
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.backgroundColor = [UIColor clearColor];
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendRequest:) forControlEvents:UIControlEventTouchUpInside];
    CGRect sendFrame = CGRectMake(messageView.frame.size.width/2+20, messageView.frame.size.height-5-30, 60, 30);
    sendButton.frame = sendFrame;
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    [messageView addSubview:cancelBtn];
    [messageView addSubview:sendButton];
    
    [[self view] addSubview:messageView];
    
}

- (void) showAnnotationDetailView:(id <MKAnnotation>) anno {

    LocationItem *selLocation = (LocationItem*) anno;
    [self mapAnnotationChanged:selLocation];
    [mapAnno changeStateToDetails:selLocation];
    [self performSelector:@selector(startMoveMap:) withObject:selLocation afterDelay:.8];
}

-(void) startMoveMap:(LocationItem*)locItem
{
    MKMapRect r = [self.mapView visibleMapRect];
    MKMapPoint pt = MKMapPointForCoordinate(locItem.coordinate);
    r.origin.x = pt.x - r.size.width * 0.3;
    r.origin.y = pt.y - r.size.height * 0.5;
    [self.mapView setVisibleMapRect:r animated:YES];
}

// MapAnnotation delegate methods
- (void) mapAnnotationChanged:(id <MKAnnotation>) anno {
    NSLog(@"MapViewController:mapAnnotationChanged");
    if (selectedAnno != nil && selectedAnno != anno) {
        LocationItem *selLocation = (LocationItem*) selectedAnno;
        selLocation.currDisplayState = MapAnnotationStateNormal;
        [_mapView removeAnnotation:(id <MKAnnotation>)selectedAnno];
        [_mapView addAnnotation:(id <MKAnnotation>)selectedAnno];
    }
    [_mapView removeAnnotation:anno];
    [_mapView addAnnotation:anno];
    selectedAnno = anno;
    
    [self.view setNeedsDisplay];

}

- (void) meetupRequestPlaceSelected:(id <MKAnnotation>)anno {
    LocationItemPlace *locItem = (LocationItemPlace*) anno;
    
    NSLog(@"meetupRequestPlaceSelected");
    
    for (LocationItemPlace *eachLocationItem in smAppDelegate.placeList) {
        if ([eachLocationItem.placeInfo.location isEqual:locItem.placeInfo.location]) {
            MeetUpRequestController *controller = [[MeetUpRequestController alloc] initWithNibName:@"MeetUpRequestController" bundle:nil];
            controller.selectedLocatonItem = locItem;
            controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentModalViewController:controller animated:YES];
            [controller release];
        }
    }
    
}

- (void) meetupRequestSelected:(id <MKAnnotation>)anno {
    NSLog(@"MapViewController:meetupRequestSelecetd");
    NSLog(@"class = %@", [anno class]);
    LocationItemPeople *locItem = (LocationItemPeople*) anno;
    
    int i = 0;
    for (; i < [friendListGlobalArray count]; i++) {
        UserInfo *userInfo = [friendListGlobalArray objectAtIndex:i];
        if ([userInfo.userId isEqualToString:locItem.userInfo.userId]) {
            break;
        }
    }
    if (i == [friendListGlobalArray count]) {
        [UtilityClass showAlert:@"" :[NSString stringWithFormat:@"%@ is not in your friend list.",locItem.userInfo.firstName]];
        return;
    }
    
    MeetUpRequestController *controller = [[MeetUpRequestController alloc] initWithNibName:@"MeetUpRequestController" bundle:nil];
    controller.selectedfriendId = locItem.userInfo.userId;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

- (void) directionSelected:(id <MKAnnotation>)anno {
    NSLog(@"MapViewController:directionSelected");
}
- (void) messageSelected:(id <MKAnnotation>)anno {
    NSLog(@"MapViewController:messageSelected");
    LocationItemPeople *locItem = (LocationItemPeople*) anno;
    
    UIView *messageView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, 
                                                                   self.view.frame.origin.y+40, 
                                                                   self.view.frame.size.width, 
                                                                   (self.view.frame.size.height-90)/2)];
    messageView.backgroundColor = [UIColor blackColor];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, messageView.frame.size.width-20, 
                                                                        messageView.frame.size.height-45)];
    [textView.layer setCornerRadius:10.0f];
    [textView.layer setMasksToBounds:YES];
    textView.backgroundColor = [UIColor whiteColor];
    textView.delegate = self;
    textView.tag = 20000;
    [textView setReturnKeyType: UIReturnKeyDone];
    [messageView addSubview:textView];
    
    // BUttons
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.backgroundColor = [UIColor clearColor];
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelRequest:) forControlEvents:UIControlEventTouchUpInside];
    CGRect cancelFrame = CGRectMake(messageView.frame.size.width/2-80, messageView.frame.size.height-5-30, 60, 30);
    cancelBtn.frame = cancelFrame;
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIImageView *sep = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"sp.png"]];
    CGRect sepFrame = CGRectMake(messageView.frame.size.width/2, messageView.frame.size.height-5-30, 
                                 1, 30);
    sep.frame = sepFrame;
    [messageView addSubview:sep];
    [sep release];
    
    callBackData.locItem = locItem;
    callBackData.txtView = textView;
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.backgroundColor = [UIColor clearColor];
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    CGRect sendFrame = CGRectMake(messageView.frame.size.width/2+20, messageView.frame.size.height-5-30, 60, 30);
    sendButton.frame = sendFrame;
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [messageView addSubview:cancelBtn];
    [messageView addSubview:sendButton];
    
    [[self view] addSubview:messageView];

}

- (void) performUserAction:(MKAnnotationView*) annoView type:(MAP_USER_ACTION) actionType {
    LocationItemPlace *locItem = (LocationItemPlace*) [annoView annotation];

    //selectedAnno = [annoView annotation];
    [self mapAnnotationChanged:[annoView annotation]];
    [_mapView bringSubviewToFront:annoView];
    
    NSLog(@"MapViewController: performUserAction %@ type=%d", locItem.itemName, actionType);
    
    switch (actionType) {
        case MapAnnoUserActionAddFriend:
            [self addFriendSelected:locItem];
            break;
        case MapAnnoUserActionMessage:
            [self messageSelected:locItem];
            break;
        case MapAnnoUserActionMeetup:
            [self meetupRequestSelected:locItem];
            break;
        case MapAnnoUserActionDirection:
            [self directionSelected:locItem];
            break;
        case MapAnnoUserActionMeetupPlace:
            [self meetupRequestPlaceSelected:locItem];
            break;
        default:
            break;
    }
}
// MapAnnotation delegate methods end

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];  
    
    NSLog(@"MapViewController:viewDidLoad" );

    // Map drag handler
    UIPanGestureRecognizer* panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
    [panRec setDelegate:self];
    [_mapView addGestureRecognizer:panRec];
    
    UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc] 
                                      initWithTarget:self action:@selector(didTapMap)];
    [_mapView addGestureRecognizer:tapRec];
    tapRec.delegate = self;
    [tapRec release];

    // GCD notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotNotifMessages:) name:NOTIF_GET_INBOX_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotFriendRequests:) name:NOTIF_GET_FRIEND_REQ_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotMeetUpRequests:) name:NOTIF_GET_MEET_UP_REQUEST_DONE object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllEventsDone:) name:NOTIF_GET_ALL_EVENTS_DONE object:nil];
//
    filteredList = [[NSMutableArray alloc] initWithArray: userFriendslistArray];
    
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self performSelectorInBackground:@selector(saveFBProfileImage) withObject:nil];
    _mapView.delegate=self;
    _mapView.showsUserLocation=YES;
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDistanceFilter:kCLLocationAccuracyHundredMeters]; 
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager startUpdatingLocation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotListings:) name:NOTIF_GET_LISTINGS_DONE object:nil];
    
    // Get Information
    [smAppDelegate getUserInformation:smAppDelegate.authToken];

    mapAnno = [[MapAnnotation alloc] init];
    mapAnno.currState = MapAnnotationStateNormal;
    mapAnno.delegate = self;
    
    mapAnnoPeople = [[MapAnnotationPeople alloc] init];
    mapAnnoPeople.currState = MapAnnotationStateNormal;
    mapAnnoPeople.delegate = self;
    
    mapAnnoPlace = [[MapAnnotationPlace alloc] init];
    mapAnnoPlace.currState = MapAnnotationStateNormal;
    mapAnnoPlace.delegate = self;
    
    // Location update button
    UIButton *locUpdateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    locUpdateBtn.frame = CGRectMake(self.view.frame.size.width-20-25, 
                                    70, 25, 24);
    [locUpdateBtn setImage:[UIImage imageNamed:@"map_geoloc_icon.png"] forState:UIControlStateNormal];
    [locUpdateBtn addTarget:self action:@selector(updateLocation:) forControlEvents:UIControlEventTouchUpInside];
    [_mapView addSubview:locUpdateBtn];
    
    afriend=[[UserFriends alloc] init];
    userFriendsInviteIdArr=[[NSMutableArray alloc] init];
    userDefault=[[UserDefault alloc] init];
    searchText=[[NSString alloc] init];

    fbHelper=[FacebookHelper sharedInstance];
    NSLog(@"frnd arrayk count %d ",[userFriendslistArray count]);
    if ([userFriendslistArray count]==0)
    {
        [inviteFriendView setHidden:YES];
    }
    else
    {
        [fbHelper inviteFriends:nil];
//        [inviteFriendView setHidden:NO];
    }
    //[self loadFriendListsData]; TODO: commented this
    
    imageDownloadsInProgress = [NSMutableDictionary dictionary];
    [imageDownloadsInProgress retain];
    
    _mapPulldown.hidden = TRUE;
    _mapPullupMenu.hidden = TRUE;
    
    selSharingType = All;
    [_shareAllButton setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
    [_shareFriendsButton setImage:[UIImage imageNamed:@"location_bar_radio.png"] forState:UIControlStateNormal];
    [_shareCircleButton setImage:[UIImage imageNamed:@"location_bar_radio.png"] forState:UIControlStateNormal];
    [_shareCustomButton setImage:[UIImage imageNamed:@"location_bar_radio.png"] forState:UIControlStateNormal];
    
    if (smAppDelegate.showPeople == TRUE)
        [_showPeopleButton setImage:[UIImage imageNamed:@"people_checked.png"] forState:UIControlStateNormal];
    else
        [_showPeopleButton setImage:[UIImage imageNamed:@"people_unchecked.png"] forState:UIControlStateNormal];
    
    if (smAppDelegate.showPlaces == TRUE)
        [_showPlacesButton setImage:[UIImage imageNamed:@"people_checked.png"] forState:UIControlStateNormal];
    else
        [_showPlacesButton setImage:[UIImage imageNamed:@"people_unchecked.png"] forState:UIControlStateNormal];
        
    if (smAppDelegate.showDeals == TRUE)
        [_showDealsButton setImage:[UIImage imageNamed:@"people_checked.png"] forState:UIControlStateNormal];
    else
        [_showDealsButton setImage:[UIImage imageNamed:@"people_unchecked.png"] forState:UIControlStateNormal];
    
    // Picker for choosing saved filter
    CGRect pickerFrame = CGRectMake(0, 120, 320, 216);
    pickSavedFilter = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickSavedFilter.delegate = self;
    pickSavedFilter.hidden = TRUE;
    pickSavedFilter.showsSelectionIndicator = TRUE;
    [self.view addSubview:pickSavedFilter];
    
    // Dummy saved filters
    savedFilters = [[NSMutableArray alloc] init];
    [savedFilters addObject:@"Show my family"];
    [savedFilters addObject:@"Show my friends"]; 
    [savedFilters addObject:@"Show my deals"];
    [savedFilters addObject:@"Show 2nd degree"];

    //[self displayNotificationCount];
    _mapPullupMenu.hidden = TRUE;
}
/*
- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder:decoder])
    {

    }
    return self;
}
*/

// Gesture recognizer for map drag event
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)didTapMap
{
    NSLog(@"Tap Map");

    if (selectedAnno) {
        
        LocationItem *selLocation = (LocationItem*)selectedAnno;
        [self mapAnnotationChanged:selLocation];
        [mapAnno changeStateToNormal:selLocation];
    }
    
    selectedAnno = nil;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO; // ignore the touch
    }
    return YES; // handle the touch
}
		
- (void)didDragMap:(UIGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        NSLog(@"Map drag ended");
        smAppDelegate.needToCenterMap = FALSE;
    }
}

-(void) displayNotificationCount {
   int totalNotif= [UtilityClass getNotificationCount];
    if (totalNotif == 0)
        _mapNotifCount.text = @"";
    else
        _mapNotifCount.text = [NSString stringWithFormat:@"%d",totalNotif];
}

-(NSMutableArray *)getUnreadMessage:(NSMutableArray *)messageList
{
    NSMutableArray *unReadMessage=[[NSMutableArray alloc] init];
    for (int i=0; i<[messageList count]; i++)
    {
        NSString *msgSts=((NotifMessage *)[messageList objectAtIndex:i]).msgStatus;
        if ([msgSts isEqualToString:@"unread"])
        {
            [unReadMessage addObject:[messageList objectAtIndex:i]];
        }
    }
    
    return unReadMessage;
}

-(void)viewDidDisappear:(BOOL)animated
{
    //userFriendslistArray=[[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_LISTINGS_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_INBOX_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_FRIEND_REQ_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_MEET_UP_REQUEST_DONE object:nil];
    userFriendslistArray=[[NSMutableArray alloc] init];

}

- (void)viewDidUnload
{
    NSLog(@"MapViewController:viewDidUnload" );
    [userDefault writeToUserDefaults:@"lastLatitude" withString:smAppDelegate.currPosition.latitude];
    [userDefault writeToUserDefaults:@"lastLongitude" withString:smAppDelegate.currPosition.longitude];
    [locationManager stopUpdatingLocation];
    _mapView = nil;
    [self setMapPulldown:nil];
    [self setShareAllButton:nil];
    [self setShareFriendsButton:nil];
    [self setShareNoneButton:nil];
    [self setShareCircleButton:nil];
    [self setShareCustomButton:nil];
    [self setShowPeopleButton:nil];
    [self setShowPlacesButton:nil];
    [self setShowDealsButton:nil];
    [self setMapNotifBubble:nil];
    [self setMapNotifCount:nil];
    [self setSelSavedFilter:nil];
    [self setSelectedFilter:nil];
    [self setMapPullupMenu:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)loadAnnotations:(BOOL)animated
{
    // 1
    CLLocationCoordinate2D zoomLocation;
    
    // Current location
    zoomLocation.latitude = [smAppDelegate.currPosition.latitude doubleValue];
    zoomLocation.longitude = [smAppDelegate.currPosition.longitude doubleValue];
    
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    // 3
    NSLog(@"MapViewController:loadAnnotations");
    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];  
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        [_mapView removeAnnotation:annotation];
    }
    for (int i=0; i < smAppDelegate.displayList.count; i++) {
        LocationItem *anno = (LocationItem*) [smAppDelegate.displayList objectAtIndex:i];
        [_mapView addAnnotation:anno];
    }

    // 4
    if (smAppDelegate.needToCenterMap == TRUE) {
        NSLog(@"MapViewController:loadAnnotations centering map");
        [_mapView setRegion:adjustedRegion animated:YES];
        [_mapView setCenterCoordinate:zoomLocation animated:YES];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    _mapView.showsUserLocation = YES;
    // 1
    CLLocationCoordinate2D zoomLocation;
    
    // Current location
    zoomLocation.latitude = [smAppDelegate.currPosition.latitude doubleValue];
    zoomLocation.longitude = [smAppDelegate.currPosition.longitude doubleValue];
    
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];  
    [_mapView setRegion:adjustedRegion animated:YES]; 
    
    if (smAppDelegate.gotListing == TRUE)
        [self loadAnnotations:animated];
    
    [super viewWillAppear:animated];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    // Calculate move from last position
    CLLocation *lastPos = [[CLLocation alloc] initWithLatitude:[smAppDelegate.currPosition.latitude doubleValue] longitude:[smAppDelegate.lastPosition.longitude doubleValue]];
    
    NSDate *now = [NSDate date];
    int elapsedTime = [now timeIntervalSinceDate:smAppDelegate.currPosition.positionTime];

    CLLocationDistance distanceMoved = [newLocation distanceFromLocation:lastPos];
    NSLog(@"MapViewController:didUpdateToLocation - old {%f,%f}, new {%f,%f}, distance moved=%f, elapsed time=%d",
          oldLocation.coordinate.latitude, oldLocation.coordinate.longitude,
          newLocation.coordinate.latitude, newLocation.coordinate.longitude,
          distanceMoved, elapsedTime);
    

    // Update location if new position detected and one of the following is true
    // 1. Moved 10 meters and 1 minute has elapsed.
    // 2. 5 mintes have elapsed. This is to get new people around and I am mostly stationary
    // 3. First time - smAppDelegate.gotListing == FALSE
    //
    if ((distanceMoved >= 10 && elapsedTime > 60) || elapsedTime > 300 || smAppDelegate.gotListing == FALSE) { // TODO : use distance
        // Update the position
        smAppDelegate.lastPosition = smAppDelegate.currPosition;
        smAppDelegate.currPosition.latitude = [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
        smAppDelegate.currPosition.longitude = [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];
        smAppDelegate.currPosition.positionTime = [NSDate date];
        
        [userDefault writeToUserDefaults:@"lastLatitude" withString:smAppDelegate.currPosition.latitude];
        [userDefault writeToUserDefaults:@"lastLongitude" withString:smAppDelegate.currPosition.longitude];
        
        // Send new location to server
        RestClient *restClient = [[[RestClient alloc] init] autorelease]; 
        [restClient getLocation:smAppDelegate.currPosition :@"Auth-Token" :smAppDelegate.authToken];

        [restClient updatePosition:smAppDelegate.currPosition authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
        smAppDelegate.gotListing = TRUE;
    }

}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (smAppDelegate.needToCenterMap == TRUE) {
        //smAppDelegate.needToCenterMap = FALSE;
        [mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    }
}

// Keep the selected annotation on top
- (void) mapView:(MKMapView *)aMapView didAddAnnotationViews:(NSArray *)views 
{
    for (MKAnnotationView *view in views) 
    {
        if ([view annotation] == selectedAnno ||
            [[view annotation] isKindOfClass:[MKUserLocation class]])
        {
            [[view superview] bringSubviewToFront:view];
        } 
        else 
        {
            [[view superview] sendSubviewToBack:view];
        }
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    [mapView bringSubviewToFront:view];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc 
{
    [imageDownloadsInProgress release];
//    [imageDownloadsInProgressCopy release];
    [_mapView release];
    [_mapView release];
    [_mapPulldown release];
    [_shareAllButton release];
    [_shareFriendsButton release];
    [_shareNoneButton release];
    [_shareCircleButton release];
    [_shareCustomButton release];
    [_showPeopleButton release];
    [_showPlacesButton release];
    [_showDealsButton release];
    [_mapNotifBubble release];
    [_mapNotifCount release];
    [_selSavedFilter release];
    [_selectedFilter release];
    [_mapPullupMenu release];
    [super dealloc];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    NSLog(@"In prepareForSegue:MapViewController");
    LocationItem *selLocation = (LocationItem*) selectedAnno;
    selLocation.currDisplayState = MapAnnotationStateNormal;
}

- (IBAction)showPullDown:(id)sender {
    _mapPulldown.hidden = FALSE;
}

- (IBAction)hidePulldown:(id)sender {
    pickSavedFilter.hidden = TRUE;
    _mapPulldown.hidden = TRUE;
}

// Select filter
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [savedFilters count];
}
- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [savedFilters objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSLog(@"Selected filter: %@. Index of selected color: %i", [savedFilters objectAtIndex:row], row);
    pickSavedFilter.hidden = TRUE;
    _selectedFilter.text = [savedFilters objectAtIndex:row];
}

//Table view delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return [filteredList count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	return NULL;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	
	static NSString *CellIdentifier = @"Cell";
    static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";
    
    // add a placeholder cell while waiting on table data
    int nodeCount = [filteredList count];
	
	if (nodeCount == 0 && indexPath.row == 0)
	{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlaceholderCellIdentifier];
        if (cell == nil)
		{
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
										   reuseIdentifier:PlaceholderCellIdentifier] autorelease];   
            cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        
		cell.detailTextLabel.text = @"Loading…";
		return cell;
    }
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									   reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
        NSLog(@"indexPath: %@",indexPath);
    }
    
    // Leave cells empty if there's no data yet
    if (nodeCount > 0)
	{
        // Set up the cell...
        UserFriends *userFriends = [filteredList objectAtIndex:indexPath.row];
        
		NSString *cellValue;		
        cellValue=userFriends.userName;
        cell.textLabel.textAlignment = UITextAlignmentLeft; 
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.text = cellValue;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:(12.0)]; 
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.opaque = NO;
        cell.textLabel.backgroundColor = [UIColor whiteColor];	
		
        // Only load cached images; defer new downloads until scrolling ends
        NSLog(@"nodeCount > 0");
        if ((!userFriends.userProfileImage)||([userFriends.userProfileImage isEqual:[UIImage imageNamed:@"girl.png"] ]))
        {
            NSLog(@"!userFriends.userProfileImage");
            if (self.inviteFrndTableView.dragging == NO && self.inviteFrndTableView.decelerating == NO)
            {
                [self startIconDownload:userFriends forIndexPath:indexPath];
                NSLog(@"Downloading for %@ index=%d", cellValue, indexPath.row);
            }            
            else if(searchFlag==true)
            {
                NSLog(@"search flag true start download");
                [self startIconDownload:userFriends forIndexPath:indexPath];
            }
            NSLog(@"userFriends %@   %@",userFriends.userProfileImage,userFriends.imageUrl);
            // if a download is deferred or in progress, return a placeholder image
            cell.imageView.image=[UIImage imageNamed:@"girl.png"];                
        }
        else
        {
            cell.imageView.image = userFriends.userProfileImage;
        }
    }

    return cell;
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserFriends *aFriend=[filteredList objectAtIndex:indexPath.row];
    
    [userFriendsInviteIdArr removeObject:aFriend.userId];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UserFriends *aFriend=[filteredList objectAtIndex:indexPath.row];
    
    if ([userFriendsInviteIdArr indexOfObject:aFriend.userId] == NSNotFound)
        [userFriendsInviteIdArr addObject:aFriend.userId];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath 
{	
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
}
//tableview delegate method ends


//Lazy loading method starts

#pragma mark -
#pragma mark Table cell image support

- (void)startIconDownload:(UserFriends *)userFriends forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:userFriends.userId];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.userFriends = userFriends;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:userFriends.userId];
        NSLog(@"imageDownloadsInProgress %@",imageDownloadsInProgress);
        [iconDownloader startDownload];
        NSLog(@"start downloads ... %@ %d",userFriends.userName, indexPath.row);
        [iconDownloader release];   
    }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([filteredList count] > 0)
    {
        NSArray *visiblePaths = [self.inviteFrndTableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            UserFriends *userFriends = [filteredList objectAtIndex:indexPath.row];
            
            if (!userFriends.userProfileImage) // avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:userFriends forIndexPath:indexPath];
            }
        }
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSString *)userId
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:userId];
    if (iconDownloader != nil)
    {
        //UserFriends *friend = [filteredList objectAtIndex:indexPath.row];
        //friend.userProfileImage = iconDownloader.userFriends.userProfileImage;
        NSNumber *indx = [userFriendslistIndex objectForKey:userId];
        UserFriends *user = [userFriendslistArray objectAtIndex:[indx intValue]];
        user.userProfileImage = iconDownloader.userFriends.userProfileImage;
        
        UITableViewCell *cell = [self.inviteFrndTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
        // Display the newly loaded image
        cell.imageView.image = iconDownloader.userFriends.userProfileImage;
        //[userProfileCopyImageArray replaceObjectAtIndex:indexPath.row withObject:iconDownloader.userFriends.userProfileImage];
        [self.inviteFrndTableView reloadData];
    }
}

#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

//Lazy loading method ends.

//search bar delegate method starts
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText 
{
    // We don't want to do anything until the user clicks 
    // the 'Search' button.
    // If you wanted to display results as the user types 
    // you would do that here.
    //[self loadFriendListsData]; TODO: commented this
    searchText=friendSearchBar.text;

    if ([searchText length]>0) 
    {
        [self performSelector:@selector(searchResult) withObject:nil afterDelay:0.1];
        searchFlag=true;
        [self.inviteFrndTableView reloadData];
        NSLog(@"searchText  %@",searchText);
    }
    else
    {
        searchText=@" ";
        //[self loadFriendListsData]; TODO: commented this
        [filteredList removeAllObjects];
        filteredList = [[NSMutableArray alloc] initWithArray: userFriendslistArray];
        [self.inviteFrndTableView reloadData];
    }
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    // searchBarTextDidBeginEditing is called whenever 
    // focus is given to the UISearchBar
    // call our activate method so that we can do some 
    // additional things when the UISearchBar shows.
    searchText=friendSearchBar.text;
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
    [self.inviteFrndTableView reloadData];
    [friendSearchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // Clear the search text
    // Deactivate the UISearchBar
    friendSearchBar.text=@"";
    searchText=@"";

    [filteredList removeAllObjects];
    filteredList = [[NSMutableArray alloc] initWithArray: userFriendslistArray];
    [self.inviteFrndTableView reloadData];
    [friendSearchBar resignFirstResponder];
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
    searchText=friendSearchBar.text;
    searchFlag=false;
    [self searchResult];
    [friendSearchBar resignFirstResponder];    
}

-(void)searchResult
{
    searchText = friendSearchBar.text;
    NSLog(@"in search method..");
    [filteredList removeAllObjects];

    if ([searchText isEqualToString:@""])
    {
        NSLog(@"null string");
        friendSearchBar.text=@" ";
        filteredList = [[NSMutableArray alloc] initWithArray: userFriendslistArray];
    }
    else
    for (UserFriends *sTemp in userFriendslistArray)
	{
		NSRange titleResultsRange = [sTemp.userName rangeOfString:searchText options:NSCaseInsensitiveSearch];		
		if (titleResultsRange.length > 0)
        {
			[filteredList addObject:sTemp];
            NSLog(@"filtered friend: %@", sTemp.userName);            
        }
        else
        {
        }
	}
    searchFlag=false;    

    NSLog(@"filteredList %@",filteredList);
    [self.inviteFrndTableView reloadData];
}

-(IBAction)inviteAllUsers:(id)sender
{        
    for (int i = 0; i < [inviteFrndTableView numberOfSections]; i++) 
    {
        for (int j = 0; j < [inviteFrndTableView numberOfRowsInSection:i]; j++) 
        {
            NSUInteger ints[2] = {i,j};
            NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
            [inviteFrndTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:0];
        }
    }
    NSArray *selectedRows = [self.inviteFrndTableView indexPathsForSelectedRows];
    NSLog(@"inviting all users %@",selectedRows);
    if([selectedRows count]>50)
    {
        [UtilityClass showAlert:@"Social Maps" :@"Can not request more then 50 friends"];
    }
    else
    {
        [self sendInvitationToSelectedUser:[selectedRows mutableCopy]];
    }
}

-(IBAction)inviteSelectedUsers:(id)sender
{
    NSArray *selectedRows = [self.inviteFrndTableView indexPathsForSelectedRows];
    if([selectedRows count]>50)
    {
        [UtilityClass showAlert:@"Social Map" :@"Can not request more then 50 friends"];
    }
    else if ([selectedRows count]>0)
    {
        [self sendInvitationToSelectedUser:[selectedRows mutableCopy]];
    }
    else 
    {
        [UtilityClass showAlert:@"Social Map" :@"Please select a friend to invite to Social Maps!"];
    }
}

-(void)sendInvitationToSelectedUser:(NSMutableArray *)selectedRows
{
    
    NSLog(@"inviting selected users %@",userFriendsInviteIdArr);
    [fbHelper inviteFriends:userFriendsInviteIdArr];
}

- (IBAction)gotoMyPlaces:(id)sender
{
//    [self performSegueWithIdentifier:@"createEvent" sender: self];   
//    RestClient *rc=[[RestClient alloc] init];    
//    [rc getEventDetailById:@"503b590ff69c29a105000000":@"Auth-Token":@"1dee739f6e1ad7f99964d40cab3a66ae27b9915b"];
}

- (IBAction)gotoDirections:(id)sender 
{
    //RestClient *rc=[[RestClient alloc] init];
    Platform *aPlatform=[[Platform alloc] init];
    aPlatform.facebook=@"1";
    aPlatform.fourSquare=@"1";
    aPlatform.gmail=@"1";
    aPlatform.googlePlus=@"1";
    aPlatform.twitter=@"1";
    aPlatform.yahoo=@"1";
    aPlatform.badoo=@"1";
    
    NotificationPref *aNotificationPref=[[NotificationPref alloc] init];
    aNotificationPref.friend_requests_sm=@"1";
    
    Layer *alayer=[[Layer alloc] init];
    alayer.wikipedia=@"1";
    UserInfo *userInfo=[[UserInfo alloc] init];
    Geofence *geo=[[Geofence alloc] init];
    geo.lat=@"23.2323";
    geo.lng=@"90.1212";
    geo.radius=@"2";
    userInfo.firstName=@"sample ";
//    [rc setPlatForm:aPlatform:@"Auth-Token":@"9068d1bdd04e1bdf66a24f97e7ddce46e71ca13b"];
//    [rc setLayer:alayer:@"Auth-Token":@"9068d1bdd04e1bdf66a24f97e7ddce46e71ca13b"];
//    [rc getAccountSettings:@"Auth-Token":@"394387e9dbb35924873567783a2e7c7226849c18"];
//    [rc setAccountSettings:userInfo:@"Auth-Token":@"394387e9dbb35924873567783a2e7c7226849c18" ];
//    NSLog(@"alayer.wikipedia method: %@",alayer.wikipedia);
//      [rc setNotifications:aNotificationPref:@"Auth-Token":@"181ba543f1820a8580c7c3fa0e0f3398acdf5d60"];
//    [rc setPlatForm:aPlatform:@"Auth-Token",@"9068d1bdd04e1bdf66a24f97e7ddce46e71ca13b"];
//    [rc setPlatForm:aPlatform:@"":@""];
//    [rc getPlatForm];
//    [rc getGeofence:@"Auth-Token":@"394387e9dbb35924873567783a2e7c7226849c18"];

//    [self performSelector:@selector(getAllEvents) withObject:nil afterDelay:0.0];    
   // viewEventList
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    ViewEventListViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"viewEventList"];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
    [smAppDelegate showActivityViewer:self.view];
}

-(void)getAllEvents
{
    RestClient *rc=[[RestClient alloc] init];
    [rc getAllEvents:@"Auth-Token":smAppDelegate.authToken];    
}

//- (void)getAllEventsDone:(NSNotification *)notif
//{
//    [smAppDelegate hideActivityViewer];
//    [smAppDelegate.window setUserInteractionEnabled:YES];
//    eventListGlobalArray=[notif object];
//    
//   
//    NSLog(@"GOT SERVICE DATA.. :D");
//}

- (IBAction)gotoBreadcrumbs:(id)sender
{
    NSLog(@"actionTestMessageBtn");
    
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    MessageListViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"messageList"];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
    [self presentModalViewController:nav animated:YES];
    nav.navigationBarHidden = YES;
    
}

- (IBAction)gotoCheckins:(id)sender
{
    UserBasicProfileViewController *prof=[[UserBasicProfileViewController alloc] init];
    prof.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:prof animated:YES];
}

- (IBAction)gotoMeetupReq:(id)sender
{
    MeetUpRequestController *controller = [[MeetUpRequestController alloc] initWithNibName:@"MeetUpRequestController" bundle:nil];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

- (IBAction)gotoMapix:(id)sender
{
//    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"CirclesStoryboard" bundle:nil];
//    ViewCircleListViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"viewCircleListViewController"];
//    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    [self presentModalViewController:controller animated:YES];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"CirclesStoryboard" bundle:nil];
    UIViewController* initialHelpView = [storyboard instantiateViewControllerWithIdentifier:@"viewCircleListViewController"];
    
    initialHelpView.modalPresentationStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:initialHelpView animated:YES];


}

- (IBAction)gotoEditFilters:(id)sender
{
}

- (IBAction)applyFilter:(id)sender
{
    pickSavedFilter.hidden = FALSE;
}

- (IBAction)peopleClicked:(id)sender
{
    if (smAppDelegate.showPeople == true)
    {
        smAppDelegate.showPeople = false;
        [_showPeopleButton setImage:[UIImage imageNamed:@"people_unchecked.png"] forState:UIControlStateNormal];
    }
    else
    {
        smAppDelegate.showPeople = true;
        [_showPeopleButton setImage:[UIImage imageNamed:@"people_checked.png"] forState:UIControlStateNormal];
    }
    [self getSortedDisplayList];
    [self loadAnnotations:YES];
    [self.view setNeedsDisplay];
}

- (IBAction)placesClicked:(id)sender
{
    if (smAppDelegate.showPlaces == true)
    {
        smAppDelegate.showPlaces = false;
        [_showPlacesButton setImage:[UIImage imageNamed:@"people_unchecked.png"] forState:UIControlStateNormal];
    }
    else
    {
        smAppDelegate.showPlaces = true;
        [_showPlacesButton setImage:[UIImage imageNamed:@"people_checked.png"] forState:UIControlStateNormal];
    }
    [self getSortedDisplayList];
    [self loadAnnotations:YES];
    [self.view setNeedsDisplay];
}

- (IBAction)dealsClicked:(id)sender {
    if (smAppDelegate.showDeals == true) {
        smAppDelegate.showDeals = false;
        [_showDealsButton setImage:[UIImage imageNamed:@"people_unchecked.png"] forState:UIControlStateNormal];
    } else {
        smAppDelegate.showDeals = true;
        [_showDealsButton setImage:[UIImage imageNamed:@"people_checked.png"] forState:UIControlStateNormal];
    }
    [self getSortedDisplayList];
    [self loadAnnotations:YES];
    [self.view setNeedsDisplay];
}

-(IBAction)closeInviteFrnds:(id)sender
{
    // terminate all pending download connections
    NSArray *allDownloads = [imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    [inviteFriendView removeFromSuperview];
    [userFriendslistArray removeAllObjects];
}

- (void) resetShareButton:(SHARING_TYPES)newSel {
    switch (selSharingType) {
        case All: 
            [_shareAllButton setImage:[UIImage imageNamed:@"location_bar_radio.png"] forState:UIControlStateNormal];
            break;
        case Friends: 
            [_shareFriendsButton setImage:[UIImage imageNamed:@"location_bar_radio.png"] forState:UIControlStateNormal];
            break;
        case None: 
            break;
        case Circles: 
            [_shareCircleButton setImage:[UIImage imageNamed:@"location_bar_radio.png"] forState:UIControlStateNormal];
            break;
        case Custom: 
            [_shareCustomButton setImage:[UIImage imageNamed:@"location_bar_radio.png"] forState:UIControlStateNormal];
            break;
    };
    
    switch (newSel) {
        case All: 
            [_shareAllButton setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
            break;
        case Friends: 
            [_shareFriendsButton setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
            break;
        case None: 
            break;
        case Circles: 
            [_shareCircleButton setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
            break;
        case Custom: 
            [_shareCustomButton setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateNormal];
            break;
    };

}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	// When the user presses return, take focus away from the text field so that the keyboard is dismissed.
    [self.view endEditing:YES];
    
	return YES;
}

- (IBAction)shareWithAll:(id)sender {
    [self resetShareButton:All];
    selSharingType = All;
}

- (IBAction)shareWithFriends:(id)sender {
    [self resetShareButton:Friends];
    selSharingType = Friends;
}

- (IBAction)shareWithNone:(id)sender {
    [self resetShareButton:None];
    selSharingType = None;
}

- (IBAction)shareWithCircles:(id)sender {
    [self resetShareButton:Circles];
    selSharingType = Circles;
}

- (IBAction)shareWithCustom:(id)sender {
    [self resetShareButton:Custom];
    selSharingType = Custom;
}

- (IBAction)showPullupMenu:(id)sender {
    _mapPullupMenu.hidden = FALSE;
}

- (IBAction)closePullupMenu:(id)sender {
    _mapPullupMenu.hidden = TRUE;
}

- (void) updateLocation:(id) sender {
    NSLog(@"MapViewController: updateLocation");
    if ([CLLocationManager locationServicesEnabled]) {
        [locationManager stopUpdatingLocation];
        [locationManager startUpdatingLocation];
        _mapView.centerCoordinate = self.mapView.userLocation.location.coordinate;
        // Send new location to server
        RestClient *restClient = [[[RestClient alloc] init] autorelease];
        [restClient updatePosition:smAppDelegate.currPosition authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
    } else {
        CLLocationCoordinate2D lastPos = CLLocationCoordinate2DMake([smAppDelegate.currPosition.latitude doubleValue], [smAppDelegate.lastPosition.longitude doubleValue]);
        _mapView.centerCoordinate = lastPos;
    }
    _mapView.showsUserLocation=YES;
    smAppDelegate.needToCenterMap = TRUE;
    [_mapView setNeedsDisplay];
//test code
    //LocationItem *locItem = (LocationItem*)[smAppDelegate.displayList objectAtIndex:5];
    //[self showAnnotationDetailView:locItem];
    
    
}

- (void) getSortedDisplayList {
    [smAppDelegate.displayList removeAllObjects];
    NSMutableArray *tempList = [[NSMutableArray alloc] init];
    if (smAppDelegate.showPeople == TRUE) 
        [tempList addObjectsFromArray:smAppDelegate.peopleList];
    if (smAppDelegate.showPlaces == TRUE) 
        [tempList addObjectsFromArray:smAppDelegate.placeList];
    if (smAppDelegate.showDeals == TRUE) 
        [tempList addObjectsFromArray:smAppDelegate.dealList];
    
    // Sort by distance
    NSArray *sortedArray = [tempList sortedArrayUsingSelector:@selector(compareDistance:)];
    [smAppDelegate.displayList addObjectsFromArray:sortedArray];
}

- (CLLocationDistance) getDistanceFromMe:(CLLocationCoordinate2D) loc {
    Geolocation *myPos = smAppDelegate.currPosition;
    CLLocation *myLoc = [[CLLocation alloc] initWithLatitude:[myPos.latitude floatValue] longitude:[myPos.longitude floatValue]];
    CLLocation *userLoc = [[CLLocation alloc] initWithCoordinate:loc altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:nil];
    CLLocationDistance distanceFromMe = [myLoc distanceFromLocation:userLoc];
    
    return distanceFromMe;
}
- (void)gotListings:(NSNotification *)notif
{
    NSLog(@"In gotListings");
    //[smAppDelegate.peopleList removeAllObjects];

    SearchLocation * listings = [notif object];
    if (listings != nil) {
        if (listings.peopleArr != nil) {
            NSMutableDictionary *newItems = [[NSMutableDictionary alloc] init];
            for (People *item in listings.peopleArr) {
                [newItems setValue:item.userId forKey:item.userId];
            }
            // Build items to discard
            NSMutableArray *discardedItems = [[NSMutableArray alloc] init];
            for (NSString *itemID in smAppDelegate.peopleIndex) {
                if ([newItems objectForKey:itemID] == nil) {
                    // Item does not exist so remove it
                    int indx = [[smAppDelegate.peopleIndex objectForKey:itemID] intValue];
                    [discardedItems addObject:[NSNumber numberWithInt: indx]];
                }
            }
            if (discardedItems.count > 0) {
                // Sort the discarded items in descending order
                NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: NO];
                NSArray *sortedIndices = [discardedItems sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortOrder]];
                
                // Remove the discarded items
                for (int i=0; i < sortedIndices.count; i++) {
                    int indx = [[sortedIndices objectAtIndex:i] intValue];
                    [smAppDelegate.peopleList removeObjectAtIndex:indx];
                }
                // Now rebuild the index
                [smAppDelegate.peopleIndex removeAllObjects];
                for (LocationItemPeople *aPerson in smAppDelegate.peopleList) {
                    [smAppDelegate.peopleIndex setValue:[NSNumber numberWithInt:smAppDelegate.peopleIndex.count] forKey:aPerson.userInfo.userId];
                }
            }
            [newItems release];
            [discardedItems release];
            
            for (People *item in listings.peopleArr) {
                // Ignore logged in user
                
                if (![smAppDelegate.userId isEqualToString:item.userId]) {
                    // Do we already have this in the list?
                    __block NSNumber *indx;
                    
                    if ((indx=[smAppDelegate.peopleIndex objectForKey:item.userId]) == nil) {
                        UIImage *icon;
                        NSString *iconPath;
                        if ([item.avatar length] == 0) {
                            if ([item.gender caseInsensitiveCompare:@"male"] == NSOrderedSame)
                                iconPath = [[NSBundle mainBundle] pathForResource:@"Photo-1" ofType:@"png"];
                            else if ([item.gender caseInsensitiveCompare:@"male"] == NSOrderedSame)
                                iconPath = [[NSBundle mainBundle] pathForResource:@"Photo-2" ofType:@"png"];
                            else
                                iconPath = [[NSBundle mainBundle] pathForResource:@"thum" ofType:@"png"];
                        } else {
                            iconPath = [[NSBundle mainBundle] pathForResource:@"thum" ofType:@"png"];
                        }
                        icon = [[UIImage alloc] initWithContentsOfFile:iconPath];
                        NSString *bgPath = [[NSBundle mainBundle] pathForResource:@"listview_bg" ofType:@"png"];
                        UIImage *bg = [[UIImage alloc] initWithContentsOfFile:bgPath];
                        
                        CLLocationCoordinate2D loc;
                        loc.latitude = [item.currentLocationLat doubleValue];
                        loc.longitude = [item.currentLocationLng doubleValue];
                        NSLog(@"Name=%@ %@ Location=%f,%f",item.firstName, item.lastName, loc.latitude,loc.longitude);

                        CLLocationDistance distanceFromMe = [self getDistanceFromMe:loc];
//                        NSString *address = [UtilityClass getAddressFromLatLon:loc.latitude withLongitude:loc.longitude];
                        //NSString *address = @"Address";
                        
                        LocationItemPeople *aPerson = [[LocationItemPeople alloc] initWithName:[NSString stringWithFormat:@"%@ %@", item.firstName, item.lastName] address:item.lastSeenAt type:ObjectTypePeople category:item.gender coordinate:loc dist:distanceFromMe icon:icon bg:bg];
                        item.distance = [NSString stringWithFormat:@"%.0f", distanceFromMe];
                        aPerson.userInfo = item;
                        [smAppDelegate.peopleIndex setValue:[NSNumber numberWithInt:smAppDelegate.peopleList.count] forKey:item.userId];
                        [smAppDelegate.peopleList addObject:aPerson];
                        
                        if ([item.avatar length] > 0) {// Need to retrieve avatar image
                            icon = [UIImage imageNamed:@"thum.png"];
                            __block int itemIndex = smAppDelegate.peopleList.count-1;
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                                NSData* imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:item.avatar]];
                                UIImage* image = [[UIImage alloc] initWithData:imageData];
                                [imageData release];
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    LocationItemPeople *person = [smAppDelegate.peopleList objectAtIndex:itemIndex];
                                    person.itemIcon = image;
                                    //
                                    //[image release];
                                    if (smAppDelegate.showPeople == TRUE)
                                        [self mapAnnotationChanged:person];
                                });
                            });
                        }

                        [aPerson release];
                    } else {
                        // Item exists, update location only
                        LocationItemPeople *aPerson = [smAppDelegate.peopleList objectAtIndex:[indx intValue]];
                        
                        CLLocationCoordinate2D loc;
                        loc.latitude = [item.currentLocationLat doubleValue];
                        loc.longitude = [item.currentLocationLng doubleValue];
                        aPerson.coordinate = loc;
                        
                        CLLocationDistance distanceFromMe = [self getDistanceFromMe:loc];
                        aPerson.itemDistance = distanceFromMe;
                        if (smAppDelegate.showPeople == TRUE)
                            [self mapAnnotationChanged:aPerson];
                    }
                }
            }
        }  
        if (listings.placeArr != nil) {
            NSMutableDictionary *newItems = [[NSMutableDictionary alloc] init];
            for (Places *item in listings.placeArr) {
                [newItems setValue:item.ID forKey:item.ID];
            }
            // Build items to discard
            NSMutableArray *discardedItems = [[NSMutableArray alloc] init];
            for (NSString *itemID in smAppDelegate.placeIndex) {
                if ([newItems objectForKey:itemID] == nil) {
                    // Item does not exist so remove it
                    int indx = [[smAppDelegate.placeIndex objectForKey:itemID] intValue];
                    [discardedItems addObject:[NSNumber numberWithInt: indx]];
                }
            }
            if (discardedItems.count > 0) {
                // Sort the discarded items in descending order
                NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: NO];
                NSArray *sortedIndices = [discardedItems sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortOrder]];

                // Remove the discarded items
                for (int i=0; i < sortedIndices.count; i++) {
                    int indx = [[sortedIndices objectAtIndex:i] intValue];
                    [smAppDelegate.placeList removeObjectAtIndex:indx];
                }
                // Now rebuild the index
                [smAppDelegate.placeIndex removeAllObjects];
                for (LocationItemPlace *aPlace in smAppDelegate.placeList) {
                    [smAppDelegate.placeIndex setValue:[NSNumber numberWithInt:smAppDelegate.placeIndex.count] forKey:aPlace.placeInfo.ID];
                }
            }
            [newItems release];
            [discardedItems release];

            for (Places *item in listings.placeArr) {
                __block NSNumber *indx;
                if ((indx=[smAppDelegate.placeIndex objectForKey:item.ID]) == nil) {
                    NSString* iconPath = [[NSBundle mainBundle] pathForResource:@"thum" ofType:@"png"];
                    UIImage *icon = [[UIImage alloc] initWithContentsOfFile:iconPath];
                    NSString* bgPath = [[NSBundle mainBundle] pathForResource:@"banner_bar" ofType:@"png"];
                    UIImage *bg = [[UIImage alloc] initWithContentsOfFile:bgPath];

                    CLLocationCoordinate2D loc;
                    loc.latitude = [item.location.latitude doubleValue];
                    loc.longitude = [item.location.longitude doubleValue];
                    CLLocationDistance distanceFromMe = [self getDistanceFromMe:loc];
                    NSLog(@"Name=%@ Location=%f,%f, distance=%f",item.name, loc.latitude,loc.longitude, distanceFromMe);
                    
                   
                    LocationItemPlace *aPlace = [[LocationItemPlace alloc] initWithName:item.name address:item.vicinity type:ObjectTypePlace category:@"Bar" coordinate:loc dist:distanceFromMe icon:icon bg:bg];
                    
                    aPlace.placeInfo = item;
                    [smAppDelegate.placeIndex setValue:[NSNumber numberWithInt:smAppDelegate.placeList.count] forKey:item.ID];
                    [smAppDelegate.placeList addObject:aPlace];
                    
                    if ([item.icon length] > 0) {
                        // Need to retrieve avatar image
                        icon = [UIImage imageNamed:@"thum.png"];
                        int itemIndex = smAppDelegate.placeIndex.count-1;
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                            NSData* imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:item.icon]];
                            UIImage* image = [[UIImage alloc] initWithData:imageData];
                            [imageData release];

                            dispatch_async(dispatch_get_main_queue(), ^{
                                LocationItemPlace *place = [smAppDelegate.placeList objectAtIndex:itemIndex];
                                place.itemIcon = image;
                                if (smAppDelegate.showPlaces == TRUE)
                                    [self mapAnnotationChanged:place];
                            });
                        });
                    } 
                    [aPlace release];
                } else {
                    // Item exists, recalculate distance only
                    LocationItemPlace *aPlace = [smAppDelegate.placeList objectAtIndex:[indx intValue]];
                    
                    CLLocationCoordinate2D loc;
                    loc.latitude = [item.location.latitude doubleValue];
                    loc.longitude = [item.location.longitude doubleValue];
                    aPlace.coordinate = loc;
                    
                    CLLocationDistance distanceFromMe = [self getDistanceFromMe:loc];
                    aPlace.itemDistance = distanceFromMe;
                    NSLog(@"Distance: service=%@, calculated=%f", item.distance, distanceFromMe);
                }
            }

        }
    }

    [self getSortedDisplayList];
    [self loadAnnotations:YES];
    [self.view setNeedsDisplay];
}

// GCD async notifications
- (void)gotNotifMessages:(NSNotification *)notif {
    NSMutableArray *msg = [notif object];
    [smAppDelegate.messages removeAllObjects];
    [smAppDelegate.messages addObjectsFromArray:msg];
    NSLog(@"AppDelegate: gotNotifications - %@", smAppDelegate.messages);
    [self displayNotificationCount];
}
- (void)gotFriendRequests:(NSNotification *)notif {
    NSMutableArray *notifs = [notif object];
    [smAppDelegate.friendRequests removeAllObjects];
    [smAppDelegate.friendRequests addObjectsFromArray:notifs];
    NSLog(@"AppDelegate: gotNotifications - %@", smAppDelegate.friendRequests);
    [self displayNotificationCount];
}
- (void)gotMeetUpRequests:(NSNotification *)notif {
    NSMutableArray *notifs = [notif object];
    [smAppDelegate.meetUpRequests removeAllObjects];
    [smAppDelegate.meetUpRequests addObjectsFromArray:notifs];
    NSLog(@"AppDelegate: gotMeetUpNotifications - %@", smAppDelegate.meetUpRequests);
    [self displayNotificationCount];
}
@end

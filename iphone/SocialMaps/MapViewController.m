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
#import "MapAnnotationEvent.h"
#import "ViewEventDetailViewController.h"
#import "CustomAlert.h"
#import "FriendsProfileViewController.h"
#import "CreateEventViewController.h"
#import "DirectionViewController.h"
#import "PlaceViewController.h"
#import "PlaceListViewController.h"
#import "Place.h"
#import "DDAnnotation.h"
#import "NewsFeedViewController.h"
#import "RecommendViewController.h"
#import "FriendListViewController.h"
#import "CreatePlanViewController.h"
#import "ListViewController.h"

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
@synthesize circleView;
@synthesize mapAnnoEvent,connectToFBView;

UserFriends *afriend;
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

- (void)didTapCurrentLocaiton
{
    NSLog(@"didTapCurrentLocaiton");
    [self gotoBasicProfile:nil];
}

- (void)doNothing:(id)sender
{
    NSLog(@"doNothing");
}

- (MKAnnotationView *)mapView:(MKMapView *)newMapView viewForAnnotation:(id <MKAnnotation>)newAnnotation {
    
    LocationItem * locItem = (LocationItem*) newAnnotation;
    
    MKAnnotationView *pin = nil;
    
    if ([locItem isKindOfClass:[LocationItemPeople class]]) {
        pin = [mapAnnoPeople mapView:_mapView viewForAnnotation:newAnnotation item:locItem];
        pin.centerOffset = CGPointMake(pin.centerOffset.x, -pin.frame.size.height / 2);
    } else if ([locItem isKindOfClass:[LocationItemPlace class]]) {
        pin = [mapAnnoPlace mapView:_mapView viewForAnnotation:newAnnotation item:locItem];
        pin.centerOffset = CGPointMake(pin.centerOffset.x, -pin.frame.size.height / 2);
    }
    else if ([locItem isKindOfClass:[LocationItem class]])
    {
        pin = [mapAnnoEvent mapView:_mapView viewForAnnotation:newAnnotation item:locItem];
        pin.centerOffset = CGPointMake(pin.centerOffset.x, -pin.frame.size.height / 2);
    }
    else {
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
    if ((smAppDelegate.fbId) && (![smAppDelegate.fbId isEqualToString:@""]))
    {
    NSString *profileImageUrl=[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",smAppDelegate.fbId];
    UIImage *profileImage=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profileImageUrl]]];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:@"FBProfilePic"];
    NSLog(@"profileImageUrl is %@  %@", profileImageUrl, profileImage );
    [prefs setObject:[NSKeyedArchiver archivedDataWithRootObject:profileImage] forKey:@"FBProfilePic"];
    [prefs synchronize];
    }
}

-(void)showConnectFBAlert
{
    [CustomAlert setBackgroundColor:[UIColor grayColor] 
                    withStrokeColor:[UIColor grayColor]];
    CustomAlert *fbConnect = [[CustomAlert alloc]
                               initWithTitle:@"Connect With Facebook"
                               message:@"This is your first login to Socialmaps app, to get a better experience, we recommand you to invite Facebook friends"
                               delegate:nil
                               cancelButtonTitle:@"Done"
                               otherButtonTitles:nil];
    
    [fbConnect show];
    [fbConnect autorelease];
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

- (void) mapAnnotationInfoUpdated:(id <MKAnnotation>) anno {
    NSLog(@"MapViewController:mapAnnotationInfoUpdated");
    if (_mapView && anno) {
        //Crashing fix Rishi
        if (CLLocationCoordinate2DIsValid(anno.coordinate))
        {
            [_mapView removeAnnotation:anno];
            [_mapView addAnnotation:anno];  
        }
    }
    
    [self.view setNeedsDisplay];
}

- (IBAction)actionSearchButton:(id)sender {
    [self searchAnnotations];
}

- (IBAction)actionShowHideSearchBtn:(id)sender {
    if (viewSearch.frame.origin.y > 44) {
        [self moveSearchBarAnimation:-44];
        searchBar.text = @"";
        [self searchAnnotations];
        pullDownView.openedCenter = CGPointMake(160, 120 + 69 - 35);
        pullDownView.closedCenter = CGPointMake(160, -5 - 69 + 34);
    } else {
        [self moveSearchBarAnimation:44];
        [searchBar becomeFirstResponder];
        pullDownView.openedCenter = CGPointMake(160, 120 + 69 - 35 + 44);
        pullDownView.closedCenter = CGPointMake(160, -5 + 44 - 69 + 34);
    }
}

-(void)moveSearchBarAnimation:(int)moveby
{
    CGRect pullDownViewFrame = pullDownView.frame;
    pullDownViewFrame.origin.y += moveby;
    CGRect searchBarFrame = viewSearch.frame;
    searchBarFrame.origin.y += moveby;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];    
    [viewSearch setFrame:searchBarFrame];    
    [pullDownView setFrame:pullDownViewFrame];  
    [UIView commitAnimations];    
}

- (void) searchAnnotations
{
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        [_mapView removeAnnotation:annotation];
    }
    
    if([searchBar.text length] > 0) {
        [copySearchAnnotationList removeAllObjects];
        NSString *searchText = searchBar.text;
        
        for (LocationItem *sTemp in smAppDelegate.displayList) {
            LocationItem *info = (LocationItem*)sTemp;
            NSRange titleResultsRange = [info.itemName rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            if (titleResultsRange.length > 0)
                [copySearchAnnotationList addObject:sTemp];
        }
        
        if (copySearchAnnotationList.count == 0) {
            [UtilityClass showAlert:@"" :@"No search result found"];
        } else {
            for (int i=0; i < copySearchAnnotationList.count; i++) {
                LocationItem *anno = (LocationItem*) [copySearchAnnotationList objectAtIndex:i];
                [_mapView addAnnotation:anno];
                
                if (i == 0) {
                    [self didTapMap];
                    [self showAnnotationDetailView:anno];
                    
                }
            }
        }
        
    } else {
        for (int i=0; i < smAppDelegate.displayList.count; i++) {
            LocationItem *anno = (LocationItem*) [smAppDelegate.displayList objectAtIndex:i];
            [_mapView addAnnotation:anno];
        }
    }
    
    [searchBar resignFirstResponder];
}

- (void) showAnnotationDetailView:(id <MKAnnotation>) anno {

    selectedAnno = anno;
    LocationItem *selLocation = (LocationItem*) anno;
    [self mapAnnotationChanged:selLocation];
    [mapAnno changeStateToSummary:selLocation];
    [self performSelector:@selector(startMoveMap:) withObject:selLocation afterDelay:.8];
}

-(void) startMoveMap:(LocationItem*)locItem
{
    MKMapRect r = [self.mapView visibleMapRect];
    MKMapPoint pt = MKMapPointForCoordinate(locItem.coordinate);
    r.origin.x = pt.x - r.size.width * 0.3;
    r.origin.y = pt.y - r.size.height * 0.6;
    if ([locItem isKindOfClass:[LocationItemPeople class]] && locItem.currDisplayState == MapAnnotationStateDetailed) {
        r.origin.y = pt.y - r.size.height * .7; 
    }
    
    [self.mapView setVisibleMapRect:r animated:YES];
}

-(void) startMoveAndAddPin:(Place*)place
{
    CLLocationCoordinate2D theCoordinate;
	theCoordinate.latitude = place.latitude;
    theCoordinate.longitude = place.longitude;
    
    DDAnnotation *annotation = [[[DDAnnotation alloc] initWithCoordinate:theCoordinate addressDictionary:nil] autorelease];
    annotation.title = [NSString stringWithFormat:@"%@", place.name];
    [_mapView addAnnotation:annotation];
    [_mapView selectAnnotation:annotation animated:NO];
    
    MKMapRect r = [self.mapView visibleMapRect];
    MKMapPoint pt = MKMapPointForCoordinate(theCoordinate);
    r.origin.x = pt.x - r.size.width / 2;
    r.origin.y = pt.y - r.size.height  / 2;
    [self.mapView setVisibleMapRect:r animated:YES];
    
    [self performSelector:@selector(removeAnnotation:) withObject:annotation afterDelay:5];
}

-(void) startMoveAndAddPinForPlan:(Plan*)plan
{
    CLLocationCoordinate2D theCoordinate;
	theCoordinate.latitude = [plan.planGeolocation.latitude doubleValue];
    theCoordinate.longitude = [plan.planGeolocation.longitude doubleValue];
    NSLog(@"plan %@ %@",plan.planGeolocation.latitude,plan.planGeolocation.longitude);
    DDAnnotation *annotation = [[[DDAnnotation alloc] initWithCoordinate:theCoordinate addressDictionary:nil] autorelease];
    annotation.title = [NSString stringWithFormat:@"%@", plan.planDescription];
    [_mapView addAnnotation:annotation];
    [_mapView selectAnnotation:annotation animated:NO];
    
    MKMapRect r = [self.mapView visibleMapRect];
    MKMapPoint pt = MKMapPointForCoordinate(theCoordinate);
    r.origin.x = pt.x - r.size.width / 2;
    r.origin.y = pt.y - r.size.height  / 2;
    [self.mapView setVisibleMapRect:r animated:YES];
    
    [self performSelector:@selector(removeAnnotation:) withObject:annotation afterDelay:5];
}

- (void) removeAnnotation:(DDAnnotation*)annotation
{
    [_mapView removeAnnotation:annotation];
}

- (void) showPinOnMapView:(Place*)place 
{
    [circleView removeFromSuperview];
    [self performSelector:@selector(startMoveAndAddPin:) withObject:place afterDelay:.8];
}

- (void) showPinOnMapViewForPlan:(Plan*)plan 
{
    NSLog(@"mapview");
    [circleView removeFromSuperview];
    [self performSelector:@selector(startMoveAndAddPinForPlan:) withObject:plan afterDelay:1.8];
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
    
    if (((LocationItem*)anno).currDisplayState != MapAnnotationStateNormal) {
        [self startMoveMap:(LocationItem*)anno];
    }
    
    [self mapAnnotationInfoUpdated:anno];
    selectedAnno = anno;
    
    [self performSelector:@selector(bringAnnotationOnTopAfterDelay:) withObject:anno afterDelay:.5];
}

- (void)bringAnnotationOnTopAfterDelay:(id <MKAnnotation>) anno
{
    MKAnnotationView* annotationView = [_mapView viewForAnnotation:anno];
    if (annotationView != nil) {
        [annotationView.superview bringSubviewToFront:annotationView];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self performSelector:@selector(bringAnnotationOnTopAfterDelay:) withObject:(id <MKAnnotation>)selectedAnno afterDelay:.5];
}

- (void) viewEventDetail:(id <MKAnnotation>)anno {
    NSLog(@"event detail action");
     LocationItem *locationItem = (LocationItem*) anno;
     Event *aEvent=[[Event alloc] init];
     int i= [smAppDelegate.eventList indexOfObject:locationItem];
    for (int j=0; j<[smAppDelegate.eventList count]; j++)
    {
        LocationItem *locItem = (LocationItem *)[smAppDelegate.eventList objectAtIndex:j];
        if (([locationItem.itemAddress isEqualToString:locItem.itemAddress]) && ([locationItem.itemName isEqualToString:locItem.itemName]))
        {
            i=j;
        }
    }
    NSLog(@"view event detail %d",i);
    if ([eventListGlobalArray count]>i)
    {
        aEvent = [eventListGlobalArray objectAtIndex:i];
    }
     NSLog(@"match found %d, %@",i,aEvent.eventID);
     globalEvent=aEvent;
     UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
     ViewEventDetailViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"eventDetail"];
     controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
     [self presentModalViewController:controller animated:YES];
}

- (void) viewPeopleProfile:(id <MKAnnotation>)anno {
    LocationItemPeople *locItem = (LocationItemPeople*) anno;
    FriendsProfileViewController *controller =[[FriendsProfileViewController alloc] init];
    controller.friendsId=locItem.userInfo.userId;
    NSLog(@"profile id = %@", controller.friendsId);
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
}

- (void) createEventWithAddress:(id <MKAnnotation>)anno {
    LocationItemPlace *locItem = (LocationItemPlace*) anno;
    isFromVenue=TRUE;
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    CreateEventViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"createEvent"];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    controller.venueAddress=locItem.itemAddress;
    Geolocation *geo=[[Geolocation alloc] init];
    geo.latitude=[NSString stringWithFormat:@"%lf",locItem.coordinate.latitude];
    geo.longitude=[NSString stringWithFormat:@"%lf",locItem.coordinate.longitude];
    controller.geolocation=geo;
    [self presentModalViewController:controller animated:YES];

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

- (void) directionSelected:(id <MKAnnotation>)anno 
{
    NSLog(@"MapViewController:directionSelected");
    LocationItem *locItem = (LocationItem*) anno;
    
    DirectionViewController *controller = [[DirectionViewController alloc] initWithNibName:@"DirectionViewController" bundle:nil];
    
    if (!anno) {
        CLLocationCoordinate2D theCoordinate;
        theCoordinate.latitude = [smAppDelegate.currPosition.latitude doubleValue];
        theCoordinate.longitude = [smAppDelegate.currPosition.longitude doubleValue];
        controller.coordinateTo = theCoordinate;
    } else {
        controller.coordinateTo = locItem.coordinate;
    }
    
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

- (void) messageSelected:(id <MKAnnotation>)anno {
    NSLog(@"MapViewController:messageSelected");
    LocationItemPeople *locItem = (LocationItemPeople*) anno;
    
    NotifMessage *notifMessage = [[NotifMessage alloc] init];
    notifMessage.notifID = @"NewMsg";
    notifMessage.notifSenderId = locItem.userInfo.userId;
    NSLog(@"receipient id = %@", notifMessage.notifSenderId);
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    MessageListViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"messageList"];
    controller.selectedMessage = notifMessage;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
    [self presentModalViewController:nav animated:YES];
    nav.navigationBarHidden = YES;
    [notifMessage release];
    
}

- (void)planselected:(id <MKAnnotation>)anno
{
    globalPlan=[[Plan alloc] init];
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"PlanStoryboard" bundle:nil];
    CreatePlanViewController* initialHelpView = [storyboard instantiateViewControllerWithIdentifier:@"createPlanViewController"];
    isPlanFromVenue=TRUE;    
    LocationItemPlace *locItemPlace = (LocationItemPlace*)anno;
    globalPlan.planAddress=[NSString stringWithFormat:@"%@, %@",locItemPlace.placeInfo.name, locItemPlace.placeInfo.vicinity];
    globalPlan.planGeolocation.latitude=locItemPlace.placeInfo.location.latitude;
    globalPlan.planGeolocation.longitude=locItemPlace.placeInfo.location.longitude;
    initialHelpView.plan=globalPlan;
    NSLog(@"plan %@",initialHelpView.plan);
    initialHelpView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:initialHelpView animated:YES];
}

- (void)recommendSelected:(id <MKAnnotation>)anno
{  
    RecommendViewController *controller = [[RecommendViewController alloc] initWithNibName:@"RecommendViewController" bundle:nil];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    LocationItemPlace *locItemPlace = (LocationItemPlace*)anno;
    Place *place = [[Place alloc] init];
    place.placeID = locItemPlace.placeInfo.ID;
    place.name = locItemPlace.itemName;
    place.address = locItemPlace.itemAddress;
    place.latitude = locItemPlace.coordinate.latitude;
    place.longitude = locItemPlace.coordinate.longitude;
    place.category = locItemPlace.itemCategory;
    [self presentModalViewController:controller animated:YES];
    [controller setSelectedPlace:place];
    [place release];
    [controller release];
    
}
- (void)reviewSelected:(id <MKAnnotation>)anno
{
    [UtilityClass showAlert:@"Social Maps" :@"This feature is coming soon."];    
}
- (void)saveSelected:(id <MKAnnotation>)anno
{
    PlaceViewController *controller = [[PlaceViewController alloc] initWithNibName:@"PlaceViewController" bundle:nil];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];

    LocationItemPlace *locItemPlace = (LocationItemPlace*)anno;
    
    Place *place = [[Place alloc] init];
    place.name = locItemPlace.itemName;
    place.address = locItemPlace.itemAddress;
    place.latitude = locItemPlace.coordinate.latitude;
    place.longitude = locItemPlace.coordinate.longitude;
    place.category = locItemPlace.itemCategory;
    NSLog(@"category = %@ vicinity = %@", locItemPlace.itemCategory, locItemPlace.placeInfo.vicinity);
    [controller setAddressLabelFromLatLon:place];
    [place release];
    [controller release];
}
- (void)checkinSelected:(id <MKAnnotation>)anno
{
    [UtilityClass showAlert:@"Social Maps" :@"This feature is coming soon."];    
}

- (void) performUserAction:(MKAnnotationView*) annoView type:(MAP_USER_ACTION) actionType {
    LocationItem *locItem = (LocationItem*) [annoView annotation];
    
    [self mapAnnotationInfoUpdated:[annoView annotation]];
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
        case MapAnnoUserActionEvent:
            [self viewEventDetail:locItem];
            break;
        case MapAnnoUserActionProfile:
            NSLog(@"locItem place = %@ name = %@", locItem, locItem.itemName);
            [self viewPeopleProfile:locItem];
            break;
        case MapAnnoUserActionCreateEvent:
            [self createEventWithAddress:locItem];
            break;
        case MapAnnoUserActionPlan:
            [self planselected:locItem];
            break;
        case MapAnnoUserActionRecommend:
            [self recommendSelected:locItem];
            break;
        case MapAnnoUserActionReview:
            [self reviewSelected:locItem];
            break;
        case MapAnnoUserActionSave:
            [self saveSelected:locItem];
            break;
        case MapAnnoUserActionCheckin:
            [self checkinSelected:locItem];
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
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];  
    
    [circleView removeFromSuperview];
    NSLog(@"MapViewController:viewDidLoad" );
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sentFriendRequest:) name:NOTIF_SEND_FRIEND_REQUEST_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllEventsForMapView:) name:NOTIF_GET_ALL_EVENTS_FOR_MAP_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllGeotagsForMapView:) name:NOTIF_GET_ALL_GEOTAG_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectFBDone:) name:NOTIF_DO_CONNECT_FB_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getConnectwithFB:) name:NOTIF_DO_CONNECT_WITH_FB object:nil];
    
    filteredList = [[NSMutableArray alloc] initWithArray: userFriendslistArray];
    
    [self performSelectorInBackground:@selector(saveFBProfileImage) withObject:nil];
    _mapView.delegate=self;
    if ([CLLocationManager locationServicesEnabled])
        _mapView.showsUserLocation=YES;
    else
        _mapView.showsUserLocation=NO;
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDistanceFilter:kCLLocationAccuracyHundredMeters];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager startUpdatingLocation];
    _mapView.centerCoordinate = CLLocationCoordinate2DMake([smAppDelegate.currPosition.latitude doubleValue], [smAppDelegate.currPosition.longitude doubleValue]);
    
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
    
    mapAnnoEvent = [[MapAnnotationEvent alloc] init];
    mapAnnoEvent.currState = MapAnnotationStateNormal;
    mapAnnoEvent.delegate = self;
    useLocalData=TRUE;
    // Location update button
    UIButton *locUpdateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    locUpdateBtn.frame = CGRectMake(self.view.frame.size.width-20-25, 
                                    70, 25, 24);
    [locUpdateBtn setImage:[UIImage imageNamed:@"map_geoloc_icon.png"] forState:UIControlStateNormal];
    [locUpdateBtn addTarget:self action:@selector(updateLocation:) forControlEvents:UIControlEventTouchUpInside];
    [_mapView addSubview:locUpdateBtn];
    
    afriend=[[UserFriends alloc] init];
    userDefault=[[UserDefault alloc] init];
    searchText=[[NSString alloc] init];
    
    fbHelper=[FacebookHelper sharedInstance];
    
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

    if ((smAppDelegate.facebookLogin==TRUE) && (![smAppDelegate.fbId isEqualToString:@""]) && ([userDefault readFromUserDefaults:@"fbinvite"]==NULL))
    {
        NSLog(@"show fb invite  %@  %@",smAppDelegate.fbId,[userDefault readFromUserDefaults:@"fbinvite"]);
        [fbHelper inviteFriends:nil];
        [userDefault writeToUserDefaults:@"fbinvite" withString:@"fbinvite"];
        [UtilityClass showAlert:@"" :@"Be aware that unknown people might now be able to see your location. You can change your sharing option in the map drop down or via the settings menu."];
    }

    _mapPullupMenu.hidden = TRUE;
    
    [self initPullView];
    pullDownView.hidden = YES;
    copySearchAnnotationList = [[NSMutableArray alloc] init];

    isFirstTimeDownloading = NO;
    
    int adjustPosX = 25;
    
    radio = [[CustomRadioButton alloc] initWithFrame:CGRectMake(0 + adjustPosX, 13, 310 - adjustPosX * 2, 41) numButtons:3 labels:[NSArray arrayWithObjects:@"All users",@"Friends only",@"No one",nil]  default:smAppDelegate.shareLocationOption sender:self tag:2000 color:[UIColor whiteColor]];
    radio.delegate = self;
    [viewSharingPrefMapPullDown addSubview:radio];
    
    if (smAppDelegate.gotListing == FALSE) {
        [smAppDelegate.window setUserInteractionEnabled:NO];
        [smAppDelegate showActivityViewer:smAppDelegate.window];

        RestClient *restClient = [[[RestClient alloc] init] autorelease]; 
        [restClient getAllEventsForMap :@"Auth-Token" :smAppDelegate.authToken];
        [restClient getAllGeotag:@"Auth-Token" :smAppDelegate.authToken];
    }
    
	if (!smAppDelegate.timerGotListing) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotListings:) name:NOTIF_GET_LISTINGS_DONE object:nil];
    }
    
}

- (void)startGetLocation:(NSTimer*)timer
{
        RestClient *restClient = [[[RestClient alloc] init] autorelease];
        [restClient getLocation:smAppDelegate.currPosition :@"Auth-Token" :smAppDelegate.authToken];
}

- (void) radioButtonClicked:(int)indx sender:(id)sender {
    NSLog(@"radioButtonClicked index = %d", indx);
    
    if ([smAppDelegate.locSharingPrefs.status caseInsensitiveCompare:@"on"] == NSOrderedSame) {
        if (indx == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you want to share your location with everyone?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [alertView show];
            [alertView release];
        } else {
            RestClient *restClient = [[[RestClient alloc] init] autorelease];
            [restClient setSharingPrivacySettings:@"Auth-Token" authTokenVal:smAppDelegate.authToken privacyType:@"shareLocation" sharingOption:[NSString stringWithFormat:@"%d", indx + 1]];
        }
    } else {
        [UtilityClass showAlert:@"" :@"Location sharing is switched off in settings, enable it to share your location."];
        [self setRadioButton];
    }
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        RestClient *restClient = [[[RestClient alloc] init] autorelease];
        [restClient setSharingPrivacySettings:@"Auth-Token" authTokenVal:smAppDelegate.authToken privacyType:@"shareLocation" sharingOption:[NSString stringWithFormat:@"1"]];
    } else {
        [self setRadioButton];
    }
}

- (void)changedLocationSharingSetting:(NSNotification *)notif
{
    NSLog(@"got LocationSharingSetting");
    NSString  *sharingOption = [notif object];
    
    if (sharingOption) {
        smAppDelegate.shareLocationOption = [sharingOption intValue] - 1;
        
        switch (smAppDelegate.shareLocationOption) {
            case 0:
                [UtilityClass showAlert:@"" :@"Location sharing is now set to: All users."];
                break;
            case 1:
                [UtilityClass showAlert:@"" :@"Location sharing is now set to: Friends only."];
                break;
            default:
                [UtilityClass showAlert:@"" :@"Location sharing is now set to: No one."];
                break;
        }
        
    } else {
        [self setRadioButton];
        [UtilityClass showAlert:@"" :@"Could not handle request due to network error, try again."];
    }
    
    
}

// Gesture recognizer for map drag event
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)didTapMap
{
    NSLog(@"Tap Map");

    if (selectedAnno) {
        
        LocationItem *selLocation = (LocationItem*)selectedAnno;
        [mapAnno changeStateToNormal:selLocation];
        [self mapAnnotationChanged:selLocation];
    }
    
    selectedAnno = nil;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    NSLog(@"touch.view.tag %d %@",touch.view.tag,touch.view);
    if (([touch.view isKindOfClass:[UIButton class]]) || (touch.view.tag==12211221) || (touch.view.tag==1234321) || (touch.view.tag==11002)|| (touch.view.tag==11001) || (touch.view.tag==12321123)||([touch.view isKindOfClass:[UIWebView class]]))
    {
        return NO; // ignore the touch
    }
    return YES; // handle the touch
}
		
- (void)didDragMap:(UIGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        NSLog(@"Map drag ended");
        smAppDelegate.needToCenterMap = FALSE;
        
        //VISIBLE MAP AREA COORDINATE IS NEEDED FOR ADD ANNOTATION ACCORDING TO MAP POSITION SERVICE CALL
        MKMapRect mRect = self.mapView.visibleMapRect;
        MKMapPoint neMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), mRect.origin.y);
        MKMapPoint swMapPoint = MKMapPointMake(mRect.origin.x, MKMapRectGetMaxY(mRect));
        CLLocationCoordinate2D neCoord = MKCoordinateForMapPoint(neMapPoint);
        CLLocationCoordinate2D swCoord = MKCoordinateForMapPoint(swMapPoint);
        
        NSLog(@"North-East point = %f,%f", neCoord.latitude, neCoord.longitude);
        NSLog(@"South-West point = %f,%f", swCoord.latitude, swCoord.longitude);
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (smAppDelegate.timerGotListing && shouldTimerStop) {
        [smAppDelegate.timerGotListing invalidate];
        smAppDelegate.timerGotListing = nil;
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SET_SHARE_LOCATION_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_INBOX_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_FRIEND_REQ_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_MEET_UP_REQUEST_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_SEND_FRIEND_REQUEST_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_LOCATION_SHARING_SETTING_DONE object:nil];
    userFriendslistArray=[[NSMutableArray alloc] init];

}

- (void)viewDidUnload
{
    NSLog(@"MapViewController:viewDidUnload" );
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_DO_CONNECT_WITH_FB object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_DO_CONNECT_FB_DONE object:nil];

    [userDefault writeToUserDefaults:@"lastLatitude" withString:smAppDelegate.currPosition.latitude];
    [userDefault writeToUserDefaults:@"lastLongitude" withString:smAppDelegate.currPosition.longitude];
//    [locationManager stopUpdatingLocation];
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
    [buttonListView release];
    buttonListView = nil;
    [buttonProfileView release];
    buttonProfileView = nil;
    [buttonMapView release];
    buttonMapView = nil;
    [imageViewSliderOpenClose release];
    imageViewSliderOpenClose = nil;
    [viewNotification release];
    viewNotification = nil;
    [viewSearch release];
    viewSearch = nil;
    [searchBar release];
    searchBar = nil;
    [viewSharingPrefMapPullDown release];
    viewSharingPrefMapPullDown = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//annotation data source
- (void)loadAnnotations:(BOOL)animated
{
    // 1
    CLLocationCoordinate2D zoomLocation;
    
    // Current location
    zoomLocation.latitude = [smAppDelegate.currPosition.latitude doubleValue];
    zoomLocation.longitude = [smAppDelegate.currPosition.longitude doubleValue];
    
    if (CLLocationCoordinate2DIsValid(zoomLocation)) {
        
        // 2
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
        // 3
        NSLog(@"MapViewController:loadAnnotations");
        MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];  
        for (id<MKAnnotation> annotation in _mapView.annotations) {
            [_mapView removeAnnotation:annotation];
        }
        [_mapView removeAnnotations:_mapView.annotations];
        for (int i=0; i < smAppDelegate.displayList.count; i++) {
            LocationItem *anno = (LocationItem*) [smAppDelegate.displayList objectAtIndex:i];
            
            if ( CLLocationCoordinate2DIsValid(anno.coordinate)==TRUE) 
            {
                [_mapView addAnnotation:anno];
            }
        }
        
        // 4
        if (smAppDelegate.needToCenterMap == TRUE) {
            NSLog(@"MapViewController:loadAnnotations centering map %f %f",adjustedRegion.center.latitude,zoomLocation.latitude);
            [_mapView setRegion:adjustedRegion animated:YES];
            NSLog(@"1");
            [_mapView setCenterCoordinate:zoomLocation animated:YES];
            NSLog(@"2");
        }
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [connectToFBView removeFromSuperview];
    if ([CLLocationManager locationServicesEnabled])
        _mapView.showsUserLocation=YES;
    else
        _mapView.showsUserLocation=NO;
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
    {
        [self loadAnnotationForGeotag];
        [self loadAnnotations:animated];
    }
    
    if (smAppDelegate.showEvents == TRUE)
    {
        [_showDealsButton setImage:[UIImage imageNamed:@"people_checked.png"] forState:UIControlStateNormal];
    } 
    else if (smAppDelegate.showEvents == FALSE)
    {
        [_showDealsButton setImage:[UIImage imageNamed:@"people_unchecked.png"] forState:UIControlStateNormal];
    }
    
    RestClient *restClient = [[[RestClient alloc] init] autorelease]; 
    if (useLocalData==false)
    {
        [restClient getAllEventsForMap :@"Auth-Token" :smAppDelegate.authToken];
    }
    
    if(loadGeotagServiceData==true)
    {
        [restClient getAllGeotag:@"Auth-Token" :smAppDelegate.authToken];
        NSLog(@"call geotag service");
    }
    
    [self loadAnnotationForEvents];
    [self loadAnnotationForGeotag];
    [self loadAnnotations:YES];

    pointOnMapFlag = FALSE;
    profileFromList = FALSE;
    smAppDelegate.currentModelViewController = self;
    
    [self displayNotificationCount];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveSettingsDone:) name:SET_SHARE_LOCATION_DONE object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!smAppDelegate.timerGotListing) 
    {
        NSLog(@"!smAppDelegate.timerGotListing %d", !smAppDelegate.timerGotListing);
        RestClient *restClient = [[[RestClient alloc] init] autorelease]; 
        [restClient getLocation:smAppDelegate.currPosition :@"Auth-Token" :smAppDelegate.authToken];
        smAppDelegate.timerGotListing = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(startGetLocation:) userInfo:nil repeats:YES];
    }
    
    shouldTimerStop = YES;
    pullDownView.hidden = NO;
    userDefault=[[UserDefault alloc] init];
    
    if ((![userDefault readFromUserDefaults:@"connectWithFB"]) && (smAppDelegate.smLogin==TRUE))
    {
        connectToFBView.layer.borderWidth=2.0;
        connectToFBView.layer.masksToBounds = YES;
        [connectToFBView.layer setCornerRadius:7.0];
        connectToFBView.layer.borderColor=[[UIColor lightTextColor]CGColor];
        [self.view addSubview:connectToFBView];
        
        [UtilityClass showAlert:@"" :@"Be aware that unknown people might now be able to see your location. You can change your sharing option in the map drop down or via the settings menu."];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changedLocationSharingSetting:) name:NOTIF_LOCATION_SHARING_SETTING_DONE object:nil];
    
    NSLog(@"viewDidAppear finished");
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)inError{
    NSLog(@"MapViewController:didFailWithError error code=%d msg=%@", [inError code], [inError localizedFailureReason]);
    NSLog(@"location manager failed with error");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"location manager update location");
    if (newLocation.coordinate.longitude == 0.0 && newLocation.coordinate.latitude == 0.0)
        return;
    // Calculate move from last position
    CLLocation *lastPos = [[CLLocation alloc] initWithLatitude:[smAppDelegate.currPosition.latitude doubleValue] longitude:[smAppDelegate.lastPosition.longitude doubleValue]];
    
    NSDate *now = [NSDate date];
    int elapsedTime = [now timeIntervalSinceDate:smAppDelegate.currPosition.positionTime];
    _mapView.showsUserLocation = YES;
    
    CLLocationDistance distanceMoved = [newLocation distanceFromLocation:lastPos];
    NSLog(@"MapViewController:didUpdateToLocation - old {%f,%f}, new {%f,%f}, distance moved=%f, elapsed time=%d",
          oldLocation.coordinate.latitude, oldLocation.coordinate.longitude,
          newLocation.coordinate.latitude, newLocation.coordinate.longitude,
          distanceMoved, elapsedTime);
    

    // Update location if new position detected and one of the following is true
    // 1. Moved 10 meters and 10 seconds has elapsed.
    // 2. 60 seconds has elapsed. This is to get new people around and I am mostly stationary
    // 3. First time - smAppDelegate.gotListing == FALSE
    //
    if ((distanceMoved >= 10 && elapsedTime > 10) || elapsedTime > 60 || smAppDelegate.gotListing == FALSE) { // TODO : use distance
        // Update the position
        smAppDelegate.lastPosition = smAppDelegate.currPosition;
        smAppDelegate.currPosition.latitude = [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
        smAppDelegate.currPosition.longitude = [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];
        smAppDelegate.currPosition.positionTime = [NSDate date];
        
        [userDefault writeToUserDefaults:@"lastLatitude" withString:smAppDelegate.currPosition.latitude];
        [userDefault writeToUserDefaults:@"lastLongitude" withString:smAppDelegate.currPosition.longitude];
        
        
        // Send new location to server
        RestClient *restClient = [[[RestClient alloc] init] autorelease]; 
        
        [restClient updatePosition:smAppDelegate.currPosition authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
    }
    if (elapsedTime > 300 && smAppDelegate.isAppInBackgound==TRUE)
    {
        smAppDelegate.lastPosition = smAppDelegate.currPosition;
        smAppDelegate.currPosition.latitude = [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
        smAppDelegate.currPosition.longitude = [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];
        smAppDelegate.currPosition.positionTime = [NSDate date];
        
        [userDefault writeToUserDefaults:@"lastLatitude" withString:smAppDelegate.currPosition.latitude];
        [userDefault writeToUserDefaults:@"lastLongitude" withString:smAppDelegate.currPosition.longitude];
        
        
        // Send new location to server
        RestClient *restClient = [[[RestClient alloc] init] autorelease]; 
        
        [restClient updatePosition:smAppDelegate.currPosition authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
        NSLog(@"update location in background after every 5 mins");
    }

}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    mapView.showsUserLocation = NO;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (smAppDelegate.needToCenterMap == TRUE) {
        [mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    }
    NSLog(@"update location");
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
    [super dealloc];
    NSLog(@"Deallocating MapViewController");
    NSLog(@"MapView retain count - %d", [_mapView retainCount]);
    [radio release];
    
    [copySearchAnnotationList release];
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
    [buttonListView release];
    [buttonProfileView release];
    [buttonMapView release];
    [imageViewSliderOpenClose release];
    [viewNotification release];
    [viewSearch release];
    [searchBar release];
    [_mapView release]; _mapView = nil;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    NSLog(@"In prepareForSegue:MapViewController");
    
    if ([segue.destinationViewController isKindOfClass:[ListViewController class]])
        shouldTimerStop = NO;
        
    LocationItem *selLocation = (LocationItem*) selectedAnno;
    selLocation.currDisplayState = MapAnnotationStateNormal;
}

-(IBAction)connectWithFB:(id)sender
{
    NSLog(@"do connect fb");
    Facebook *facebookApi = [[FacebookHelper sharedInstance] facebook];
    if ([facebookApi isSessionValid])
    {
        [fbHelper inviteFriends:nil];        
    }
    else
    {
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"email",
                                @"user_likes", 
                                @"user_photos", 
                                @"publish_checkins", 
                                @"photo_upload", 
                                @"user_location",
                                @"user_birthday",
                                @"user_about_me",
                                @"publish_stream",
                                @"read_stream",
                                @"friends_status",
                                @"user_checkins",
                                @"friends_checkins",
                                nil];
        [facebookApi authorize:permissions];
        [permissions release];
    }
    [userDefault writeToUserDefaults:@"connectWithFB" withString:@"FBConnect"];
    [userDefault writeToUserDefaults:@"connectWithFBDone" withString:@"FBConnectedDone"];
    [connectToFBView removeFromSuperview];
}

-(IBAction)closeConnectWithFB:(id)sender
{
    NSLog(@"close connect fb");
    [connectToFBView removeFromSuperview];
    [userDefault writeToUserDefaults:@"connectWithFB" withString:@"FBConnect"];
}

- (IBAction)showPullDown:(id)sender {
    _mapPulldown.hidden = FALSE;
}

- (IBAction)hidePulldown:(id)sender {
    pickSavedFilter.hidden = TRUE;
    _mapPulldown.hidden = TRUE;
}

-(IBAction)gotoProfile:(id)sender
{
    [pullUpView setOpened:FALSE animated:TRUE];
    [self.view addSubview:circleView];
}

-(IBAction)gotoBasicProfile:(id)sender
{
    UserBasicProfileViewController *controller =[[UserBasicProfileViewController alloc] init];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
}

-(IBAction)gotoSettings:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];   
    UIViewController* initialHelpView = [storyboard instantiateViewControllerWithIdentifier:@"settingsController"];
    
    initialHelpView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:initialHelpView animated:YES];
}

-(IBAction)gotoCircle:(id)sender
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"CirclesStoryboard" bundle:nil];
    UITabBarController* initialHelpView = [storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];
    [[UITabBar appearance] setTintColor:[UIColor blackColor]];
    initialHelpView.modalPresentationStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:initialHelpView animated:YES];
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

- (IBAction)gotoMyPlaces:(id)sender
{
}

- (IBAction)gotoDirections:(id)sender 
{/*
   // viewEventList
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    ViewEventListViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"viewEventList"];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
    */
    [self directionSelected:nil];
}

-(void)getAllEvents
{
    RestClient *rc=[[RestClient alloc] init];
    [rc getAllEvents:@"Auth-Token":smAppDelegate.authToken];    
}

- (void)connectFBDone:(NSNotification *)notif
{
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    
    [userDefault writeToUserDefaults:@"connectWithFB" withString:@"FBConnect"];
    NSLog(@"Connected with fb :D %@",[notif object]);
}

- (void)getConnectwithFB:(NSNotification *)notif
{
    NSLog(@"(smAppDelegate.facebookLogin: %i smAppDelegate.smLogin: %i",smAppDelegate.facebookLogin,smAppDelegate.smLogin);
    if ((smAppDelegate.smLogin==TRUE))
    {
        userDefault=[[UserDefault alloc] init];
        NSLog(@"");
        RestClient *rc=[[RestClient alloc] init];
        [connectToFBView removeFromSuperview];
        [smAppDelegate showActivityViewer:self.view];
        NSLog(@"fb access token in map: 1: %@ 2: %@ 3: %@",[notif object],smAppDelegate.fbId,[userDefault readFromUserDefaults:@"FBUserId"]);
        [fbHelper inviteFriends:nil];
        if ([smAppDelegate.fbId isEqualToString:@""])
        {
            smAppDelegate.fbId=[userDefault readFromUserDefaults:@"FBUserId"];
        }
        
        if (smAppDelegate.fbAccessToken) 
        {
            [rc doConnectFB:@"Auth-Token" :smAppDelegate.authToken :smAppDelegate.fbId :smAppDelegate.fbAccessToken];
            NSLog(@"got access token");
        }
        else if ([userDefault readFromUserDefaults:@"FBAccessTokenKey"]) 
        {
            [rc doConnectFB:@"Auth-Token" :smAppDelegate.authToken :smAppDelegate.fbId :[userDefault readFromUserDefaults:@"FBAccessTokenKey"]];
            NSLog(@"got accees token from user default");
        }
        else
        {
            [smAppDelegate hideActivityViewer];
        }
    }
}

- (void)saveSettingsDone:(NSNotification *)notif
{
    ShareLocation *shareLocation = notif.object;
    if (shareLocation) {
        if ([shareLocation.status caseInsensitiveCompare:@"Off"] == NSOrderedSame) {
            
        } 
    }else {
        [UtilityClass showAlert:@"" :@"Error saving changes, please try again."];
    }
    [self setRadioButton];
}

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
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"CirclesStoryboard" bundle:nil];
    UIViewController* initialHelpView = [storyboard instantiateViewControllerWithIdentifier:@"viewCircleListViewController"];
    
    initialHelpView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:initialHelpView animated:YES];
}

-(IBAction)addCircleView:(id)sender
{
    [pullUpView setOpened:FALSE animated:TRUE];
    CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[self.view layer] addAnimation:animation forKey:@"layerAnimation"];

    [self.view addSubview:circleView];
}

-(IBAction)removeCircleView:(id)sender
{
    // Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[self.view layer] addAnimation:animation forKey:@"layerAnimation"];

    [circleView removeFromSuperview];
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
    [self loadAnnotationForEvents];
    [self loadAnnotationForGeotag];
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
    [self loadAnnotationForEvents];
    [self loadAnnotationForGeotag];   
    [self loadAnnotations:YES];
    [self.view setNeedsDisplay];
}

- (IBAction)dealsClicked:(id)sender {
    if (smAppDelegate.showEvents == true) {
        smAppDelegate.showEvents = false;
        [_showDealsButton setImage:[UIImage imageNamed:@"people_unchecked.png"] forState:UIControlStateNormal];
    } else {
        smAppDelegate.showEvents = true;
        [_showDealsButton setImage:[UIImage imageNamed:@"people_checked.png"] forState:UIControlStateNormal];
    }
    [self loadAnnotationForEvents];
    [self loadAnnotationForGeotag];
    [self loadAnnotations:YES];
    [self.view setNeedsDisplay];
}

-(IBAction)gotoPlace:(id)sender
{
    PlaceListViewController *controller = [[PlaceListViewController alloc] initWithNibName:@"PlaceListViewController" bundle:nil];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
    [controller release];
    
}

-(IBAction)gotoFriends:(id)sender
{
    FriendListViewController *controller = [[FriendListViewController alloc] initWithNibName:@"FriendListViewController" bundle:nil];
    [controller selectUserId:smAppDelegate.userId];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
    controller.labelUserName.text = @"My friend list";
    [controller release];   
}

-(IBAction)gotonNewsFeed:(id)sende
{
    NewsFeedViewController *controller =[[NewsFeedViewController alloc] init];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
}

-(IBAction)gotonDeals:(id)sender
{
    [UtilityClass showAlert:@"Social Maps" :@"This feature is coming soon."];    
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

-(void)initPullView
{
    CGFloat xOffset = 0;
    pullUpView = [[PullableView alloc] initWithFrame:CGRectMake(xOffset, 0, 320, 60)];
    pullUpView.openedCenter = CGPointMake(160 + xOffset,self.view.frame.size.height - 30);
    pullUpView.closedCenter = CGPointMake(160 + xOffset, self.view.frame.size.height);
    pullUpView.center = pullUpView.closedCenter;
    pullUpView.handleView.frame = CGRectMake(0, 0, 320, 40);
    pullUpView.delegate = self;
    
    [pullUpView addSubview:_mapPullupMenu];
    _mapPullupMenu.userInteractionEnabled = NO;
    [pullUpView addSubview:buttonListView];
    [pullUpView addSubview:buttonMapView];
    [pullUpView addSubview:buttonProfileView];
    _mapPullupMenu.hidden = NO;
    _mapPullupMenu.frame = CGRectMake(0, 0, _mapPullupMenu.frame.size.width, _mapPullupMenu.frame.size.height);
    [self.view addSubview:pullUpView];
    
    
    UIImageView *imageViewFooterSliderOpen = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
    imageViewFooterSliderOpen.image = [UIImage imageNamed:@"btn_footer_slider_open.png"];
    [pullUpView.handleView addSubview:imageViewFooterSliderOpen];
    [pullUpView bringSubviewToFront:pullUpView.handleView];
    imageViewFooterSliderOpen.tag = 420;    
    [imageViewFooterSliderOpen release];
    
    
    pullDownView = [[PullableView alloc] initWithFrame:CGRectMake(xOffset, 0, 320, 219)];
    pullDownView.openedCenter = CGPointMake(160 + xOffset, 120 + 69 - 35);
    pullDownView.closedCenter = CGPointMake(160 + xOffset, -5 - 69 + 34);
    pullDownView.center = pullDownView.closedCenter;
    pullDownView.handleView.frame = CGRectMake(0, pullDownView.frame.size.height - 25, 320, 25);
    pullDownView.delegate = self;
    
    [self.view addSubview:pullDownView];
    [self.view bringSubviewToFront:viewSearch];
    [self.view bringSubviewToFront:viewNotification];
    [pullDownView addSubview:_mapPulldown];
    [self.view bringSubviewToFront:viewNotification];
    _mapPulldown.userInteractionEnabled = NO;
    for (UIView *view in [_mapPulldown subviews]) {
            [pullDownView addSubview:view];
    }
    _mapPulldown.hidden = NO;
    _mapPulldown.frame = CGRectMake(0, 0, _mapPulldown.frame.size.width, _mapPulldown.frame.size.height);
    
    imageViewFooterSliderOpen = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
    imageViewFooterSliderOpen.image = [UIImage imageNamed:@"slide_close_bar.png"];
    [pullDownView.handleView addSubview:imageViewFooterSliderOpen];
    [pullDownView bringSubviewToFront:pullDownView.handleView];
    imageViewFooterSliderOpen.tag = 840;    
    [imageViewFooterSliderOpen release];
     
}

- (void)pullableView:(PullableView *)pView didChangeState:(BOOL)opened {
    if (opened)
    {
        ((UIImageView*)[pView.handleView viewWithTag:420]).image = [UIImage imageNamed:@"btn_footer_slider_close.png"];
        ((UIImageView*)[pView.handleView viewWithTag:840]).image = nil;
    }
    else
    {
        ((UIImageView*)[pView.handleView viewWithTag:420]).image = [UIImage imageNamed:@"btn_footer_slider_open.png"];
        ((UIImageView*)[pView.handleView viewWithTag:840]).image = [UIImage imageNamed:@"slide_close_bar.png"];
    }
}

- (void) updateLocation:(id) sender {
    CLLocationCoordinate2D lastPos = CLLocationCoordinate2DMake([smAppDelegate.currPosition.latitude doubleValue], [smAppDelegate.currPosition.longitude doubleValue]);
    _mapView.centerCoordinate = lastPos;
    NSLog(@"MapViewController: updateLocation lat:%f lng:%f", lastPos.latitude, lastPos.longitude);
    if ([CLLocationManager locationServicesEnabled]) {
        _mapView.showsUserLocation=YES;
        // Send new location to server
        RestClient *restClient = [[[RestClient alloc] init] autorelease];
        [restClient updatePosition:smAppDelegate.currPosition authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
    } else {
        _mapView.showsUserLocation=NO;
    }
    smAppDelegate.needToCenterMap = TRUE;
    [_mapView setNeedsDisplay];

}

- (void) getSortedDisplayList {
    [smAppDelegate.displayList removeAllObjects];
    NSMutableArray *tempList = [[NSMutableArray alloc] init];
    if (smAppDelegate.showPeople == TRUE) 
        [tempList addObjectsFromArray:smAppDelegate.peopleList];
    if (smAppDelegate.showPlaces == TRUE) 
        [tempList addObjectsFromArray:smAppDelegate.placeList];
    if (smAppDelegate.showEvents == TRUE) 
        [tempList addObjectsFromArray:smAppDelegate.eventList];
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
    NSLog(@"got listing");
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
                    [_mapView removeAnnotation:[smAppDelegate.peopleList objectAtIndex:indx]];
                    [smAppDelegate.peopleList removeObjectAtIndex:indx];
                    [self.view setNeedsDisplay];
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
                
                if ([item.friendshipStatus isEqualToString:@"friend"]) {
                    
                    BOOL isExistingFriend = FALSE;
                    
                    for (UserFriends *userFriends in friendListGlobalArray) {
                        if ([userFriends.userId isEqualToString:item.userId]) {
                            isExistingFriend = TRUE;
                            break;
                        }
                    }
                    
                    if (!isExistingFriend) {
                        UserFriends *frnd = [[UserFriends alloc] init];
                        frnd.userId = item.userId;
                        NSString *firstName = item.firstName;
                        NSString *lastName = item.lastName;
                        frnd.userName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                        frnd.imageUrl = item.avatar;
                        frnd.distance = [item.distance intValue];
                        frnd.coverImageUrl = item.coverPhotoUrl;
                        frnd.address =  item.city;
                        frnd.statusMsg = item.statusMsg;
                        frnd.regMedia = item.regMedia;
                        [friendListGlobalArray addObject:frnd];
                        [frnd release];
                    }
                }
                 
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

                        CLLocationDistance distanceFromMe = [self getDistanceFromMe:loc];
                        
                        LocationItemPeople *aPerson = [[LocationItemPeople alloc] initWithName:[NSString stringWithFormat:@"%@ %@", item.firstName, item.lastName] address:item.lastSeenAt type:ObjectTypePeople category:item.gender coordinate:loc dist:distanceFromMe icon:icon bg:bg itemCoverPhotoUrl:[NSURL URLWithString:item.coverPhotoUrl]];
                        
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
                                    if ([smAppDelegate.peopleList count] > itemIndex) {
                                        //it was crashing sometimes... errorlog trying to get objectAtIndex of an empty array... above if condition added - Rishi
                                        LocationItemPeople *person = [smAppDelegate.peopleList objectAtIndex:itemIndex];
                                        person.itemIcon = image;
                                        if (smAppDelegate.showPeople == TRUE)
                                            [self mapAnnotationInfoUpdated:person];
                                    }
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
                        

                        CLLocationDistance distanceFromMe = [self getDistanceFromMe:loc];
                        aPerson.itemAddress = item.lastSeenAt;
                        aPerson.itemCoverPhotoUrl = [NSURL URLWithString:item.coverPhotoUrl];
                        aPerson.itemDistance = distanceFromMe;
                        aPerson.userInfo.relationsipStatus = item.relationsipStatus;
                        aPerson.userInfo.workStatus = item.workStatus;
                        aPerson.userInfo.city = item.city;
                        aPerson.userInfo.firstName = item.firstName;
                        aPerson.userInfo.lastName = item.lastName;
                        
                        if (smAppDelegate.showPeople == TRUE && ((item.friendshipStatus && ![item.friendshipStatus isEqualToString:aPerson.userInfo.friendshipStatus]) || (item.avatar && ![item.avatar isEqualToString:aPerson.userInfo.avatar]) || (item.isOnline && item.isOnline != aPerson.userInfo.isOnline) || loc.latitude != aPerson.coordinate.latitude || loc.longitude != aPerson.coordinate.longitude)) 
                        {
                            
                            if (CLLocationCoordinate2DIsValid(loc))
                            {
                                aPerson.coordinate = loc;
                            }
                            
                            NSLog(@"update only %@", aPerson.userInfo.firstName);
                            
                            aPerson.userInfo.friendshipStatus = item.friendshipStatus;
                            aPerson.userInfo.isOnline = item.isOnline;
                            
                            if (![item.avatar isEqualToString:aPerson.userInfo.avatar]) {

                                aPerson.userInfo.avatar = item.avatar;
                                [self downloadImage:aPerson];
                            }
                            
                            [self mapAnnotationInfoUpdated:aPerson];
                        }
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
                    NSString* iconPath = [[NSBundle mainBundle] pathForResource:@"venueimg" ofType:@"png"];
                    UIImage *icon = [[UIImage alloc] initWithContentsOfFile:iconPath];
                    NSString* bgPath = [[NSBundle mainBundle] pathForResource:@"banner_bar" ofType:@"png"];
                    UIImage *bg = [[UIImage alloc] initWithContentsOfFile:bgPath];

                    CLLocationCoordinate2D loc;
                    loc.latitude = [item.location.latitude doubleValue];
                    loc.longitude = [item.location.longitude doubleValue];
                    CLLocationDistance distanceFromMe = [self getDistanceFromMe:loc];
                    NSLog(@"Name=%@ Location=%f,%f, distance=%f",item.name, loc.latitude,loc.longitude, distanceFromMe);
                    
                   
                    LocationItemPlace *aPlace = [[LocationItemPlace alloc] initWithName:item.name address:item.vicinity type:ObjectTypePlace category:[item.typeArr lastObject] coordinate:loc dist:distanceFromMe icon:icon bg:bg itemCoverPhotoUrl:[NSURL URLWithString:item.coverPhotoUrl]];
                    
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
                                if ([smAppDelegate.placeList count] > itemIndex) {
                                    //it was crashing sometimes... errorlog trying to get objectAtIndex of an empty array... above if condition added - Rishi
                                    LocationItemPlace *place = [smAppDelegate.placeList objectAtIndex:itemIndex];
                                    place.itemIcon = image;
                                    if (smAppDelegate.showPlaces == TRUE)
                                        [self mapAnnotationInfoUpdated:place];
                                }
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
                }
            }

        }
        if (smAppDelegate.gotListing == FALSE) {
            smAppDelegate.gotListing = TRUE;
            [smAppDelegate.window setUserInteractionEnabled:YES];
            [smAppDelegate hideActivityViewer];
        }
        [self getSortedDisplayList];
        
        //by Rishi
        if (!isFirstTimeDownloading) { 
            //for first time
            [self loadAnnotationForEvents];
            [self loadAnnotationForGeotag];
            [self loadAnnotations:YES];
            [self.view setNeedsDisplay];
            isFirstTimeDownloading = YES;
        }
    }
}

- (void)downloadImage:(LocationItemPeople*)person 
{
    if ([person.userInfo.avatar length] > 0) {// Need to retrieve avatar image
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSData* imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:person.userInfo.avatar]];
            UIImage* image = [[UIImage alloc] initWithData:imageData];
            [imageData release];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                    person.itemIcon = image;
                person.currDisplayState = MapAnnotationStateNormal;
                if (smAppDelegate.showPeople == TRUE) {
                    [_mapView removeAnnotation:(id <MKAnnotation>)person];
                    [_mapView addAnnotation:(id <MKAnnotation>)person];
                }
                
                    if (smAppDelegate.showPeople == TRUE)
                        [self mapAnnotationInfoUpdated:person];
                
            });
        });
    }
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
    NSLog(@"userAccountPref %d", smAppDelegate.shareLocationOption);

    if (smAppDelegate.shareLocationOption < 0) {
        smAppDelegate.shareLocationOption = 0;
    }
    
    [self setRadioButton];
    
    [self displayNotificationCount];
}

- (void)setRadioButton {
    if ([smAppDelegate.locSharingPrefs.status caseInsensitiveCompare:@"off"] == NSOrderedSame)
        [radio gotoButton:2];
    else
        [radio gotoButton:smAppDelegate.shareLocationOption];
}

- (void)sentFriendRequest:(NSNotification *)notif {
    callBackData.locItem.userInfo.friendshipStatus = @"requested";
    [self mapAnnotationChanged:callBackData.locItem];
    [mapAnno changeStateToDetails:callBackData.locItem];
}

-(void)getAllEventsForMapView:(NSNotification *)notif 
{
    useLocalData=TRUE;
    NSLog(@"got all events for map %@",smAppDelegate.eventList);
    [self loadAnnotationForEvents];
    [self loadAnnotationForGeotag];
    [self loadAnnotations:NO];
}

-(void)getAllGeotagsForMapView:(NSNotification *)notif 
{
    smAppDelegate.geotagList=[notif object];
    NSLog(@"got all geotag for map %@",smAppDelegate.geotagList);
    [self loadAnnotationForGeotag];
    [self loadAnnotations:NO];    
    loadGeotagServiceData=false;
}

-(void)loadAnnotationForGeotag
{
    if (smAppDelegate.showPlaces == TRUE)
    {
        for (int i=0; i<[smAppDelegate.geotagList count]; i++)
        {
            if ([[smAppDelegate.geotagList objectAtIndex:i] isKindOfClass:[Geotag class]])
            {
                Geotag *aGeotag=[[Geotag alloc] init];
                aGeotag=[smAppDelegate.geotagList objectAtIndex:i];
                LocationItem *item=[[LocationItem alloc] init];
                item.itemName=aGeotag.geoTagTitle;
                item.itemAddress=[NSString stringWithFormat:@"at %@",aGeotag.geoTagAddress] ;
                item.itemType=4;
                item.coordinate=CLLocationCoordinate2DMake([aGeotag.geoTagLocation.latitude doubleValue], [aGeotag.geoTagLocation.longitude doubleValue]);
                item.itemDistance=[aGeotag.geoTagDistance floatValue];
                item.itemDistance=[UtilityClass getDistanceWithoutFormattingFromLocation:aGeotag.geoTagLocation];
                item.itemIcon=[UIImage imageNamed:@"sm_icon.png.png"];
                item.itemCoverPhotoUrl=[NSURL URLWithString:aGeotag.geoTagImageUrl];
                item.currDisplayState=0;
                item.itemCategory=[NSString stringWithFormat:@"%@ %@",aGeotag.ownerLastName,aGeotag.ownerFirstName];
                [smAppDelegate.geotagList replaceObjectAtIndex:i withObject:item];
            }
        }
        
        //adding annotations  
        if ([smAppDelegate.geotagList count]>0) 
        {
            for (int i=0; i<[smAppDelegate.geotagList count]; i++)
            {
                if([[smAppDelegate.geotagList objectAtIndex:i] isKindOfClass:[LocationItem class]])
                {
                    NSLog(@"geotag annotation added ");
                    LocationItem *anno = (LocationItem*) [smAppDelegate.geotagList objectAtIndex:i];
                    if ( CLLocationCoordinate2DIsValid(anno.coordinate)==TRUE) 
                    {
                        if (![smAppDelegate.displayList containsObject:anno])
                        {
                            [smAppDelegate.displayList addObject:anno];
                        }
                    }
                }
            }
        }
    }
    else
    {
        for (int i=0; i<[smAppDelegate.geotagList count]; i++)
        {
            if([[smAppDelegate.geotagList objectAtIndex:i] isKindOfClass:[LocationItem class]])
            {
                NSLog(@"geotag annotation removed ");
                LocationItem *anno = (LocationItem*) [smAppDelegate.geotagList objectAtIndex:i];
                if ( CLLocationCoordinate2DIsValid(anno.coordinate)==TRUE) 
                {
                    [smAppDelegate.displayList removeObject:anno];
                }
            }
        }
    }
}

-(void)loadAnnotationForEvents
{
    if (smAppDelegate.showEvents == TRUE)
    {
        if ([eventListGlobalArray count]>0)
        {
            smAppDelegate.eventList=[eventListGlobalArray mutableCopy];
        }
        for (int i=0; i<[smAppDelegate.eventList count]; i++)
        {
            if ([[smAppDelegate.eventList objectAtIndex:i] isKindOfClass:[Event class]])
            {
                Event *aEvent=[[Event alloc] init];
                aEvent=[smAppDelegate.eventList objectAtIndex:i];
                LocationItem *item=[[LocationItem alloc] init];
                item.itemName=aEvent.eventName;
                item.itemAddress=aEvent.eventDate.date;
                item.itemType=0;
                item.itemCategory=0;
                item.coordinate=CLLocationCoordinate2DMake([aEvent.eventLocation.latitude doubleValue], [aEvent.eventLocation.longitude doubleValue]);
                item.itemDistance=[UtilityClass getDistanceWithoutFormattingFromLocation:aEvent.eventLocation];
                item.itemIcon=[UIImage imageNamed:@"icon_event.png"];
                item.itemBg=[UIImage imageNamed:@"event_item_bg.png"];
                item.currDisplayState=0;
                item.itemCoverPhotoUrl=[NSURL URLWithString:aEvent.eventImageUrl];
                [smAppDelegate.eventList replaceObjectAtIndex:i withObject:item];
            }
        }
        
        //adding annotations  
        if ([smAppDelegate.eventList count]>0) 
        {
            for (int i=0; i<[smAppDelegate.eventList count]; i++)
            {
                if([[smAppDelegate.eventList objectAtIndex:i] isKindOfClass:[LocationItem class]])
                {
                    NSLog(@"event annotation added ");
                    LocationItem *anno = (LocationItem*) [smAppDelegate.eventList objectAtIndex:i];
                    if ( CLLocationCoordinate2DIsValid(anno.coordinate)==TRUE) 
                    {
                        if (![smAppDelegate.displayList containsObject:anno])
                        {
                            [smAppDelegate.displayList addObject:anno];
                        }
                         
                    }
                }
            }
        }
    }
    else
    {
        for (int i=0; i<[smAppDelegate.eventList count]; i++)
        {
            if([[smAppDelegate.eventList objectAtIndex:i] isKindOfClass:[LocationItem class]])
            {
                NSLog(@"event annotation added ");
                LocationItem *anno = (LocationItem*) [smAppDelegate.eventList objectAtIndex:i];
                if ( CLLocationCoordinate2DIsValid(anno.coordinate)==TRUE) 
                {
                    [smAppDelegate.displayList removeObject:anno];
                }
            }
        }
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar 
{
    if ([theSearchBar isEqual:searchBar]) {
        [self searchAnnotations];
        [searchBar resignFirstResponder];
        return;
    }
}

@end

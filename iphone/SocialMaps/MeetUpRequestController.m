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

#define     kOFFSET_FOR_KEYBOARD    215
#define     TAG_TABLEVIEW_REPLY     1001
#define     TAG_TABLEVIEW_INBOX     1002


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

DDAnnotation *annotation;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    CustomRadioButton *radio = [[CustomRadioButton alloc] initWithFrame:CGRectMake(10, 93, self.view.frame.size.width - 20, 41) numButtons:4 labels:[NSArray arrayWithObjects:@"Current location",@"My places",@"Places near to me",@"Point on map",nil]  default:0 sender:self tag:2000];
    radio.delegate = self;
    [self.view addSubview:radio];
    
    NSArray *def    = [NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil];
    NSArray *layers = [NSArray arrayWithObjects:@"Send direction", nil];
    
    CustomCheckbox *chkBox = [[CustomCheckbox alloc] initWithFrame:CGRectMake(180, 313, 140, 20) boxLocType:LabelPositionRight numBoxes:1 default:def labels:layers];
    chkBox.tag = 1003;
    chkBox.backgroundColor = [UIColor clearColor];
    //chkBox.delegate = self;
    [self.view addSubview:chkBox];
    
    //friends list
    frndListScrollView.delegate = self;
    selectedFriendsIndex=[[NSMutableArray alloc] init];
    filteredList=[[NSMutableArray alloc] init];
    friendListArr=[[NSMutableArray alloc] init];
    dicImages_msg = [[NSMutableDictionary alloc] init];
    
    //set scroll view content size.
    [self loadDummydata];
    
    //reloading scrollview to start asynchronous download.
    [self reloadScrolview]; 
    
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //load map data
    CLLocationCoordinate2D theCoordinate;
	theCoordinate.latitude = [smAppDelegate.currPosition.latitude doubleValue];
    theCoordinate.longitude = [smAppDelegate.currPosition.longitude doubleValue];
	
	annotation = [[[DDAnnotation alloc] initWithCoordinate:theCoordinate addressDictionary:nil] autorelease];
    
	annotation.title = @"Drag to Move Pin";
	//annotation.subtitle = [NSString	stringWithFormat:@"Current Location"];
    //    NSLog(@"annotation.coordinate %@",annotation.coordinate);
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = annotation.coordinate.latitude;
    newRegion.center.longitude = annotation.coordinate.longitude;
    newRegion.span.latitudeDelta = 1.112872;
    newRegion.span.longitudeDelta = 1.109863;
    
    [pointOnMapView setRegion:newRegion animated:YES];
    
	[pointOnMapView setCenterCoordinate:annotation.coordinate];
    
	[pointOnMapView addAnnotation:annotation];
    
    //tableView setup
    tableViewPlaces.dataSource = self;
    tableViewPlaces.delegate = self;
}

- (void)viewDidUnload
{
    [pointOnMapView release];
    pointOnMapView = nil;
    [labelAddress release];
    labelAddress = nil;
    [tableViewPlaces release];
    tableViewPlaces = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)actionBackMe:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void) radioButtonClicked:(int)indx sender:(id)sender {
    NSLog(@"radioButtonClicked index = %d", indx);
    switch (indx) {
        case 3:
            tableViewPlaces.hidden = YES;
            break;
        case 2:
            tableViewPlaces.hidden = NO;
            break;
        case 1:
            tableViewPlaces.hidden = NO;
            break;
        default:
            break;
    }
}

// Tableview stuff
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"placeList Class %@", [[smAppDelegate.placeList objectAtIndex:indexPath.row] class]);
    LocationItemPlace *aPlaceItem = (LocationItemPlace*)[smAppDelegate.placeList objectAtIndex:indexPath.row];
    
    
    //CGSize senderStringSize = [msg.notifSender sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:kSmallLabelFontSize]];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"placeList"];
    
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"placeList"] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        UIButton *buttonSelectPlace = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonSelectPlace.frame = CGRectMake(320-21-20, 18-10, 21, 21);
        [buttonSelectPlace setImage:[UIImage imageNamed:@"location_bar_radio_cheked.png"] forState:UIControlStateSelected];
        [buttonSelectPlace setImage:[UIImage imageNamed:@"location_bar_radio.png"] forState:UIControlStateNormal];
        [buttonSelectPlace addTarget:self action:@selector(actionSelectPlaceButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.contentView addSubview:buttonSelectPlace];
        
        UILabel *labelPlaceName = [[UILabel alloc] initWithFrame:CGRectMake(10, 18 - 10, 265, 21)];
        labelPlaceName.tag = 1001;
        [cell.contentView addSubview:labelPlaceName];
    } 

    //cell.textLabel.text = aPlaceItem.placeInfo.name;
  
    UILabel *labelPlacename = (UILabel*)[cell.contentView viewWithTag:1001];
    labelPlacename.text = aPlaceItem.placeInfo.name;
    
    UIButton *selectBtn;

    for (UIView *eachView in [cell.contentView subviews]) {
        if ([eachView isKindOfClass:[UIButton class]]) {
            selectBtn = (UIButton*)eachView;
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
    
    //if (annotation == nil) {
    //    annotation = [[MyAnnotation alloc] init];
    //    annotation.title = @"Tap arrow to use address";
    //}
    
    //[annotation moveAnnotation:placemark.coordinate];
    //annotation.subtitle = placemark.formattedAddress;
    
    
    
    LocationItemPlace *aPlaceItem = (LocationItemPlace*)[smAppDelegate.placeList objectAtIndex:indexPath.row];
    labelAddress.text = aPlaceItem.placeInfo.name;
    //NSLog(@"aplaceItem.coordinate = %f %f", aPlaceItem.coordinate.latitude, aPlaceItem.coordinate.longitude);
    ////[pointOnMapView removeAnnotation:annotation];
    ////annotation=[[DDAnnotation alloc] initWithCoordinate:aPlaceItem.coordinate addressDictionary:nil];
    annotation.coordinate = aPlaceItem.coordinate;
    ////[pointOnMapView addAnnotation:annotation];
    //NSLog(@"annotation.coordinate = %f %f", annotation.coordinate.latitude, aPlaceItem.coordinate.longitude);

    
    CLLocationCoordinate2D theCoordinate;
	theCoordinate.latitude = annotation.coordinate.latitude;
    theCoordinate.longitude =annotation.coordinate.longitude;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(theCoordinate, 1000, 1000);
    MKCoordinateRegion adjustedRegion = [pointOnMapView regionThatFits:viewRegion];  
    [pointOnMapView setRegion:adjustedRegion animated:YES]; 

    //[pointOnMapView addAnnotation:annotation];
	[pointOnMapView setCenterCoordinate:annotation.coordinate];
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [smAppDelegate.placeList count];
}


- (void) actionSelectPlaceButton:(id)sender
{
    NSLog(@"place selected %d", [sender tag]);
  
    selectedPlaceIndex = [sender tag];
    [tableViewPlaces reloadData];
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

/*
 - (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
 {
 isDragging_msg = FALSE;
 }
 - (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
 {
 isDecliring_msg = FALSE;
 }
 */
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
    frndListScrollView.contentSize=CGSizeMake([filteredList count]*45, 45);
    
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

-(void)loadDummydata
{
//    circleList=[[NSMutableArray alloc] initWithObjects:@"Friends",@"Family",@"Collegue",@"Close Friends",@"Relatives", nil];
//    [circleList removeAllObjects];
//    UserCircle *circle=[[UserCircle alloc]init];
//    
//    for (int i=0; i<[circleListGlobalArray count]; i++)
//    {
//        circle=[circleListGlobalArray objectAtIndex:i];
//        [circleList addObject:circle.circleName];
//    }
    UserFriends *frnds=[[UserFriends alloc] init];
    /*
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
    */
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
}

#pragma mark -
#pragma mark DDAnnotationCoordinateDidChangeNotification

// NOTE: DDAnnotationCoordinateDidChangeNotification won't fire in iOS 4, use -mapView:annotationView:didChangeDragState:fromOldState: instead.
- (void)coordinateChanged_:(NSNotification *)notification
{	
	annotation = notification.object;
	//annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
    //annotation.subtitle=[UtilityClass getAddressFromLatLon:annotation.coordinate.latitude withLongitude:annotation.coordinate.longitude];
    
    labelAddress.text = [UtilityClass getAddressFromLatLon:annotation.coordinate.latitude withLongitude:annotation.coordinate.longitude];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState 
{
	
	if (oldState == MKAnnotationViewDragStateDragging) 
    {
		annotation = (DDAnnotation *)annotationView.annotation;
                //annotation.coordinate.latitude=[smAppDelegate.currPosition.latitude doubleValue];
                //annotation.coordinate.longitude=[smAppDelegate.currPosition.longitude doubleValue];
        
		//annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];		
        //annotation.subtitle=[UtilityClass getAddressFromLatLon:annotation.coordinate.latitude withLongitude:annotation.coordinate.longitude];
        labelAddress.text = [UtilityClass getAddressFromLatLon:annotation.coordinate.latitude withLongitude:annotation.coordinate.longitude];
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
    [super dealloc];
}
@end

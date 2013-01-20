//
//  PlaceListViewController.m
//  SocialMaps
//
//  Created by Warif Rishi on 11/3/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "PlaceListViewController.h"
#import "NotificationController.h"
#import <QuartzCore/QuartzCore.h>
#import "PlaceViewController.h"
#import "UIImageView+Cached.h"
#import "UtilityClass.h"
#import "AppDelegate.h"
#import "RestClient.h"
#import "Constants.h"
#import "Place.h"
#import "CachedImages.h"
#import "OverlayViewController.h"
#import "LocationItemPlace.h"


#define     CELL_HEIGHT                 130
#define     TAG_TABLEVIEW_PLACES_NEARBY 1001
#define     TAG_TABLEVIEW_MY_PLACES     1002


@implementation PlaceListViewController

@synthesize placeType;
@synthesize otherUserId;
@synthesize userName;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotPlaces:) name:NOTIF_GET_PLACES_DONE object:nil];
    
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    
    if (self.placeType == OtherPeople) {
        [restClient getOtherUserPlacesByUserId:self.otherUserId authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
        labelPlaces.textAlignment = UITextAlignmentLeft;
        labelPlaces.frame = CGRectMake(labelPlaces.frame.origin.x, labelPlaces.frame.origin.y, 200, labelPlaces.frame.size.height);
        labelPlaces.text = [NSString stringWithFormat:@"%@'s places", self.userName];
    }
    else {
        [restClient getPlaces:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
        [self showPlacesNearbyTab];
    }
    
    [smAppDelegate showActivityViewer:self.view];
    
    copyListOfItems = [[NSMutableArray alloc] init];
    
    labelPlaces.highlighted = YES;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self displayNotificationCount];    
    smAppDelegate.currentModelViewController = self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_PLACES_DONE object:nil];
    
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [tableViewPlaceList release];
    tableViewPlaceList = nil;
    [totalNotifCount release];
    totalNotifCount = nil;
    [viewSearch release];
    viewSearch = nil;
    [searchBar release];
    searchBar = nil;
    [labelNearToMe release];
    labelNearToMe = nil;
    [labelPlaces release];
    labelPlaces = nil;
    [buttonPlaces release];
    buttonPlaces = nil;
    [buttonNearToMe release];
    buttonNearToMe = nil;
    [imageViewDivider release];
    imageViewDivider = nil;
    [viewTabContainer release];
    viewTabContainer = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)showPlacesNearbyTab
{
    labelNearToMe.hidden = buttonPlaces.hidden = buttonNearToMe.hidden = imageViewDivider.hidden = NO;
}

-(void) displayNotificationCount 
{
    int totalNotif= [UtilityClass getNotificationCount];
    if (totalNotif == 0)
        totalNotifCount.text = @"";
    else
        totalNotifCount.text = [NSString stringWithFormat:@"%d",totalNotif];
}

- (CLLocationDistance) getDistanceFromMe:(CLLocationCoordinate2D) loc 
{
    CLLocation *myLoc = [[CLLocation alloc] initWithLatitude:[smAppDelegate.currPosition.latitude floatValue] longitude:[smAppDelegate.currPosition.longitude floatValue]];
    CLLocation *userLoc = [[CLLocation alloc] initWithCoordinate:loc altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:nil];
    CLLocationDistance distanceFromMe = [myLoc distanceFromLocation:userLoc];
    
    return distanceFromMe;
}

- (int) decideLabelHeight:(UITextView *) textView {
    int height = [textView contentSize].height;
    if (height > 70)
        return 70;
    else
        return height;
}

-(Place*)getPlaceFromLocationItemPlace:(LocationItemPlace*)aPlaceItem
{
    Place *place = [[Place alloc] init];
    place.name = aPlaceItem.itemName;
    place.address = aPlaceItem.itemAddress;
    place.photoURL = aPlaceItem.itemCoverPhotoUrl;
    place.latitude = [aPlaceItem.placeInfo.location.latitude floatValue];
    place.longitude = [aPlaceItem.placeInfo.location.longitude floatValue];
    return place;
}

- (Place*)getPlaceFromList:(int)row
{
    Place *place;
    
    if (tableViewPlaceList.tag == TAG_TABLEVIEW_PLACES_NEARBY) 
    {
        LocationItemPlace *aPlaceItem = (LocationItemPlace*)[smAppDelegate.placeList objectAtIndex:row];
        place = [self getPlaceFromLocationItemPlace:aPlaceItem];
    }
    else 
    {
        place = (Place*)[placeList objectAtIndex:row];
    }
    
    return place;
}

// Tableview stuff
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Place *place = [self getPlaceFromList:indexPath.row];

    if(searching) 
        place = (Place*)[copyListOfItems objectAtIndex:indexPath.row];
    
    CGSize addressStringSize = [place.address sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:kSmallLabelFontSize]];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"placeList"];
    
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"placeList"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //Thumb Image
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, CELL_HEIGHT)];
        imageView.tag = 3001;
        imageView.backgroundColor = [UIColor blackColor];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:imageView];
        [imageView release];
        
        UITextView *lblPlaceName = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 210, 70)];
        lblPlaceName.tag = 3002;
        [lblPlaceName.layer setCornerRadius:3.0f];
        [lblPlaceName.layer setMasksToBounds:YES];
        lblPlaceName.textAlignment = UITextAlignmentLeft;
        lblPlaceName.font = [UIFont fontWithName:@"Helvetica-Bold" size:kLargeLabelFontSize];
        lblPlaceName.textColor = [UIColor whiteColor];
        lblPlaceName.backgroundColor = [UIColor colorWithWhite:0 alpha:.4];
        lblPlaceName.editable = FALSE;
        [cell.contentView addSubview:lblPlaceName];
        
        [lblPlaceName release];
        
        UIButton *btnEdit = [UIButton buttonWithType:UIButtonTypeCustom];
        btnEdit.frame = CGRectMake(240, (CELL_HEIGHT - 30 - 25) / 2, 70, 30);
        btnEdit.backgroundColor  = [UIColor colorWithRed:119.0/255.0 green:184.0/255.0 blue:0.0 alpha:0.8];
        [btnEdit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnEdit.layer setCornerRadius:6.0f];
        [btnEdit.layer setMasksToBounds:YES];
        [btnEdit.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:kSmallLabelFontSize]];
        [btnEdit setTitle:@"Edit place" forState:UIControlStateNormal];
        [btnEdit addTarget:self action:@selector(actionEditPlace:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btnEdit];
        
        // Footer view
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(10, CELL_HEIGHT - 30, 300, 25)];
        footerView.tag = 3333;
        [footerView.layer setCornerRadius:6.0f];
        [footerView.layer setMasksToBounds:YES];
        footerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.6];
        [cell.contentView addSubview:footerView];
        
		// Address
        UIScrollView *scrollAddress = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 180, 25)];
        scrollAddress.tag = 3003;
        scrollAddress.backgroundColor = [UIColor clearColor];
        
		UILabel *lblAddress = [[[UILabel alloc] initWithFrame:CGRectMake(2, (scrollAddress.frame.size.height - 15) / 2, addressStringSize.width, addressStringSize.height)] autorelease];
		lblAddress.tag = 3004;
		lblAddress.font = [UIFont fontWithName:@"Helvetica-Bold" size:kSmallLabelFontSize];
		lblAddress.textColor = [UIColor whiteColor];
		lblAddress.backgroundColor = [UIColor clearColor];
        [scrollAddress addSubview:lblAddress];
		[footerView addSubview:scrollAddress];
        
        UIButton *btnMap = [UIButton buttonWithType:UIButtonTypeCustom];
        btnMap.frame = CGRectMake(203, 0, 25, 25);
        btnMap.backgroundColor = [UIColor clearColor];
        [btnMap setImage:[UIImage imageNamed:@"show_on_map.png"] forState:UIControlStateNormal];
        [btnMap addTarget:self action:@selector(showInMapview:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:btnMap];
        
		// Distance
		UILabel *lblDist = [[[UILabel alloc] initWithFrame:CGRectMake(228, (footerView.frame.size.height - 15) / 2, 70, 15)] autorelease];
		lblDist.tag = 3005;
        lblDist.textAlignment = UITextAlignmentRight;
        lblDist.textColor = [UIColor whiteColor];
		lblDist.font = [UIFont fontWithName:@"Helvetica-Bold" size:kSmallLabelFontSize];
		lblDist.textColor = [UIColor whiteColor];
		lblDist.backgroundColor = [UIColor clearColor];
		[footerView addSubview:lblDist];
            
        [scrollAddress release];                                                                
        [footerView release];
        
        // Line
        CGRect lineFrame = CGRectMake(0, CELL_HEIGHT - 3, 320, 2);
        UIView *line = [[UIView alloc] initWithFrame:lineFrame];
        line.tag = 3006;
        line.backgroundColor = [UIColor grayColor];
        [cell.contentView addSubview:line];
        [line release];
    }
    
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:3001];
    
    if (place.photo) {
        imageView.image = place.photo;
    } else {
        [imageView setImageForUrlIfAvailable:place.photoURL];
    }
    
    UITextView *placeNameTextView  = (UITextView*)[cell viewWithTag:3002];
    
    placeNameTextView.text = place.name;
    placeNameTextView.frame = CGRectMake(placeNameTextView.frame.origin.x, 
                                      placeNameTextView.frame.origin.y, 
                                      210, 
                                      [self decideLabelHeight:placeNameTextView]);
    
    UIScrollView *scrollViewAddress = (UIScrollView*)[cell viewWithTag:3003];
    scrollViewAddress.contentSize = addressStringSize;
    
    UILabel *labelAddress = (UILabel*)[cell viewWithTag:3004];
    labelAddress.frame = CGRectMake(labelAddress.frame.origin.x, labelAddress.frame.origin.y, addressStringSize.width, addressStringSize.height);
    labelAddress.text = place.address; 
    
    UILabel *labelDistance = (UILabel*)[cell viewWithTag:3005];
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = place.latitude;
    theCoordinate.longitude = place.longitude;
    float distance = [self getDistanceFromMe:theCoordinate];
    if (distance > 999)
        labelDistance.text = [NSString stringWithFormat:@"%.1fkm", distance/1000.0];
    else
        labelDistance.text = [NSString stringWithFormat:@"%dm", (int)distance];
    
    for (UIView *subView in [cell.contentView subviews]) {
        if ([subView isKindOfClass:[UIButton class]]) {
            subView.tag = indexPath.row;
            if (self.placeType == OtherPeople || tableView.tag == TAG_TABLEVIEW_PLACES_NEARBY)
                subView.hidden = YES;
            break;
        }
    }
    
    for (UIView *subView in [[cell.contentView viewWithTag:3333] subviews]) {
        if ([subView isKindOfClass:[UIButton class]]) {
            subView.tag = indexPath.row;
            break;
        }
    }

    

    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  
{   
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (searching) ? [copyListOfItems count] : (tableView.tag == TAG_TABLEVIEW_PLACES_NEARBY)  ? [smAppDelegate.placeList count] : [placeList count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return CELL_HEIGHT;
}

- (void)actionEditPlace:(id)sender
{
    NSLog(@"actionEditPlace tag = %d", [sender tag]);
    
    Place *place = [placeList objectAtIndex:[sender tag]]; 
    
    if(searching)
        place = (Place*)[copyListOfItems objectAtIndex:[sender tag]];
    
    PlaceViewController *controller = [[PlaceViewController alloc] initWithNibName:@"PlaceViewController" bundle:nil];
    
    NSArray *visiblePaths = [tableViewPlaceList indexPathsForVisibleRows];
    
     for (NSIndexPath *indexPath in visiblePaths) 
     {
         if (indexPath.row == [sender tag]) 
         {
             UITableViewCell *cell = [tableViewPlaceList cellForRowAtIndexPath:indexPath];
             UIImageView *imgCover = (UIImageView*) [cell viewWithTag:3001];
             place.photo = imgCover.image;
             break;
         }
     }
    
    controller.isEditingMode = TRUE;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
    [controller setAddressLabelFromLatLon:place];
    [controller release];

}

-(void) reloadTableView
{
    [tableViewPlaceList reloadData];
}

-(void)showInMapview:(id)sender 
{
    Place *place = [self getPlaceFromList:[sender tag]];
    
    if(searching) 
        place = (Place*)[copyListOfItems objectAtIndex:[sender tag]];
    
    smAppDelegate.needToCenterMap = FALSE;
    
    [self.presentingViewController performSelector:@selector(showPinOnMapView:) withObject:place afterDelay:.8];
    
    [self dismissModalViewControllerAnimated:NO];
}

// GCD async notifications
- (void)gotPlaces:(NSNotification *)notif 
{
    placeList = [notif object];

    NSLog(@"placeList = %@", placeList);
    [tableViewPlaceList reloadData];
    [smAppDelegate hideActivityViewer];
    [self loadImagesForOnscreenRows];
    if ([placeList count]==0)
    {
        [UtilityClass showAlert:@"" :@"No places found"];
    }
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"didReceiveMemoryWarining");
    [CachedImages removeAllCache];
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc 
{
    [copyListOfItems release];
    [tableViewPlaceList release];
    [totalNotifCount release];
    [viewSearch release];
    [searchBar release];
    [labelNearToMe release];
    [labelPlaces release];
    [buttonPlaces release];
    [buttonNearToMe release];
    [imageViewDivider release];
    [viewTabContainer release];
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

- (IBAction)actionOkSearchButton:(id)sender 
{
    [self searchBarSearchButtonClicked:searchBar];
}

- (IBAction)actionShowSearchBarButton:(id)sender 
{
    if (viewSearch.frame.origin.y > 44) {
        [self moveSearchBarAnimation:-44];
        [self doneSearching_Clicked:nil];
        
    } else {
        [self moveSearchBarAnimation:44];
        [searchBar becomeFirstResponder];
    }
}

- (void)closeSearchBarIfOpen
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    searching = NO;
    tableViewPlaceList.scrollEnabled = YES;
    [ovController.view removeFromSuperview];
    [ovController release];
    ovController = nil;
    if (viewSearch.frame.origin.y > 44)
        [self moveSearchBarAnimation:-44];
}

- (IBAction)actionPlacesButton:(id)sender 
{
    [self closeSearchBarIfOpen];
    tableViewPlaceList.tag = TAG_TABLEVIEW_MY_PLACES;
    [tableViewPlaceList reloadData];
    labelPlaces.highlighted = YES;
    labelNearToMe.highlighted = NO;
}

- (IBAction)actionNearToMeButton:(id)sender 
{
    [self closeSearchBarIfOpen];
    tableViewPlaceList.tag = TAG_TABLEVIEW_PLACES_NEARBY;
    [tableViewPlaceList reloadData];
    [self loadImagesForOnscreenRows];
    labelPlaces.highlighted = NO;
    labelNearToMe.highlighted = YES;
}

- (void)loadImagesForOnscreenRows {
    
    if ([placeList count] > 0 || tableViewPlaceList.tag == TAG_TABLEVIEW_PLACES_NEARBY) {
        
        NSArray *visiblePaths = [tableViewPlaceList indexPathsForVisibleRows];
        
        for (NSIndexPath *indexPath in visiblePaths) {
            
            UITableViewCell *cell = [tableViewPlaceList cellForRowAtIndexPath:indexPath];
            
            //get the imageView on cell
            
            UIImageView *imgCover = (UIImageView*) [cell viewWithTag:3001];
            
            Place *place = [self getPlaceFromList:indexPath.row];
            
            if(searching) 
                place = (Place*)[copyListOfItems objectAtIndex:indexPath.row];
            
            if (!place.photo) 
                [imgCover loadFromURL:place.photoURL];
            
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (!decelerate) 
        [self loadImagesForOnscreenRows];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self loadImagesForOnscreenRows];
    
}

#pragma mark -
#pragma mark Search Bar 

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
	
	//This method is called again when the user clicks back from teh detail view.
	//So the overlay is displayed on the results, which is something we do not want to happen.
	if(searching)
		return;
	
    if (tableViewPlaceList.dragging) 
        return;
    
	//Add the overlay view.
	if(ovController == nil)
		ovController = [[OverlayViewController alloc] initWithNibName:@"OverlayView" bundle:[NSBundle mainBundle]];
	
	CGFloat yaxis = 87;//self.navigationController.navigationBar.frame.size.height;
	CGFloat width = self.view.frame.size.width;
	CGFloat height = self.view.frame.size.height;
	
	//Parameters x = origion on x-axis, y = origon on y-axis.
	CGRect frame = CGRectMake(0, yaxis, width, height);
	ovController.view.frame = frame;	
	ovController.view.backgroundColor = [UIColor grayColor];
	ovController.view.alpha = 0.5;
	
	ovController.rvController = self;
	
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	
    [searchBar resignFirstResponder];
    
    if([searchBar.text length] > 0) {
		
		[ovController.view removeFromSuperview];
		searching = YES;
		
		tableViewPlaceList.scrollEnabled = YES;
		[self searchTableView];
	}
	else {
		
		searching = NO;
        
	}
	
	[tableViewPlaceList reloadData];
}

- (void) searchTableView 
{
	NSString *searchText = searchBar.text;
    
    [copyListOfItems removeAllObjects];
    
    if (tableViewPlaceList.tag == TAG_TABLEVIEW_PLACES_NEARBY) 
    {
        for (LocationItemPlace *place in smAppDelegate.placeList)
        {
            NSRange titleResultsRange = [place.itemName rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            if (titleResultsRange.length > 0)
                [copyListOfItems addObject:[self getPlaceFromLocationItemPlace:place]];
        }
    } 
    else 
    {
        for (Place *place in placeList)
        {
            NSRange titleResultsRange = [place.name rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            if (titleResultsRange.length > 0)
                [copyListOfItems addObject:place];
        }
    }
	
}

-(void)moveSearchBarAnimation:(int)moveby
{
    if (moveby > 0) {
        tableViewPlaceList.contentInset = UIEdgeInsetsMake(43,0.0,0,0.0);
    } else {
        tableViewPlaceList.contentInset = UIEdgeInsetsMake(0,0.0,0,0.0);
    }
    
    CGRect viewFrame = viewSearch.frame;
    viewFrame.origin.y += moveby;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];    
    [viewSearch setFrame:viewFrame]; 
    viewTabContainer.frame = CGRectMake(0, viewTabContainer.frame.origin.y + moveby, 320, viewTabContainer.frame.size.height);
    [UIView commitAnimations];    
}

- (void) doneSearching_Clicked:(id)sender {
	
	searchBar.text = @"";
	[searchBar resignFirstResponder];
	
	searching = NO;
    
	tableViewPlaceList.scrollEnabled = YES;
	
	[ovController.view removeFromSuperview];
	[ovController release];
	ovController = nil;
	
	[tableViewPlaceList reloadData];
    
    if (sender) {
        [self actionShowSearchBarButton:nil];
    }
}

-(void) deletePlace:(Place*)place
{
    int index = [placeList indexOfObject:place];
    [placeList removeObject:place];
    [tableViewPlaceList deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:YES];
}

@end

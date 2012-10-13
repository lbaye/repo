//
//  ListViewController.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/13/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "ListViewController.h"
#import "LocationItemPeople.h"
#import "LocationItemPlace.h"
#import "AppDelegate.h"
#import "NotificationController.h"
#import "UtilityClass.h"
#import "UserBasicProfileViewController.h"
#import "OverlayViewController.h"
#import "MessageListViewController.h"
#import "MeetUpRequestController.h"
#import "ViewEventListViewController.h"

@implementation ListViewController
@synthesize listPullupMenu;
@synthesize listPulldownMenu;
@synthesize listViewfilter;
@synthesize listView;
@synthesize listPulldown;
@synthesize itemList;
@synthesize listNotifCount;
@synthesize selectedType;
@synthesize selectedItemIndex;
@synthesize smAppDelegate;
@synthesize totalNotifCount;
@synthesize circleView;

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{

}*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [circleView removeFromSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [circleView removeFromSuperview];
    [self displayNotificationCount];
    listPulldownMenu.backgroundColor = [UIColor clearColor];
    listPullupMenu.backgroundColor   = [UIColor clearColor];
    
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *lblStr = [NSString stringWithString:@"Show in list:"];
    CGSize   strSize = [lblStr sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0f]];
    
    CGRect labelFrame = CGRectMake(2, (listViewfilter.frame.size.height-strSize.height)/2, strSize.width, strSize.height);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.text = @"Show in list:";
    label.font = [UIFont fontWithName:@"Helvetica" size:14.0f];
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    [listViewfilter addSubview:label];
    
    CGRect filterFrame = CGRectMake(4+labelFrame.size.width, 0, listViewfilter.frame.size.width-labelFrame.size.width-4, listViewfilter.frame.size.height);
//    CustomCheckbox *chkBox = [[CustomCheckbox alloc] initWithFrame:filterFrame boxLocType:LabelPositionRight numBoxes:3 default:[NSArray arrayWithObjects:[NSNumber numberWithInt:smAppDelegate.showPeople],[NSNumber numberWithInt:smAppDelegate.showPlaces],[NSNumber numberWithInt:smAppDelegate.showDeals], nil] labels:[NSArray arrayWithObjects:@"People",@"Places",@"Deals", nil]];
    CustomCheckbox *chkBox = [[CustomCheckbox alloc] initWithFrame:filterFrame boxLocType:LabelPositionRight numBoxes:2 default:[NSArray arrayWithObjects:[NSNumber numberWithInt:smAppDelegate.showPeople],[NSNumber numberWithInt:smAppDelegate.showPlaces], nil] labels:[NSArray arrayWithObjects:@"People",@"Places", nil]];
    chkBox.delegate = self;
    [listViewfilter addSubview:chkBox];
    [chkBox release];
    
    itemList.delegate = self;
    itemList.dataSource = self;
    [self.view sendSubviewToBack:listView];
    
    copyListOfItems = [[NSMutableArray alloc] init];

    [self initPullView];
    
    CGSize labelSize = CGSizeMake(70, 20); 
    UILabel *labelRefresh = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - labelSize.width) / 2, -labelSize.height - 10, labelSize.width, labelSize.height)];
    labelRefresh.text = @"Refresh...";
    labelRefresh.textAlignment = UITextAlignmentCenter;
    labelRefresh.textColor = [UIColor whiteColor];
    [labelRefresh setFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize]];
    labelRefresh.backgroundColor= [UIColor clearColor];
    [itemList addSubview:labelRefresh];
    [labelRefresh release];
    
    copyDisplayListArray = [[NSMutableArray alloc] init];
    [copyDisplayListArray addObjectsFromArray:smAppDelegate.displayList];
    
    //copyDisplayListArray = [smAppDelegate.displayList mutableCopy];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < -30 && ![[[self.view subviews] lastObject] isKindOfClass:[UIActivityIndicatorView class]]) {
        NSLog(@"At the top");
        [smAppDelegate showActivityViewer:self.view];
        [smAppDelegate performSelector:@selector(hideActivityViewer) withObject:nil afterDelay:1];
        [self getSortedDisplayList];
        [itemList reloadData];
    }
}

-(void)initPullView
{
    //listPullupMenu.hidden = YES;
    
    CGFloat xOffset = 0;
    PullableView *pullUpView = [[PullableView alloc] initWithFrame:CGRectMake(xOffset, 0, 320, 60)];
    pullUpView.openedCenter = CGPointMake(160 + xOffset,self.view.frame.size.height - 30);
    pullUpView.closedCenter = CGPointMake(160 + xOffset, self.view.frame.size.height);
    pullUpView.center = pullUpView.closedCenter;
    pullUpView.handleView.frame = CGRectMake(0, 0, 320, 40);
    pullUpView.delegate = self;
    //pullUpView.backgroundColor = [UIColor blueColor];
    
    [pullUpView addSubview:listPullupMenu];
    listPullupMenu.userInteractionEnabled = NO;
    for (UIView *view in [listPullupMenu subviews]) {
        if ([view isKindOfClass:[UIButton class]]) {
            [pullUpView addSubview:view];
        }
    }
    
    listPullupMenu.hidden = NO;
    listPullupMenu.frame = CGRectMake(0, 0, listPullupMenu.frame.size.width, listPullupMenu.frame.size.height);
    [self.view addSubview:pullUpView];
    [self.view bringSubviewToFront:pullUpView];
    
    UIImageView *imageViewFooterSliderOpen = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
    imageViewFooterSliderOpen.image = [UIImage imageNamed:@"btn_footer_slider_open.png"];
    [pullUpView.handleView addSubview:imageViewFooterSliderOpen];
    [pullUpView bringSubviewToFront:pullUpView.handleView];
    imageViewFooterSliderOpen.tag = 420;    
    [imageViewFooterSliderOpen release];
    
    pullDownView = [[PullableView alloc] initWithFrame:CGRectMake(xOffset, 0, 320, 70)];
    pullDownView.openedCenter = CGPointMake(160 + xOffset, 80);
    pullDownView.closedCenter = CGPointMake(160 + xOffset, 35);
    pullDownView.center = pullDownView.closedCenter;
    
    pullDownView.handleView.frame = CGRectMake(0, pullDownView.frame.size.height - 25, 320, 25);
    pullDownView.delegate = self;
    //pullDownView.handleView.backgroundColor = [UIColor yellowColor];
    
    //pullDownView.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:pullDownView];
    [self.view bringSubviewToFront:viewSearch];
    [pullDownView addSubview:listPulldownMenu];
    [self.view bringSubviewToFront:viewNotification];
    listPulldownMenu.userInteractionEnabled = NO;
    for (UIView *view in [listPulldownMenu subviews]) {
        //if ([view isKindOfClass:[UIButton class]]) {
        [pullDownView addSubview:view];
        //}
    }
    listPulldownMenu.hidden = NO;
    listPulldownMenu.frame = CGRectMake(0, 0, listPulldownMenu.frame.size.width, listPulldownMenu.frame.size.height);
    
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
        NSLog(@"Now I'm open!");
        ((UIImageView*)[pView.handleView viewWithTag:420]).image = [UIImage imageNamed:@"btn_footer_slider_close.png"];
        ((UIImageView*)[pView.handleView viewWithTag:840]).image = nil;
    }
    else
    {
        ((UIImageView*)[pView.handleView viewWithTag:420]).image = [UIImage imageNamed:@"btn_footer_slider_open.png"];
        ((UIImageView*)[pView.handleView viewWithTag:840]).image = [UIImage imageNamed:@"slide_close_bar.png"];
        
        NSLog(@"Now I'm closed, pull me up again!");
    }
}

- (void) getSortedDisplayList {
    [copyDisplayListArray removeAllObjects];
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
    [copyDisplayListArray addObjectsFromArray:sortedArray];
    //copyListOfItems = [sortedArray mutableCopy];
    [smAppDelegate.displayList addObjectsFromArray:copyDisplayListArray];
    
}

- (void)viewDidUnload
{
    [self setListPullupMenu:nil];
    [self setListPulldownMenu:nil];
    [self setListViewfilter:nil];
    [self setListView:nil];
    [self setListPulldown:nil];
    [self setItemList:nil];
    [self setListNotifCount:nil];
    [searchBar release];
    searchBar = nil;
    [viewSearch release];
    viewSearch = nil;
    [viewNotification release];
    viewNotification = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"segueShowDetailAnno"]) {
        //[self dismissModalViewControllerAnimated:YES];
        [self backToMapview:nil];
        [[segue destinationViewController] performSelector:@selector(showAnnotationDetailView:) withObject:(LocationItem*)sender];
        //[self dismissModalViewControllerAnimated:YES];
    }
    
    //NSLog(@"In prepareForSegue:ListViewController");
    //NSLog(@"segue destinationViewController = %@", [segue destinationViewController]);
    
    //LocationItem *locItem = (LocationItem*)[smAppDelegate.displayList objectAtIndex:0];
    //[self showAnnotationDetailView:locItem];
    
}

-(IBAction)gotoProfile:(id)sender
{
//    UserBasicProfileViewController *controller =[[UserBasicProfileViewController alloc] init];
//    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    [self presentModalViewController:controller animated:YES];
    [self.view addSubview:circleView];
}

- (IBAction)backToMapview:(id)sender {
    [self removeFromParentViewController];
    
}

- (IBAction)closePullup:(id)sender {
    listPullupMenu.hidden = TRUE;
}

- (IBAction)closePulldown:(id)sender {
    listPulldownMenu.hidden = TRUE;
}

- (IBAction)showPullUpMenu:(id)sender {
    listPullupMenu.hidden = FALSE;
}

- (IBAction)showPulldownMenu:(id)sender {
    listPulldownMenu.hidden = FALSE;
}

- (IBAction)goToNotifications:(id)sender {
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


- (IBAction)gotoEvents:(id)sender 
{
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    ViewEventListViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"viewEventList"];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
    [smAppDelegate showActivityViewer:self.view];
}

- (IBAction)gotoMessages:(id)sender
{
    NSLog(@"actionTestMessageBtn");
    
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    MessageListViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"messageList"];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
    [self presentModalViewController:nav animated:YES];
    nav.navigationBarHidden = YES;
    
}

- (IBAction)gotoUserBasicProfile:(id)sender
{
    UserBasicProfileViewController *prof=[[UserBasicProfileViewController alloc] init];
    prof.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:prof animated:YES];
}

-(IBAction)gotoSettings:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];   
    UIViewController* initialHelpView = [storyboard instantiateViewControllerWithIdentifier:@"settingsController"];
    
    initialHelpView.modalPresentationStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:initialHelpView animated:YES];
}

- (IBAction)gotoMeetupReq:(id)sender
{
    MeetUpRequestController *controller = [[MeetUpRequestController alloc] initWithNibName:@"MeetUpRequestController" bundle:nil];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

- (IBAction)gotoCircles:(id)sender
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

-(IBAction)removeCircleView:(id)sender
{
    [circleView removeFromSuperview];
}

-(IBAction)gotoPlace:(id)sender
{
    [UtilityClass showAlert:@"Social Maps" :@"This feature is coming soon."];
}

-(IBAction)gotoFriends:(id)sender
{
    [UtilityClass showAlert:@"Social Maps" :@"This feature is coming soon."];    
}

-(IBAction)gotonNewsFeed:(id)sende
{
    [UtilityClass showAlert:@"Social Maps" :@"This feature is coming soon."];    
}

-(IBAction)gotonDeals:(id)sender
{
    [UtilityClass showAlert:@"Social Maps" :@"This feature is coming soon."];    
}

- (void)dealloc {
    [listPullupMenu release];
    [listPulldownMenu release];
    [listViewfilter release];
    [ovController release];
    [listView release];
    [listPulldown release];
    [itemList release];
    [listNotifCount release];
    [searchBar release];
    [viewSearch release];
    [viewNotification release];
    [super dealloc];
}

// Tableview stuff
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSLog(@"IndexPath:%d,%d",indexPath.section,indexPath.row);
    LocationItem *anItem = (LocationItem*)[copyDisplayListArray objectAtIndex:indexPath.row];
    if(searching) 
		anItem = (LocationItem *)[copyListOfItems objectAtIndex:indexPath.row];
    anItem.delegate = self;
    UITableViewCell * cell = [anItem getTableViewCell:tv sender:self];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
	selectedItemIndex = indexPath.section;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (searching) ? [copyListOfItems count] :[copyDisplayListArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"IndexPath:%d,%d",indexPath.section,indexPath.row);
    LocationItem *anItem = (LocationItem*)[copyDisplayListArray objectAtIndex:indexPath.row];
    return [anItem getRowHeight:tableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 0;
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
}

-(UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    return [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
}

- (void) checkboxClicked:(int)btnNum withState:(int) newState sender:(id) sender 
{
    NSLog(@"ListViewController: checkboxClicked btn:%d state:%d", btnNum, newState);
    switch (btnNum) {
        case 0:
            if (newState == 0)
                smAppDelegate.showPeople = FALSE;
            else
                smAppDelegate.showPeople = TRUE;
            break;
        case 1:
            if (newState == 0)
                smAppDelegate.showPlaces = FALSE;
            else
                smAppDelegate.showPlaces = TRUE;
            break;
        case 2:
            if (newState == 0)
                smAppDelegate.showDeals = FALSE;
            else
                smAppDelegate.showDeals = TRUE;
            break;
        default:
            break;
    }
    [self getSortedDisplayList];
    if (viewSearch.frame.origin.y > 44) {
        [self searchTableView];
    }
    [itemList reloadData];
}

// LocationItem delegate
- (void) buttonClicked:(LOCATION_ACTION_TYPE) action row:(int)row {
    LocationItem *anItem = (LocationItem*) [copyDisplayListArray objectAtIndex:row];
    NSLog(@"ListviewController: %d, row=%d name=%@", action, row, anItem.itemName);
    //ShowOnMapController *controller;
    switch (action) {
        case LocationActionTypeGotoMap:
            
            NSLog(@"cordinate %f %f", anItem.coordinate.longitude, anItem.coordinate.latitude);
            
            //controller = [[ShowOnMapController alloc] initWithNibName:@"ShowOnMapController" bundle:nil andLocation:anItem.coordinate];
            //controller.modalTransitionStyle = UIModalTransitionStylePartialCurl;
            //[self presentModalViewController:controller animated:YES];
            //[controller release];
            
            LocationItem *locItem = (LocationItem*)[copyDisplayListArray objectAtIndex:row];
            if(searching)
                locItem = (LocationItem*)[copyListOfItems objectAtIndex:row];
            smAppDelegate.needToCenterMap = FALSE;
            [self performSegueWithIdentifier:@"segueShowDetailAnno" sender:locItem];
            
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark Search Bar 

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
	
	//This method is called again when the user clicks back from teh detail view.
	//So the overlay is displayed on the results, which is something we do not want to happen.
	if(searching)
		return;
	
    if (itemList.dragging) {
        return;
    }
    
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
	
	//////////////[self.view insertSubview:ovController.view aboveSubview:itemList];
	
	//searching = YES;
	/////////letUserSelectRow = NO;
	////////itemList.scrollEnabled = NO;
	
    /*
	self.navigationItem.rightBarButtonItem	= [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneSearching_Clicked:)] autorelease];
	self.navigationItem.leftBarButtonItem.enabled = NO;
    */
}
/*
- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
	
	//Remove all objects first.
	//[copyListOfItems removeAllObjects];
	
	if([searchText length] > 0) {
		
		[ovController.view removeFromSuperview];
		searching = YES;
		letUserSelectRow = YES;
		itemList.scrollEnabled = YES;
		[self searchTableView];
	}
	else {
		
		//////[self.view insertSubview:ovController.view aboveSubview:itemList];
		
		searching = NO;
		/////////letUserSelectRow = NO;
		/////////itemList.scrollEnabled = NO;
	}
	
	[itemList reloadData];
}
*/
- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	
    [searchBar resignFirstResponder];
    
    if([searchBar.text length] > 0) {
		
		[ovController.view removeFromSuperview];
		searching = YES;
		letUserSelectRow = YES;
		itemList.scrollEnabled = YES;
		[self searchTableView];
	}
	else {
		
		//////[self.view insertSubview:ovController.view aboveSubview:itemList];
		
		searching = NO;
		/////////letUserSelectRow = NO;
		/////////itemList.scrollEnabled = NO;
	}
	
	[itemList reloadData];
}

- (void) searchTableView 
{
	NSString *searchText = searchBar.text;
    /*
    if ([searchText isEqualToString:@""]) {
        return;
    }
    */
    [copyListOfItems removeAllObjects];
	for (LocationItem *sTemp in copyDisplayListArray)
	{
		LocationItem *info = (LocationItem*)sTemp;
		NSRange titleResultsRange = [info.itemName rangeOfString:searchText options:NSCaseInsensitiveSearch];
		
		if (titleResultsRange.length > 0)
			[copyListOfItems addObject:sTemp];
	}
}

-(void)moveSearchBarAnimation:(int)moveby
{
    if (moveby > 0) {
        itemList.contentInset = UIEdgeInsetsMake(43,0.0,0,0.0);
    } else {
        itemList.contentInset = UIEdgeInsetsMake(0,0.0,0,0.0);
    }
    
    //itemList.contentOffset = CGPointZero;
    CGRect viewFrame = viewSearch.frame;
    viewFrame.origin.y += moveby;
    CGRect listPullDownFrame = pullDownView.frame;
    listPullDownFrame.origin.y += moveby;
    //CGRect listPullDownMenuFrame = listPulldownMenu.frame;
    //listPullDownMenuFrame.origin.y += moveby;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];    
    [viewSearch setFrame:viewFrame];  
    //[listPulldown setFrame:listPullDownFrame]; 
    //[listPulldownMenu setFrame:listPullDownMenuFrame]; 
    [pullDownView setFrame:listPullDownFrame];
    [UIView commitAnimations];    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)theSearchBar
{
    //[self doneSearching_Clicked:nil];
    [self actionSearchButton:nil];
}

- (void) doneSearching_Clicked:(id)sender {
	
	searchBar.text = @"";
	[searchBar resignFirstResponder];
	
	letUserSelectRow = YES;
	searching = NO;
    /*
	self.navigationItem.rightBarButtonItem	= [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionCreateNewFolder:)] autorelease];
	self.navigationItem.leftBarButtonItem.enabled = YES;
     */
	itemList.scrollEnabled = YES;
	
	[ovController.view removeFromSuperview];
	[ovController release];
	ovController = nil;
	
	[itemList reloadData];
    
    if (sender) {
        [self actionSearchButton:nil];
    }

}

- (IBAction)actionSearchButton:(id)sender {
    if (viewSearch.frame.origin.y > 44) {
        [self moveSearchBarAnimation:-44];
        [self doneSearching_Clicked:nil];
        pullDownView.openedCenter = CGPointMake(160, 80);
        pullDownView.closedCenter = CGPointMake(160, 35);
    } else {
        [self moveSearchBarAnimation:44];
        //listPulldownMenu.hidden = TRUE;
        [searchBar becomeFirstResponder];
        pullDownView.openedCenter = CGPointMake(160, 80 + 44);
        pullDownView.closedCenter = CGPointMake(160, 80);
    }
    
}

- (IBAction)actionSearchOkButton:(id)sender {
    [self searchBarSearchButtonClicked:searchBar];
}

@end

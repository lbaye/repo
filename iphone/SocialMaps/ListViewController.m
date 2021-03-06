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
#import "Event.h"
#import "FriendsProfileViewController.h"
#import "Geotag.h"
#import "PlaceListViewController.h"
#import "UIImageView+Cached.h"
#import "CachedImages.h"
#import "NewsFeedViewController.h"
#import "FriendListViewController.h"
#import "Globals.h"
#import "ODRefreshControl.h"
#import "RestClient.h"

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
@synthesize mapViewImg,listViewImg;
@synthesize searchListViewController;

PullableView *pullUpView;

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
    [CachedImages removeAllCache];
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [circleView removeFromSuperview];
    listPulldownMenu.backgroundColor = [UIColor clearColor];
    listPullupMenu.backgroundColor   = [UIColor clearColor];
    
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    searchListViewController.delegate = self;
    
    NSString *lblStr = @"Show in list:";
    CGSize   strSize = [lblStr sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0f]];
    
    CGRect labelFrame = CGRectMake(10, 45, strSize.width, strSize.height);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.text = @"Show in list:";
    label.font = [UIFont fontWithName:@"Helvetica" size:14.0f];
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    [listViewfilter addSubview:label];
    [label release];
    
    CGRect filterFrame = CGRectMake(4+labelFrame.size.width, 25, listViewfilter.frame.size.width-labelFrame.size.width-4, listViewfilter.frame.size.height / 2);
    CustomCheckbox *chkBox = [[CustomCheckbox alloc] initWithFrame:filterFrame boxLocType:LabelPositionRight numBoxes:3 default:[NSArray arrayWithObjects:[NSNumber numberWithInt:smAppDelegate.showPeople],[NSNumber numberWithInt:smAppDelegate.showPlaces],[NSNumber numberWithInt:smAppDelegate.showEvents], nil] labels:[NSArray arrayWithObjects:@"People",@"Places",@"Events", nil]];
    chkBox.delegate = self;
    [listViewfilter addSubview:chkBox];
    [chkBox release];
    
    CustomRadioButton *peopleFilter = [[CustomRadioButton alloc] initWithFrame:CGRectMake(5, 70, (310 - 30) / 2, 41) numButtons:2 labels:[NSArray arrayWithObjects:@"All users",@"Friends only",nil]  default:!smAppDelegate.showAllUsers sender:self tag:3000];
    peopleFilter.delegate = self;
    [listViewfilter addSubview:peopleFilter];
    
    CustomRadioButton *onlineFilter = [[CustomRadioButton alloc] initWithFrame:CGRectMake(5 + (310 - 30) / 2 + 20, 70, (310 - 30) / 2, 41) numButtons:2 labels:[NSArray arrayWithObjects:@"Show offline",@"Online only",nil]  default:!smAppDelegate.showOffline sender:self tag:4000];
    onlineFilter.delegate = self;
    [listViewfilter addSubview:onlineFilter];
    
    itemList.delegate = self;
    itemList.dataSource = self;
    [self.view sendSubviewToBack:listView];
    
    copyListOfItems = [[NSMutableArray alloc] init];

    [self initPullView];
    
    CGSize labelSize = CGSizeMake(90, 20); 
    UILabel *labelRefresh = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - labelSize.width) / 2, -labelSize.height - 10, labelSize.width, labelSize.height)];
    labelRefresh.text = @"Reloading...";
    labelRefresh.textAlignment = UITextAlignmentCenter;
    labelRefresh.textColor = [UIColor whiteColor];
    [labelRefresh setFont:[UIFont fontWithName:@"Helvetica" size:kMediumLabelFontSize]];
    labelRefresh.backgroundColor= [UIColor clearColor];
    [itemList addSubview:labelRefresh];
    [labelRefresh release];
    
    copyDisplayListArray = [[NSMutableArray alloc] init];
    [copyDisplayListArray addObjectsFromArray:smAppDelegate.displayList];
    [self getSortedDisplayList];
    
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.itemList];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    [refreshControl release];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadImagesForOnscreenRows];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSearchResultDone:) name:GET_SEARCH_RESULT_DONE object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    smAppDelegate.currentModelViewController = self;
    [self displayNotificationCount];
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    [self getSortedDisplayList];
    [itemList reloadData];
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [refreshControl endRefreshing];
    });
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
    
    pullDownView = [[PullableView alloc] initWithFrame:CGRectMake(xOffset, 0, 320, 140)];
    pullDownView.openedCenter = CGPointMake(160 + xOffset, 80);
    pullDownView.closedCenter = CGPointMake(160 + xOffset, 0);
    pullDownView.center = pullDownView.closedCenter;
    
    pullDownView.handleView.frame = CGRectMake(0, pullDownView.frame.size.height - 25, 320, 25);
    pullDownView.delegate = self;
    
    [self.view addSubview:pullDownView];
    [self.view bringSubviewToFront:viewSearch];
    [pullDownView addSubview:listPulldownMenu];
    [self.view bringSubviewToFront:viewNotification];
    listPulldownMenu.userInteractionEnabled = NO;
    for (UIView *view in [listPulldownMenu subviews]) {
        [pullDownView addSubview:view];
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

- (void)pullableView:(PullableView *)pView didChangeState:(BOOL)opened 
{
    if (opened) {
        ((UIImageView*)[pView.handleView viewWithTag:420]).image = [UIImage imageNamed:@"btn_footer_slider_close.png"];
        ((UIImageView*)[pView.handleView viewWithTag:840]).image = nil;
    } else {
        ((UIImageView*)[pView.handleView viewWithTag:420]).image = [UIImage imageNamed:@"btn_footer_slider_open.png"];
        ((UIImageView*)[pView.handleView viewWithTag:840]).image = [UIImage imageNamed:@"slide_close_bar.png"];
    }
}

- (void) getSortedDisplayList {
    [copyDisplayListArray removeAllObjects];
    [smAppDelegate.displayList removeAllObjects];
    NSMutableArray *tempList = [[NSMutableArray alloc] init];
    if (smAppDelegate.showPeople == TRUE) {
        [tempList addObjectsFromArray:smAppDelegate.peopleList];
        
        // Check to see if we are showing all users or friends only. Also, check for online/offline setting
        if (smAppDelegate.showOffline == FALSE || smAppDelegate.showAllUsers == FALSE) {
            // Build items to discard
            for (LocationItemPeople *aPerson in smAppDelegate.peopleList) {
                if ((!aPerson.userInfo.isFriend && smAppDelegate.showAllUsers ==FALSE) ||
                    (!aPerson.userInfo.isOnline && smAppDelegate.showOffline  == FALSE)) {
                    [tempList removeObject:aPerson];
                }
            }
        }
    }
    if (smAppDelegate.showPlaces == TRUE) 
    {
        [tempList addObjectsFromArray:smAppDelegate.placeList];
        for (int i=0; i<[smAppDelegate.geotagList count]; i++)
        {
            if ([[smAppDelegate.geotagList objectAtIndex:i] isKindOfClass:[Geotag class]])
            {
                Geotag *aGeotag=[smAppDelegate.geotagList objectAtIndex:i];
                LocationItem *item=[[LocationItem alloc] init];
                item.itemName=aGeotag.geoTagTitle;
                item.itemType=4;
                item.coordinate=CLLocationCoordinate2DMake([aGeotag.geoTagLocation.latitude doubleValue], [aGeotag.geoTagLocation.longitude doubleValue]);
                item.itemDistance=[UtilityClass getDistanceWithoutFormattingFromLocation:aGeotag.geoTagLocation];
                item.itemIcon=[UIImage imageNamed:@"sm_icon.png.png"];
                item.itemBg=[UIImage imageNamed:@"cover_pic_default.png"];
                item.currDisplayState=0;
                item.itemCategory=[NSString stringWithFormat:@"%@ %@",aGeotag.ownerLastName,aGeotag.ownerFirstName];;
                item.itemAddress=[NSString stringWithFormat:@"at %@",aGeotag.geoTagAddress] ;
                [smAppDelegate.geotagList replaceObjectAtIndex:i withObject:item];
                [item release];
            }
        }
        [tempList addObjectsFromArray:smAppDelegate.geotagList];
    }   
    if (smAppDelegate.showEvents == TRUE) 
    {
        NSLog(@"smAppDelegate.eventList %@",smAppDelegate.eventList);
        for (int i=0; i<[smAppDelegate.eventList count]; i++)
        {
            if ([[smAppDelegate.eventList objectAtIndex:i] isKindOfClass:[Event class]])
            {
                Event *aEvent=[smAppDelegate.eventList objectAtIndex:i];
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
                [item release];
            }
        }

        [tempList addObjectsFromArray:smAppDelegate.eventList];
    }
    // Sort by distance
    NSArray *sortedArray = [tempList sortedArrayUsingSelector:@selector(compareDistance:)];
    [copyDisplayListArray addObjectsFromArray:sortedArray];
    [smAppDelegate.displayList addObjectsFromArray:copyDisplayListArray];
    [tempList release];
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
        [self backToMapview:nil];
        [[segue destinationViewController] performSelector:@selector(showAnnotationDetailView:) withObject:(LocationItem*)sender];
    }
}

-(IBAction)gotoProfile:(id)sender
{
    [pullUpView setOpened:FALSE animated:TRUE];
    [self.view addSubview:circleView];
}

- (IBAction)backToMapview:(id)sender {
    [mapViewImg setImage:[UIImage imageNamed:@"map_view_icon.png"]];
    [self performSelector:@selector(loadPrevImage) withObject:nil afterDelay:0.2];
    [self dismissModalViewControllerAnimated:YES];
    
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
    profileFromList=TRUE;
    UserBasicProfileViewController *prof=[[UserBasicProfileViewController alloc] init];
    prof.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:prof animated:YES];
    [prof release];
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
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"CirclesStoryboard" bundle:nil];
    UITabBarController* initialHelpView = [storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];
    [[UITabBar appearance] setTintColor:[UIColor blackColor]];
    initialHelpView.modalPresentationStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:initialHelpView animated:YES];
}

- (void) showPinOnMapViewPlan:(Plan *)plan 
{
    NSLog(@"in listview plan %@",plan);
    [self.presentingViewController performSelector:@selector(showPinOnMapViewForPlan:) withObject:plan];
    [self performSelector:@selector(dismissModalView) withObject:nil afterDelay:1.5];
}

- (void) dismissModalView
{
    
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)removeCircleView:(id)sender
{
    [circleView removeFromSuperview];
}

-(IBAction)gotoPlace:(id)sender
{
    PlaceListViewController *controller = [[PlaceListViewController alloc] initWithNibName:@"PlaceListViewController" bundle:nil];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

- (void) showPinOnMapView:(Place*)place 
{
    [self.presentingViewController performSelector:@selector(showPinOnMapView:) withObject:place];
    [self dismissModalViewControllerAnimated:NO];
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
    [controller release];
}

-(IBAction)gotonDeals:(id)sender
{
    [UtilityClass showAlert:@"Social Maps" :@"This feature is coming soon."];    
}

- (IBAction)selectMapView:(id)sender
{
    NSLog(@"asdasd");
}

- (IBAction)selectListView:(id)sender
{
    NSLog(@"go to list view");
    [listViewImg setImage:[UIImage imageNamed:@"list_view_icon_black.png"]];
    [self performSelector:@selector(loadPrevListImage) withObject:nil afterDelay:0.2];
}

-(void)loadPrevImage
{
    [mapViewImg setImage:[UIImage imageNamed:@"map_view_icon_black.png"]];
    [self removeFromParentViewController];
}

-(void)loadPrevListImage
{
    [listViewImg setImage:[UIImage imageNamed:@"list_view_icon.png"]];
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
    LocationItem *anItem = (LocationItem*)[copyDisplayListArray objectAtIndex:indexPath.row];
    if(searching) 
		anItem = (LocationItem *)[copyListOfItems objectAtIndex:indexPath.row];
    anItem.delegate = self;
    UITableViewCell * cell = [anItem getTableViewCell:tv sender:self];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:123456789];
    [imageView setImageForUrlIfAvailable:anItem.itemCoverPhotoUrl];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
	selectedItemIndex = indexPath.section;
    NSLog(@"selected: %@",[copyDisplayListArray objectAtIndex:indexPath.row]);
    if (searching==YES)
    {
        if ([[copyListOfItems objectAtIndex:indexPath.row] isKindOfClass:[LocationItemPeople class]]) 
        {
            
            NSLog(@"in search");
            if (![((LocationItemPeople *)[copyListOfItems objectAtIndex:indexPath.row]).userInfo.source isEqualToString:@"facebook"])
            {
                profileFromList=TRUE;
                FriendsProfileViewController *controller =[[FriendsProfileViewController alloc] init];
                controller.friendsId=((LocationItemPeople *)[copyListOfItems objectAtIndex:indexPath.row]).userInfo.userId;
                controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentModalViewController:controller animated:YES];
            }
        }                
    }
    else 
    {
        if ([[copyDisplayListArray objectAtIndex:indexPath.row] isKindOfClass:[LocationItemPeople class]]) 
        {
            NSLog(@"not in search");
            profileFromList=TRUE;
            if (![((LocationItemPeople *)[copyDisplayListArray objectAtIndex:indexPath.row]).userInfo.source isEqualToString:@"facebook"])
            {
            FriendsProfileViewController *controller =[[FriendsProfileViewController alloc] init];
            controller.friendsId=((LocationItemPeople *)[copyDisplayListArray objectAtIndex:indexPath.row]).userInfo.userId;
            controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentModalViewController:controller animated:YES];
                [controller release];
            }
        }        
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (searching) ? [copyListOfItems count] :[copyDisplayListArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    LocationItem *anItem = (LocationItem*)[copyDisplayListArray objectAtIndex:indexPath.row];
    if(searching) 
		anItem = (LocationItem *)[copyListOfItems objectAtIndex:indexPath.row];
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
    NSLog(@"states %i %i %i",smAppDelegate.showPeople,smAppDelegate.showPlaces,smAppDelegate.showEvents);
    switch (btnNum) {
        case 7000:
            if (newState == 0)
                smAppDelegate.showPeople = FALSE;
            else
                smAppDelegate.showPeople = TRUE;
            break;
        case 7001:
            if (newState == 0)
                smAppDelegate.showPlaces = FALSE;
            else
                smAppDelegate.showPlaces = TRUE;
            break;
        case 7002:
            if (newState == 0)
                smAppDelegate.showEvents = FALSE;
            else
                smAppDelegate.showEvents = TRUE;
            break;
        default:
            break;
    }
    
    [self refreshTableView];
}

- (void)refreshTableView
{
    [self getSortedDisplayList];
    if (viewSearch.frame.origin.y > 44) {
        [self searchTableView];
    }
    [itemList reloadData];
    [self loadImagesForOnscreenRows];
}

- (void) radioButtonClicked:(int)indx sender:(id)sender {
    UIButton *btn = (UIButton*) sender;
    NSLog(@"radioButtonClicked index = %d, sender tag=%d", indx, btn.tag);
    
    if (btn.tag == 3000) { // People filter - All or friends only
        if (indx == 0) { // All users
            if (smAppDelegate.showAllUsers == FALSE) {
                smAppDelegate.showAllUsers = TRUE;
            }
        } else {
            if (smAppDelegate.showAllUsers == TRUE) {
                smAppDelegate.showAllUsers = FALSE;
            }
        }
    } else if (btn.tag == 4000) { // Show offline or online only
        if (indx == 0) { // Show offline users also
            if (smAppDelegate.showOffline == FALSE) {
                smAppDelegate.showOffline = TRUE;
            }
        } else {
            if (smAppDelegate.showOffline == TRUE) {
                smAppDelegate.showOffline = FALSE;
            }
        }
    }
    
    [self refreshTableView];
}

// LocationItem delegate
- (void) buttonClicked:(LOCATION_ACTION_TYPE) action row:(int)row {
    LocationItem *anItem = (LocationItem*) [copyDisplayListArray objectAtIndex:row];
    NSLog(@"ListviewController: %d, row=%d name=%@", action, row, anItem.itemName);
    switch (action) {
        case LocationActionTypeGotoMap:
            
            NSLog(@"cordinate %f %f", anItem.coordinate.longitude, anItem.coordinate.latitude);
            
            LocationItem *locItem = (LocationItem*)[copyDisplayListArray objectAtIndex:row];
            if(searching)
                locItem = (LocationItem*)[copyListOfItems objectAtIndex:row];
            smAppDelegate.needToCenterMap = FALSE;
            
            [self.presentingViewController performSelector:@selector(showAnnotationDetailView:) withObject:locItem];
            [self dismissModalViewControllerAnimated:YES];
            
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
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	
    [searchBar resignFirstResponder];
    
    if([searchBar.text length] > 0) {
		
//		[ovController.view removeFromSuperview];
//		searching = NO;
//		letUserSelectRow = YES;
//		itemList.scrollEnabled = YES;
//		[self searchTableView];
        [self getSearchResult:searchBar.text];
	}
	else {
		
		searching = NO;
	}
	
	[itemList reloadData];
}

- (void) searchTableView 
{
	NSString *searchText = searchBar.text;
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
    
    CGRect viewFrame = viewSearch.frame;
    viewFrame.origin.y += moveby;
    CGRect listPullDownFrame = pullDownView.frame;
    listPullDownFrame.origin.y += moveby;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];    
    [viewSearch setFrame:viewFrame];  
    [pullDownView setFrame:listPullDownFrame];
    [UIView commitAnimations];    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)theSearchBar
{
    [self actionSearchButton:nil];
}

- (void) doneSearching_Clicked:(id)sender {
	
	searchBar.text = @"";
	[searchBar resignFirstResponder];
	
	letUserSelectRow = YES;
	searching = NO;
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
        pullDownView.closedCenter = CGPointMake(160, 0);
    } else {
        [self moveSearchBarAnimation:44];
        [searchBar becomeFirstResponder];
        pullDownView.openedCenter = CGPointMake(160, 80 + 44);
        pullDownView.closedCenter = CGPointMake(160, 44);
    }
    
}

- (IBAction)actionSearchOkButton:(id)sender {
//    [self searchBarSearchButtonClicked:searchBar];
    [self getSearchResult:searchBar.text];
}

- (void)loadImagesForOnscreenRows {
    
    if ([copyDisplayListArray count] > 0) {
        
        NSArray *visiblePaths = [itemList indexPathsForVisibleRows];
        
        for (NSIndexPath *indexPath in visiblePaths) {
            
            UITableViewCell *cell = [itemList cellForRowAtIndexPath:indexPath];
            
            //get the imageView on cell
            
            UIImageView *imgCover = (UIImageView*) [cell viewWithTag:123456789];
            UIImageView *imgIcon = (UIImageView*) [cell viewWithTag:2010];
            
            LocationItem *anItem = (LocationItem*)[copyDisplayListArray objectAtIndex:indexPath.row];
            
            if(searching) 
                anItem = (LocationItem *)[copyListOfItems objectAtIndex:indexPath.row];
            
            if (anItem.itemCoverPhotoUrl) 
                [imgCover loadFromURL:anItem.itemCoverPhotoUrl];
            
            if (anItem.itemAvaterURL && [anItem.itemAvaterURL rangeOfString:[[NSBundle mainBundle] resourcePath]].location != NSNotFound)
                 [imgIcon loadFromURL:[NSURL fileURLWithPath:anItem.itemAvaterURL isDirectory:NO]];
            else
                [imgIcon loadFromURL:[NSURL URLWithString:anItem.itemAvaterURL]];
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

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GET_SEARCH_RESULT_DONE object:nil];
}

-(void)navigateToSearchView:(NSMutableArray *)dataSource
{
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    searchListViewController =[storybrd instantiateViewControllerWithIdentifier:@"searchListViewController"];
    //    [controller.view setFrame:CGRectMake(0, 50, 320, 370)];
    searchListViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    searchListViewController.searchText = searchBar.text;
    searchListViewController.filteredList = dataSource;
    searchListViewController.delegate = self;
    [self presentModalViewController:searchListViewController animated:YES];
    
}

-(void)getSearchResult:(NSString *)searchString
{
    [searchBar resignFirstResponder];
    if(searchString.length >= 3)
    {
        [smAppDelegate showActivityViewer:self.view];
        RestClient *rc = [[RestClient alloc] init];
        [rc getSearchResultWithKeyWord:searchString authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
        [rc release];
    }
    else
    {
        [UtilityClass showAlert:@"" :@"Please enter atleast 3 characters"];
    }
}

-(void)getSearchResultDone:(NSNotification *)notif
{
    [smAppDelegate hideActivityViewer];
    if ([[notif object] count] == 0)
    {
        [UtilityClass showAlert:@"" :@"No search result found"];
    }
    else
    {
        [self navigateToSearchView:[notif object]];
    }
}

-(void)removeSearchViewWithLocation:(LocationItem *)item
{
    NSLog(@"searched location Item listview %@   %@",item,searchListViewController.delegate);
    [self performSelector:@selector(showOnMap:) withObject:item afterDelay:1];
}

- (void)showOnMap:(LocationItem *)item
{
    [self.presentingViewController performSelector:@selector(showAnnotationDetailView:) withObject:item afterDelay:.8];
    [self dismissModalViewControllerAnimated:YES];
}

-(void)removeSearchView
{
    NSLog(@"removeSearchView listview");
}

@end

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

@implementation ListViewController
@synthesize listPullupMenu;
@synthesize listPulldownMenu;
@synthesize listViewfilter;
@synthesize listView;
@synthesize listPulldown;
@synthesize itemList;
@synthesize selectedType;
@synthesize showPeople;
@synthesize showPlaces;
@synthesize showDeals;
@synthesize selectedItemIndex;
//@synthesize objectLists;
//@synthesize peopleList;
//@synthesize placeList;
//@synthesize dealList;
//@synthesize displayList;
@synthesize smAppDelegate;

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
- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    showPeople = TRUE;
    showPlaces = FALSE;
    showDeals  = FALSE;
    
    CGRect filterFrame = CGRectMake(4+labelFrame.size.width, 0, listViewfilter.frame.size.width-labelFrame.size.width-4, listViewfilter.frame.size.height);
    CustomCheckbox *chkBox = [[CustomCheckbox alloc] initWithFrame:filterFrame boxLocType:LabelPositionRight numBoxes:3 default:[NSArray arrayWithObjects:[NSNumber numberWithInt:1],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0], nil] labels:[NSArray arrayWithObjects:@"People",@"Places",@"Deals", nil]];
    chkBox.delegate = self;
    [listViewfilter addSubview:chkBox];
    [chkBox release];
    
    itemList.delegate = self;
    itemList.dataSource = self;
    [self.view sendSubviewToBack:listView];
    
    // Dummy data
    // starting lat,long 23.795240529083365, 90.41318893432617
//    peopleList = [[NSMutableArray alloc] init];
//    CLLocationDegrees currLat = 23.795633200965806;
//    CLLocationDegrees currLong = 90.41279196739197;
//    float dist;
//    for (int i=0; i < 4; i++) {
//        UIImage *bg = [UIImage imageNamed:@"listview_bg.png"];
//        UIImage *icon = [UIImage imageNamed:@"Photo-3.png"];
//        dist = rand()%500;
//        CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(currLat, currLong);
//        LocationItemPeople *aPerson = [[LocationItemPeople alloc] initWithName:[NSString stringWithFormat:@"Person %d", i] address:[NSString stringWithFormat:@"Address %d", i] type:ObjectTypePeople category:@"Male" coordinate:loc dist:dist icon:icon bg:bg];
//        currLat += 0.00004;
//        currLong += 0.00004;
//        dist -= 100;
//        [peopleList addObject:aPerson];
//        [aPerson release];
//    }
//    
//    placeList = [[NSMutableArray alloc] init];
//    currLat = 23.796526525077528;
//    currLong = 90.41537761688232;
//    
//    for (int i=0; i < 3; i++) {
//        UIImage *bg = [UIImage imageNamed:@"listview_bg.png"];
//        UIImage *icon = [UIImage imageNamed:@"user_thumb_only.png"];
//        CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(currLat, currLong);
//        dist = rand()%500;
//        LocationItemPlace *aPlace = [[LocationItemPlace alloc] initWithName:[NSString stringWithFormat:@"Place %d", i] address:[NSString stringWithFormat:@"Place Address %d", i] type:ObjectTypePeople category:@"Bar" coordinate:loc dist:dist icon:icon bg:bg];
//        currLat += 0.00004;
//        currLong += 0.00004;
//        aPlace.delegate = self;
//        [placeList addObject:aPlace];
//        [aPlace release];
//    }
//
//    dealList = [[NSMutableArray alloc] initWithCapacity:0];
//    smAppDelegate.displayList = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self getSortedDisplayList];
    [itemList reloadData];
}

- (void) getSortedDisplayList {
    [smAppDelegate.displayList removeAllObjects];
    NSMutableArray *tempList = [[NSMutableArray alloc] init];
    if (showPeople == TRUE) 
        [tempList addObjectsFromArray:smAppDelegate.peopleList];
    if (showPlaces == TRUE) 
        [tempList addObjectsFromArray:smAppDelegate.placeList];
    if (showDeals == TRUE) 
        [tempList addObjectsFromArray:smAppDelegate.dealList];
    
    // Sort by distance
    NSArray *sortedArray = [tempList sortedArrayUsingSelector:@selector(compareDistance:)];
    [smAppDelegate.displayList addObjectsFromArray:sortedArray];
}

- (void)viewDidUnload
{
    [self setListPullupMenu:nil];
    [self setListPulldownMenu:nil];
    [self setListViewfilter:nil];
    [self setListView:nil];
    [self setListPulldown:nil];
    [self setItemList:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
- (void)dealloc {
    [listPullupMenu release];
    [listPulldownMenu release];
    [listViewfilter release];
    
    [listView release];
    [listPulldown release];
    [itemList release];
    [super dealloc];
}

// Tableview stuff
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"IndexPath:%d,%d",indexPath.section,indexPath.row);
    LocationItem *anItem = (LocationItem*)[smAppDelegate.displayList objectAtIndex:indexPath.row];
    UITableViewCell * cell = [anItem getTableViewCell:tv sender:self];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
	selectedItemIndex = indexPath.section;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [smAppDelegate.displayList count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"IndexPath:%d,%d",indexPath.section,indexPath.row);
    LocationItem *anItem = (LocationItem*)[smAppDelegate.displayList objectAtIndex:indexPath.row];
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

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//	CGRect CellFrame   = CGRectMake(0, 0, tableView.frame.size.width, SECTION_HEADER_HEIGHT);
//	
//	UIView *header = [[UIView alloc] initWithFrame:CellFrame];
//    
//	header.backgroundColor = [UIColor clearColor];
//    UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(0,0,
//                                                                tableView.frame.size.width,
//                                                                SECTION_HEADER_HEIGHT)];
//    tempLabel.backgroundColor=[UIColor clearColor];
//    if (selectedType == ObjectTypePeople)
//        tempLabel.text= @"People";
//    else if (selectedType == ObjectTypePlace)
//        tempLabel.text= @"Placec";
//    else
//        tempLabel.text= @"Deals";
//    [tempLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
//    [header addSubview: tempLabel];
//    [tempLabel release];
//	
//	return header;
//}
//
- (void) checkboxClicked:(int)btnNum withState:(int) newState sender:(id) sender {
    NSLog(@"ListViewController: checkboxClicked btn:%d state:%d", btnNum, newState);
    switch (btnNum) {
        case 0:
            if (newState == 0)
                showPeople = FALSE;
            else
                showPeople = TRUE;
            break;
        case 1:
            if (newState == 0)
                showPlaces = FALSE;
            else
                showPlaces = TRUE;
            break;
        case 2:
            if (newState == 0)
                showDeals = FALSE;
            else
                showDeals = TRUE;
            break;
        default:
            break;
    }
    [self getSortedDisplayList];
    [itemList reloadData];
}

// LocationItemPlaceDelegate
- (void) showLocationReview:(int)row {
    NSLog(@"ListviewController: showLocationReview, row=%d", row);
}
@end

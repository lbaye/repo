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
@synthesize listNotifCount;
@synthesize selectedType;
@synthesize selectedItemIndex;
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
    
    CGRect filterFrame = CGRectMake(4+labelFrame.size.width, 0, listViewfilter.frame.size.width-labelFrame.size.width-4, listViewfilter.frame.size.height);
    CustomCheckbox *chkBox = [[CustomCheckbox alloc] initWithFrame:filterFrame boxLocType:LabelPositionRight numBoxes:3 default:[NSArray arrayWithObjects:[NSNumber numberWithInt:smAppDelegate.showPeople],[NSNumber numberWithInt:smAppDelegate.showPlaces],[NSNumber numberWithInt:smAppDelegate.showDeals], nil] labels:[NSArray arrayWithObjects:@"People",@"Places",@"Deals", nil]];
    chkBox.delegate = self;
    [listViewfilter addSubview:chkBox];
    [chkBox release];
    
    itemList.delegate = self;
    itemList.dataSource = self;
    [self.view sendSubviewToBack:listView];
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

- (void)viewDidUnload
{
    [self setListPullupMenu:nil];
    [self setListPulldownMenu:nil];
    [self setListViewfilter:nil];
    [self setListView:nil];
    [self setListPulldown:nil];
    [self setItemList:nil];
    [self setListNotifCount:nil];
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

- (IBAction)goToNotifications:(id)sender {
}
- (void)dealloc {
    [listPullupMenu release];
    [listPulldownMenu release];
    [listViewfilter release];
    
    [listView release];
    [listPulldown release];
    [itemList release];
    [listNotifCount release];
    [super dealloc];
}

// Tableview stuff
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"IndexPath:%d,%d",indexPath.section,indexPath.row);
    LocationItem *anItem = (LocationItem*)[smAppDelegate.displayList objectAtIndex:indexPath.row];
    anItem.delegate = self;
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

- (void) checkboxClicked:(int)btnNum withState:(int) newState sender:(id) sender {
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
    [itemList reloadData];
}

// LocationItem delegate
- (void) buttonClicked:(LOCATION_ACTION_TYPE) action row:(int)row {
    LocationItem *anItem = (LocationItem*) [smAppDelegate.displayList objectAtIndex:row];
    NSLog(@"ListviewController: %d, row=%d name=%@", action, row, anItem.itemName);
    switch (action) {
        case LocationActionTypeGotoMap:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
            
        default:
            break;
    }
}

@end

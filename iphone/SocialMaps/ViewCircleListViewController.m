//
//  ViewCircleListViewController.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 9/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewCircleListViewController.h"
#import "UserCircle.h"
#import "UserFriends.h"
#import "AppDelegate.h"
#import "Globals.h"
#import "UtilityClass.h"
#import "CircleListTableCell.h"
#import "CircleListCheckBoxTableCell.h"
#import "CircleImageDownloader.h"
#import "CustomCheckbox.h"
#import "LocationItemPeople.h"
#import "RestClient.h"
#import "NotificationController.h"

@interface ViewCircleListViewController ()
- (void)startIconDownload:(UserFriends *)userFriend forIndexPath:(NSIndexPath *)indexPath;
@end

@implementation ViewCircleListViewController
@synthesize circleListTableView,circleSearchBar;
@synthesize listPulldownMenu,listPulldown,downloadedImageDict;
@synthesize listViewfilter;
@synthesize  msgView,textViewNewMsg;
@synthesize itemDistance;

__strong NSMutableArray *filteredList, *eventListArray;
__strong NSMutableDictionary *imageDownloadsInProgress;
__strong NSMutableDictionary *eventListIndex;
NSString *searchText2=@"";
AppDelegate         *smAppDelegate;

//rsvpFlag=
bool searchFlag2=true;
bool showFB=true;
bool showSM=true;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    filteredList=[[NSMutableArray alloc] init]; 
    eventListArray=[[NSMutableArray alloc] init];
    smAppDelegate=[[AppDelegate alloc] init];
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    imageDownloadsInProgress=[[NSMutableDictionary alloc] init];
    [imageDownloadsInProgress retain];
    eventListIndex=[[NSMutableDictionary alloc] init];
    listPulldownMenu.backgroundColor = [UIColor clearColor];
    
    filteredList=[[self loadDummyData] mutableCopy]; 
    eventListArray=[[self loadDummyData] mutableCopy];
    
    downloadedImageDict=[[NSMutableDictionary alloc] init];
    
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
    
    NSArray *subviews = [circleSearchBar subviews];
    UIButton *cancelButton = [subviews objectAtIndex:2];
    cancelButton.tintColor = [UIColor darkGrayColor];
    cancelButton.titleLabel.text=@"   OK";
    
    CGRect filterFrame = CGRectMake(4+labelFrame.size.width, 0, listViewfilter.frame.size.width-labelFrame.size.width-4, listViewfilter.frame.size.height);
    //    CustomCheckbox *chkBox = [[CustomCheckbox alloc] initWithFrame:filterFrame boxLocType:LabelPositionRight numBoxes:3 default:[NSArray arrayWithObjects:[NSNumber numberWithInt:smAppDelegate.showPeople],[NSNumber numberWithInt:smAppDelegate.showPlaces],[NSNumber numberWithInt:smAppDelegate.showDeals], nil] labels:[NSArray arrayWithObjects:@"People",@"Places",@"Deals", nil]];
    CustomCheckbox *chkBox = [[CustomCheckbox alloc] initWithFrame:filterFrame boxLocType:LabelPositionRight numBoxes:2 default:[NSArray arrayWithObjects:[NSNumber numberWithInt:showFB],[NSNumber numberWithInt:showSM], nil] labels:[NSArray arrayWithObjects:@"Facebook",@"Social Maps", nil]];
    chkBox.delegate = self;
    [listViewfilter addSubview:chkBox];
    [chkBox release];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    labelNotifCount.text = [NSString stringWithFormat:@"%d", [UtilityClass getNotificationCount]];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    filteredList=[[self loadDummyData] mutableCopy]; 
    eventListArray=[[self loadDummyData] mutableCopy];
//    [self.mapContainer removeFromSuperview];
//    [smAppDelegate showActivityViewer:self.view];
//    [smAppDelegate.window setUserInteractionEnabled:NO];
    NSLog(@"activity start.  %@",smAppDelegate);
    [self.circleSearchBar setText:@""];
    [msgView removeFromSuperview];
    
    smAppDelegate.currentModelViewController = self;
    
//    
//    
//    filteredList = [[eventListArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
//        NSString *first = [(Event*)a eventDistance];
//        NSString *second = [(Event*)b eventDistance];
//        return [first compare:second];
//    }] mutableCopy];
//    [self.circleListTableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
//    RestClient *rc=[[RestClient alloc] init];
//    [rc getAllEvents:@"Auth-Token":smAppDelegate.authToken];  
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    filteredList=[[self loadDummyData] mutableCopy]; 
    eventListArray=[[self loadDummyData] mutableCopy];
    [self getSortedDisplayList];
    [self.circleListTableView reloadData];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.circleSearchBar resignFirstResponder];
}

-(NSMutableArray *)loadDummyData
{
    for (int i=0; i<[smAppDelegate.peopleList count]; i++)
    {
        LocationItemPeople *people=[[LocationItemPeople alloc] init];
        people = (LocationItemPeople *)[smAppDelegate.peopleList objectAtIndex:i];
        Geolocation *geoLocation=[[Geolocation alloc] init];
        geoLocation.latitude=people.userInfo.currentLocationLat;
        geoLocation.longitude=people.userInfo.currentLocationLng;
        people.userInfo.distance=[UtilityClass getDistanceWithFormattingFromLocation:geoLocation];
        [smAppDelegate.peopleList replaceObjectAtIndex:i withObject:people];
    }
    
    
    
    smAppDelegate.peopleList = [[smAppDelegate.peopleList sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
                     {
                         People *firstPeople = [(LocationItemPeople*)a userInfo];
                         People *secondPeople = [(LocationItemPeople*)a userInfo];
                         if (firstPeople.distance > secondPeople.distance) 
                         {
                             return (NSComparisonResult)NSOrderedDescending;
                         }
                         
                         if (firstPeople.distance < secondPeople.distance) 
                         {
                             return (NSComparisonResult)NSOrderedAscending;
                         }
                         return (NSComparisonResult)NSOrderedSame;
                     }] mutableCopy];
    return smAppDelegate.peopleList;
}

- (NSComparisonResult) compareDistance:(LocationItem*) other {
    if (self.itemDistance < other.itemDistance)
        return NSOrderedAscending;
    else if (self.itemDistance > other.itemDistance)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}


- (void) checkboxClicked:(int)btnNum withState:(int) newState sender:(id) sender 
{
    NSLog(@"ListViewController: checkboxClicked btn:%d state:%d", btnNum, newState);
    switch (btnNum) {
        case 7000:
            if (newState == 0)
                showFB = FALSE;
            else
                showFB = TRUE;
            break;
        case 7001:
            if (newState == 0)
                showSM = FALSE;
            else
                showSM = TRUE;
            break;
        default:
            break;
    }
    [self getSortedDisplayList];
    [circleListTableView reloadData];
    [circleSearchBar setText:@""];
    [circleSearchBar resignFirstResponder];
}

-(void)moveSearchBarAnimation:(int)moveby
{
    if (moveby > 0) {
        circleListTableView.contentInset = UIEdgeInsetsMake(43,0.0,0,0.0);
    } else {
        circleListTableView.contentInset = UIEdgeInsetsMake(0,0.0,0,0.0);
    }
    NSLog(@"moveby %d",moveby);
    //itemList.contentOffset = CGPointZero;
    CGRect viewFrame = circleSearchBar.frame;
    viewFrame.origin.y += moveby;
    CGRect listPullDownFrame = listPulldown.frame;
    listPullDownFrame.origin.y += moveby;
    CGRect listPullDownMenuFrame = listPulldownMenu.frame;
    listPullDownMenuFrame.origin.y += moveby;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];    
    [circleSearchBar setFrame:viewFrame];  
    [listPulldown setFrame:listPullDownFrame]; 
    [listPulldownMenu setFrame:listPullDownMenuFrame]; 
    [UIView commitAnimations];    
}

- (void) getSortedDisplayList {
    NSMutableArray *tempList = [[NSMutableArray alloc] init];
    [filteredList removeAllObjects];
    if (showFB == TRUE) 
    {
        for (int i=0; i<[smAppDelegate.peopleList count]; i++)
        {
            if([((LocationItemPeople *)[smAppDelegate.peopleList objectAtIndex:i]).userInfo.regMedia isEqualToString:@"fb"])
            {
                [tempList addObject:[smAppDelegate.peopleList objectAtIndex:i]];
            }
        }
    }
    if (showSM == TRUE)
    {
        for (int i=0; i<[smAppDelegate.peopleList count]; i++)
        {
            if(![((LocationItemPeople *)[smAppDelegate.peopleList objectAtIndex:i]).userInfo.regMedia isEqualToString:@"fb"])
            {
                [tempList addObject:[smAppDelegate.peopleList objectAtIndex:i]];
            }
        }
    }
    
    // Sort by distance
    NSArray *sortedArray = [tempList sortedArrayUsingSelector:@selector(compareDistance:)];
    [filteredList addObjectsFromArray:sortedArray];
}

- (void)getAllEventsDone:(NSNotification *)notif
{
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    friendListGlobalArray=[[notif object] mutableCopy];
    NSLog(@"GOT SERVICE DATA EVENT.. :D  %@",[notif object]);
    [self performSelector:@selector(hideActivity) withObject:nil afterDelay:1.0];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    [self viewDidLoad];
    filteredList=[[self loadDummyData] mutableCopy]; 
    eventListArray=[[self loadDummyData] mutableCopy];
    [self.circleListTableView reloadData];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{    
    if (!(textView.textColor == [UIColor blackColor])) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    return YES;
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (!(textView.textColor == [UIColor lightGrayColor])) {
        textView.text = @"Your message...";
        textView.textColor = [UIColor lightGrayColor];
    }
}

-(void)hideActivity
{
    NSArray* subviews = [NSArray arrayWithArray: self.view.subviews];
    for (UIView* view in subviews) 
    {
        if([view isKindOfClass :[UIActivityIndicatorView class]])
        {
            [view removeFromSuperview];
        }
    }
    
    [smAppDelegate hideActivityViewer];
    NSLog(@"activity removed %@",smAppDelegate);
}

- (void)viewDidUnload
{
    [labelNotifCount release];
    labelNotifCount = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(IBAction)gotoTabBar:(id)sender
{
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"CirclesStoryboard" bundle:nil];
    UITabBarController *controller =[storybrd instantiateViewControllerWithIdentifier:@"tabBarController"];
    controller.selectedIndex=0;
    controller.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];

}

-(IBAction)showSearch:(id)sender
{
    if (circleSearchBar.frame.origin.y >= 44) {
        [self moveSearchBarAnimation:-44];
        [circleSearchBar resignFirstResponder];
    } else {
        [self moveSearchBarAnimation:44];
        //listPulldownMenu.hidden = TRUE;
        [circleSearchBar becomeFirstResponder];
    }
}

-(IBAction)gotoInvites:(id)sender
{
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"CirclesStoryboard" bundle:nil];
    UITabBarController *controller =[storybrd instantiateViewControllerWithIdentifier:@"tabBarController"];
    controller.selectedIndex=0;
//    controller.tabBar.frame=CGRectMake(0, -100, 32, 32);
    controller.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
    
}

-(IBAction)gotoCircles:(id)sender
{
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"CirclesStoryboard" bundle:nil];
    UITabBarController *controller =[storybrd instantiateViewControllerWithIdentifier:@"tabBarController"];
    controller.selectedIndex=1;
    controller.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];

}

-(IBAction)gotoBlockUnBlock:(id)sender
{
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"CirclesStoryboard" bundle:nil];
    UITabBarController *controller =[storybrd instantiateViewControllerWithIdentifier:@"tabBarController"];
    controller.selectedIndex=2;
    controller.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];

}

- (IBAction)closePulldown:(id)sender {
    listPulldownMenu.hidden = TRUE;
}

- (IBAction)showPulldownMenu:(id)sender {
    listPulldownMenu.hidden = FALSE;
}

-(IBAction)sendMsg:(id)sender
{
    if (([textViewNewMsg.text isEqualToString:@""]) ||([textViewNewMsg.text isEqualToString:@"Your message..."]))
    {
        [UtilityClass showAlert:@"Social Maps" :@"Enter message"];
    }
    else
    {
    CircleListTableCell *clickedCell = (CircleListTableCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.circleListTableView indexPathForCell:clickedCell];

    [textViewNewMsg resignFirstResponder];
    [msgView removeFromSuperview];
    NSString * subject = [NSString stringWithFormat:@"Message from %@ %@", smAppDelegate.userAccountPrefs.firstName,
                          smAppDelegate.userAccountPrefs.lastName];
    
    NSMutableArray *userIDs=[[NSMutableArray alloc] init];
    
    LocationItemPeople *people=(LocationItemPeople *)[filteredList objectAtIndex:clickedButtonPath.row];

    NSString *userId = people.userInfo.userId;
    [userIDs addObject:userId];
    NSLog(@"user id %@", userIDs);
    
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    [restClient sendMessage:subject content:textViewNewMsg.text recipients:userIDs authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
    }
}

-(IBAction)cancelMsg:(id)sender
{
    [textViewNewMsg resignFirstResponder];
    [msgView removeFromSuperview];
}

- (IBAction)actionNotificationButton:(id)sender {
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    NotificationController *controller =[storybrd instantiateViewControllerWithIdentifier:@"notificationViewController"];
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
}

//table view delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [filteredList count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"circleListTableCell";
    int nodeCount = [filteredList count];
    
    LocationItemPeople *people=[[LocationItemPeople alloc] init];
    people = (LocationItemPeople *)[filteredList objectAtIndex:indexPath.row];
    NSLog(@"[filteredList count] %d",[filteredList count]);

    
    CircleListTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
            cell = [[CircleListTableCell alloc]
                    initWithStyle:UITableViewCellStyleDefault 
                    reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.addressLabel.text = [NSString stringWithFormat:@"event address"];
    cell.firstNameLabel.text = [NSString stringWithFormat:@"event name"];
//    cell.eventDetail.text = [NSString stringWithFormat:@"1"];
    cell.distanceLabel.text = [NSString stringWithFormat:@"event distance"];
    cell.showOnMapButton.tag=indexPath.row;
    [cell.showOnMapButton addTarget:self action:@selector(viewLocationButton:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.showOnMapButton.tag=indexPath.row;
    //    NSLog(@"event.myResponse: %@",event.myResponse);
    // Leave cells empty if there's no data yet
    if (nodeCount > 0)
	{
        // Set up the cell...
        NSString *cellValue;	
        cellValue=people.itemName;
        cell.firstNameLabel.text = cellValue;
        cell.addressLabel.text=people.itemAddress;
        cell.distanceLabel.text=[NSString stringWithFormat:@"%.2lfm",people.itemDistance];
        cell.regStsImgView.layer.borderColor=[[UIColor lightTextColor] CGColor];
        cell.regStsImgView.userInteractionEnabled=YES;
        cell.regStsImgView.layer.borderWidth=1.0;
        cell.regStsImgView.layer.masksToBounds = YES;
        [cell.regStsImgView.layer setCornerRadius:5.0];
        if ([people.userInfo.regMedia isEqualToString:@"fb"]) 
        {
            NSLog(@"reg media fb %@",[UIImage imageNamed:@"icon_facebook.png"]);
            cell.regStsImgView.image=[UIImage imageNamed:@"icon_facebook.png"];
            cell.inviteButton.hidden=NO;
        }
        else
        {
            cell.regStsImgView.image=[UIImage imageNamed:@"sm_icon@2x.png"];
            cell.inviteButton.hidden=YES;
        }
        
        if ([people.userInfo.friendshipStatus isEqualToString:@"friend"]) 
        {
            cell.friendShipStatus.hidden=NO;
        }
        else
        {
            cell.friendShipStatus.hidden=YES;
        }
        cell.profilePicImgView.image=people.itemIcon;
        cell.profilePicImgView.layer.borderColor=[[UIColor lightTextColor] CGColor];
        cell.profilePicImgView.userInteractionEnabled=YES;
        cell.profilePicImgView.layer.borderWidth=1.0;
        cell.profilePicImgView.layer.masksToBounds = YES;
        cell.coverPicImgView.image=people.itemBg;
        [cell.profilePicImgView.layer setCornerRadius:5.0];
        [cell.showOnMapButton addTarget:self action:@selector(viewLocationButton:) forControlEvents:UIControlEventTouchUpInside];
        [cell.inviteButton addTarget:self action:@selector(inviteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.messageButton addTarget:self action:@selector(messageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        Geolocation *geoLocation=[[Geolocation alloc] init];
        geoLocation.latitude=people.userInfo.currentLocationLat;
        geoLocation.longitude=people.userInfo.currentLocationLng;
        cell.distanceLabel.text=[UtilityClass getDistanceWithFormattingFromLocation:geoLocation];


    }
    [cell.inviteButton.layer setCornerRadius:6.0f];
    [cell.inviteButton.layer setMasksToBounds:YES];
    [cell.messageButton.layer setCornerRadius:6.0f];
    [cell.messageButton.layer setMasksToBounds:YES];

    
    NSLog(@"downloadedImageDict c: %@ %d",downloadedImageDict,[downloadedImageDict count]);
    //    cell.eventImage.image = eventPhoto;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults]; 
    smAppDelegate.authToken=[prefs stringForKey:@"authToken"];
}

//Lazy loading method starts

//Lazy loading method ends.

-(void)viewLocationButton:(id)sender
{}

-(void)inviteButtonAction:(id)sender
{}

-(void)messageButtonAction:(id)sender
{
    [self.view addSubview:msgView];
}

//search bar delegate method starts
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText 
{
    // We don't want to do anything until the user clicks 
    // the 'Search' button.
    // If you wanted to display results as the user types 
    // you would do that here.
    //[self loadFriendListsData]; TODO: commented this
    searchText2=circleSearchBar.text;
    
    if ([searchText2 length]>0) 
    {
        [self performSelector:@selector(searchResult) withObject:nil afterDelay:0.1];
        searchFlag2=true;
        [self.circleListTableView reloadData];
        NSLog(@"searchText  %@",searchText2);
    }
    else
    {
        searchText2=@"";
        //[self loadFriendListsData]; TODO: commented this
        [filteredList removeAllObjects];
        filteredList = [[NSMutableArray alloc] initWithArray: smAppDelegate.peopleList];
        NSLog(@"eventListGlobalArray: %@",smAppDelegate.peopleList);
        [self.circleListTableView reloadData];
    }
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar 
{
    // searchBarTextDidBeginEditing is called whenever 
    // focus is given to the UISearchBar
    // call our activate method so that we can do some 
    // additional things when the UISearchBar shows.
    searchText2=circleSearchBar.text;
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
    [self.circleListTableView reloadData];
    [circleSearchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // Clear the search text
    // Deactivate the UISearchBar
    circleSearchBar.text=@"";
    searchText2=@"";
    
    [filteredList removeAllObjects];
    filteredList = [[NSMutableArray alloc] initWithArray: smAppDelegate.peopleList];
    [self.circleListTableView reloadData];
    [circleSearchBar resignFirstResponder];
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
    searchText2=circleSearchBar.text;
    searchFlag2=false;
    [self searchResult];
    [circleSearchBar resignFirstResponder];
}

-(void)searchResult
{
    searchText2 = circleSearchBar.text;
    NSLog(@"in search method..");
    [filteredList removeAllObjects];
    
    if ([searchText2 isEqualToString:@""])
    {
        NSLog(@"null string");
        circleSearchBar.text=@"";
        filteredList = [[NSMutableArray alloc] initWithArray: friendListGlobalArray];
    }
    else
        for (LocationItemPeople *sTemp in smAppDelegate.peopleList)
        {
            NSRange titleResultsRange = [sTemp.itemName rangeOfString:searchText2 options:NSCaseInsensitiveSearch];		
            if (titleResultsRange.length > 0)
            {
                [filteredList addObject:sTemp];
                NSLog(@"filtered friend: %@", sTemp.itemName);            
            }
            else
            {
            }
        }
    searchFlag2=false;
    
    NSLog(@"filteredList %@ %d  %d  imageDownloadsInProgress: %@",filteredList,[filteredList count],[eventListArray count], imageDownloadsInProgress);
    [self.circleListTableView reloadData];
}
//searchbar delegate method end

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)backButton:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
    [self.circleSearchBar resignFirstResponder];
}

- (void)setRsvpDone:(NSNotification *)notif
{
    NSLog(@"rsvp updated.");
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];    
}
- (void)dealloc {
    [labelNotifCount release];
    [super dealloc];
}
@end

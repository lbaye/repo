//
// BlockUnblockCircleViewController.m
// SocialMaps
//
// Created by Abdullah Md. Zubair on 9/20/12.
// Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "BlockUnblockCircleViewController.h"
#import "CircleListCheckBoxTableCell.h"
#import "UserCircle.h"
#import "UserFriends.h"
#import "AppDelegate.h"
#import "Globals.h"
#import "UtilityClass.h"
#import "CircleListTableCell.h"
#import "CircleListCheckBoxTableCell.h"
#import "CircleImageDownloader.h"

@interface BlockUnblockCircleViewController ()
- (void)startIconDownload:(UserFriends *)userFriend forIndexPath:(NSIndexPath *)indexPath;
@end

@implementation BlockUnblockCircleViewController
@synthesize blockTableView,blockSearchBar,downloadedImageDict;

__strong NSMutableArray *filteredList, *eventListArray;
__strong NSMutableDictionary *imageDownloadsInProgress;
__strong NSMutableDictionary *eventListIndex;
NSString *searchText3=@"";
AppDelegate *smAppDelegate;

//rsvpFlag=
bool searchFlag3=true;

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
    
    filteredList=[[self loadDummyData] mutableCopy];
    eventListArray=[[self loadDummyData] mutableCopy];
    
    downloadedImageDict=[[NSMutableDictionary alloc] init];
    
    [super viewDidLoad];
    UserFriends *aUserFriends=[[UserFriends alloc] init];
    // EventList *eventList=[[EventList alloc] init];
    // NSLog(@"eventList.eventListArr: %@ eventListGlobalArray: %@",eventList.eventListArr,eventListGlobalArray);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setRsvpDone:) name:NOTIF_SET_RSVP_EVENT_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllEventsDone:) name:NOTIF_GET_ALL_EVENTS_DONE object:nil];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    filteredList=[[self loadDummyData] mutableCopy];
    eventListArray=[[self loadDummyData] mutableCopy];
    // [self.mapContainer removeFromSuperview];
    // [smAppDelegate showActivityViewer:self.view];
    // [smAppDelegate.window setUserInteractionEnabled:NO];
    NSLog(@"activity start. %@",smAppDelegate);
    [self.blockSearchBar setText:@""];
}

-(void)viewDidAppear:(BOOL)animated
{
    // RestClient *rc=[[RestClient alloc] init];
    // [rc getAllEvents:@"Auth-Token":smAppDelegate.authToken];
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    filteredList=[[self loadDummyData] mutableCopy];
    eventListArray=[[self loadDummyData] mutableCopy];
    [self.blockTableView reloadData];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.blockSearchBar resignFirstResponder];
}

-(NSMutableArray *)loadDummyData
{
    for (int i=0; i<[friendListGlobalArray count]; i++)
    {
        NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
        UserFriends *aUserFriends=[[UserFriends alloc] init];
        aUserFriends=[friendListGlobalArray objectAtIndex:i];
        NSLog(@"aEvent.eventImageUrl: %@",aUserFriends.imageUrl);
        if (!(aUserFriends.imageUrl)||(aUserFriends.imageUrl==(NSString *)[NSNull null]))
        {
            aUserFriends.imageUrl=[[NSBundle mainBundle] pathForResource:@"event_item_bg" ofType:@"png"];
            NSLog(@"aUserFriends.imageUrl %@",aUserFriends.imageUrl);
        }
        [friendListGlobalArray replaceObjectAtIndex:i withObject:aUserFriends];
        [pool drain];
    }
    return friendListGlobalArray;
}

- (void)getAllEventsDone:(NSNotification *)notif
{
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    friendListGlobalArray=[[notif object] mutableCopy];
    NSLog(@"GOT SERVICE DATA EVENT.. :D %@",[notif object]);
    [self performSelector:@selector(hideActivity) withObject:nil afterDelay:1.0];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    [self viewDidLoad];
    filteredList=[[self loadDummyData] mutableCopy];
    eventListArray=[[self loadDummyData] mutableCopy];
    [self.blockTableView reloadData];
}

-(void)hideActivity
{
    NSArray* subviews = [NSArray arrayWithArray: self.view.subviews];
    UIActivityIndicatorView *indView;
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
    static NSString *CellIdentifier1 = @"circleListCheckBoxTableCell";
    int nodeCount = [filteredList count];
    
    UserFriends *userFriend=[[UserFriends alloc] init];
    userFriend = [filteredList objectAtIndex:indexPath.row];
    NSLog(@"[filteredList count] %d",[filteredList count]);
    
    CircleListTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    CircleListCheckBoxTableCell *cell1= [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
    if (cell == nil)
    {
        if (indexPath.row%2==1)
        {
            cell = [[CircleListTableCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:CellIdentifier];
        }
        else
        {
            cell1 = [[CircleListCheckBoxTableCell alloc]
                     initWithStyle:UITableViewCellStyleDefault
                     reuseIdentifier:CellIdentifier1];
        }
    }
    
    // Configure the cell...
    cell.addressLabel.text = [NSString stringWithFormat:@"event address"];
    cell.firstNameLabel.text = [NSString stringWithFormat:@"event name"];
    // cell.eventDetail.text = [NSString stringWithFormat:@"1"];
    cell.distanceLabel.text = [NSString stringWithFormat:@"event distance"];
    cell.showOnMapButton.tag=indexPath.row;
    [cell.showOnMapButton addTarget:self action:@selector(viewLocationButton:) forControlEvents:UIControlEventTouchUpInside];
    
    cell1.checkBoxButton.tag=indexPath.row;
    cell1.showOnMapButton.tag=indexPath.row;
    // NSLog(@"event.myResponse: %@",event.myResponse);
    NSLog(@"event: %@",userFriend);
    
    UIImage *eventPhoto = [UIImage imageNamed:@"1.png"];
    
    // Leave cells empty if there's no data yet
    if (nodeCount > 0)
    {
        // Set up the cell...
        
        
        NSString *cellValue;	
        cellValue=userFriend.userName;
        cell.firstNameLabel.text = cellValue;
        // cell.addressLabel.text=userFriend.userAddress;
        // cell.distanceLabel.text=[NSString stringWithFormat:@"%.2lfm",[userFriend.eventDistance doubleValue]];
        
        cell1.firstNameLabel.text = cellValue;
        // cell1.addressLabel.text=event.eventAddress;
        // cell1.distanceLabel.text=[NSString stringWithFormat:@"%.2lfm",[userFriend.eventDistance doubleValue]];
        
        
        // Only load cached images; defer new downloads until scrolling ends
        NSLog(@"nodeCount > 0 %@",userFriend.imageUrl);
        if (!userFriend.userProfileImage)
        {
            NSLog(@"!userFriends.userProfileImage");
            if (self.blockTableView.dragging == NO && self.blockTableView.decelerating == NO)
            {
                [self startIconDownload:userFriend forIndexPath:indexPath];
                NSLog(@"Downloading for %@ index=%d", cellValue, indexPath.row);
            }
            else if(searchFlag3==true)
            {
                NSLog(@"search flag true start download");
                [self startIconDownload:userFriend forIndexPath:indexPath];
            }
            
            NSLog(@"userFriends %@ %@",userFriend.userProfileImage,userFriend.imageUrl);
            // if a download is deferred or in progress, return a placeholder image
            cell.profilePicImgView.image=[UIImage imageNamed:@"event_item_bg.png"];
            cell1.profilePicImgView.image=[UIImage imageNamed:@"event_item_bg.png"];
        }
        
        if ([downloadedImageDict objectForKey:userFriend.userId])
        {
            cell.profilePicImgView.image=[downloadedImageDict objectForKey:userFriend.userId];
            cell1.profilePicImgView.image=[downloadedImageDict objectForKey:userFriend.userId];
        }
        else
        {
            cell.profilePicImgView.image=[UIImage imageNamed:@"event_item_bg.png"];
            cell1.profilePicImgView.image=[UIImage imageNamed:@"event_item_bg.png"];
        }
        
        // else if ([[imageDownloadsInProgress objectForKey:event.eventID]isEqual:event.eventID]&&([imageDownloadsInProgress objectForKey:event.eventImage]!=NULL) )
        // {
        // EventImageDownloader *iconDownloader=[imageDownloadsInProgress objectForKey:event.eventID];
        // cell.eventImage.image = iconDownloader.event.eventImage;
        // cell1.eventImage.image = iconDownloader.event.eventImage;
        // }
        // else
        // {
        // cell.eventImage.image = event.eventImage;
        // cell1.eventImage.image=event.eventImage;
        // }
    }
    
    NSLog(@"downloadedImageDict c: %@ %d",downloadedImageDict,[downloadedImageDict count]);
    // cell.eventImage.image = eventPhoto;
    // if (indexPath.row%2==0)
    // {
    // return cell;
    // }
    // else
    {
        return cell1;
    }
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
// UserFriends *aUserFriends=[[UserFriends alloc] init];
// aUserFriends=[filteredList objectAtIndex:indexPath.row];
// if (indexPath.row%2==0)
// {
// return 122;
// }
// else
// {
// return 172;
// }
// return 122;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    smAppDelegate.authToken=[prefs stringForKey:@"authToken"];
    
    // [smAppDelegate showActivityViewer:self.view];
    // RestClient *rc=[[RestClient alloc] init];
    // Event *aEvent=[[Event alloc] init];
    // aEvent=[filteredList objectAtIndex:indexPath.row];
    // globalEvent=[[Event alloc] init];
    // globalEvent=aEvent;
    // NSLog(@"globalEvent.eventImage: %@",globalEvent.eventImage);
    // UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    // ViewEventDetailViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"eventDetail"];
    // [self presentModalViewController:controller animated:YES];
    
}

//Lazy loading method starts

#pragma mark -
#pragma mark Table cell image support

- (void)startIconDownload:(UserFriends *)userFriends forIndexPath:(NSIndexPath *)indexPath
{
    CircleImageDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:userFriends.userId];
    if (iconDownloader == nil)
    {
        iconDownloader = [[CircleImageDownloader alloc] init];
        iconDownloader.userFriend = userFriends;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:userFriends.userId];
        NSLog(@"imageDownloadsInProgress %@",imageDownloadsInProgress);
        [iconDownloader startDownload];
        //[downloadedImageDict setValue:iconDownloader.event.eventImage forKey:event.eventID];
        NSLog(@"start downloads ... %@ %d",userFriends.userId, indexPath.row);
        [iconDownloader release];
    }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([filteredList count] > 0)
    {
        NSArray *visiblePaths = [self.blockTableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            UserFriends *userFriend = [filteredList objectAtIndex:indexPath.row];
            
            if (!userFriend.userProfileImage) // avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:userFriend forIndexPath:indexPath];
            }
        }
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSString *)eventID
{
    CircleImageDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:eventID];
    if (iconDownloader != nil)
    {
        NSNumber *indx = [eventListIndex objectForKey:eventID];
        UserFriends *userFriend = [eventListArray objectAtIndex:iconDownloader.indexPathInTableView.row];
        userFriend.userProfileImage = iconDownloader.userFriend.userProfileImage;
        
        CircleListTableCell *cell = (CircleListTableCell *)[self.blockTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        CircleListCheckBoxTableCell *cell1 = (CircleListCheckBoxTableCell*)[self.blockTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
        // Display the newly loaded image
        [downloadedImageDict setValue:iconDownloader.userFriend.userProfileImage forKey:eventID];
        cell.profilePicImgView.image = iconDownloader.userFriend.userProfileImage;
        cell1.profilePicImgView.image = iconDownloader.userFriend.userProfileImage;
        //[userProfileCopyImageArray replaceObjectAtIndex:indexPath.row withObject:iconDownloader.userFriends.userProfileImage];
        [self.blockTableView reloadData];
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
    searchText3=blockSearchBar.text;
    
    if ([searchText3 length]>0)
    {
        [self performSelector:@selector(searchResult) withObject:nil afterDelay:0.1];
        searchFlag3=true;
        [self.blockTableView reloadData];
        NSLog(@"searchText %@",searchText3);
    }
    else
    {
        searchText3=@"";
        //[self loadFriendListsData]; TODO: commented this
        [filteredList removeAllObjects];
        filteredList = [[NSMutableArray alloc] initWithArray: friendListGlobalArray];
        NSLog(@"eventListGlobalArray: %@",friendListGlobalArray);
        [self.blockTableView reloadData];
    }
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    // searchBarTextDidBeginEditing is called whenever
    // focus is given to the UISearchBar
    // call our activate method so that we can do some
    // additional things when the UISearchBar shows.
    searchText3=blockSearchBar.text;
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
    [self.blockTableView reloadData];
    [blockSearchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // Clear the search text
    // Deactivate the UISearchBar
    blockSearchBar.text=@"";
    searchText3=@"";
    
    [filteredList removeAllObjects];
    filteredList = [[NSMutableArray alloc] initWithArray: friendListGlobalArray];
    [self.blockTableView reloadData];
    [blockSearchBar resignFirstResponder];
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
    searchText3=blockSearchBar.text;
    searchFlag3=false;
    [self searchResult];
    [blockSearchBar resignFirstResponder];
}

-(void)searchResult
{
    searchText3 = blockSearchBar.text;
    NSLog(@"in search method..");
    [filteredList removeAllObjects];
    
    if ([searchText3 isEqualToString:@""])
    {
        NSLog(@"null string");
        blockSearchBar.text=@"";
        filteredList = [[NSMutableArray alloc] initWithArray: friendListGlobalArray];
    }
    else
        for (UserFriends *sTemp in friendListGlobalArray)
        {
            NSRange titleResultsRange = [sTemp.userName rangeOfString:searchText3 options:NSCaseInsensitiveSearch];	
            if (titleResultsRange.length > 0)
            {
                [filteredList addObject:sTemp];
                NSLog(@"filtered friend: %@", sTemp.userName);
            }
            else
            {
            }
        }
    searchFlag3=false;
    
    NSLog(@"filteredList %@ %d %d imageDownloadsInProgress: %@",filteredList,[filteredList count],[eventListArray count], imageDownloadsInProgress);
    [self.blockTableView reloadData];
}
//searchbar delegate method end

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)backButton:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
    [self.blockSearchBar resignFirstResponder];
}

-(IBAction)viewLocationButton:(id)sender
{
}

- (void)setRsvpDone:(NSNotification *)notif
{
    NSLog(@"rsvp updated.");
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
}
@end
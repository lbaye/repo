//
//  InviteFromCircleViewController.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 9/30/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "InviteFromCircleViewController.h"
#import "CircleListCheckBoxTableCell.h"
#import "UserCircle.h"
#import "AppDelegate.h"
#import "Globals.h"
#import "UtilityClass.h"
#import "CircleListTableCell.h"
#import "CircleListCheckBoxTableCell.h"
#import "CircleImageDownloader.h"
#import "LocationItemPeople.h"
#import "RestClient.h"
#import "UtilityClass.h"
#import "NotificationController.h"
#import "UIImageView+Cached.h"

@interface InviteFromCircleViewController ()
-(void)inviteButtonAction:(id)sender;
-(void)messageButtonAction:(id)sender;
-(void)checkBoxButtonAction:(id)sender;
-(IBAction)viewLocationButton:(id)sender;
@end

@implementation InviteFromCircleViewController
@synthesize inviteTableView,inviteSearchBar,downloadedImageDict;
@synthesize msgView;
@synthesize textViewNewMsg,selectAllButton;


__strong NSMutableArray *filteredList, *peopleListArray, *selectedPeople;
__strong NSMutableDictionary *imageDownloadsInProgress;
__strong NSMutableDictionary *eventListIndex;
NSString *searchText4=@"";
AppDelegate *smAppDelegate;
int inviteCountSel=0;

bool searchFlag4=true;

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
    peopleListArray=[[NSMutableArray alloc] init];
    selectedPeople=[[NSMutableArray alloc] init];
    smAppDelegate=[[AppDelegate alloc] init];
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    imageDownloadsInProgress=[[NSMutableDictionary alloc] init];
    [imageDownloadsInProgress retain];
    eventListIndex=[[NSMutableDictionary alloc] init];
    
    filteredList=[[self loadDummyData] mutableCopy];
    peopleListArray=[[self loadDummyData] mutableCopy];
    
    downloadedImageDict=[[NSMutableDictionary alloc] init];
    NSLog(@"smAppDelegate.peopleList %@",smAppDelegate.peopleList);
    NSLog(@"smAppDelegate.peopleIndex %@",smAppDelegate.peopleIndex);
    
    [super viewDidLoad];
    NSArray *subviews = [inviteSearchBar subviews];
    UIButton *cancelButton = [subviews objectAtIndex:3];
    cancelButton.tintColor = [UIColor darkGrayColor];
    // Do any additional setup after loading the view.
    labelNotifCount.text = [NSString stringWithFormat:@"%d", [UtilityClass getNotificationCount]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [msgView removeFromSuperview];
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    filteredList=[[self loadDummyData] mutableCopy];
    peopleListArray=[[self loadDummyData] mutableCopy];
    NSLog(@"activity start. %@",smAppDelegate);
    [self.inviteSearchBar setText:@""];
    smAppDelegate.currentModelViewController = self;
}

-(void)viewDidAppear:(BOOL)animated
{
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    filteredList=[[self loadDummyData] mutableCopy];
    peopleListArray=[[self loadDummyData] mutableCopy];
    [self.inviteTableView reloadData];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.inviteSearchBar resignFirstResponder];
}

-(NSMutableArray *)loadDummyData
{
    NSMutableArray *peopleList=[[[NSMutableArray alloc] init] autorelease];
    
    for (int i=0; i<[smAppDelegate.peopleList count]; i++)
    {
        
        LocationItemPeople *people=[smAppDelegate.peopleList objectAtIndex:i];
        if ([people.userInfo.source isEqualToString:@"facebook"])
        {
            [peopleList addObject:[smAppDelegate.peopleList objectAtIndex:i]];            
        }
    }
    return peopleList;
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
    peopleListArray=[[self loadDummyData] mutableCopy];
    [self.inviteTableView reloadData];
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
    static NSString *CellIdentifier1 = @"circleListCheckBoxTableCell";
    int nodeCount = [filteredList count];
    
    LocationItemPeople *people = (LocationItemPeople *)[filteredList objectAtIndex:indexPath.row];
    NSLog(@"[filteredList count] %d",[filteredList count]);
    
    CircleListCheckBoxTableCell *cell1= [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
    
    // Configure the cell...    
    cell1.checkBoxButton.tag=indexPath.row;
    cell1.showOnMapButton.tag=indexPath.row;
    cell1.inviteButton.tag=indexPath.row ;
    cell1.messageButton.tag=indexPath.row ;
    cell1.checkBoxButton.tag=indexPath.row ;
    NSLog(@"event: %@",people);
    
    // Leave cells empty if there's no data yet
    if (nodeCount > 0)
    {
        // Set up the cell...
        
        NSString *cellValue;	
        cellValue=people.itemName;
        cell1.firstNameLabel.text = cellValue;
        cell1.addressLabel.text=people.itemAddress;
        Geolocation *geoLocation=[[Geolocation alloc] init];
        geoLocation.latitude=people.userInfo.currentLocationLat;
        geoLocation.longitude=people.userInfo.currentLocationLng;
        cell1.distanceLabel.text=[UtilityClass getDistanceWithFormattingFromLocation:geoLocation];
        [geoLocation release];
        // Only load cached images; defer new downloads until scrolling ends
        NSLog(@"nodeCount > 0 %@",people.itemBg);
        
        [cell1.footerView.layer setCornerRadius:6.0f];
        [cell1.footerView.layer setMasksToBounds:YES];
        cell1.footerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.6];
        cell1.regStsImgView.layer.borderColor=[[UIColor lightTextColor] CGColor];
        cell1.regStsImgView.userInteractionEnabled=YES;
        cell1.regStsImgView.layer.borderWidth=1.0;
        cell1.regStsImgView.layer.masksToBounds = YES;
        [cell1.regStsImgView.layer setCornerRadius:5.0];
        if ([people.userInfo.regMedia isEqualToString:@"fb"]) 
        {
            NSLog(@"reg media fb %@",[UIImage imageNamed:@"icon_facebook.png"]);
            cell1.regStsImgView.image=[UIImage imageNamed:@"icon_facebook.png"];
            cell1.inviteButton.hidden=NO;
        }
        else if ([people.userInfo.source isEqualToString:@"facebook"])
        {
            cell1.regStsImgView.image = [UIImage imageNamed:@"fbCheckinIcon.png"];
            cell1.regStsImgView.userInteractionEnabled=YES;
            cell1.regStsImgView.layer.masksToBounds = YES;
            [cell1.regStsImgView.layer setCornerRadius:5.0];
        }
        else
        {
            cell1.regStsImgView.image=[UIImage imageNamed:@"sm_icon@2x.png"];
            cell1.inviteButton.hidden=YES;
        }
        
        if ([people.userInfo.friendshipStatus isEqualToString:@"friend"]) 
        {
            cell1.friendShipStatus.hidden=NO;
        }
        else
        {
            cell1.friendShipStatus.hidden=YES;
        }
        
        
        if ([selectedPeople containsObject:[filteredList objectAtIndex:indexPath.row]])
        {
            [cell1.checkBoxButton setImage:[UIImage imageNamed:@"checkbox_checked.png"] forState:UIControlStateNormal];
        }
        else
        {
            [cell1.checkBoxButton setImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
        }
        
        [cell1.profilePicImgView setImageForUrlIfAvailable:[NSURL URLWithString:people.itemAvaterURL]];
        cell1.profilePicImgView.layer.borderColor=[[UIColor lightTextColor] CGColor];
        cell1.profilePicImgView.userInteractionEnabled=YES;
        cell1.profilePicImgView.layer.borderWidth=1.0;
        cell1.profilePicImgView.layer.masksToBounds = YES;
        [cell1.profilePicImgView.layer setCornerRadius:5.0];
        [cell1.showOnMapButton addTarget:self action:@selector(viewLocationButton:) forControlEvents:UIControlEventTouchUpInside];
        [cell1.inviteButton addTarget:self action:@selector(inviteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell1.messageButton addTarget:self action:@selector(messageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell1.checkBoxButton addTarget:self action:@selector(checkBoxButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell1.inviteButton.layer setCornerRadius:6.0f];
        [cell1.inviteButton.layer setMasksToBounds:YES];
        [cell1.messageButton.layer setCornerRadius:6.0f];
        [cell1.messageButton.layer setMasksToBounds:YES];
        
        [cell1.coverPicImgView setImageForUrlIfAvailable:[NSURL URLWithString:people.userInfo.coverPhotoUrl]];
        [self showIsOnlineImage:cell1.profilePicImgView :people];
    }
    
    NSLog(@"downloadedImageDict c: %@ %d",downloadedImageDict,[downloadedImageDict count]);
    return cell1;
}


- (void)showIsOnlineImage:(UIView*)profileImage :(LocationItemPeople*)people
{
    UIView *imageViewIcon = profileImage;
    
    if ([imageViewIcon viewWithTag:20101] == nil) 
    {
        UIImageView *imageViewIsOnline = [[UIImageView alloc] initWithFrame:CGRectMake(5, imageViewIcon.frame.size.height - 15, 10, 10)];
        imageViewIsOnline.tag = 20101;
        
        [imageViewIcon addSubview:imageViewIsOnline];
        [imageViewIsOnline release];
    }
    
    if (!people.userInfo.external) {
        
        UIImageView *imageIsOnline = (UIImageView*)[imageViewIcon viewWithTag:20101];
        
        if (people.userInfo.isOnline) 
        {
            NSArray *imageArray = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"online_dot.png"], [UIImage imageNamed:@"blank.png"], nil];
            imageIsOnline.animationDuration = 2;
            imageIsOnline.animationImages = imageArray;
            [imageIsOnline startAnimating];
            [imageArray release];
        } else {
            imageIsOnline.image = [UIImage imageNamed:@"offline_dot.png"]; 
        }
    } else {
        [[imageViewIcon viewWithTag:20101] removeFromSuperview];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    smAppDelegate.authToken=[prefs stringForKey:@"authToken"];
    
}

//Lazy loading method starts

- (void)loadImagesForOnscreenRows {
    
    if ([filteredList count] > 0) {
        
        NSArray *visiblePaths = [inviteTableView indexPathsForVisibleRows];
        
        for (NSIndexPath *indexPath in visiblePaths) {
            
            CircleListCheckBoxTableCell *cell = (CircleListCheckBoxTableCell *)[inviteTableView cellForRowAtIndexPath:indexPath];
            
            //get the imageView on cell
            
            UIImageView *imgCover = (UIImageView*) [cell coverPicImgView];
            
            LocationItemPeople *anItem = (LocationItemPeople *)[filteredList objectAtIndex:indexPath.row];
            
            if (anItem.userInfo.coverPhotoUrl)
                [imgCover loadFromURL:[NSURL URLWithString:anItem.userInfo.coverPhotoUrl]];
            
            if (anItem.itemAvaterURL)
                [cell.profilePicImgView loadFromURL:[NSURL URLWithString:anItem.itemAvaterURL]];
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

-(IBAction)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)selectedUser:(id)sender
{
    if ([selectedPeople count]==0)
    {
        [UtilityClass showAlert:@"" :@"Please select any Facebook friends"];
    }
    else 
    {
        Facebook *facebookApi = [[FacebookHelper sharedInstance] facebookApi];
        if ([facebookApi isSessionValid])
        {
            NSMutableArray *idArr=[[NSMutableArray alloc] init];
            for (int i=0; i<[selectedPeople count]; i++)
            {
                [idArr addObject:((LocationItemPeople *)[selectedPeople objectAtIndex:i]).userInfo.userId];
            }
            FacebookHelper *fbHelper=[[FacebookHelper alloc] init];
            [fbHelper inviteFriends:idArr];
            [idArr release];
            [fbHelper release];
        }
    }
}

-(IBAction)selectAllpeople:(id)sender
{
    if (inviteCountSel%2==0)
    {
        [selectAllButton setTitle:@"Unselect all users" forState:UIControlStateNormal];
        selectedPeople =[filteredList mutableCopy];
        [self.inviteTableView reloadData];
    }
    else
    {
        [selectAllButton setTitle:@"Select all users" forState:UIControlStateNormal];
        [selectedPeople removeAllObjects];
        [self.inviteTableView reloadData];
    }
    inviteCountSel++;
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
    NSIndexPath *clickedButtonPath = [self.inviteTableView indexPathForCell:clickedCell];
    
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
        [userIDs release];
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

#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished

//Lazy loading method ends.


//search bar delegate method starts
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // We don't want to do anything until the user clicks
    // the 'Search' button.
    // If you wanted to display results as the user types
    // you would do that here.
    searchText4=inviteSearchBar.text;
    
    if ([searchText4 length]>0)
    {
        [self performSelector:@selector(searchResult) withObject:nil afterDelay:0.1];
        searchFlag4=true;
        [self.inviteTableView reloadData];
        NSLog(@"searchText %@",searchText4);
    }
    else
    {
        searchText4=@"";
        [filteredList removeAllObjects];
        filteredList = [[NSMutableArray alloc] initWithArray: [self loadDummyData]];
        NSLog(@"eventListGlobalArray: %@",friendListGlobalArray);
        [self.inviteTableView reloadData];
    }
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    // searchBarTextDidBeginEditing is called whenever
    // focus is given to the UISearchBar
    // call our activate method so that we can do some
    // additional things when the UISearchBar shows.
    searchText4=inviteSearchBar.text;
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
    [self.inviteTableView reloadData];
    [inviteSearchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // Clear the search text
    // Deactivate the UISearchBar
    inviteSearchBar.text=@"";
    searchText4=@"";
    
    [filteredList removeAllObjects];
    filteredList = [[NSMutableArray alloc] initWithArray: [self loadDummyData]];
    [self.inviteTableView reloadData];
    [inviteSearchBar resignFirstResponder];
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
    searchText4=inviteSearchBar.text;
    searchFlag4=false;
    [self searchResult];
    [inviteSearchBar resignFirstResponder];
}

-(void)searchResult
{
    searchText4 = inviteSearchBar.text;
    NSLog(@"in search method..");
    [filteredList removeAllObjects];
    
    if ([searchText4 isEqualToString:@""])
    {
        NSLog(@"null string");
        inviteSearchBar.text=@"";
        filteredList = [[NSMutableArray alloc] initWithArray: [self loadDummyData]];
    }
    else
        for (LocationItemPeople *sTemp in smAppDelegate.peopleList)
        {
            NSRange titleResultsRange = [sTemp.itemName rangeOfString:searchText4 options:NSCaseInsensitiveSearch];	
            if (titleResultsRange.length > 0)
            {
                [filteredList addObject:sTemp];
                NSLog(@"filtered friend: %@", sTemp.itemName);
            }
            else
            {
            }
        }
    searchFlag4=false;
    
    NSLog(@"filteredList %@ %d %d imageDownloadsInProgress: %@",filteredList,[filteredList count],[peopleListArray count], imageDownloadsInProgress);
    [self.inviteTableView reloadData];
}
//searchbar delegate method end

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)backButton:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
    [self.inviteSearchBar resignFirstResponder];
}

-(void)inviteButtonAction:(id)sender
{
}

-(void)messageButtonAction:(id)sender
{
    [self.view addSubview:msgView];
}

-(void)checkBoxButtonAction:(id)sender
{
    NSLog(@"yesButton tag: %d",[sender tag]);
    CircleListCheckBoxTableCell *clickedCell = (CircleListCheckBoxTableCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.inviteTableView indexPathForCell:clickedCell];
    NSLog(@"clickedButtonPath %@",clickedButtonPath);
    if ([selectedPeople containsObject:[filteredList objectAtIndex:[sender tag]]])
    {
        [selectedPeople removeObject:[filteredList objectAtIndex:[sender tag]]];
        [clickedCell.checkBoxButton setImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
    }
    else
    {
        [selectedPeople addObject:[filteredList objectAtIndex:[sender tag]]];
        [clickedCell.checkBoxButton setImage:[UIImage imageNamed:@"checkbox_checked.png"] forState:UIControlStateNormal];        
    }
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
- (void)dealloc {
    [labelNotifCount release];
    [super dealloc];
}
@end
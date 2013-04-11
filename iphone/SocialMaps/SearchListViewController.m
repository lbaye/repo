//
//  SearchListViewController.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on ১১/৪/১৩.
//  Copyright (c) ২০১৩ Genweb2. All rights reserved.
//

#import "SearchListViewController.h"
#import "AppDelegate.h"
#import "LocationItemPeople.h"
#import "Globals.h"
#import "CircleListTableCell.h"
#import "UtilityClass.h"
#import "UIImageView+Cached.h"

@interface SearchListViewController ()

@end

@implementation SearchListViewController
@synthesize searchTableView, delegate;
@synthesize searchText, searchBar;
@synthesize filteredList;

AppDelegate *smAppDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    filteredList=[[self loadDummyData] mutableCopy];
//    peopleListArray=[[self loadDummyData] mutableCopy];
    NSLog(@"count: %d %d",[filteredList count],[peopleListArray count]);
    searchBar.text = searchText;
    [searchTableView reloadData];
    [self loadImagesForOnscreenRows];
	// Do any additional setup after loading the view.
}

-(NSMutableArray *)loadDummyData
{
    NSMutableArray *peopleList=[[[NSMutableArray alloc] init] autorelease];
    
    for (int i=0; i<[smAppDelegate.displayList count]; i++)
    {
        [peopleList addObject:[smAppDelegate.displayList objectAtIndex:i]];
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
    [self.searchTableView reloadData];
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

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (!decelerate)
        [self loadImagesForOnscreenRows];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self loadImagesForOnscreenRows];
    
}

- (void)loadImagesForOnscreenRows {
    
    if ([filteredList count] > 0) {
        
        NSArray *visiblePaths = [searchTableView indexPathsForVisibleRows];
        
        for (NSIndexPath *indexPath in visiblePaths) {
            
            CircleListTableCell *cell = (CircleListTableCell *)[searchTableView cellForRowAtIndexPath:indexPath];
            
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
    static NSString *CellIdentifier1 = @"searchListTableCell";
    int nodeCount = [filteredList count];
    
    LocationItem *item = (LocationItem *)[filteredList objectAtIndex:indexPath.row];
    NSLog(@"[filteredList count] %d",[filteredList count]);
    
    CircleListTableCell *cell1= [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
    
    // Configure the cell...
    cell1.showOnMapButton.tag=indexPath.row;
    cell1.inviteButton.tag=indexPath.row ;
    cell1.messageButton.tag=indexPath.row ;
    NSLog(@"cell1: %@",cell1);
    
    // Leave cells empty if there's no data yet
    if (nodeCount > 0)
    {
        // Set up the cell...
        
        NSString *cellValue;
        cellValue=item.itemName;
        cell1.firstNameLabel.text = cellValue;
        
        CGSize   strSize = [cell1.addressLabel.text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:13.0f]];
        ((UIScrollView*)cell1.addressLabel.superview).contentSize = strSize;
        CGRect addressLabelFrame = cell1.addressLabel.frame;
        addressLabelFrame = CGRectMake(addressLabelFrame.origin.x, addressLabelFrame.origin.y, strSize.width, strSize.height);
        cell1.addressLabel.frame = addressLabelFrame;
        
        cell1.addressLabel.text=item.itemAddress;
        Geolocation *geoLocation=[[Geolocation alloc] init];
        geoLocation.latitude=[NSString stringWithFormat:@"%lf",item.coordinate.latitude];
        geoLocation.latitude=[NSString stringWithFormat:@"%lf",item.coordinate.longitude];
        cell1.distanceLabel.text=[UtilityClass getDistanceWithFormattingFromLocation:geoLocation];
        [geoLocation release];
        // Only load cached images; defer new downloads until scrolling ends
        NSLog(@"nodeCount > 0 %lf  %lf  %@  %@",item.coordinate.latitude,item.coordinate.longitude, smAppDelegate.currPosition.latitude,smAppDelegate.currPosition.longitude);
        
        [cell1.footerView.layer setCornerRadius:6.0f];
        [cell1.footerView.layer setMasksToBounds:YES];
        cell1.footerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.6];
        cell1.regStsImgView.layer.borderColor=[[UIColor lightTextColor] CGColor];
        cell1.regStsImgView.userInteractionEnabled=YES;
        cell1.regStsImgView.layer.borderWidth=1.0;
        cell1.regStsImgView.layer.masksToBounds = YES;
        [cell1.regStsImgView.layer setCornerRadius:5.0];
        
        [cell1.profilePicImgView setImageForUrlIfAvailable:[NSURL URLWithString:item.itemAvaterURL]];
        cell1.profilePicImgView.layer.borderColor=[[UIColor lightTextColor] CGColor];
        cell1.profilePicImgView.userInteractionEnabled=YES;
        cell1.profilePicImgView.layer.borderWidth=1.0;
        cell1.profilePicImgView.layer.masksToBounds = YES;
        [cell1.profilePicImgView.layer setCornerRadius:5.0];
        [cell1.showOnMapButton addTarget:self action:@selector(viewLocationButton:) forControlEvents:UIControlEventTouchUpInside];
        [cell1.inviteButton addTarget:self action:@selector(inviteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell1.messageButton addTarget:self action:@selector(messageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell1.inviteButton.layer setCornerRadius:6.0f];
        [cell1.inviteButton.layer setMasksToBounds:YES];
        [cell1.messageButton.layer setCornerRadius:6.0f];
        [cell1.messageButton.layer setMasksToBounds:YES];
        [cell1.coverPicImgView setImageForUrlIfAvailable:item.itemCoverPhotoUrl];
    }
    
    return cell1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self removeSearchViewWithLocation:(LocationItem *) [filteredList objectAtIndex:indexPath.row]];
}

-(void)removeSearchView
{
//    [self.view removeFromSuperview];
    [self dismissModalViewControllerAnimated:YES];
    [self.delegate removeSearchView];
}

-(void)removeSearchViewWithLocation:(LocationItem *)item
{
    [self dismissModalViewControllerAnimated:YES];
    [self.delegate removeSearchViewWithLocation:item];
}

-(IBAction)cancelSearchAction:(id)sender
{
    [self removeSearchView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

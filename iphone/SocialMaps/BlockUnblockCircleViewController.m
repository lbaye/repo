//
// BlockUnblockCircleViewController.m
// SocialMaps
//
// Created by Abdullah Md. Zubair on 9/20/12.
// Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "BlockUnblockCircleViewController.h"
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
#import "NotificationController.h"
#import "UserFriends.h"

@interface BlockUnblockCircleViewController ()
- (void)startIconDownload:(LocationItemPeople *)people forIndexPath:(NSIndexPath *)indexPath;
-(void)inviteButtonAction:(id)sender;
-(void)messageButtonAction:(id)sender;
-(void)checkBoxButtonAction:(id)sender;
-(IBAction)viewLocationButton:(id)sender;
@end

@implementation BlockUnblockCircleViewController
@synthesize blockTableView,blockSearchBar,downloadedImageDict;
@synthesize msgView,textViewNewMsg,selectAllButton;

__strong NSMutableArray *filteredList, *peopleListArray, *selectedPeople, *blockedIdArr, *allUserIdArr;
__strong NSMutableDictionary *imageDownloadsInProgress;
__strong NSMutableDictionary *eventListIndex;
NSString *searchText3=@"";
AppDelegate *smAppDelegate;
RestClient *rc;
NSMutableArray *blockedUser,*blockedUserRemoveArr;
LocationItemPeople *unblockedPeople;
int blockCountSel=0;

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
    rc=[[RestClient alloc] init];
    filteredList=[[NSMutableArray alloc] init];
    peopleListArray=[[NSMutableArray alloc] init];
    selectedPeople=[[NSMutableArray alloc] init];
    blockedIdArr=[[NSMutableArray alloc] init]; 
    allUserIdArr=[[NSMutableArray alloc] init];
    blockedUser=[[NSMutableArray alloc] init];
    smAppDelegate=[[AppDelegate alloc] init];
    blockedUserRemoveArr=[[NSMutableArray alloc] init];
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    imageDownloadsInProgress=[[NSMutableDictionary alloc] init];
    [imageDownloadsInProgress retain];
    eventListIndex=[[NSMutableDictionary alloc] init];
    unblockedPeople=[[LocationItemPeople alloc] init];
    
    filteredList=[[self loadDummyData] mutableCopy];
    peopleListArray=[[self loadDummyData] mutableCopy];
    
    downloadedImageDict=[[NSMutableDictionary alloc] init];
    NSLog(@"smAppDelegate.peopleList %@",smAppDelegate.peopleList);
    NSLog(@"smAppDelegate.peopleIndex %@",smAppDelegate.peopleIndex);

    [super viewDidLoad];
    NSArray *subviews = [self.blockSearchBar subviews];
    NSLog(@"%@",subviews);
    UIButton *cancelButton = [subviews objectAtIndex:2];
    cancelButton.tintColor = [UIColor grayColor];
//    cancelButton.titleLabel.text=@"   OK";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getBlockUserListDone:) name:NOTIF_GET_ALL_BLOCKED_USERS_DONE object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blockUsresDone:) name:NOTIF_SET_BLOCKED_USERS_DONE object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unBlockUsresDone:) name:NOTIF_SET_UNBLOCKED_USERS_DONE object:nil];

    
//    [rc getBlockUserList:@"Auth-Token" :smAppDelegate.authToken];
//    [smAppDelegate  showActivityViewer:self.view];
//    [smAppDelegate.window setUserInteractionEnabled:NO];
    
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
    // [self.mapContainer removeFromSuperview];
    // [smAppDelegate showActivityViewer:self.view];
    // [smAppDelegate.window setUserInteractionEnabled:NO];
    NSLog(@"activity start. %@",smAppDelegate);
    [self.blockSearchBar setText:@""];
    
    smAppDelegate.currentModelViewController = self;
}

-(void)viewDidAppear:(BOOL)animated
{
    // RestClient *rc=[[RestClient alloc] init];
    // [rc getAllEvents:@"Auth-Token":smAppDelegate.authToken];
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    filteredList=[[self loadDummyData] mutableCopy];
//    peopleListArray=[[self loadDummyData] mutableCopy];
    [self.blockTableView reloadData];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.blockSearchBar resignFirstResponder];
}

-(NSMutableArray *)loadDummyData
{
    NSMutableArray *peopleList=[[NSMutableArray alloc] init];
    
    for (int i=0; i<[smAppDelegate.peopleList count]; i++)
    {
        
        LocationItemPeople *people=[smAppDelegate.peopleList objectAtIndex:i];
        if (![people.userInfo.source isEqualToString:@"facebook"])
        {
            [peopleList addObject:[smAppDelegate.peopleList objectAtIndex:i]];            
        }
    }
    return peopleList;
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [blockSearchBar setShowsCancelButton:YES animated:NO];
    for (UIView *subView in blockSearchBar.subviews){
        if([subView isKindOfClass:[UIButton class]]){
            [(UIButton*)subView setTitle:@"   OK" forState:UIControlStateNormal];
            [(UIButton*)subView setBackgroundImage:[UIImage imageNamed:@"search_ok_button.png"] forState:UIControlStateNormal];
        }
    }
}

- (void)getBlockUserListDone:(NSNotification *)notif
{
    NSLog(@"[notif object]: %@",[notif object]);
    [blockedUser removeAllObjects];
    blockedUser=[notif object];
//    [self removeBlockedUser];
//    for(int i=0; i<[blockedUser count];i++)
//    {
//        LocationItemPeople *locItem=[[LocationItemPeople alloc] init];
//        People *ppl=[[People alloc] init];
//        ppl=[blockedUser objectAtIndex:i];
//        locItem.itemAddress=ppl.city;
//        locItem.itemBg=[UIImage imageNamed:@"cover_pic_default.png"];
//        locItem.itemCategory=@"";
//        locItem.itemDistance=[ppl.distance doubleValue];
//        locItem.itemIcon=[UIImage imageNamed:@"thum.png"];
//        locItem.itemName=ppl.firstName;
//        locItem.itemType=0;
//        locItem.userInfo=ppl;
//        
//        [peopleListArray addObject:locItem];
//        NSLog(@"locItem %@ %@",locItem,ppl);
//        [blockedIdArr addObject:ppl.userId];
//        [blockedUser replaceObjectAtIndex:i withObject:locItem];
//    }
//    filteredList=[peopleListArray mutableCopy];
//    NSLog(@"blockedUser: %@ filteredList: %@",blockedUser,filteredList);
//    [allUserIdArr removeAllObjects];
//    NSLog(@"[peopleListArray count]: %d",[peopleListArray count]);
//    for (int i=0; i<[peopleListArray count]; i++)
//    {
//        NSLog(@"index: %d",i);
//        if ([[peopleListArray objectAtIndex:i] isKindOfClass:[LocationItemPeople class]]) 
//        {
//            NSLog(@"((LocationItem *)[peopleListArray objectAtIndex:i]).itemName %@",((LocationItem *)[peopleListArray objectAtIndex:i]).itemName);
//            [allUserIdArr addObject:((LocationItemPeople *)[peopleListArray objectAtIndex:i]).userInfo.userId];
//        }
//    }
    
    [self.blockTableView reloadData];
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
}

- (void)blockUsresDone:(NSNotification *)notif
{
    NSLog(@"block user done");
    blockSearchBar.text=@"";
    [self searchResult];
//    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    NSLog(@"[notif object]: %@",[notif object]);
//    blockedUser=[[NSMutableArray alloc] init];
//    blockedUser=[notif object];
//    peopleListArray=[[self loadDummyData] mutableCopy];
//    [self removeBlockedPeople];
//    //blocked people should remove from here
//    NSLog(@"blockedUserRemoveArr: %@",blockedUserRemoveArr);
//    NSLog(@"blockedUser %d",[blockedUser count]);
////    [self removeBlockedUser];
//
//    for(int i=0; i<[blockedUser count];i++)
//    {
//        LocationItemPeople *locItem=[[LocationItemPeople alloc] init];
//        People *ppl=[[People alloc] init];
//        ppl=[blockedUser objectAtIndex:i];
//        locItem.itemAddress=ppl.city;
//        locItem.itemBg=[UIImage imageNamed:@"cover_pic_default.png"];
//        locItem.itemCategory=@"blocked";
//        locItem.itemDistance=[ppl.distance doubleValue];
//        locItem.itemIcon=[UIImage imageNamed:@"thum.png"];
//        locItem.itemName=ppl.firstName;
//        locItem.itemType=0;
//        locItem.userInfo=ppl;
//        [peopleListArray addObject:locItem];
//        NSLog(@"locItem %@ %@",locItem,ppl);
//        [blockedIdArr addObject:ppl.userId];
//        [blockedUser replaceObjectAtIndex:i withObject:locItem];
//    }
//    filteredList=[peopleListArray mutableCopy];
//    [allUserIdArr removeAllObjects];
//    NSLog(@"[peopleListArray count]: %d",[peopleListArray count]);
//    for (int i=0; i<[peopleListArray count]; i++)
//    {        
//        if ([[peopleListArray objectAtIndex:i] isKindOfClass:[LocationItemPeople class]]) 
//        {
//            [allUserIdArr addObject:((LocationItemPeople *)[peopleListArray objectAtIndex:i]).userInfo.userId];
//        }
//    }
//    NSLog(@"all user index: %d  %d",[allUserIdArr count],[peopleListArray count]);
    [self.blockTableView reloadData];
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
}

- (void)unBlockUsresDone:(NSNotification *)notif
{
    NSLog(@"unblock user done");    
    blockSearchBar.text=@"";    
    [self searchResult];
//    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];   
//    NSLog(@"[notif object]: %@",[notif object]);
//    blockedUser=[[NSMutableArray alloc] init];
//    blockedUser=[notif object];
//    peopleListArray=[[self loadDummyData] mutableCopy];
//    [peopleListArray addObject:unblockedPeople];
//    NSLog(@"before unblocked: %d",[peopleListArray count]);
//    //remove all blocked user
//    for (int i=0; i<[peopleListArray count]; i++)
//    {
//        NSLog(@"user id: %@",((LocationItemPeople *)[peopleListArray objectAtIndex:i]).userInfo.userId);
//        if ([blockedIdArr containsObject:((LocationItemPeople *)[peopleListArray objectAtIndex:i]).userInfo.userId])
//        {
//            NSLog(@"find matching");
//            [peopleListArray removeObjectAtIndex:i];
//            [blockedIdArr removeObject:[allUserIdArr objectAtIndex:i]];
//        }
//    }
//    NSLog(@"after unblocked: %d",[peopleListArray count]);
//    for(int i=0; i<[blockedUser count];i++)
//    {
//        LocationItemPeople *locItem=[[LocationItemPeople alloc] init];
//        People *ppl=[[People alloc] init];
//        ppl=[blockedUser objectAtIndex:i];
//        locItem.itemAddress=ppl.city;
//        locItem.itemBg=[UIImage imageNamed:@"cover_pic_default.png"];
//        locItem.itemCategory=@"blocked";
//        locItem.itemDistance=[ppl.distance doubleValue];
//        locItem.itemIcon=[UIImage imageNamed:@"thum.png"];
//        locItem.itemName=ppl.firstName;
//        locItem.itemType=0;
//        locItem.userInfo=ppl;
//        
////        if (![allUserIdArr containsObject:ppl.userId])
//        {
//            [peopleListArray addObject:locItem];
//            NSLog(@"locItem %@ %@",locItem,ppl);
//            [blockedIdArr addObject:ppl.userId];
//        }
//        [blockedUser replaceObjectAtIndex:i withObject:locItem];
//    }
//    filteredList=[peopleListArray mutableCopy];
//    [allUserIdArr removeAllObjects];
//    NSLog(@"[peopleListArray count]: %d",[peopleListArray count]);
//    for (int i=0; i<[peopleListArray count]; i++)
//    {
//        NSLog(@"index: %d",i);
//        if ([[peopleListArray objectAtIndex:i] isKindOfClass:[LocationItemPeople class]]) 
//        {
//            NSLog(@"((LocationItem *)[peopleListArray objectAtIndex:i]).itemName %@",((LocationItem *)[peopleListArray objectAtIndex:i]).itemName);
//            [allUserIdArr addObject:((LocationItemPeople *)[peopleListArray objectAtIndex:i]).userInfo.userId];
//        }
//    }
    
    [self.blockTableView reloadData];
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
}

-(void)removeBlockedPeople
{
    for (int i=0; i<[peopleListArray count]; i++)
    {
        if ([blockedUserRemoveArr containsObject:[peopleListArray objectAtIndex:i]])
        {
            [peopleListArray removeObject:[peopleListArray objectAtIndex:i]];
        }
    }
}

-(void)removeBlockedUser
{
    NSMutableArray *userIDArr=[[NSMutableArray alloc] init];
    for (int i=0; i<[blockedUser count]; i++)
    {
        if ([[blockedUser objectAtIndex:i] isKindOfClass:[LocationItemPeople class]]) 
        {
            [userIDArr addObject:((LocationItemPeople *)[blockedUser objectAtIndex:i]).userInfo.userId];
        }
        else if ([[blockedUser objectAtIndex:i] isKindOfClass:[People class]]) 
        {
            [userIDArr addObject:((People *)[blockedUser objectAtIndex:i]).userId];
        }
    }
    
    for (int i=0; i<[peopleListArray count]; i++)
    {
        if ([userIDArr containsObject:((LocationItemPeople *)[peopleListArray objectAtIndex:i]).userInfo.userId])
        {
            NSLog(@"removed user from block list %@",((LocationItemPeople *)[peopleListArray objectAtIndex:i]).userInfo.firstName);            
            [peopleListArray removeObjectAtIndex:i];
        }
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
//    [CircleImageDownloader cancelDownload];
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

-(IBAction)blockUser:(id)sender
{
    CircleListCheckBoxTableCell *clickedCell = (CircleListCheckBoxTableCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.blockTableView indexPathForCell:clickedCell];
    
//    [self removeBlockedUser];
//    [allUserIdArr removeObjectAtIndex:clickedButtonPath.row];
    
    [smAppDelegate showActivityViewer:self.view];
    [smAppDelegate.window setUserInteractionEnabled:NO];    
    
    //Block user operation on people list starts here
    NSLog(@"[filteredList count] %d",[filteredList count]);
    if ([filteredList count]>clickedButtonPath.row) 
    {
        LocationItemPeople *ppl=[filteredList objectAtIndex:clickedButtonPath.row];
        ppl.userInfo.blockStatus=@"blocked";
        [filteredList replaceObjectAtIndex:clickedButtonPath.row withObject:ppl];
    }
//    [smAppDelegate.peopleList replaceObjectAtIndex:[smAppDelegate.peopleList indexOfObject:[filteredList objectAtIndex:clickedButtonPath.row]] withObject:ppl];
    //Block user operation on people list ends here
    
    NSLog(@"block user %d",[allUserIdArr count]);
    [rc blockUserList:@"Auth-Token" :smAppDelegate.authToken :[NSMutableArray arrayWithObjects:((LocationItemPeople *)[filteredList objectAtIndex:clickedButtonPath.row]).userInfo.userId, nil]];
//    blockedUserRemoveArr=[[NSMutableArray arrayWithObjects:[filteredList objectAtIndex:clickedButtonPath.row], nil] mutableCopy];
//    [selectedPeople removeAllObjects];
}

-(IBAction)unBlockUser:(id)sender
{
    CircleListCheckBoxTableCell *clickedCell = (CircleListCheckBoxTableCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.blockTableView indexPathForCell:clickedCell];    
    NSLog(@"unblock user");
    LocationItemPeople *ppl=[[LocationItemPeople alloc] init];
    //Un-Block user operation on people list starts here
    NSLog(@"[filteredList count] %d",[filteredList count]);
    if ([filteredList count]>clickedButtonPath.row) 
    {
        ppl=[filteredList objectAtIndex:clickedButtonPath.row];
        ppl.userInfo.blockStatus=@"unblocked";
        [filteredList replaceObjectAtIndex:clickedButtonPath.row withObject:ppl];
    }
//    if ([smAppDelegate.peopleList indexOfObject:[filteredList objectAtIndex:clickedButtonPath.row]] >0)
//    {
//        [smAppDelegate.peopleList replaceObjectAtIndex:[smAppDelegate.peopleList indexOfObject:[filteredList objectAtIndex:clickedButtonPath.row]] withObject:ppl];
//
//    }
    //Un-Block user operation on people list ends here

    
    [smAppDelegate showActivityViewer:self.view];
    [smAppDelegate.window setUserInteractionEnabled:NO];    
    
    [rc unBlockUserList:@"Auth-Token":smAppDelegate.authToken :[NSMutableArray arrayWithObjects:((LocationItemPeople *)[filteredList objectAtIndex:clickedButtonPath.row]).userInfo.userId, nil]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"circleListTableCell";
    static NSString *CellIdentifier1 = @"circleListCheckBoxTableCell";
    int nodeCount = [filteredList count];
    
    LocationItemPeople *people=[[LocationItemPeople alloc] init];
    people = (LocationItemPeople *)[filteredList objectAtIndex:indexPath.row];
    NSLog(@"[filteredList count] %d",[filteredList count]);
    
//    CircleListTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    CircleListCheckBoxTableCell *cell1= [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
    if (cell1 == nil)
    {
            cell1 = [[CircleListCheckBoxTableCell alloc]
                     initWithStyle:UITableViewCellStyleDefault
                     reuseIdentifier:CellIdentifier1];
    }
    
    // Configure the cell... 
    [cell1.footerView.layer setCornerRadius:6.0f];
    [cell1.footerView.layer setMasksToBounds:YES];
    cell1.footerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.6];
    cell1.checkBoxButton.tag=indexPath.row;
    cell1.showOnMapButton.tag=indexPath.row;
    cell1.inviteButton.tag=indexPath.row ;
    cell1.messageButton.tag=indexPath.row ;
    cell1.checkBoxButton.tag=indexPath.row ;
    [cell1.inviteButton.layer setCornerRadius:6.0f];
    [cell1.inviteButton.layer setMasksToBounds:YES];
    [cell1.messageButton.layer setCornerRadius:6.0f];
    [cell1.messageButton.layer setMasksToBounds:YES];

    
    // NSLog(@"event.myResponse: %@",event.myResponse);
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

        // Only load cached images; defer new downloads until scrolling ends
        NSLog(@"nodeCount > 0 %@",people.itemBg);
        if (!people.userInfo.coverImage)
        {
            NSLog(@"!userFriends.userProfileImage");
            if (self.blockTableView.dragging == NO && self.blockTableView.decelerating == NO)
            {
                [self startIconDownload:people forIndexPath:indexPath];
                NSLog(@"Downloading for %@ index=%d", cellValue, indexPath.row);
            }
            else if(searchFlag3==true)
            {
                NSLog(@"search flag true start download");
                [self startIconDownload:people forIndexPath:indexPath];
            }
            
            NSLog(@"userFriends %@ %@",people.itemIcon,people.itemBg);
            // if a download is deferred or in progress, return a placeholder image
            cell1.profilePicImgView.image=[UIImage imageNamed:@"event_item_bg.png"];
        }
        
        cell1.regStsImgView.layer.borderColor=[[UIColor lightTextColor] CGColor];
        cell1.regStsImgView.userInteractionEnabled=YES;
        cell1.regStsImgView.layer.borderWidth=1.0;
        cell1.regStsImgView.layer.masksToBounds = YES;
        [cell1.regStsImgView.layer setCornerRadius:5.0];
        if ([people.userInfo.regMedia isEqualToString:@"fb"]) 
        {
            NSLog(@"reg media fb %@",[UIImage imageNamed:@"icon_facebook.png"]);
            cell1.regStsImgView.image=[UIImage imageNamed:@"icon_facebook.png"];
        }
        else if ([people.userInfo.source isEqualToString:@"facebook"])
        {
            //            regMedia.image = [UIImage imageNamed:@"icon_facebook.png"];
            cell1.regStsImgView.image = [UIImage imageNamed:@"fbCheckinIcon.png"];
            cell1.regStsImgView.userInteractionEnabled=YES;
            cell1.regStsImgView.layer.masksToBounds = YES;
            [cell1.regStsImgView.layer setCornerRadius:5.0];
        }
        else
        {
            cell1.regStsImgView.image=[UIImage imageNamed:@"sm_icon@2x.png"];
        }
        
        if ([people.userInfo.friendshipStatus isEqualToString:@"friend"]) 
        {
            cell1.friendShipStatus.hidden=NO;
        }
        else
        {
            cell1.friendShipStatus.hidden=YES;
        }
        
        
        if ([downloadedImageDict objectForKey:people.userInfo.userId])
        {
            cell1.coverPicImgView.image=[downloadedImageDict objectForKey:people.userInfo.userId];
        }
        else
        {
            cell1.coverPicImgView.image=people.itemBg;
        }
        
        if ([selectedPeople containsObject:[filteredList objectAtIndex:indexPath.row]])
        {
            [cell1.checkBoxButton setImage:[UIImage imageNamed:@"checkbox_checked.png"] forState:UIControlStateNormal];
        }
        else
        {
            [cell1.checkBoxButton setImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
        }
        
        if ([filteredList count]>indexPath.row)
        {
            NSLog(@"people.blockStatus %@",people.userInfo.blockStatus);
            if ([people.userInfo.blockStatus isEqualToString:@"blocked"])
            {
                NSLog(@"marked as unblocked");
                [cell1.inviteButton setTitle:@"Unblock" forState:UIControlStateNormal];
                [cell1.inviteButton removeTarget:self action:@selector(unBlockUser:) forControlEvents:UIControlEventTouchUpInside];            
                [cell1.inviteButton addTarget:self action:@selector(unBlockUser:) forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                NSLog(@"marked as blocked %d %d",[blockedUser count],[filteredList count]);
                [cell1.inviteButton setTitle:@"Block" forState:UIControlStateNormal];
                [cell1.inviteButton removeTarget:self action:@selector(blockUser:) forControlEvents:UIControlEventTouchUpInside];
                [cell1.inviteButton addTarget:self action:@selector(blockUser:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        
        cell1.profilePicImgView.image=people.itemIcon;
        cell1.profilePicImgView.layer.borderColor=[[UIColor lightTextColor] CGColor];
        cell1.profilePicImgView.userInteractionEnabled=YES;
        cell1.profilePicImgView.layer.borderWidth=1.0;
        cell1.profilePicImgView.layer.masksToBounds = YES;
        [cell1.profilePicImgView.layer setCornerRadius:5.0];
        [cell1.showOnMapButton addTarget:self action:@selector(viewLocationButton:) forControlEvents:UIControlEventTouchUpInside];
        [cell1.messageButton addTarget:self action:@selector(messageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell1.checkBoxButton addTarget:self action:@selector(checkBoxButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
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
    
    UIImageView *imageIsOnline = (UIImageView*)[imageViewIcon viewWithTag:20101];
    
    if (!people.userInfo.external) {
        
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

- (void)startIconDownload:(LocationItemPeople *)people forIndexPath:(NSIndexPath *)indexPath
{
    CircleImageDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:people.userInfo.userId];
    if (iconDownloader == nil)
    {
        iconDownloader = [[CircleImageDownloader alloc] init];
        iconDownloader.people = people;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:people.userInfo.userId];
        NSLog(@"imageDownloadsInProgress %@",imageDownloadsInProgress);
        [iconDownloader startDownload];
        [downloadedImageDict setValue:iconDownloader.people.userInfo.coverImage forKey:people.userInfo.userId];
        NSLog(@"start downloads ... %@ %d",people.userInfo.userId, indexPath.row);
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
            LocationItemPeople *people = [filteredList objectAtIndex:indexPath.row];
            
            if (!people.itemBg) // avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:people forIndexPath:indexPath];
            }
        }
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSString *)userID
{
    CircleImageDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:userID];
    if (iconDownloader != nil)
    {
//        NSNumber *indx = [eventListIndex objectForKey:userID];
        LocationItemPeople *people = [peopleListArray objectAtIndex:iconDownloader.indexPathInTableView.row];
        people.userInfo.coverImage = people.userInfo.coverImage;
        
        CircleListTableCell *cell = (CircleListTableCell *)[self.blockTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        CircleListCheckBoxTableCell *cell1 = (CircleListCheckBoxTableCell*)[self.blockTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
        // Display the newly loaded image
        [downloadedImageDict setValue:iconDownloader.people.userInfo.coverImage forKey:userID];
        cell.profilePicImgView.image = iconDownloader.people.userInfo.coverImage;
        cell1.profilePicImgView.image = iconDownloader.people.userInfo.coverImage;
        //[userProfileCopyImageArray replaceObjectAtIndex:indexPath.row withObject:iconDownloader.userFriends.userProfileImage];
        [self.blockTableView reloadData];
    }
}

-(IBAction)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)selectedUser:(id)sender
{
    [smAppDelegate showActivityViewer:self.view];
    [smAppDelegate.window setUserInteractionEnabled:NO];
    
    NSMutableArray *userIdArr=[[NSMutableArray alloc] init];
    for (int i=0; i<[selectedPeople count]; i++)
    {
//        [userIdArr addObject:((LocationItemPeople *)[selectedPeople objectAtIndex:i]).userInfo.userId];
        NSLog(@"ids %@",((LocationItemPeople *)[selectedPeople objectAtIndex:i]).userInfo.userId);
        //Block user operation on people list starts here
        LocationItemPeople *ppl=[selectedPeople objectAtIndex:i];
        ppl.userInfo.blockStatus=@"blocked";
        
        [filteredList replaceObjectAtIndex:[filteredList indexOfObject:[selectedPeople objectAtIndex:i]] withObject:ppl];
//        [smAppDelegate.peopleList replaceObjectAtIndex:[smAppDelegate.peopleList indexOfObject:[selectedPeople objectAtIndex:i]] withObject:ppl];
        //Block user operation on people list ends here

    }
    
//    blockedUserRemoveArr=[selectedPeople mutableCopy];
    NSLog(@"userIdArr: %@ selectedPeople: %@",userIdArr,selectedPeople);
    [rc blockUserList:@"Auth-Token":smAppDelegate.authToken :userIdArr];
    [selectedPeople removeAllObjects];
    [self.blockTableView reloadData];
}

-(IBAction)selectAllpeople:(id)sender
{
    if (blockCountSel%2==0)
    {
        [selectAllButton setTitle:@"Unselect all users" forState:UIControlStateNormal];
        selectedPeople =[filteredList mutableCopy];
        [self.blockTableView reloadData];
    }
    else
    {
        [selectAllButton setTitle:@"Select all users" forState:UIControlStateNormal];
        [selectedPeople removeAllObjects];
        [self.blockTableView reloadData];
    }
    blockCountSel++;
}

- (IBAction)actionNotificationButton:(id)sender {
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    NotificationController *controller =[storybrd instantiateViewControllerWithIdentifier:@"notificationViewController"];
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
}

-(IBAction)sendMsg:(id)sender
{
    if (([textViewNewMsg.text isEqualToString:@""]) ||([textViewNewMsg.text isEqualToString:@"Your message..."]))
    {
        [UtilityClass showAlert:@"Social Maps" :@"Enter message"];
    }
    else {
    CircleListTableCell *clickedCell = (CircleListTableCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.blockTableView indexPathForCell:clickedCell];
    
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
        filteredList = [[NSMutableArray alloc] initWithArray: [peopleListArray mutableCopy]];
        NSLog(@"peopleListArray: %@",peopleListArray);
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
    filteredList = [[NSMutableArray alloc] initWithArray: [peopleListArray mutableCopy]];
    for (int i=0; i<[peopleListArray count]; i++)
    {
        [allUserIdArr addObject:((LocationItemPeople *)[peopleListArray objectAtIndex:i]).userInfo.userId];
    }
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
    NSLog(@"in search method.. %@",searchText3);
    NSLog(@"sTemp.itemName1 %d",[peopleListArray count]);
    peopleListArray = [[self loadDummyData] mutableCopy];
    [filteredList removeAllObjects];
    [allUserIdArr removeAllObjects];
    NSLog(@"sTemp.itemName2 %d",[peopleListArray count]);
    if ([searchText3 isEqualToString:@""])
    {
        NSLog(@"null string");
        blockSearchBar.text=@"";
        filteredList = [[NSMutableArray alloc] initWithArray: peopleListArray];
    }
    else
    {
        NSLog(@"sTemp.itemName3 %d",[peopleListArray count]);
        for (LocationItemPeople *sTemp in peopleListArray)
        {
            NSLog(@"sTemp.itemName %@ %d",sTemp.itemName,[peopleListArray count]);
            NSRange titleResultsRange = [sTemp.itemName rangeOfString:searchText3 options:NSCaseInsensitiveSearch];	
            if (titleResultsRange.length > 0)
            {
                [filteredList addObject:sTemp];
                [allUserIdArr addObject:((LocationItemPeople *)sTemp).userInfo.userId];

                NSLog(@"filtered friend: %@", sTemp.itemName);
            }
            else
            {
            }
        }
    }
    searchFlag3=false;
    
    NSLog(@"filteredListPeople %@ %d %d ",filteredList,[filteredList count],[peopleListArray count]);
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
    NSIndexPath *clickedButtonPath = [self.blockTableView indexPathForCell:clickedCell];
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
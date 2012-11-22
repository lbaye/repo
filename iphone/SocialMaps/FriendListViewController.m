//
//  FriendListViewController.m
//  SocialMaps
//
//  Created by Warif Rishi on 9/19/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "FriendListViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Globals.h"
#import "UserFriends.h"
#import "RestClient.h"
#import "AppDelegate.h"
#import "EachFriendInList.h"
#import "UIImageView+Cached.h"
#import "CachedImages.h"
#import "FriendsProfileViewController.h"
#import "NotificationController.h"
#import "UtilityClass.h"

#define     IMAGE_THUMB_WIDTH       65
#define     IMAGE_THUMB_HEIGHT      65

@implementation FriendListViewController

@synthesize userId;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotFriendsList:) name:NOTIF_GET_FRIEND_LIST_DONE object:nil];
    
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    circleList = [[NSMutableArray alloc] init];
    filteredList = [[NSMutableArray alloc] init];
    
}

- (void) selectUserId:(NSString *)_userId {
    
    self.userId = _userId;
    
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    [restClient getFriendListWithAuthKey:@"Auth-Token" tokenValue:smAppDelegate.authToken andFriendId:self.userId];
    [smAppDelegate showActivityViewer:self.view];
}

-(void) displayNotificationCount 
{
    int totalNotif= [UtilityClass getNotificationCount];
    if (totalNotif == 0)
        totalNotifCount.text = @"";
    else
        totalNotifCount.text = [NSString stringWithFormat:@"%d",totalNotif];
}

- (void)viewWillAppear:(BOOL)animated 
{
    smAppDelegate.currentModelViewController = self;
    [self displayNotificationCount];
}

- (void) gotFriendsList:(NSNotification *)notif 
{
    eachFriendList = [notif object];
    [self sortByAtoZ];
    [smAppDelegate hideActivityViewer];
}

- (void)viewDidUnload
{
    [scrollViewFriendList release];
    scrollViewFriendList = nil;
    [searchBarFriendList release];
    searchBarFriendList = nil;
    [totalNotifCount release];
    totalNotifCount = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)actionBackMe:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

-(void)moveSearchBarAnimation:(int)moveby
{
    if (moveby > 0) {
        scrollViewFriendList.contentInset = UIEdgeInsetsMake(43,0.0,0,0.0);
    } else {
        scrollViewFriendList.contentInset = UIEdgeInsetsMake(0,0.0,0,0.0);
    }
    
    CGRect viewFrame = searchBarFriendList.frame;
    viewFrame.origin.y += moveby;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];    
    [searchBarFriendList setFrame:viewFrame];  
    [UIView commitAnimations];    
}

- (IBAction)actionShowSearchBar:(id)sender 
{
    if (searchBarFriendList.frame.origin.y > 44) {
        [self moveSearchBarAnimation:-44];
        [self searchBarCancelButtonClicked:searchBarFriendList];
    } else {
        [self moveSearchBarAnimation:44];
        [searchBarFriendList becomeFirstResponder];
    }
}

- (IBAction)gotoNotification:(id)sender 
{
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    NotificationController *controller =[storybrd instantiateViewControllerWithIdentifier:@"notificationViewController"];
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
}

- (void)clearScrollView
{
    for (UIView *view in scrollViewFriendList.subviews)
    {
        if ([[view viewWithTag:840] isKindOfClass:[UIImageView class]]) {
            @try{
                [[(UIImageView*)[view viewWithTag:840] getImageInfo] removeObserver:(UIImageView*)[view viewWithTag:840] forKeyPath:@"image"];
            }@catch(id anException){
                NSLog(@"Cannot remove an observer");
            }
        }
        [view removeFromSuperview];
    }
}

- (void)addObjectInScrollView:(int)posX :(int)posY :(int)GAP :(EachFriendInList*)eachFriend :(int)tag
{
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 45, 45)];
    UIView *thumbView = [[UIView alloc] initWithFrame:CGRectMake(posX, posY, 65, 65)];
    UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(2, 45, 61, 12)];
    [labelName setFont:[UIFont fontWithName:kFontName size:10]];
    [labelName setNumberOfLines:0];
    labelName.textAlignment = UITextAlignmentCenter;
    labelName.backgroundColor = [UIColor clearColor];
    NSLog(@"friend name = %@", eachFriend.friendName);
    labelName.text = eachFriend.friendName; 
    imgView.userInteractionEnabled = YES;
    thumbView.tag = tag;
    imgView.tag = 840;
    NSLog(@"url = %@", eachFriend.friendAvater);
    
    if ([eachFriend.friendAvater isKindOfClass:[NSString class]])
        [imgView loadFromURL:[NSURL URLWithString:eachFriend.friendAvater]];
    
    imgView.clipsToBounds = NO;
    CGColorSpaceRef cmykSpace = CGColorSpaceCreateDeviceCMYK();
    CGFloat cmykValue[] = {.38, .02, .98, .05, 1};      
    CGColorRef colorCMYK = CGColorCreate(cmykSpace, cmykValue);
    CGColorSpaceRelease(cmykSpace);
    imgView.layer.borderColor = [[UIColor colorWithCGColor:colorCMYK] CGColor];
    imgView.userInteractionEnabled = YES;
    imgView.layer.borderWidth = 1.0;
    imgView.layer.masksToBounds = YES;
    [imgView.layer setCornerRadius:7.0];
    [thumbView addSubview:imgView];
    [thumbView addSubview:labelName];
    [imgView release];
    [labelName release];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    [thumbView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    [scrollViewFriendList addSubview:thumbView];
    [thumbView release];
}

-(void) handleTapGesture:(UIGestureRecognizer *)sender 
{
    NSMutableArray *selectedArray = ([filteredList count])? filteredList :eachFriendList;
    FriendsProfileViewController *controller =[[FriendsProfileViewController alloc] init];
    controller.friendsId = [[selectedArray objectAtIndex:sender.view.tag] friendId];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
}

- (void)refreshScrollViewforCircle:(NSMutableArray*)searchArray
{
    int posX = 20;
    int posY = 5;
    int GAP = 5;
    
    [self clearScrollView];
    
    [circleList removeAllObjects];
    for (EachFriendInList *eachFriend in searchArray) 
    {
        for (int i = 0; i < [eachFriend.friendCircle count]; i++) 
        {
            NSString *circleName = [eachFriend.friendCircle objectAtIndex:i];
            if (![circleList containsObject:circleName])
                [circleList addObject:circleName];
        }
    }

    for (int j = 0; j < [circleList count]; j++) 
    {
        [self addHeaderlabel:[circleList objectAtIndex:j] :posY];
        posX = 20;
        posY += 30;
        
        for (int i = 0; i < [searchArray count]; i++) 
        {
            EachFriendInList *eachFriend = [searchArray objectAtIndex:i];
            if ([eachFriend.friendCircle containsObject:[circleList objectAtIndex:j]])
            {
                if (posX + IMAGE_THUMB_WIDTH >= self.view.frame.size.width) {
                    posX = 20;
                    posY += GAP + IMAGE_THUMB_HEIGHT;
                }
                
                [self addObjectInScrollView:posX :posY :GAP :eachFriend :i];        
                
                posX += IMAGE_THUMB_WIDTH + GAP;
            }
        }
        
        posY += GAP + IMAGE_THUMB_HEIGHT;
    }
    
    scrollViewFriendList.contentSize = CGSizeMake(scrollViewFriendList.frame.size.width, posY);
}

- (NSString*)getLabelTextFromDistance:(int)distance
{
    NSString *labelText;
    
    if (distance < 1000) {
        if(distance < 500) {
            labelText = @"<500m";
            NSLog(@"<500%d", distance);
        }
        else {
            labelText = @"<1Km";
            NSLog(@"<1%d", distance);
        }
        
    } else {
        labelText = @"1km+";
        NSLog(@"1km+%d", distance);
    }
    
    return labelText;

}

- (void) refreshScrollView:(FILTER_BY)filter_by :(NSMutableArray*)searchArray {
    
    int posX = 20;
    int posY = 5;
    int GAP = 5;
    
    [self clearScrollView];
    previousLabelText = @"";
    
    for (int i = 0; i < [searchArray count]; i++) {
        
        EachFriendInList *eachFriend = [searchArray objectAtIndex:i];
        NSString *firstLetter = [eachFriend.friendName substringToIndex:1];
        
        if(i == 0) 
        {
            if (filter_by == AtoZ)
                [self addHeaderlabel:firstLetter:posY];
            else  if (filter_by == Distance) {
                NSString *labelText = [self getLabelTextFromDistance:[eachFriend.friendDistance intValue]];
                [self addHeaderlabel:labelText: posY];
                previousLabelText = labelText;
            }
            else if (filter_by == Circle)
                [self addHeaderlabel:@"Friends" :posY];

            posY += 30;
        } 
        else {
            
            EachFriendInList *eachFriendPrevious = [searchArray objectAtIndex:i - 1];
            
            if (filter_by == AtoZ) 
            {
                if ([firstLetter caseInsensitiveCompare:[eachFriendPrevious.friendName substringToIndex:1]] != NSOrderedSame)
                {
                    posY += GAP + IMAGE_THUMB_HEIGHT;
                    [self addHeaderlabel:firstLetter:posY];
                    posX = 20;
                    posY += 30;
                }
            } 
            else  if (filter_by == Distance)
            {
                NSString *labelText = [self getLabelTextFromDistance:[eachFriend.friendDistance intValue]];
                
                if (![previousLabelText isEqualToString:labelText]) {
                    posY += GAP + IMAGE_THUMB_HEIGHT;
                    [self addHeaderlabel:labelText: posY];
                    posX = 20;
                    posY += 30;
                    previousLabelText = labelText;
                }
            }
        }
        
        if (posX + IMAGE_THUMB_WIDTH >= self.view.frame.size.width) {
            posX = 20;
            posY += GAP + IMAGE_THUMB_HEIGHT;
        }
        
        [self addObjectInScrollView:posX :posY :GAP :eachFriend :i];        
        
        posX += IMAGE_THUMB_WIDTH + GAP;
        
    }
    
    scrollViewFriendList.contentSize = CGSizeMake(scrollViewFriendList.frame.size.width, posY + IMAGE_THUMB_HEIGHT + GAP);
}

- (int)getHeaderDistance:(int)distance
{
    int i = 500;
    while(i < distance)
        i += 500;
    return i;
}

- (BOOL)willAddNewLabelForDistance:(int)distance previousDistance:(int)previousDistance
{
    int currentLabelHeaderDistance = [self getHeaderDistance:distance];
    
    if (currentLabelHeaderDistance > [self getHeaderDistance:previousDistance]) 
        return YES;
    
    return NO;
    
}

- (void) addHeaderlabel:(NSString*)firstLetter:(int)posY 
{
    UILabel *labelHeader = [[UILabel alloc] initWithFrame:CGRectMake(10, posY, self.view.frame.size.width - 20, 16)];
    labelHeader.backgroundColor = [UIColor clearColor];
    labelHeader.font = [UIFont fontWithName:kFontNameBold size:kSmallLabelFontSize];
    labelHeader.text = firstLetter;
    [scrollViewFriendList addSubview:labelHeader];
    [labelHeader release];
    
    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, posY + 16, 300, 7)];
    lineImage.image = [UIImage imageNamed:@"line_arrow_down_left.png"];
    [scrollViewFriendList addSubview:lineImage];
    [lineImage release];
}

//search bar delegate method starts
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText 
{
    searchText=searchBar.text;
    
    if ([searchText length] > 0) 
    {
        [self performSelector:@selector(searchResult) withObject:nil afterDelay:0.1];
        NSLog(@"searchText  %@",searchText);
    } 
    else
    {
        searchText = @"";
        [filteredList removeAllObjects];
        
        if (searchBarFriendList.selectedScopeButtonIndex == 2) 
            [self refreshScrollViewforCircle:eachFriendList];
        else
            [self refreshScrollView:searchBarFriendList.selectedScopeButtonIndex :eachFriendList];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar 
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [filteredList removeAllObjects];
    
    if (searchBarFriendList.selectedScopeButtonIndex == 2) 
        [self refreshScrollViewforCircle:eachFriendList];
    else
        [self refreshScrollView:searchBarFriendList.selectedScopeButtonIndex :eachFriendList];
    
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar 
{
    [self searchResult];
    [searchBar resignFirstResponder];    
}

-(void)searchResult
{
    [filteredList removeAllObjects];
    
    for (EachFriendInList *eachFriend in eachFriendList)
    {
        NSRange titleResultsRange = [eachFriend.friendName rangeOfString:searchBarFriendList.text options:NSCaseInsensitiveSearch];		
        
        if (titleResultsRange.length > 0)
            [filteredList addObject:eachFriend];
    }
    
    NSLog(@"filteredList = %@", filteredList);
    
    if (searchBarFriendList.selectedScopeButtonIndex == 2) 
        [self refreshScrollViewforCircle:filteredList];
    else
        [self refreshScrollView:searchBarFriendList.selectedScopeButtonIndex :filteredList];
     
}

- (void)sortByDistance
{
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"friendDistance"                                      ascending:YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [eachFriendList sortedArrayUsingDescriptors:sortDescriptors];
    [eachFriendList removeAllObjects];
    [eachFriendList addObjectsFromArray:sortedArray];
    
    for (EachFriendInList *eachFriend in eachFriendList) {
        NSLog(@"%@ name - %@", eachFriend.friendDistance , eachFriend.friendName);
    }
    
    [self refreshScrollView:Distance :([filteredList count]) ? filteredList : eachFriendList];
}

- (void)sortByAtoZ
{
    NSSortDescriptor *sorter = [[[NSSortDescriptor alloc]
                                 initWithKey:@"friendName"
                                 ascending:YES
                                 selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject: sorter];
    NSArray *sortedArray = [eachFriendList sortedArrayUsingDescriptors:sortDescriptors];
    [eachFriendList removeAllObjects];
    [eachFriendList addObjectsFromArray:sortedArray];
    
    [self refreshScrollView:AtoZ :([filteredList count]) ? filteredList : eachFriendList];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    NSLog(@"selectedScopeButtonIndexDidChange %d", selectedScope);
    
    if (selectedScope == 0) 
        [self sortByAtoZ];
    else if (selectedScope == 1)
        [self sortByDistance];
    else if (selectedScope == 2)
        [self refreshScrollViewforCircle:([filteredList count]) ? filteredList: eachFriendList];
}

//searchbar delegate method end

- (void)dealloc {
    [CachedImages removeAllCache];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_FRIEND_LIST_DONE object:nil];
    [circleList release];
    [scrollViewFriendList release];
    [searchBarFriendList release];
    [totalNotifCount release];
    [super dealloc];
}
@end

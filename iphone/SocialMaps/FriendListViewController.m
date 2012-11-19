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

#define     IMAGE_THUMB_WIDTH       65
#define     IMAGE_THUMB_HEIGHT      65

@implementation FriendListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotFriendsList:) name:NOTIF_GET_FRIEND_LIST_DONE object:nil];
    
    AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    [restClient getFriendListWithAuthKey:@"Auth-Token" tokenValue:smAppDelegate.authToken];
    
    circleList = [[NSMutableArray alloc] init];
    filteredList = [[NSMutableArray alloc] init];
    
}

- (void)viewWillAppear:(BOOL)animated 
{
    AppDelegate *smAppdelegate = [[UIApplication sharedApplication] delegate];
    smAppdelegate.currentModelViewController = self;
}

- (void) gotFriendsList:(NSNotification *)notif 
{
    eachFriendList = [notif object];
    [self sortByAtoZ];
    
}

- (void)viewDidUnload
{
    [scrollViewFriendList release];
    scrollViewFriendList = nil;
    [searchBarFriendList release];
    searchBarFriendList = nil;
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
    labelName.text = [[eachFriend.friendName componentsSeparatedByString:@" "] objectAtIndex:0]; 
    imgView.userInteractionEnabled = YES;
    thumbView.tag = tag;
    imgView.tag = 840;
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

- (void) refreshScrollView:(FILTER_BY)filter_by :(NSMutableArray*)searchArray {
    
    int posX = 20;
    int posY = 5;
    int GAP = 5;
    
    [self clearScrollView];
    
    for (int i = 0; i < [searchArray count]; i++) {
        
        EachFriendInList *eachFriend = [searchArray objectAtIndex:i];
        NSString *firstLetter = [eachFriend.friendName substringToIndex:1];
        
        if(i == 0) 
        {
            if (filter_by == AtoZ)
                [self addHeaderlabel:firstLetter:posY];
            else  if (filter_by == Distance)
                [self addHeaderlabel:@"<500m" :posY];
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
                int currentLabelHeaderDistance = [self getHeaderDistance:[eachFriend.friendDistance intValue]];
                
                BOOL willAddLabel = [self willAddNewLabelForDistance:currentLabelHeaderDistance previousDistance:[eachFriendPrevious.friendDistance intValue]];

                if (willAddLabel && [eachFriendPrevious.friendDistance intValue] <= 499)
                {
                    NSString *labelText;
                    
                    if (currentLabelHeaderDistance > 999)
                        labelText = @"1km+";
                    else if (currentLabelHeaderDistance <= 999)
                        labelText = [NSString stringWithFormat:@"<%.1fkm", currentLabelHeaderDistance/1000.0];
                    else
                        labelText = [NSString stringWithFormat:@"<%dm", (int)currentLabelHeaderDistance];
                    
                    posY += GAP + IMAGE_THUMB_HEIGHT;
                    [self addHeaderlabel:labelText: posY];
                    posX = 20;
                    posY += 30;
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
    [super dealloc];
}
@end

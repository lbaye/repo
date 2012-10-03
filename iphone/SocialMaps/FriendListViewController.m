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

#define     IMAGE_THUMB_WIDTH       65
#define     IMAGE_THUMB_HEIGHT      65

@implementation FriendListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    friendList = [[NSMutableArray alloc] init];

    
    [self addAllFriendsInFriendListArray];
    
    /*
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"userName"
                                                  ascending:YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [friendList sortedArrayUsingDescriptors:sortDescriptors];
    
    UserFriends *userFriend = [sortedArray objectAtIndex:0];
    NSLog(@"sortedArray = %@", userFriend.userName);
    */
    
    [self refreshScrollView];
    
}

- (void)viewDidUnload
{
    [scrollViewFriendList release];
    scrollViewFriendList = nil;
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

-(void) addAllFriendsInFriendListArray 
{
    [friendList removeAllObjects];
    
    for (int i=0; i<[friendListGlobalArray count]; i++)
    {
        UserFriends *userFriend = [friendListGlobalArray objectAtIndex:i];
        
        if ((userFriend.imageUrl==NULL)||[userFriend.imageUrl isEqual:[NSNull null]]) {
            userFriend.imageUrl=[[NSBundle mainBundle] pathForResource:@"thum" ofType:@"png"];
        }
        
        [friendList addObject:userFriend];
    }
}

-(void) refreshScrollView {
    
    int posX = 15;
    int posY = 5;
    int GAP = 5;
    
    for (int i = 0; i < [friendList count]; i++) {
        
        UserFriends *userFriend = [friendList objectAtIndex:i];
        
        if(i == 0) {
            NSString *firstLetter = [userFriend.userName substringToIndex:1];
            [self addHeaderlabel:firstLetter:posY];
            posY += 23;
        } else {
            UserFriends *userFriendPrevious = [friendList objectAtIndex:i - 1];
            
            if ([userFriend.userName caseInsensitiveCompare:userFriendPrevious.userName] != NSOrderedSame) {
                NSString *firstLetter = [userFriend.userName substringToIndex:1];
                
                
                posY += GAP + IMAGE_THUMB_HEIGHT;
                [self addHeaderlabel:firstLetter:posY];
                posX = 15;
                posY += 23;
            }
        }
        
        if (posX + IMAGE_THUMB_WIDTH >= self.view.frame.size.width) {
            posX = 15;
            posY += GAP + IMAGE_THUMB_HEIGHT;
        }
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 45, 45)];
        UIView *thumbView = [[UIView alloc] initWithFrame:CGRectMake(posX, posY, 65, 65)];
        UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(2, 45, 61, 20)];
        [labelName setFont:[UIFont fontWithName:@"Helvetica-Light" size:10]];
        [labelName setNumberOfLines:0];
        labelName.textAlignment = UITextAlignmentCenter;
        
        
        labelName.text = [[userFriend.userName componentsSeparatedByString:@" "] objectAtIndex:0]; 
        [imgView setBackgroundColor:[UIColor blueColor]];
        imgView.userInteractionEnabled = YES;
        imgView.tag = i;
        //thumbView.tag = i;
        imgView.exclusiveTouch = YES;
        imgView.clipsToBounds = NO;
        imgView.opaque = YES;
        imgView.layer.borderColor = [[UIColor clearColor] CGColor];
        imgView.userInteractionEnabled=YES;
        imgView.layer.borderWidth=2.0;
        imgView.layer.masksToBounds = YES;
        [imgView.layer setCornerRadius:7.0];
        
        imgView.layer.borderColor=[[UIColor lightGrayColor] CGColor];                    
        
        [thumbView addSubview:imgView];
        [thumbView addSubview:labelName];
        [imgView release];
        [labelName release];
        
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        tapGesture.numberOfTapsRequired = 1;
        [thumbView addGestureRecognizer:tapGesture];
        [tapGesture release];
        
        [scrollViewFriendList addSubview:thumbView];
    
    posX += IMAGE_THUMB_WIDTH + GAP;
        
    }
    
    scrollViewFriendList.contentSize = CGSizeMake(scrollViewFriendList.frame.size.width, posY + IMAGE_THUMB_HEIGHT + GAP);
}

- (void) addHeaderlabel:(NSString*)firstLetter:(int)posY {

    NSLog(@"addHeaderLabel");
    
    
    
    UILabel *labelHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, posY, self.view.frame.size.width, 16)];
    labelHeader.backgroundColor = [UIColor greenColor];
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
    
    if ([searchText length]>0) 
    {
        [self performSelector:@selector(searchResult) withObject:nil afterDelay:0.1];
        NSLog(@"searchText  %@",searchText);
    }
    /*
    else
    {
        searchText=@"";
        [selectedFriendsIndex removeAllObjects];
        //[self loadFriendListsData]; TODO: commented this
        [filteredList removeAllObjects];
        filteredList = [[NSMutableArray alloc] initWithArray: friendListArr];
        [self reloadScrolview];
    }
    */
}
/*
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar 
{
    // searchBarTextDidBeginEditing is called whenever 
    // focus is given to the UISearchBar
    // call our activate method so that we can do some 
    // additional things when the UISearchBar shows.
    searchTexts=friendSearchbar.text;
    [UIView beginAnimations:@"FadeIn" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView commitAnimations];
    [self beganEditing];
}
*/
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar 
{
    //[self endEditing];
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // Clear the search text
    // Deactivate the UISearchBar
    searchBar.text=@"";
    
    //[filteredList removeAllObjects];
    //filteredList = [[NSMutableArray alloc] initWithArray: friendListArr];
    //[selectedFriendsIndex removeAllObjects];
    
    //[self reloadScrolview];
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar 
{
    [self searchResult];
    [searchBar resignFirstResponder];    
}

-(void)searchResult
{
    /*
    searchTexts = friendSearchbar.text;
    
    [filteredList removeAllObjects];
    
    if ([searchTexts isEqualToString:@""])
    {
        friendSearchbar.text=@"";
        filteredList = [[NSMutableArray alloc] initWithArray: friendListArr];
    }
    else
    {
        for (UserFriends *sTemp in friendListArr)
        {
            NSRange titleResultsRange = [sTemp.userName rangeOfString:searchTexts options:NSCaseInsensitiveSearch];		
            
            if (titleResultsRange.length > 0)
            {
                [filteredList addObject:sTemp];
            }
            else
            {
            }
        }
    }
    searchFlag=false;    
    
    [self reloadScrolview];
     */
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    NSLog(@"selectedScopeButtonIndexDidChange %d", selectedScope);
    
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"userName"
                                                                    ascending:NO] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedFriendList = [friendList sortedArrayUsingDescriptors:sortDescriptors];
    [friendList removeAllObjects];
    [friendList addObjectsFromArray:sortedFriendList];
    
    [self refreshScrollView];
}

//searchbar delegate method end

- (void)dealloc {
    [scrollViewFriendList release];
    [super dealloc];
}
@end

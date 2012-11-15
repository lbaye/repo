//
//  RecommendViewController.m
//  SocialMaps
//
//  Created by Warif Rishi on 11/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "RecommendViewController.h"
#import "NotificationController.h"
#import <QuartzCore/QuartzCore.h>
#import "UtilityClass.h"
#import "Place.h"
#import "Globals.h"
#import "UserFriends.h"
#import "UITextView+Rounded.h"
#import "UITextView+PlaceHolder.h"
#import "RestClient.h"
#import "UIImageView+Cached.h"
#import "CachedImages.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

@implementation RecommendViewController

@synthesize place;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self displayNotificationCount];
    
    NSArray *subviews = [friendSearchbar subviews];
    UIButton *cancelButton = [subviews objectAtIndex:3];
    cancelButton.tintColor = [UIColor darkGrayColor];
    
    selectedFriendsIndex = [[NSMutableArray alloc] init];
    filteredList = [[NSMutableArray alloc] init];
    
    [self initScrollView:friendListGlobalArray];
    
    [textViewComment makeRoundCorner];
    [textViewComment setPlaceHolderText:@"Add comment"];
    
}

- (void)initScrollView:(NSMutableArray*)friendList
{
    for (UIView* view in [scrollViewFriends subviews]) { 
        
        if ([view isKindOfClass:[UIImageView class]]) {
            [[(UIImageView*)view getImageInfo] removeObserver:(UIImageView*)view forKeyPath:@"image"];
        }
        
        [view removeFromSuperview];
    }
    
    for (int i=0; i < [friendList count]; i++)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((i+1) * 12 + 65 * i, 0, 65, 65)];
        [imageView loadFromURL:[NSURL URLWithString:[(UserFriends*)[friendList objectAtIndex:i] imageUrl]]];  
        [scrollViewFriends addSubview:imageView];
        imageView.layer.masksToBounds = YES;
        [imageView.layer setCornerRadius:7.0];
        
        // test kCGColorSpaceDeviceCMYK
        CGColorSpaceRef cmykSpace = CGColorSpaceCreateDeviceCMYK();
        CGFloat cmykValue[] = {.38, .02, .98, .05, 1};      // green
        CGColorRef colorCMYK = CGColorCreate(cmykSpace, cmykValue);
        CGColorSpaceRelease(cmykSpace);
        
        // color with CGColor, uicolor will just retain it
        imageView.layer.borderColor = [[UIColor colorWithCGColor:colorCMYK] CGColor];
        imageView.layer.borderWidth = 1.0;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        tapGesture.numberOfTapsRequired = 1;
        [imageView addGestureRecognizer:tapGesture];
        [tapGesture release];
        imageView.tag = i + 1;
        imageView.userInteractionEnabled = YES;
        
        UILabel *labelFriendName = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x, 66, 65, 13)];
        labelFriendName.text = [[[(UserFriends*)[friendList objectAtIndex:i] userName] componentsSeparatedByString:@" "] objectAtIndex:0];
        [labelFriendName setFont:[UIFont fontWithName:kFontName size:kMediumLabelFontSize]];
        labelFriendName.textAlignment = UITextAlignmentCenter;
        [scrollViewFriends addSubview:labelFriendName];
        labelFriendName.backgroundColor = [UIColor clearColor];
        [labelFriendName release];
        
        scrollViewFriends.contentSize = CGSizeMake(imageView.frame.origin.x + 77, scrollViewFriends.contentSize.height);
        
        [imageView release];
    }
}

- (void) displayNotificationCount 
{
    int totalNotif= [UtilityClass getNotificationCount];
    
    if (totalNotif == 0)
        totalNotifCount.text = @"";
    else
        totalNotifCount.text = [NSString stringWithFormat:@"%d",totalNotif];
}

- (IBAction)gotoNotification:(id)sender 
{
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    NotificationController *controller =[storybrd instantiateViewControllerWithIdentifier:@"notificationViewController"];
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
}

- (IBAction)actionBackMe:(id)sender 
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)actionAddAllFriendsButton:(id)sender 
{
    for (int i = 0; i < [friendListGlobalArray count]; i++)
    {
        [selectedFriendsIndex addObject:[NSString stringWithFormat:@"%d", i]];
        [scrollViewFriends viewWithTag:i + 1].layer.borderWidth = 4.0;
    }
}

- (IBAction)actionRemoveAllFriendsButton:(id)sender 
{
    [selectedFriendsIndex removeAllObjects];
    
    for (int i = 1; i <= [friendListGlobalArray count]; i++)
    {
        [scrollViewFriends viewWithTag:i].layer.borderWidth = 1.0;
    }
}

- (IBAction)actionSendButton:(id)sender 
{
    if ([selectedFriendsIndex count] == 0) {
        [UtilityClass showAlert:@"" :@"Select at least one friend"];
        return;
    }

    NSMutableArray *userIDs=[[NSMutableArray alloc] init];
    
    for (int i = 0; i < [selectedFriendsIndex count]; i++) {
        NSString *userId = ((UserFriends*)[friendListGlobalArray objectAtIndex:[[selectedFriendsIndex objectAtIndex:i] intValue]]).userId;
        
        if ([filteredList count] > 0) {
            userId = ((UserFriends*)[filteredList objectAtIndex:[[selectedFriendsIndex objectAtIndex:i] intValue]]).userId;
        }
        
        [userIDs addObject:userId];
    }
    
    NSLog(@"user id %@", userIDs);
    
    NSString *stringNote = ([[textViewComment getPlaceHolderText] isEqualToString:textViewComment.text]) ? @"" : textViewComment.text;
    
    AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    [restClient recommendPlace:self.place :@"Auth-Token" :smAppDelegate.authToken withNote:stringNote andRecipients:userIDs];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)setSelectedPlace:(Place*)_place
{
    self.place = _place;
    NSLog(@"place id = %@", self.place.placeID);
    
    AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    textViewMsg.text = [NSString stringWithFormat:@"%@ has recommended you at \"%@\"", smAppDelegate.userAccountPrefs.firstName, place.name];
}

-(void) handleTapGesture:(UIGestureRecognizer *)sender
{
    NSLog(@"handleTapGesture sender.tag = %d", [sender.view tag]);
    
    int tag = sender.view.tag;
    
    if ([selectedFriendsIndex containsObject:[NSString stringWithFormat:@"%d", tag - 1]]) {
        [selectedFriendsIndex removeObject:[NSString stringWithFormat:@"%d", tag - 1]];
        [scrollViewFriends viewWithTag:tag].layer.borderWidth = 1.0;
    } else {
        [selectedFriendsIndex addObject:[NSString stringWithFormat:@"%d",[sender.view tag] - 1]];
        [scrollViewFriends viewWithTag:tag].layer.borderWidth = 4.0;
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    NSLog(@"Text view is in editing mode");
    if ([[textView getPlaceHolderText] isEqualToString:textView.text])
        [textView resetPlaceHolderText];
    
    return true;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        
        if ([textView.text isEqualToString:@""])
            [textView setPlaceHolderText:[textView getPlaceHolderText]];
        
        return NO;
    }
    else
        return YES;
}

//search bar delegate method starts

-(void)beganEditing
{
    //UIControl need to config here
    CGRect textFieldRect =
	[self.view.window convertRect:friendSearchbar.bounds fromView:friendSearchbar];
    
    CGRect viewRect =
	[self.view.window convertRect:self.view.bounds fromView:self.view];
	
	CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = 
	midline - viewRect.origin.y
	- MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
	(MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
	* viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
	if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
	UIInterfaceOrientation orientation =
	[[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
	CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
    
}

-(void)endEditing
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];    
    [self.view setFrame:viewFrame];    
    [UIView commitAnimations];    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText 
{
    searchText=friendSearchbar.text;
    
    if ([searchText length]>0) 
    {
        [self performSelector:@selector(searchResult) withObject:nil afterDelay:0.1];
        searchFlag=true;
        NSLog(@"searchText  %@",searchText);
    }
    else
    {
        searchText = @"";
        [self actionRemoveAllFriendsButton:nil];
        [self initScrollView:friendListGlobalArray];
    }
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar 
{
    searchTexts = friendSearchbar.text;
    [UIView beginAnimations:@"FadeIn" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView commitAnimations];
    [self beganEditing];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar 
{
    [self endEditing];
    [friendSearchbar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    friendSearchbar.text = @"";
    searchTexts = @"";
    [filteredList removeAllObjects];
    [self actionRemoveAllFriendsButton:nil];
    [friendSearchbar resignFirstResponder];
    [self initScrollView:friendListGlobalArray];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar 
{
    searchTexts = friendSearchbar.text;
    searchFlag = false;
    [friendSearchbar resignFirstResponder];    
}

-(void)searchResult
{
    searchTexts = friendSearchbar.text;
    
    [filteredList removeAllObjects];
    
    for (UserFriends *sTemp in friendListGlobalArray)
    {
        NSRange titleResultsRange = [sTemp.userName rangeOfString:searchTexts options:NSCaseInsensitiveSearch];		
        
        if (titleResultsRange.length > 0)
            [filteredList addObject:sTemp];
    }
    
    searchFlag = false;    
    
    [self initScrollView:filteredList];
}

- (void)viewDidUnload
{
    [totalNotifCount release];
    totalNotifCount = nil;
    [friendSearchbar release];
    friendSearchbar = nil;
    [scrollViewFriends release];
    scrollViewFriends = nil;
    [textViewComment release];
    textViewComment = nil;
    [textViewMsg release];
    textViewMsg = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [filteredList release];
    [CachedImages removeAllCache];
    [selectedFriendsIndex release];
    [totalNotifCount release];
    [friendSearchbar release];
    [scrollViewFriends release];
    [textViewComment release];
    [textViewMsg release];
    [super dealloc];
}
@end

//
//  RecommendViewController.h
//  SocialMaps
//
//  Created by Warif Rishi on 11/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Place;

@interface RecommendViewController : UIViewController
{
    IBOutlet UILabel *totalNotifCount;
    IBOutlet UISearchBar *friendSearchbar;
    IBOutlet UIScrollView *scrollViewFriends;
    IBOutlet UITextView *textViewComment;
    IBOutlet UITextView *textViewMsg;
    
    Place           *place;
    NSMutableArray  *selectedFriendsIndex;
    BOOL            searchFlag;
    CGFloat         animatedDistance;
    NSString        *searchTexts;
    NSMutableArray  *filteredList;
}

@property (nonatomic, retain) Place *place;

- (IBAction)gotoNotification:(id)sender;
- (IBAction)actionBackMe:(id)sender;
- (IBAction)actionAddAllFriendsButton:(id)sender;
- (IBAction)actionRemoveAllFriendsButton:(id)sender;
- (IBAction)actionSendButton:(id)sender;

- (void)initScrollView:(NSMutableArray*)friendList;
- (void)setSelectedPlace:(Place*)_place;
- (void) displayNotificationCount;

@end

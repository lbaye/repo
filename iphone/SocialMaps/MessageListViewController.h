//
//  MessageListViewController.h
//  SocialMaps
//
//  Created by Warif Rishi on 8/29/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IconDownloader.h"

@class AppDelegate;

@interface MessageListViewController : UIViewController <IconDownloaderDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource> {
    
    IBOutlet    UITableView     *msgListTableView;
    IBOutlet    UIView          *messageCreationView;
    IBOutlet    UITextView      *textViewNewMsg;
    IBOutlet    UIView          *msgWritingView;
    IBOutlet    UIButton        *buttonMessage;
    IBOutlet    UIButton        *buttonMeetUp;
    IBOutlet    UIView          *messageRepiesView;
    IBOutlet    UITextView      *textViewReplyMsg;
    IBOutlet    UITableView     *messageReplyTableView;
    IBOutlet UIView *msgReplyCreationView;
    
    AppDelegate                 *smAppDelegate;
    NSMutableArray              *profileImageList;
    NSMutableArray              *messageReplyList;
    
    NSString                    *timeSinceLastUpdate; //needed for automatic reply update
    
    //for test
    IBOutlet UITextField *textFieldUserID1;
    IBOutlet UITextField *textFieldUserID2;
    IBOutlet UITextField *textFieldUserID3;
    
    //friends list code
    IBOutlet UIScrollView *frndListScrollView;
    IBOutlet UISearchBar  *friendSearchbar;
    
    NSMutableArray *selectedFriendsIndex;
    BOOL isDragging_msg;
    BOOL isDecliring_msg;
    CGFloat animatedDistance;
    NSMutableDictionary *dicImages_msg;
    NSMutableArray *ImgesName;
}

@property (nonatomic, retain) NSString *msgParentID;

- (IBAction)actionMessageBtn:(id)sender;
- (IBAction)actionMeetUpBtn:(id)sender;
- (IBAction)actionNewMessageBtn:(id)sender;
- (IBAction)actionBackBtn:(id)sender;
- (IBAction)actionCancelBtn:(id)sender;
- (IBAction)actionSendBtn:(id)sender;
- (IBAction)actionSendReplyBtn:(id)sender;
- (IBAction)actionRefreshBtn:(id)sender;
- (void)gotInboxMessages:(NSNotification *)notif;


@end

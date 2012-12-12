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
@class MessageReply;
@class NotifMessage;

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
    
    NSTimer                     *replyTimer;
    
    //for test
    IBOutlet    UITextField     *textFieldUserID1;
    IBOutlet    UITextField     *textFieldUserID2;
    IBOutlet    UITextField     *textFieldUserID3;
    
    //friends list code
    IBOutlet UIScrollView *frndListScrollView;
    IBOutlet UISearchBar  *friendSearchbar;
    
    NSMutableArray *selectedFriendsIndex;
    BOOL isDragging_msg;
    BOOL isDecliring_msg;
    CGFloat animatedDistance;
    NSMutableArray *ImgesName;
    
    NotifMessage *selectedMessage;
    IBOutlet UILabel *totalNotifCount;
    IBOutlet UIView *viewSearch;
    
    //circle list
    CGRect  viewSearchFrame;
    IBOutlet UITableView *tableViewCircle;
    NSMutableArray *selectedCircleCheckArr;
    IBOutlet UIView *viewCircleList;
    
    NSMutableArray *selectedCircleCheckOriginalArr;
    
    BOOL            isGroupChat;
}

@property (nonatomic, retain) NSString *msgParentID;
@property (nonatomic, retain) NSString *timeSinceLastUpdate; //needed for automatic reply update
@property (nonatomic, retain) NotifMessage *selectedMessage;
@property (nonatomic, retain) IBOutlet UILabel *totalNotifCount;
@property (nonatomic, assign) BOOL willSelectMeetUp;

- (IBAction)actionMessageBtn:(id)sender;
- (IBAction)actionMeetUpBtn:(id)sender;
- (IBAction)actionNewMessageBtn:(id)sender;
- (IBAction)actionBackBtn:(id)sender;
- (IBAction)actionCancelBtn:(id)sender;
- (IBAction)actionSendBtn:(id)sender;
- (IBAction)actionSendReplyBtn:(id)sender;
- (IBAction)actionRefreshBtn:(id)sender;
- (void)gotInboxMessages:(NSNotification *)notif;
- (CGFloat) getRowHeight:(UITableView*)tv:(MessageReply*)msgReply;
- (void)startReqForReplyMessages;
-(void)doTopViewAnimation:(UIView*)incomingView;
-(void)loadDummydata;

- (IBAction)gotoNotification:(id)sender;
- (IBAction)actionAddMoreButton:(id)sender;
- (IBAction)actionCancelAddPplButton:(id)sender;
- (IBAction)actionSaveAddPplButton:(id)sender;
- (IBAction)actionCancelCircleButton:(id)sender;
- (IBAction)actionSaveCircleButton:(id)sender;
- (IBAction)actionShowCircleListButton:(id)sender;
- (void)setMsgReplyTableView:(NotifMessage*)msg;

@end

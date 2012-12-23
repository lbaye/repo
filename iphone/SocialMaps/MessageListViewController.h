//
//  MessageListViewController.h
//  SocialMaps
//
//  Created by Warif Rishi on 8/29/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file MessageListViewController.h
 * @brief Show inbox and reply thread list.
 */

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
    BOOL            isCheckingNewReplies;
}

@property (nonatomic, retain) NSString *msgParentID;
@property (nonatomic, retain) NSString *timeSinceLastUpdate; //needed for automatic reply update
@property (nonatomic, retain) NotifMessage *selectedMessage;
@property (nonatomic, retain) IBOutlet UILabel *totalNotifCount;
@property (nonatomic, assign) BOOL willSelectMeetUp;

/**
 * @brief Navigate to inbox screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionMessageBtn:(id)sender;

/**
 * @brief Navigate to meetup list screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionMeetUpBtn:(id)sender;

/**
 * @brief Pressed new message to compose
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionNewMessageBtn:(id)sender;

/**
 * @brief Navigate user to previous screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionBackBtn:(id)sender;

/**
 * @brief Cancel sending new message
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionCancelBtn:(id)sender;

/**
 * @brief Send new message
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionSendBtn:(id)sender;

/**
 * @brief Send reply
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionSendReplyBtn:(id)sender;

/**
 * @brief Pressed refresh button to get inbox list again
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionRefreshBtn:(id)sender;

/**
 * @brief Inbox list received from server
 * @param (NSNotification) - Notif object contains inbox message list
 * @retval none
 */
- (void)gotInboxMessages:(NSNotification *)notif;

/**
 * @brief Get row height for cell according to the containg message height
 * @param (UITableVeiw) - Tableview which contains cell
 * @parm (MessageReply) - Message reply for which height needs to be determined  
 * @retval (CGFloat) - Height of the cell
 */
- (CGFloat) getRowHeight:(UITableView*)tv:(MessageReply*)msgReply;

/**
 * @brief Reply message schedule for every 10 seconds
 * @param none
 * @retval none
 */
- (void)startReqForReplyMessages;

/**
 * @brief Animate view from bottom
 * @param (UIView) - View which needs to be moved with animation 
 * @retval none
 */
-(void)doTopViewAnimation:(UIView*)incomingView;

/**
 * @brief Load friend list data
 * @param none
 * @retval none
 */
-(void)loadDummydata;

/**
 * @brief Navigate to notification view
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoNotification:(id)sender;

/**
 * @brief Pressed add more button to add more friends to the existing message thread
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionAddMoreButton:(id)sender;

/**
 * @brief Cancel adding more friends to the exixting message thread
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionCancelAddPplButton:(id)sender;

/**
 * @brief Add more friends to the message thread
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionSaveAddPplButton:(id)sender;

/**
 * @brief Remove Circle select
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionCancelCircleButton:(id)sender;

/**
 * @brief Save friends from circle
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionSaveCircleButton:(id)sender;

/**
 * @brief Show Circle List
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionShowCircleListButton:(id)sender;

/**
 * @brief Display replies of a message
 * @param (NOtifMessage) - Message for which replies are needed to see
 * @retval none
 */
- (void)setMsgReplyTableView:(NotifMessage*)msg;

@end

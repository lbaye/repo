//
//  MessageListViewController.m
//  SocialMaps
//
//  Created by Warif Rishi on 8/29/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "MessageListViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NotifMessage.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "UserFriends.h"
#import "RestClient.h"
#import "MessageReply.h"
#import "UserCircle.h"
#import "Globals.h"
#import "UtilityClass.h"
#import "MeetUpRequestListView.h"
#import "NotificationController.h"
#import "SelectCircleTableCell.h"
#import "DirectionViewController.h"
#import "UITextView+PlaceHolder.h"
#import "UIImageView+Cached.h"

#define     SENDER_NAME_START_POSX  60
#define     CELL_HEIGHT             60
#define     GAP                     3 
#define     kOFFSET_FOR_KEYBOARD    215
#define     TAG_TABLEVIEW_REPLY     1001
#define     TAG_TABLEVIEW_INBOX     1002
#define     TAG_MEETUP_VIEW         1003
#define     SENDER_NAME_REPLY_START_POSX    90

@implementation MessageListViewController

@synthesize msgParentID;
@synthesize timeSinceLastUpdate;
@synthesize selectedMessage;
@synthesize totalNotifCount;
@synthesize willSelectMeetUp;

static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;

bool searchFlag;
__strong NSMutableArray *filteredList,*friendListArr, *circleList;
__strong NSString *searchTexts;
NSMutableDictionary *friendsNameArr, *friendsIDArr;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    messageReplyList = [[NSMutableArray alloc] init];
    
    msgListTableView.delegate = self;
    msgListTableView.dataSource = self;
    messageReplyTableView.delegate = self;
    messageReplyTableView.dataSource = self;
    msgListTableView.tag = TAG_TABLEVIEW_INBOX;
    messageReplyTableView.tag =TAG_TABLEVIEW_REPLY;

    [textViewNewMsg.layer setCornerRadius:8.0f];
    [textViewNewMsg.layer setBorderWidth:0.5];
    [textViewNewMsg.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [textViewNewMsg.layer setMasksToBounds:YES];
    
    [textViewReplyMsg.layer setCornerRadius:8.0f];
    [textViewReplyMsg.layer setBorderWidth:0.5];
    [textViewReplyMsg.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [textViewReplyMsg.layer setMasksToBounds:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotInboxMessages:) name:NOTIF_GET_INBOX_DONE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendReplyDone:) name:NOTIF_SEND_REPLY_DONE object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewThreadDone:) name:NOTIF_GET_NEW_THREAD_DONE object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getReplyMessages:) name:NOTIF_GET_REPLIES_DONE object:nil];
    
    //friends list
    frndListScrollView.delegate = self;
     selectedFriendsIndex=[[NSMutableArray alloc] init];
     filteredList=[[NSMutableArray alloc] init];
    friendListArr=[[NSMutableArray alloc] init];
    
    //set scroll view content size.
    [self loadDummydata];
    
    MeetUpRequestListView *meetUpRequestListView = [[MeetUpRequestListView alloc] initWithFrame:CGRectMake(0, 0, messageRepiesView.frame.size.width, messageRepiesView.frame.size.height) andParentControllder:self];
    meetUpRequestListView.tag = TAG_MEETUP_VIEW;
    meetUpRequestListView.hidden = YES;
    [messageRepiesView addSubview:meetUpRequestListView];
    [meetUpRequestListView release];
    
    NSArray *subviews = [friendSearchbar subviews];
    UIButton *cancelButton = [subviews objectAtIndex:3];
    cancelButton.tintColor = [UIColor darkGrayColor];
    
    selectedCircleCheckArr = [[NSMutableArray alloc] init];
    selectedCircleCheckOriginalArr = [[NSMutableArray alloc] init];
    tableViewCircle.dataSource = self;
    tableViewCircle.delegate = self;
    
    [textViewReplyMsg setPlaceHolderText:@"Your Message..."];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self displayNotificationCount];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getReplyMessages:) name:NOTIF_GET_REPLIES_DONE object:nil];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.selectedMessage) {
        [self setMsgReplyTableView:self.selectedMessage];
    } 
    
    if (self.willSelectMeetUp) {
        [self actionMeetUpBtn:nil];
    }
    
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    
    if ([selectedMessage.notifID isEqualToString:@"NewMsg"]) {
        NSLog(@"reciepientId = %@", selectedMessage.notifSenderId);
        [restClient getThread:self.selectedMessage.notifSenderId authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
    } else {
        [self actionRefreshBtn:nil];
        [restClient getMeetUpRequest:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
    }
    
    [self loadImagesForOnscreenRows];
    smAppDelegate.currentModelViewController = self;
}

- (void) viewDidDisappear:(BOOL)animated
{
    if (replyTimer) {
        [replyTimer invalidate];
        replyTimer = nil;
    }
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
}

- (void)viewDidUnload
{
    NSLog(@"called View did unload");
    
    msgListTableView = nil;
    [messageCreationView release];
    messageCreationView = nil;
    [textViewNewMsg release];
    textViewNewMsg = nil;
    [msgWritingView release];
    msgWritingView = nil;
    [textFieldUserID1 release];
    textFieldUserID1 = nil;
    [textFieldUserID2 release];
    textFieldUserID2 = nil;
    [textFieldUserID3 release];
    textFieldUserID3 = nil;
    [buttonMessage release];
    buttonMessage = nil;
    [buttonMeetUp release];
    buttonMeetUp = nil;
    [messageRepiesView release];
    messageRepiesView = nil;
    [textViewReplyMsg release];
    textViewReplyMsg = nil;
    [messageReplyTableView release];
    messageReplyTableView = nil;
    [msgReplyCreationView release];
    msgReplyCreationView = nil;
    [viewSearch release];
    viewSearch = nil;
    [tableViewCircle release];
    tableViewCircle = nil;
    [viewCircleList release];
    viewCircleList = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)actionMessageBtn:(id)sender {
    NSLog(@"actionMessageBtn");
    buttonMeetUp.selected = NO;
    buttonMessage.selected = YES;
    if (!messageCreationView.hidden) {
        if ([textViewNewMsg isFirstResponder]) {
            [textViewNewMsg resignFirstResponder];
            [self setViewMovedDown:msgWritingView];
        }else {
            [self doTopViewAnimation:messageCreationView];
        }
    } else if ([textViewReplyMsg isFirstResponder]) {
        [textViewReplyMsg resignFirstResponder];
        [self setViewMovedDown:messageRepiesView];
    }else if (!messageRepiesView.hidden) {
        [self doLeftViewAnimation:messageRepiesView];
    }
    [friendSearchbar resignFirstResponder];
    
    [messageRepiesView viewWithTag:TAG_MEETUP_VIEW].hidden = YES;
}

- (IBAction)actionMeetUpBtn:(id)sender {
    buttonMeetUp.selected = YES;
    buttonMessage.selected = NO;
    NSLog(@"actionMeetUpBtn");
    
    messageRepiesView.hidden = NO;
    [messageRepiesView viewWithTag:TAG_MEETUP_VIEW].hidden = NO;
    
}

- (IBAction)actionNewMessageBtn:(id)sender {
    NSLog(@"actionNewMessageBtn");
    [selectedFriendsIndex removeAllObjects];
    [selectedCircleCheckArr removeAllObjects];
    [selectedCircleCheckOriginalArr removeAllObjects];
    [self reloadScrolview];
    [tableViewCircle reloadData];
    [self doBottomViewAnimation:messageCreationView];
}

- (IBAction)actionBackBtn:(id)sender 
{
    if (replyTimer) {
        [replyTimer invalidate];
        replyTimer = nil;
    }
    
    if (!messageCreationView.hidden || !messageRepiesView.hidden) {
        [self actionMessageBtn:nil];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
    
}

- (IBAction)actionCancelBtn:(id)sender {
    if (textViewNewMsg.isFirstResponder) {
        [textViewNewMsg resignFirstResponder];
        [self setViewMovedDown:msgWritingView];
    } else {
        [self doTopViewAnimation:messageCreationView];
    }
}

- (IBAction)actionSendBtn:(id)sender {
    
    if (textViewNewMsg.isFirstResponder) {
        [textViewNewMsg resignFirstResponder];
        [self setViewMovedDown:msgWritingView];
    }
    
    BOOL isCircleContainsFriend = NO;
    
    for (UserCircle *userCircle in selectedCircleCheckOriginalArr) {
        if ([userCircle.friends count] > 0) {
            isCircleContainsFriend = YES;
            break;
        }
    }
    
    if ([selectedFriendsIndex count] == 0 && !isCircleContainsFriend) {
        [UtilityClass showAlert:@"" :@"Please select recipient"];
    } else if ([textViewNewMsg.text isEqualToString:@""] || [textViewNewMsg.text isEqualToString:@"Your Message..."]) {
        [UtilityClass showAlert:@"" :@"Please enter your message"];
    } else {
        [self sendMessage:sender];
        [self doTopViewAnimation:messageCreationView];
        [self clearTextView:textViewNewMsg];
    }
}

- (IBAction)actionSendReplyBtn:(id)sender {
    
    if ([textViewReplyMsg isFirstResponder]) {
        [textViewReplyMsg resignFirstResponder];
        [self setViewMovedDown:messageRepiesView];
    }
    if ([textViewReplyMsg.text isEqualToString:@""] || [textViewReplyMsg.text isEqualToString:@"Your Message..."]) {
        [UtilityClass showAlert:@"" :@"Please enter your message"];
    } else {
        if (![textViewReplyMsg.superview viewWithTag:5005]) 
        {
            RestClient *restClient = [[[RestClient alloc] init] autorelease];
            
            if ([selectedMessage.notifID isEqualToString:@"NewMsg"]) {
                [UtilityClass showAlert:@"" :@"Please wait"];
            } else {
                NSLog(@"msg parent id %@", msgParentID);
                [restClient sendReply:msgParentID content:textViewReplyMsg.text authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
            }
            
            [self showHideIndicatorOnTextview:textViewReplyMsg];
        } 
        else {
            [UtilityClass showAlert:@"" :@"Please wait"];
        }
    }
}

- (void)showHideIndicatorOnTextview:(UITextView*)textView
{
    if (![textView.superview viewWithTag:5005]) 
    {
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = CGRectMake(textView.frame.size.width + textView.frame.origin.x - indicator.frame.size.width - 5, textView.frame.origin.y + 3, indicator.frame.size.width, indicator.frame.size.height);
        indicator.hidesWhenStopped = YES;
        [indicator startAnimating];
        indicator.tag = 5005;
        [textView.superview addSubview:indicator];
        [indicator release];
        textView.userInteractionEnabled = NO;
    }
    else 
    {
        [[textView.superview viewWithTag:5005] removeFromSuperview];
        textView.userInteractionEnabled = YES;
    }
    
}

- (void) clearTextView:(UITextView*)textVeiw
{
    textVeiw.text = @"Your Message...";
    textVeiw.textColor = [UIColor lightGrayColor];
}

- (IBAction)actionRefreshBtn:(id)sender {
    
    [smAppDelegate showActivityViewer:self.view];
    [smAppDelegate.window setUserInteractionEnabled:NO];
    
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    [restClient getInbox:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
    NSLog(@"AuthToken = %@", smAppDelegate.authToken);

}   

- (void)gotInboxMessages:(NSNotification *)notif {
    NSMutableArray *msg = [notif object];
    
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    
    if (!msg) {
        [UtilityClass showAlert:@"" :@"Network error, try again"];
        return;
    } else if ([msg count] == 0) {
        [UtilityClass showAlert:@"" :@"No messages"];
        return;
    }
    
    [smAppDelegate.messages removeAllObjects];
    [smAppDelegate.messages addObjectsFromArray:msg];
    
    for (int i = 0; i < [smAppDelegate.messages count]; i++)
    {
        if([self.selectedMessage.notifID isEqualToString:[(NotifMessage*)[smAppDelegate.messages objectAtIndex:i] notifID]])
            {
                [(NotifMessage*)[smAppDelegate.messages objectAtIndex:i] setMsgStatus:@"read"];
                
                if ([self.selectedMessage.notifSenderId isEqualToString:@"sender_id"] && [self.selectedMessage.notifID isEqualToString:[(NotifMessage*)[smAppDelegate.messages objectAtIndex:i] notifID]]) {
                    NotifMessage *notifMsg = (NotifMessage*)[smAppDelegate.messages objectAtIndex:i];
                    MessageReply *messageReply = [[MessageReply alloc] init];
                    messageReply.content = notifMsg.notifMessage;
                    messageReply.time = notifMsg.notifTime;
                    NSArray *components = [notifMsg.notifSender componentsSeparatedByString:@" "];
                    messageReply.senderName = [components objectAtIndex:0];
                    messageReply.senderID = notifMsg.notifSenderId;
                    messageReply.senderAvater = notifMsg.notifAvater;
                    [messageReplyList insertObject:messageReply atIndex:0];
                    [messageReply release];
                    [messageReplyTableView reloadData];
                }
            }
    }
    
    [msgListTableView reloadData];
    
}

-(void) displayNotificationCount {
    int totalNotif= [UtilityClass getNotificationCount];
    if (totalNotif == 0)
        totalNotifCount.text = @"";
    else
        totalNotifCount.text = [NSString stringWithFormat:@"%d",totalNotif];
}

- (void) sendMessage:(id)sender {
    
    NSString * subject = [NSString stringWithFormat:@"Message from %@ %@", smAppDelegate.userAccountPrefs.firstName,
                          smAppDelegate.userAccountPrefs.lastName];
    
    NSMutableArray *userIDs = [[self getUserIds] retain];
    
    for (UserCircle *userCircle in selectedCircleCheckOriginalArr) 
        [userIDs addObjectsFromArray:userCircle.friends];
    
    NSLog(@"userIDs = %@", userIDs);
    
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    [restClient sendMessage:subject content:textViewNewMsg.text recipients:userIDs authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
    [userIDs release];
}

- (void)getNewThreadDone:(NSNotification*)notif
{
    if (notif.object) {
        
        self.selectedMessage = notif.object;
        self.msgParentID = self.selectedMessage.notifID;
        [self setMsgReplyTableView:selectedMessage];

    } else {
        [UtilityClass showAlert:@"" :@"Network Error"];
    }
}

- (void)sendReplyDone:(NSNotification *)notif
{
    [self showHideIndicatorOnTextview:textViewReplyMsg];
    
    if (notif.object) {
        [self startReqForReplyMessages];
        [self clearTextView:textViewReplyMsg];
    } else {
        [UtilityClass showAlert:@"" :@"Error sending reply, try again."];
    }
    
}
/*
- (void)addTempReplyInTableView:(NSTimer*)timer
{
    if (!isCheckingNewReplies) {
        [messageReplyList addObject:timer.userInfo];
        [timer invalidate];
        [messageReplyTableView reloadData];
        [self clearTextView:textViewReplyMsg];
        NSIndexPath* ipath = [NSIndexPath indexPathForRow: [messageReplyList count] -1 inSection:0];
        [messageReplyTableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
        isCheckingNewReplies = YES;
    }
}
*/
- (NSMutableArray*)getUserIds
{
    NSMutableArray *userIDs = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [selectedFriendsIndex count]; i++) {
        NSString *userId = ((UserFriends*)[filteredList objectAtIndex:[[selectedFriendsIndex objectAtIndex:i] intValue]]).userId;
        [userIDs addObject:userId];
    }
    
    NSLog(@"user id %@", userIDs);

    return [userIDs autorelease];
}

- (void) getReplyMessages:(NSNotification *)notif
{
    NSLog(@"gotReplyMessages");
    
    notifBadgeFlag=FALSE;
    [smAppDelegate hideActivityViewer];
    
    NSMutableArray *msgReplies = [notif object];
    
    if ([msgReplies count] == 0 || ![self.msgParentID isEqualToString:[notif.userInfo valueForKey:@"parentMsgId"]]) {
        return;
    }
    
    for (int i = 0; i < [msgReplies count]; i++) {
        for (int j = 0; j < [messageReplyList count]; j++) {
            if ([((MessageReply*)[msgReplies objectAtIndex:i]).msgId isEqualToString:((MessageReply*)[messageReplyList objectAtIndex:j]).msgId]) {
                [msgReplies removeObjectAtIndex:i];
                if ([msgReplies count] == 0) {
                    return;
                }
            }
        }
    }
    
    [messageReplyList addObjectsFromArray:msgReplies];
    [messageReplyTableView reloadData];
    
    if (textViewReplyMsg.isFirstResponder) {
        [self scrollSelfViewUp];
    } else {
        NSIndexPath* ipath = [NSIndexPath indexPathForRow: [messageReplyList count] -1 inSection:0];
        [messageReplyTableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
    }
  
    NSTimeInterval ti =[((MessageReply*)[messageReplyList objectAtIndex:[messageReplyList count] - 1]).time timeIntervalSince1970];
    self.timeSinceLastUpdate = [NSString stringWithFormat:@"%f", ti];
    
    [self displayNotificationCount];
}


// Tableview stuff
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tableViewCircle) {
        static NSString *CellIdentifier = @"circleTableCell";
        SelectCircleTableCell *cell = [tableViewCircle
                                       dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[[SelectCircleTableCell alloc]
                    initWithStyle:UITableViewCellStyleDefault 
                    reuseIdentifier:CellIdentifier] autorelease];
        }
        
        if ([[[circleListGlobalArray objectAtIndex:indexPath.row] circleName] isEqual:[NSNull null]] ) {
            cell.circrcleName.text = [NSString stringWithFormat:@"Custom (%d)",[((UserCircle *)[circleListGlobalArray objectAtIndex:indexPath.row]).friends count]];
        } else {
            NSLog(@"circle name %@", [[circleListGlobalArray objectAtIndex:indexPath.row] circleName]);
            cell.circrcleName.text=[NSString stringWithFormat:@"%@ (%d)", [[circleListGlobalArray objectAtIndex:indexPath.row] circleName],[((UserCircle *)[circleListGlobalArray objectAtIndex:indexPath.row]).friends count]] ;
        }
        
        if ([selectedCircleCheckArr containsObject:[circleListGlobalArray objectAtIndex:indexPath.row]]) {
            [cell.circrcleCheckbox setImage:[UIImage imageNamed:@"people_checked.png"] forState:UIControlStateNormal];
        } else {
            [cell.circrcleCheckbox setImage:[UIImage imageNamed:@"list_uncheck.png"] forState:UIControlStateNormal];
        }
        
        [cell.circrcleCheckbox addTarget:self action:@selector(handleTableViewCheckbox:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    
    if (tableView.tag == TAG_TABLEVIEW_REPLY) {
        
        MessageReply *msgReply = [messageReplyList objectAtIndex:indexPath.row];
        
        CGSize senderStringSize = [msgReply.senderName sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:kMediumLabelFontSize]];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"replyList"];
        
        CGFloat rowHeight = [self getRowHeightForReplyCell:tableView :msgReply];
        
        CGFloat rowWidth = tableView.frame.size.width - SENDER_NAME_REPLY_START_POSX - GAP * 4;
        CGFloat rowStartPos = SENDER_NAME_REPLY_START_POSX;
        
        if (rowWidth > [self getRowWidth:tableView :msgReply]) {
            rowWidth = [self getRowWidth:tableView :msgReply];
            rowStartPos = tableView.frame.size.width - rowWidth - 12;
        }
        
        CGRect senderFrame = CGRectMake(rowStartPos, 0, senderStringSize.width, senderStringSize.height);
        
        CGRect msgFrame = CGRectMake(rowStartPos, GAP, rowWidth, rowHeight - GAP * 2);
        
        CGRect timeFrame = CGRectMake(10, msgFrame.size.height + msgFrame.origin.y - senderStringSize.height,  msgFrame.origin.x - GAP - 10, senderStringSize.height);
        
        
        if (cell == nil) {
            
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"replyList"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            
            // Message sender
            UILabel *lblSender = [[[UILabel alloc] initWithFrame:senderFrame] autorelease];
            lblSender.tag = 3002;
            lblSender.font = [UIFont fontWithName:@"Helvetica-Bold" size:kSmallLabelFontSize];
            lblSender.textColor = [UIColor blackColor];
            lblSender.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:lblSender];
            
            // Time
            UILabel *lblTime = [[[UILabel alloc] initWithFrame:timeFrame] autorelease];
            lblTime.tag = 3004;
            lblTime.textAlignment = UITextAlignmentRight;
            lblTime.font = [UIFont fontWithName:@"Helvetica-Oblique" size:kSmallLabelFontSize];
            lblTime.textColor = [UIColor blackColor];
            lblTime.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:lblTime];
            
            // Message
            UITextView *txtViewTxtMsg = [[[UITextView alloc] initWithFrame:msgFrame] autorelease];
            txtViewTxtMsg.tag = 3005;
            txtViewTxtMsg.textColor = [UIColor blackColor];
            txtViewTxtMsg.font = [UIFont fontWithName:@"Helvetica" size:kMediumLabelFontSize];
            [txtViewTxtMsg.layer setCornerRadius:5.0f];
            [txtViewTxtMsg.layer setBorderWidth:0.5];
            [txtViewTxtMsg.layer setBorderColor:[UIColor lightGrayColor].CGColor];
            [txtViewTxtMsg.layer setMasksToBounds:YES];
            txtViewTxtMsg.userInteractionEnabled = NO;
            [cell.contentView addSubview:txtViewTxtMsg];
            
            //Thumb Image
            UIImageView *imageViewReply = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 48, 48)];
            imageViewReply.tag = 3006;
            [imageViewReply.layer setCornerRadius:6.0f];
            [imageViewReply.layer setBorderWidth:2.0];
            [imageViewReply.layer setBorderColor:[UIColor darkGrayColor].CGColor];
            [imageViewReply.layer setMasksToBounds:YES];
            [cell addSubview:imageViewReply];
            imageViewReply.hidden = YES;
            [imageViewReply release];
        }
        
        UILabel     *lblSender  = (UILabel*) [cell viewWithTag:3002];
        UILabel     *lblTime    = (UILabel*) [cell viewWithTag:3004];
        UITextView  *txtMsg     = (UITextView*) [cell viewWithTag:3005];
        UIImageView *imageViewReply = (UIImageView*) [cell viewWithTag:3006];
        
        if ([smAppDelegate.userId isEqualToString:msgReply.senderID]) {
            imageViewReply.frame = CGRectMake(37, msgFrame.origin.y, 48, 48);
            
            lblTime.frame = timeFrame;
            txtMsg.frame = msgFrame;
            txtMsg.backgroundColor = [UIColor colorWithRed:163.0/255 green:232.0/255 blue:95.0/255 alpha:0.4];
            lblSender.frame = CGRectMake(0, 0, 0, 0);
            lblTime.textAlignment = UITextAlignmentRight;
  
        } else {
            
            lblSender.frame = CGRectMake(10, senderFrame.origin.y, senderFrame.size.width, senderFrame.size.height);
            txtMsg.backgroundColor = [UIColor colorWithRed:243.0/255 green:244.0/255 blue:245.0/255 alpha:0.4];
            lblTime.frame = CGRectMake(timeFrame.origin.x + msgFrame.size.width + GAP, timeFrame.origin.y , timeFrame.size.width, timeFrame.size.height);
            
            txtMsg.frame = CGRectMake(10, senderFrame.origin.y + senderFrame.size.height, rowWidth, msgFrame.size.height - 15);
            imageViewReply.frame = CGRectMake(txtMsg.frame.size.width + txtMsg.frame.origin.x + GAP, txtMsg.frame.origin.y, 48, 48);
            
            if (!isGroupChat) {
                lblSender.frame = CGRectMake(0, 0, 0, 0);
                txtMsg.frame = CGRectMake(10, 0, rowWidth, msgFrame.size.height);
            }
            
            lblTime.textAlignment = UITextAlignmentLeft;
        }
        
        lblSender.text = msgReply.senderName;
        lblTime.text = [UtilityClass timeAsString:msgReply.time];
        txtMsg.text = msgReply.content;
        
        if (msgReply.metaType)
        {
            [imageViewReply setImageForUrlIfAvailable:[NSURL URLWithString:msgReply.senderAvater]];
            imageViewReply.hidden = NO;
            
            if (![cell viewWithTag:10001]) {
                UIButton *buttonGotoDirection = [UIButton buttonWithType:UIButtonTypeCustom];
                [buttonGotoDirection setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [buttonGotoDirection setTitle:@"Get Directions" forState:UIControlStateNormal];
                [buttonGotoDirection.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize]];
                [buttonGotoDirection addTarget:self action:@selector(actionGotoDirectionButton:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:buttonGotoDirection];
                [buttonGotoDirection setBackgroundImage:[UIImage imageNamed:@"btn_bg_green_small"] forState:UIControlStateNormal];
                buttonGotoDirection.tag = 10001;
            }
            [cell viewWithTag:10001].frame = CGRectMake(txtMsg.frame.origin.x + (txtMsg.frame.size.width - 90) / 2, rowHeight - 40, 90, 30);
        } else {
            [[cell viewWithTag:10001] removeFromSuperview];
            imageViewReply.hidden = YES;
        }
        
        return cell;
    }
    
    NotifMessage *msg = [smAppDelegate.messages objectAtIndex:indexPath.row];
    
    CGSize senderStringSize = [msg.notifSender sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:kSmallLabelFontSize]];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"msgList"];
    
    if (cell == nil) {
    
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"msgList"] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        CGRect senderFrame = CGRectMake(SENDER_NAME_START_POSX + GAP, GAP, senderStringSize.width +100, senderStringSize.height);
        
        CGRect timeFrame = CGRectMake(senderStringSize.width + GAP, 
                                      GAP, tableView.frame.size.width - 22 - senderStringSize.width, senderStringSize.height);
        
        CGRect msgFrame = CGRectMake(SENDER_NAME_START_POSX, senderFrame.size.height + senderFrame.origin.y + 1, tableView.frame.size.width - SENDER_NAME_START_POSX - GAP * 4, 35);
        
        // Message sender
        UILabel *lblSender = [[[UILabel alloc] initWithFrame:senderFrame] autorelease];
        lblSender.tag = 2002;
        lblSender.font = [UIFont fontWithName:@"Helvetica-Bold" size:kSmallLabelFontSize];
        lblSender.textColor = [UIColor blackColor];
        lblSender.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:lblSender];
        
        // Time
        UILabel *lblTime = [[[UILabel alloc] initWithFrame:timeFrame] autorelease];
        lblTime.tag = 2004;
        lblTime.textAlignment = UITextAlignmentRight;
        lblTime.font = [UIFont fontWithName:@"Helvetica-Oblique" size:kSmallLabelFontSize];
        lblTime.textColor = [UIColor blackColor];
        lblTime.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:lblTime];
        
        // Message
        UILabel *lblTxtMsg = [[[UILabel alloc] initWithFrame:CGRectMake(GAP * 3, -1, msgFrame.size.width - GAP * 6, msgFrame.size.height)] autorelease];
        lblTxtMsg.numberOfLines = 2;
        lblTxtMsg.tag = 2005;
        lblTxtMsg.textColor = [UIColor blackColor];
        lblTxtMsg.font = [UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize];
        lblTxtMsg.backgroundColor = [UIColor clearColor];
        UILabel *lblTxtMsgContainer = [[[UILabel alloc] initWithFrame:msgFrame] autorelease];
        [lblTxtMsgContainer.layer setCornerRadius:5.0f];
        [lblTxtMsgContainer.layer setBorderWidth:0.5];
        [lblTxtMsgContainer.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [lblTxtMsgContainer.layer setMasksToBounds:YES];
        [lblTxtMsgContainer addSubview:lblTxtMsg];
        lblTxtMsgContainer.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:lblTxtMsgContainer];
        
        //Thumb Image
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 5, 48, 48)];
        imageView.tag = 2006;
        [imageView.layer setCornerRadius:6.0f];
        [imageView.layer setBorderWidth:2.0];
        [imageView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [imageView.layer setMasksToBounds:YES];
        [cell addSubview:imageView];
        [imageView release];
    } 
    
    UILabel *lblSender  = (UILabel*) [cell viewWithTag:2002];
    UILabel *lblTime    = (UILabel*) [cell viewWithTag:2004];
    UILabel *txtMsg     = (UILabel*) [cell viewWithTag:2005];
    UIImageView *thumbImageView = (UIImageView*) [cell viewWithTag:2006];
    
    NSDictionary *titleAndAvatar = [[self buildMessageTitleAndAvatar:msg] retain];
    
    lblSender.text = [titleAndAvatar valueForKey:@"title"]; 
    lblTime.text = [UtilityClass timeAsString:msg.notifUpdateTime];
    [thumbImageView setImageForUrlIfAvailable:[NSURL URLWithString:[titleAndAvatar valueForKey:@"avatar"]]];
    [titleAndAvatar release];
    
    if (![msg.lastReply isEqual:[NSNull null]]) {
        for (NSDictionary *lastReplyDic in msg.lastReply) {
            
            NSString *lastReply = [lastReplyDic valueForKey:@"content"];
            
            if ((lastReply == NULL) || [lastReply isEqual:[NSNull null]]) {
                txtMsg.text = msg.notifMessage;
            } else {
                txtMsg.text = lastReply;
            }
        }
    } else {
        txtMsg.text = msg.notifMessage;
    }
    
    if ([msg.msgStatus isEqualToString:@"unread"]) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:163.0/255 green:232.0/255 blue:95.0/255 alpha:0.4];
    } else {
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
}

- (NSDictionary*) buildMessageTitleAndAvatar:(NotifMessage*) message {
    // Get logged in user id
    NSString *activeUserId = smAppDelegate.userId;
    NSMutableArray *recipientNames = [[NSMutableArray alloc] init];
    NSMutableArray *avatarImages = [[NSMutableArray alloc] init];
    NSMutableArray *recipientIds = [[NSMutableArray alloc] init];
    NSMutableDictionary *titleAndAvatar = [[NSMutableDictionary alloc] init];
    
    // Iterate through all recipients
    for (NSDictionary *recipient in message.recipients) {
        NSString *_id = [recipient valueForKey:@"id"];
        
        // If recipient is not ME
        if (![_id isEqualToString:activeUserId]) { 
            [recipientIds addObject:_id];
            
            // Add first name to title string buffer
            
            NSString *name = [recipient valueForKey:@"username"];
            
            if (![name isKindOfClass:[NSString class]]) {
                name = [recipient valueForKey:@"firstName"];
            }
            
            [recipientNames addObject:name];
            
            // Add avatar to avatar array
            NSString *urlAvatar = [recipient valueForKey:@"avatar"];
            NSLog(@"Avatar=%@", urlAvatar);
            if ((urlAvatar==NULL)||[urlAvatar isEqual:[NSNull null]])
                urlAvatar=[[NSBundle mainBundle] pathForResource:@"thum" ofType:@"png"];

            [avatarImages addObject:urlAvatar];
        }
    }
    
    // If recipient name array is not empty
    if ([recipientNames count] > 0) {
        // Join all string with "," 
        [titleAndAvatar setObject:[recipientNames componentsJoinedByString:@", "] forKey:@"title" ];
    } else {
        // Otherwise set sender first name
        [titleAndAvatar setObject:[[message.notifSender componentsSeparatedByString:@" "] objectAtIndex:0] forKey:@"title"];
    }
    
    [recipientNames release];
    
    // If avatar array is not empty
    if ([avatarImages count] > 0) {
        // Take first avatar element from array
        [titleAndAvatar setObject: [avatarImages objectAtIndex:0] forKey: @"avatar"];
        [titleAndAvatar setObject: [recipientIds objectAtIndex:0] forKey: @"id"];
        // Otherwise set sender avatar image
    } else if (message.notifAvater) {
        [titleAndAvatar setObject: message.notifAvater forKey: @"avatar"];
        [titleAndAvatar setObject: message.notifSenderId forKey: @"id"];
    } else {
        [titleAndAvatar setObject: message.notifSenderId forKey: @"id"];
    }
    
    [recipientIds release];
    [avatarImages release];
    
    NSLog(@"TitleAndAvatar: Message - %@, %@", message.notifMessage, titleAndAvatar);
    
    return [titleAndAvatar autorelease];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    NSLog(@"get replies");
    if (tableView.tag == TAG_TABLEVIEW_REPLY) {
        if ([textViewReplyMsg isFirstResponder]) {
            [textViewReplyMsg resignFirstResponder];
            [self setViewMovedDown:messageRepiesView];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    NotifMessage *msg = [smAppDelegate.messages objectAtIndex:indexPath.row];
    msg.msgStatus = @"read";
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];

    [self setMsgReplyTableView:msg];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
     
-(void) setMsgReplyTableView:(NotifMessage*)msg
{
    MessageReply *messageReply = [[MessageReply alloc] init];
    messageReply.content = msg.notifMessage;
    messageReply.time = msg.notifTime;
    NSArray *components = [msg.notifSender componentsSeparatedByString:@" "];
    messageReply.senderName = [components objectAtIndex:0];
    messageReply.senderID = msg.notifSenderId;
    messageReply.senderAvater = msg.notifAvater;
    messageReply.address = msg.address;
    messageReply.metaType = msg.metaType;
    messageReply.lat = msg.lat;
    messageReply.lng = msg.lng;
    
    NSLog(@"notif id = %@", msg.notifID);
    
    [messageReplyList removeAllObjects];
    if (![messageReply.senderID isEqualToString:@"sender_id"])
        if (![msg.notifID isEqualToString:@"NewMsg"])
            if ([messageReply.content isKindOfClass:[NSString class]])
                [messageReplyList addObject:messageReply];
    [messageReply release];
    
    if (msg.recipients.count > 2) {
        isGroupChat = YES;
    } else {
        isGroupChat = NO;
    }
    
    [messageReplyTableView reloadData];
    if (messageRepiesView.hidden) {
        [self doRightViewAnimation:messageRepiesView];
    }
    
    if (![selectedMessage.notifID isEqualToString:@"NewMsg"]) {   // "NewMsg" = come form user profile
        
        self.msgParentID = msg.notifID;
        self.timeSinceLastUpdate = @"420";
        
        [self startReqForReplyMessages];
        
        //Stop any previous timer
        if (replyTimer) {
            [replyTimer invalidate];
            replyTimer = nil;
        }
        
        if (!replyTimer) {
            replyTimer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(startReqForReplyMessages) userInfo:nil repeats:YES];
        }
    }
    [smAppDelegate showActivityViewer:self.view];
}

- (void)startReqForReplyMessages
{
    if (!messageRepiesView.hidden /*&& !smAppDelegate.isAppInBackgound*/) {
        RestClient *restClient = [[[RestClient alloc] init] autorelease];
        [restClient getReplies:@"Auth-Token" authTokenVal:smAppDelegate.authToken msgID:self.msgParentID since:self.timeSinceLastUpdate];
    } else {
        if (replyTimer) {
            [replyTimer invalidate];
            replyTimer = nil;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (tableView.tag == TAG_TABLEVIEW_REPLY) ? [messageReplyList count] : (tableViewCircle == tableView)? [circleListGlobalArray count] : [smAppDelegate.messages count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.tag == TAG_TABLEVIEW_REPLY) {
        MessageReply *msgReply = [messageReplyList objectAtIndex:indexPath.row];
        return [self getRowHeightForReplyCell:tableView :msgReply];
    } else if (tableViewCircle == tableView) {
        return 44;
    }
    
    return CELL_HEIGHT;
}

- (CGFloat) getRowWidth:(UITableView*)tv:(MessageReply*)msgReply 
{
    CGSize msgStringSize = [msgReply.content sizeWithFont:[UIFont fontWithName:@"Helvetica" size:kMediumLabelFontSize]];
    return msgStringSize.width + 18;
}


- (CGFloat) getRowHeightForReplyCell:(UITableView*)tv:(MessageReply*)msgReply 
{
    CGFloat cellRowHeight;
    
    CGSize senderStringSize = [msgReply.senderName sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:kLargeLabelFontSize]];
    CGSize msgStringSize = [msgReply.content sizeWithFont:[UIFont fontWithName:@"Helvetica" size:kLargeLabelFontSize]];
    
    int newLine = [[msgReply.content componentsSeparatedByString:@"\n"] count];
    
    CGFloat msgRows = ceil(msgStringSize.width / (tv.frame.size.width - SENDER_NAME_START_POSX - 45));
    
    msgRows = msgRows + newLine - 1;
   
    if (!isGroupChat || [smAppDelegate.userId isEqualToString:msgReply.senderID])
        senderStringSize.height = 0;
        
    
    cellRowHeight = senderStringSize.height + msgRows*18 + 22;
    
    CGFloat cellHeight = (cellRowHeight < CELL_HEIGHT - 20) ? CELL_HEIGHT - 20: cellRowHeight;
    
    if (msgReply.metaType)
        cellHeight += 40; 
    
    return cellHeight;
}

- (CGFloat) getRowHeight:(UITableView*)tv:(MessageReply*)msgReply {
    
    CGFloat cellRowHeight;
    
    CGSize senderStringSize = [msgReply.senderName sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:kLargeLabelFontSize]];
    CGSize msgStringSize = [msgReply.content sizeWithFont:[UIFont fontWithName:@"Helvetica" size:kLargeLabelFontSize]];
    
    int newLine = [[msgReply.content componentsSeparatedByString:@"\n"] count];
    
    CGFloat msgRows = ceil(msgStringSize.width / (tv.frame.size.width - SENDER_NAME_START_POSX - 45));
    
    msgRows = msgRows + newLine - 1;
    
    cellRowHeight = senderStringSize.height + msgRows*18 + 17;
    
    CGFloat cellHeight = (cellRowHeight < CELL_HEIGHT) ? CELL_HEIGHT: cellRowHeight;
    
    if (msgReply.metaType)
        cellHeight += 40; 
    
    
    return cellHeight;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([textView isEqual:textViewNewMsg]) {
        [self setViewMovedUp:msgWritingView];
    } else {
        [self setViewMovedUp:messageRepiesView];
    }

    if (!(textView.textColor == [UIColor blackColor])) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    return YES;
    
}

//Lazy loading method starts

#pragma mark -
#pragma mark Table cell image support

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if (!messageRepiesView.hidden)
        return;
    
    if ([smAppDelegate.messages count] > 0)
    {
        NSArray *visiblePaths = [msgListTableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            UITableViewCell *cell = [msgListTableView cellForRowAtIndexPath:indexPath];
            UIImageView *imgIcon = (UIImageView*) [cell viewWithTag:2006];
            NotifMessage *msg = [smAppDelegate.messages objectAtIndex:indexPath.row];
            NSDictionary *titleAndAvatar = [self buildMessageTitleAndAvatar:msg];
            [imgIcon loadFromURL:[NSURL URLWithString:[titleAndAvatar valueForKey:@"avatar"]]];
        }
    }
}

#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    isDragging_msg = FALSE;
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    isDecliring_msg = FALSE;
    [self loadImagesForOnscreenRows];
}

//Lazy loading method ends.

-(void)doBottomViewAnimation:(UIView*)incomingView
{	
    CATransition *animation = [CATransition animation];
	
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromTop];
	
    [animation setDuration:0.5];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
    [[incomingView layer] addAnimation:animation forKey:kCATransition];
	incomingView.hidden = !incomingView.hidden;
}

-(void)doTopViewAnimation:(UIView*)incomingView
{	
	CATransition *animation = [CATransition animation];
	
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromBottom];
	
    [animation setDuration:0.5];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
    [[incomingView layer] addAnimation:animation forKey:kCATransition];
	incomingView.hidden = !incomingView.hidden;
}

-(void)doLeftViewAnimation:(UIView*)incomingView
{	
    CATransition *animation = [CATransition animation];
	
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromLeft];
	
    [animation setDuration:0.5];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
    [[incomingView layer] addAnimation:animation forKey:kCATransition];
	incomingView.hidden = !incomingView.hidden;
}

-(void)doRightViewAnimation:(UIView*)incomingView
{	
    CATransition *animation = [CATransition animation];
	
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromRight];
	
    [animation setDuration:0.5];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
    [[incomingView layer] addAnimation:animation forKey:kCATransition];
	incomingView.hidden = !incomingView.hidden;
}

- (void)scrollSelfViewDown
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; 
	
    CGRect rect = self.view.frame;
	
	rect.origin.y = 0;
	msgReplyCreationView.frame = CGRectMake(0, messageRepiesView.frame.size.height - 59, msgReplyCreationView.frame.size.width, msgReplyCreationView.frame.size.height);
	
    self.view.frame = rect;
    [UIView commitAnimations];
}

- (void)scrollSelfViewUp
{
    NSLog(@"scrollSelfView");
    if ([messageReplyList count]) {
        NSIndexPath* ipath = [NSIndexPath indexPathForRow: [messageReplyList count] -1 inSection:0];
        [messageReplyTableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
    }    
        NSArray *visiblePaths = [messageReplyTableView indexPathsForVisibleRows];
    
        int totalVisibleCellHeight = 0;
        
        for (NSIndexPath *indexPath in visiblePaths)
        {
            MessageReply *msgReply = [messageReplyList objectAtIndex:indexPath.row];
            totalVisibleCellHeight += [self getRowHeight:messageReplyTableView :msgReply];
        }
        
        NSLog(@"Total visible cell heitht %d", totalVisibleCellHeight);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3]; 
        
        if (totalVisibleCellHeight > 55) {
            CGRect rect = self.view.frame;
            int moveBy = -totalVisibleCellHeight + 55;
            
            //TODO: for iPhone 5 calculation complication
            if (messageReplyTableView.frame.size.height < totalVisibleCellHeight) {
                moveBy = -kOFFSET_FOR_KEYBOARD; 
            }
            
            rect.origin.y = moveBy;
            self.view.frame = rect;
            msgReplyCreationView.frame = CGRectMake(0, messageRepiesView.frame.size.height - 59 - kOFFSET_FOR_KEYBOARD - moveBy, msgReplyCreationView.frame.size.width, msgReplyCreationView.frame.size.height);
        } else {
            msgReplyCreationView.frame = CGRectMake(0, messageRepiesView.frame.size.height - 59 - kOFFSET_FOR_KEYBOARD, msgReplyCreationView.frame.size.width, msgReplyCreationView.frame.size.height);
        }
        [UIView commitAnimations];
}

-(void)setViewMovedUp:(UIView*)view
{
    if (messageRepiesView == view) {
        [self scrollSelfViewUp];
        return;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; 
	
    CGRect rect = view.frame;
	
	rect.origin.y -= kOFFSET_FOR_KEYBOARD;
	
    view.frame = rect;
    [UIView commitAnimations];

}

-(void)setViewMovedDown:(UIView*)view
{
    if (messageRepiesView == view) {
        [self scrollSelfViewDown];
        return;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
	
    CGRect rect = view.frame;
	
	rect.origin.y += kOFFSET_FOR_KEYBOARD;
    
    view.frame = rect;
	
    [UIView commitAnimations];
}

- (void)dealloc 
{
    if (replyTimer) {
        [replyTimer invalidate];
        replyTimer = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_INBOX_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_SEND_REPLY_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_NEW_THREAD_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_REPLIES_DONE object:nil];
    
    [messageReplyList release];
    [messageCreationView release];
    [textViewNewMsg release];
    [msgWritingView release];
    [textFieldUserID1 release];
    [textFieldUserID2 release];
    [textFieldUserID3 release];
    [buttonMessage release];
    [buttonMeetUp release];
    [messageRepiesView release];
    [textViewReplyMsg release];
    [messageReplyTableView release];
    [msgReplyCreationView release];
    [viewSearch release];
    [tableViewCircle release];
    [viewCircleList release];
    [super dealloc];
}

////friends List code
//handling selection from scroll view of friends selection
-(IBAction) handleTapGesture:(UIGestureRecognizer *)sender
{
    int imageIndex =((UITapGestureRecognizer *)sender).view.tag;
    NSArray* subviews = [NSArray arrayWithArray: frndListScrollView.subviews];
    if ([selectedFriendsIndex containsObject:[NSString stringWithFormat:@"%d",[sender.view tag]]])
    {
        [selectedFriendsIndex removeObject:[NSString stringWithFormat:@"%d",[sender.view tag]]];
    } 
    else 
    {
        [selectedFriendsIndex addObject:[NSString stringWithFormat:@"%d",[sender.view tag]]];
        
    }
    
    for (int l=0; l<[subviews count]; l++)
    {
        if (l==imageIndex)
        {
            UIView *im=[subviews objectAtIndex:l];
            NSArray* subviews1 = [NSArray arrayWithArray: im.subviews];
            UIImageView *im1=[subviews1 objectAtIndex:0];
            [im1 setAlpha:1.0];
            im1.layer.borderWidth=2.0;
            im1.layer.masksToBounds = YES;
            [im1.layer setCornerRadius:7.0];
            im1.layer.borderColor=[[UIColor greenColor]CGColor];
        }
    }
    [self reloadScrolview];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    isDragging_msg = TRUE;
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    isDecliring_msg = TRUE;
}

//lazy load method ends


//search bar delegate method starts
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText 
{
    // We don't want to do anything until the user clicks 
    // the 'Search' button.
    // If you wanted to display results as the user types 
    // you would do that here.
    //[self loadFriendListsData]; TODO: commented this
    searchText=friendSearchbar.text;
    
    if ([searchText length]>0) 
    {
        [self performSelector:@selector(searchResult) withObject:nil afterDelay:0.1];
        searchFlag=true;
        NSLog(@"searchText  %@",searchText);
    }
    else
    {
        [selectedFriendsIndex removeAllObjects];
        [filteredList removeAllObjects];
        filteredList = [[NSMutableArray alloc] initWithArray: friendListArr];
        [self reloadScrolview];
    }
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar 
{
    searchTexts=friendSearchbar.text;
    [self beganEditing];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar 
{
    [self endEditing];
    [friendSearchbar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // Clear the search text
    // Deactivate the UISearchBar
    friendSearchbar.text=@"";
    searchTexts=@"";
    
    [filteredList removeAllObjects];
    filteredList = [[NSMutableArray alloc] initWithArray: friendListArr];
    [selectedFriendsIndex removeAllObjects];
    [self reloadScrolview];
    [friendSearchbar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar 
{
    searchTexts=friendSearchbar.text;
    searchFlag=false;
    [self searchResult];
    [friendSearchbar resignFirstResponder];    
}

-(void)searchResult
{
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
}
//searchbar delegate method end

//keyboard hides input fields deleget methods

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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

//lazy scroller

-(void) reloadScrolview
{
    int x=0; //declared for imageview x-axis point    
    NSArray* subviews = [NSArray arrayWithArray: frndListScrollView.subviews];
    UIImageView *imgView;
    for (UIView* view in subviews) 
    {
        if([view isKindOfClass :[UIView class]])
        {
            [view removeFromSuperview];
        }
    }
    
    frndListScrollView.contentSize = CGSizeMake([filteredList count]*65 - 10, 65);
    
    for(int i=0; i<[filteredList count];i++)               
    {
        if(i< [filteredList count]) 
        { 
            UserFriends *userFrnd=[filteredList objectAtIndex:i];
            imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
            /*
            if (iconDownloader && iconDownloader.userFriends.userProfileImage.size.height > 5){
                imgView.image = iconDownloader.userFriends.userProfileImage; 
            } 
            
            else 
            { 
                if (!isDragging_msg && !isDecliring_msg)
                {
                    if (!iconDownloader) {
                        iconDownloader = [[IconDownloader alloc] init];
                    }
                    //
                    iconDownloader.userFriends = userFrnd;
                    iconDownloader.delegate = self;
                    [imageDownloadsInProgress setObject:iconDownloader forKey:userFrnd.userId];
                    iconDownloader.scrollSubViewTag = 420 + i;
                    [iconDownloader startDownload];
                }
            }
             */
            
            if (!isDragging_msg && !isDecliring_msg)
                 [imgView loadFromURL:[NSURL URLWithString:userFrnd.imageUrl]];
            
            UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(x, 0, 65, 65)];
            UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(0, 45, 60, 20)];
            [name setFont:[UIFont fontWithName:@"Helvetica-Light" size:10]];
            [name setNumberOfLines:0];
            [name setText:userFrnd.userName];
            [name setBackgroundColor:[UIColor clearColor]];
            imgView.userInteractionEnabled = YES;
            imgView.tag = i;
            aView.tag=i;
            imgView.exclusiveTouch = YES;
            imgView.clipsToBounds = NO;
            imgView.opaque = YES;
            imgView.layer.borderColor=[[UIColor clearColor] CGColor];
            imgView.userInteractionEnabled=YES;
            imgView.layer.borderWidth=2.0;
            imgView.layer.masksToBounds = YES;
            [imgView.layer setCornerRadius:7.0];
            
            imgView.layer.borderColor=[[UIColor lightGrayColor] CGColor];
            
            for (int c=0; c<[selectedFriendsIndex count]; c++)
            {
                if (i==[[selectedFriendsIndex objectAtIndex:c] intValue]) 
                {
                    imgView.layer.borderColor=[[UIColor greenColor] CGColor];
                }
            }
            
            [aView addSubview:imgView];
            [imgView release];
            [aView addSubview:name];
            [name release];
            
            UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
            tapGesture.numberOfTapsRequired = 1;
            [aView addGestureRecognizer:tapGesture];
            [tapGesture release];
            
            [frndListScrollView addSubview:aView];
            [aView release];
        }
        x+=65;
    }
}

-(IBAction)unSelectAll:(id)sender
{
    [selectedFriendsIndex removeAllObjects];
    [selectedCircleCheckArr removeAllObjects];
    [selectedCircleCheckOriginalArr removeAllObjects];
    [tableViewCircle reloadData];
    [self reloadScrolview];
}

-(IBAction)addAll:(id)sender
{
    for (int i=0; i<[filteredList count]; i++)
    {
        [selectedFriendsIndex addObject:[NSString stringWithFormat:@"%d",i]];
    }
    [self reloadScrolview];
}

-(void)loadDummydata
{
    for (int i=0; i<[friendListGlobalArray count]; i++)
    {
        UserFriends *frnds=[friendListGlobalArray objectAtIndex:i];
        if ((frnds.imageUrl==NULL)||[frnds.imageUrl isEqual:[NSNull null]])
        {
            frnds.imageUrl=[[NSBundle mainBundle] pathForResource:@"thum" ofType:@"png"];
            NSLog(@"img url null %d",i);
        }
        [friendListArr addObject:frnds];
    }
    filteredList=[friendListArr mutableCopy];
}

-(IBAction)gotoNotification:(id)sender
{
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    NotificationController *controller =[storybrd instantiateViewControllerWithIdentifier:@"notificationViewController"];
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
    
}

- (void)actionGotoDirectionButton:(id)sender
{
    DirectionViewController *controller = [[DirectionViewController alloc] initWithNibName: @"DirectionViewController" bundle:nil];
    CLLocationCoordinate2D theCoordinate;
	theCoordinate.latitude = [[(MessageReply*)[messageReplyList objectAtIndex:0] lat] floatValue];
    theCoordinate.longitude = [[(MessageReply*)[messageReplyList objectAtIndex:0] lng] floatValue];
    controller.coordinateTo = theCoordinate;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

- (IBAction)actionAddMoreButton:(id)sender {
    if ([textViewReplyMsg isFirstResponder]) {
        [textViewReplyMsg resignFirstResponder];
        [self setViewMovedDown:messageRepiesView];
    }
    [selectedFriendsIndex removeAllObjects];
    [selectedCircleCheckArr removeAllObjects];
    [selectedCircleCheckOriginalArr removeAllObjects];
    [self reloadScrolview];
    [tableViewCircle reloadData];
    viewSearchFrame = viewSearch.frame;
    [self.view addSubview:viewSearch];
    viewSearch.frame = CGRectMake(0, self.view.frame.size.height - viewSearch.frame.size.height, viewSearch.frame.size.width, viewSearch.frame.size.height);
    messageReplyTableView.userInteractionEnabled = NO;
    buttonMeetUp.userInteractionEnabled = NO;
    buttonMessage.userInteractionEnabled = NO;
}

- (IBAction)actionCancelAddPplButton:(id)sender {
    [messageCreationView addSubview:viewSearch];
    [messageCreationView sendSubviewToBack:viewSearch];
    viewSearch.frame = viewSearchFrame;
    messageReplyTableView.userInteractionEnabled = YES;
    buttonMessage.selected = YES;
    buttonMessage.userInteractionEnabled = YES;
    buttonMeetUp.userInteractionEnabled = YES;
}

- (IBAction)actionSaveAddPplButton:(id)sender 
{
    NSMutableArray *userIDs = [[self getUserIds] retain];
    for (UserCircle *userCircle in selectedCircleCheckOriginalArr) 
        [userIDs addObjectsFromArray:userCircle.friends];
    
    NSLog(@"userIDs = %@", userIDs);
    
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    [restClient updateMessageRecipients:@"Auth-Token" authTokenVal:smAppDelegate.authToken msgID:msgParentID recipients:userIDs];
    [userIDs release];
    [self actionCancelAddPplButton:nil];
}

- (IBAction)actionCancelCircleButton:(id)sender {
    [selectedCircleCheckArr removeAllObjects];
    [selectedCircleCheckArr addObjectsFromArray:selectedCircleCheckOriginalArr];
    viewCircleList.hidden = YES;
    self.view.userInteractionEnabled = YES;
}

- (IBAction)actionSaveCircleButton:(id)sender {
    viewCircleList.hidden = YES;
    self.view.userInteractionEnabled = YES;
    [selectedCircleCheckOriginalArr removeAllObjects];
    [selectedCircleCheckOriginalArr addObjectsFromArray:selectedCircleCheckArr];
}

- (IBAction)actionShowCircleListButton:(id)sender {
    viewCircleList.hidden = NO;
    [selectedCircleCheckArr removeAllObjects];
    [selectedCircleCheckArr addObjectsFromArray:selectedCircleCheckOriginalArr];
    [tableViewCircle reloadData];
    [smAppDelegate.window addSubview:viewCircleList];
    self.view.userInteractionEnabled = NO; 
}

-(void)handleTableViewCheckbox:(id)sender
{
    SelectCircleTableCell *clickedCell = (SelectCircleTableCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [tableViewCircle indexPathForCell:clickedCell];

    if ([selectedCircleCheckArr containsObject:[circleListGlobalArray objectAtIndex:clickedButtonPath.row]]) {
        
        [selectedCircleCheckArr removeObject:[circleListGlobalArray objectAtIndex:clickedButtonPath.row]];
        [sender setImage:[UIImage imageNamed:@"list_uncheck.png"] forState:UIControlStateNormal];
        NSLog(@"removed");
    
    } else {
        
        [selectedCircleCheckArr addObject:[circleListGlobalArray objectAtIndex:clickedButtonPath.row]];
        [sender setImage:[UIImage imageNamed:@"people_checked.png"] forState:UIControlStateNormal];
        NSLog(@"added");
    }
}

@end

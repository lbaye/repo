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

#define     SENDER_NAME_START_POSX  60
#define     CELL_HEIGHT             60
#define     GAP                     3 
#define     kOFFSET_FOR_KEYBOARD    215
#define     TAG_TABLEVIEW_REPLY     1001
#define     TAG_TABLEVIEW_INBOX     1002
#define     TAG_MEETUP_VIEW         1003

@implementation MessageListViewController


@synthesize msgParentID;
@synthesize timeSinceLastUpdate;
@synthesize selectedMessage;
@synthesize totalNotifCount;

static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;

bool searchFlag;
__strong NSMutableArray *filteredList,*friendListArr, *circleList;
__strong NSString *searchTexts;
NSMutableDictionary *imageDownloadsInProgress, *friendsNameArr, *friendsIDArr;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    imageDownloadsInProgress = [NSMutableDictionary dictionary];
    [imageDownloadsInProgress retain];
    
    profileImageList = [[NSMutableArray alloc] init];
    messageReplyList = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [smAppDelegate.messages count]; i++) {
        [profileImageList addObject:@""];
    }
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getReplyMessages:) name:NOTIF_GET_REPLIES_DONE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotInboxMessages:) name:NOTIF_GET_INBOX_DONE object:nil];
    
    //friends list
    frndListScrollView.delegate = self;
     selectedFriendsIndex=[[NSMutableArray alloc] init];
     filteredList=[[NSMutableArray alloc] init];
    friendListArr=[[NSMutableArray alloc] init];
    //dicImages_msg = [[NSMutableDictionary alloc] init];
    
    //set scroll view content size.
    [self loadDummydata];
    
    //reloading scrollview to start asynchronous download.
    //[self reloadScrolview]; 
    
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
}

- (void) viewDidAppear:(BOOL)animated
{
    [self displayNotificationCount];
    [super viewDidAppear:animated];
    
    if (self.selectedMessage) {
        [self setMsgReplyTableView:self.selectedMessage];
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    NSArray *allDownloads = [imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // terminate all pending download connections
    NSArray *allDownloads = [imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    NSLog(@"called View did unload");
    [replyTimer invalidate];
    replyTimer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_REPLIES_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_INBOX_DONE object:nil];
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
    //msgListTableView.tag = TAG_TABLEVIEW_INBOX;
    
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
        RestClient *restClient = [[[RestClient alloc] init] autorelease];
        [restClient sendReply:msgParentID content:textViewReplyMsg.text authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
        //[self doTopViewAnimation:messageRepiesView];
        [self clearTextView:textViewReplyMsg];
    }
}

- (void) clearTextView:(UITextView*)textVeiw
{
    textVeiw.text = @"Your Message...";
    textVeiw.textColor = [UIColor lightGrayColor];
}

- (IBAction)actionRefreshBtn:(id)sender {
    
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    [restClient getInbox:@"Auth-Token" authTokenVal:smAppDelegate.authToken];

}

- (void)gotInboxMessages:(NSNotification *)notif {
    NSMutableArray *msg = [notif object];
    [smAppDelegate.messages removeAllObjects];
    [smAppDelegate.messages addObjectsFromArray:msg];
    
    for (int i = 0; i < [smAppDelegate.messages count]; i++) {
        [profileImageList addObject:@""];
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
    
    NSMutableArray *userIDs = [self getUserIds];
    
    for (UserCircle *userCircle in selectedCircleCheckOriginalArr) 
        [userIDs addObjectsFromArray:userCircle.friends];
    
    NSLog(@"userIDs = %@", userIDs);
    
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    [restClient sendMessage:subject content:textViewNewMsg.text recipients:userIDs authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
}

- (NSMutableArray*)getUserIds
{
    NSMutableArray *userIDs = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [selectedFriendsIndex count]; i++) {
        NSString *userId = ((UserFriends*)[filteredList objectAtIndex:[[selectedFriendsIndex objectAtIndex:i] intValue]]).userId;
        [userIDs addObject:userId];
    }
    
    NSLog(@"user id %@", userIDs);

    return userIDs;
}

- (void) getReplyMessages:(NSNotification *)notif {
    NSLog(@"gotReplyMessages");
    
    //NSDate *currentTime = [NSDate date];
    //NSTimeInterval ti = [currentTime timeIntervalSince1970];
    //self.timeSinceLastUpdate = [NSString stringWithFormat:@"%f", ti - 50];
    
    NSMutableArray *msgReplies = [notif object];

    /*
    if ([msgReplies count] == 0  || [((MessageReply*)[messageReplyList objectAtIndex:[messageReplyList count] -1]).time isEqual:((MessageReply*)[msgReplies objectAtIndex:[msgReplies count] - 1]).time]) {
        return;
    }
    */
    
    if ([msgReplies count] == 0) {
        return;
    }
    /*
    NSTimeInterval ti =[((MessageReply*)[msgReplies objectAtIndex:[msgReplies count] - 1]).time timeIntervalSince1970];
    self.timeSinceLastUpdate = [NSString stringWithFormat:@"%f", ti];
    NSLog(@"timeSinceLastUpdate %@", self.timeSinceLastUpdate);
    */
    
    /*
    for (MessageReply *eachMsgReply in messageReplyList) {
            MessageReply *parentMsg = (MessageReply*)[messageReplyList objectAtIndex:0];
            if ([eachMsgReply.senderID isEqualToString:parentMsg.senderID]) {
                eachMsgReply.senderImage = parentMsg.senderImage;
            }
    }
    */
    for (int i = 0; i < [msgReplies count]; i++) {
        for (int j = 0; j < [messageReplyList count]; j++) {
            if ([((MessageReply*)[msgReplies objectAtIndex:i]).msgId isEqualToString:((MessageReply*)[messageReplyList objectAtIndex:j]).msgId]) {
                [msgReplies removeObjectAtIndex:i];
            }
        }
    }
    
    if ([msgReplies count] == 0) {
        return;
    }
    
    [messageReplyList addObjectsFromArray:msgReplies];
    [messageReplyTableView reloadData];
    NSIndexPath* ipath = [NSIndexPath indexPathForRow: [messageReplyList count] -1 inSection:0];
    [messageReplyTableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];

    
    NSTimeInterval ti =[((MessageReply*)[messageReplyList objectAtIndex:[messageReplyList count] - 1]).time timeIntervalSince1970];
    self.timeSinceLastUpdate = [NSString stringWithFormat:@"%f", ti];
    NSLog(@"timeSinceLastUpdate %@", self.timeSinceLastUpdate);
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
            cell = [[SelectCircleTableCell alloc]
                    initWithStyle:UITableViewCellStyleDefault 
                    reuseIdentifier:CellIdentifier];
        }
        
        if ([[[circleListGlobalArray objectAtIndex:indexPath.row] circleName] isEqual:[NSNull null]] ) {
            //cell.circrcleName.text=@"Custom";
            cell.circrcleName.text = [NSString stringWithFormat:@"Custom (%d)",[((UserCircle *)[circleListGlobalArray objectAtIndex:indexPath.row]).friends count]];
        } else {
            NSLog(@"circle name %@", [[circleListGlobalArray objectAtIndex:indexPath.row] circleName]);
            //cell.circrcleName.text = [[circleListGlobalArray objectAtIndex:indexPath.row] circleName];
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
        
        CGSize senderStringSize = [msgReply.senderName sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:kSmallLabelFontSize]];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"replyList"];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        CGRect senderFrame = CGRectMake(SENDER_NAME_START_POSX + GAP, GAP, senderStringSize.width, senderStringSize.height);
        
        CGRect timeFrame = CGRectMake(senderStringSize.width + GAP, 
                                      GAP, tableView.frame.size.width - 22 - senderStringSize.width, senderStringSize.height);
        
        CGFloat rowHeight = [self getRowHeight:tableView :msgReply];
        
        CGRect msgFrame = CGRectMake(SENDER_NAME_START_POSX, senderFrame.size.height + senderFrame.origin.y + 1, tableView.frame.size.width - SENDER_NAME_START_POSX - GAP * 4, rowHeight - 22);
        
        if (cell == nil) {
            
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"replyList"] autorelease];
            
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
            txtViewTxtMsg.font = [UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize];
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
            
        }
        
        UILabel     *lblSender  = (UILabel*) [cell viewWithTag:3002];
        UILabel     *lblTime    = (UILabel*) [cell viewWithTag:3004];
        UITextView  *txtMsg     = (UITextView*) [cell viewWithTag:3005];
        UIImageView *imageViewReply = (UIImageView*) [cell viewWithTag:3006];
        
        if ([smAppDelegate.userId isEqualToString:msgReply.senderID]) {
            imageViewReply.frame = CGRectMake(10, (rowHeight - 48) / 2, 48, 48);
            lblTime.frame = timeFrame;
            txtMsg.frame = msgFrame;
            lblSender.frame = senderFrame;
            lblTime.textAlignment = UITextAlignmentRight;
  
        } else {
            imageViewReply.frame = CGRectMake(tableView.frame.size.width - 60, (rowHeight - 48) / 2, 48, 48);
            lblSender.frame = CGRectMake(tableView.frame.size.width - senderFrame.size.width - 64, senderFrame.origin.y, senderFrame.size.width, senderFrame.size.height);
            
            lblTime.frame = CGRectMake(10, lblTime.frame.origin.y, lblTime.frame.size.width, lblTime.frame.size.height);
            txtMsg.frame = CGRectMake(10, txtMsg.frame.origin.y, txtMsg.frame.size.width, msgFrame.size.height);
            lblTime.textAlignment = UITextAlignmentLeft;
        }
        
        IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:msgReply.senderID];
        
        if (!iconDownloader)
        {
            //imageViewReply.image = [UIImage imageNamed:@"girl.png"];
            imageViewReply.image = nil;
            if (tableView.dragging == NO && tableView.decelerating == NO) {
                [self startReplyIconDownload:msgReply forIndexPath:indexPath];
            }            
        }  else {
            //NSLog(@"image crash = %@", msgReply.senderImage);
            //imageViewReply.image = msgReply.senderImage;
            imageViewReply.image = iconDownloader.userFriends.userProfileImage;
        }
        
        lblSender.text = msgReply.senderName;
        lblTime.text = [UtilityClass timeAsString:msgReply.time];
        txtMsg.text = msgReply.content;
        
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
        [cell.contentView addSubview:lblTxtMsgContainer];
        
        [cell.imageView.layer setCornerRadius:6.0f];
        [cell.imageView.layer setBorderWidth:2.0];
        [cell.imageView.layer setBorderColor:[UIColor darkGrayColor].CGColor];
        [cell.imageView.layer setMasksToBounds:YES];
    } 
    
    UILabel *lblSender  = (UILabel*) [cell viewWithTag:2002];
    UILabel *lblTime    = (UILabel*) [cell viewWithTag:2004];
    UILabel *txtMsg     = (UILabel*) [cell viewWithTag:2005];
    
    NSDictionary *titleAndAvatar = [self buildMessageTitleAndAvatar:msg];
    
    lblSender.text = [titleAndAvatar valueForKey:@"title"]; 
    lblTime.text = [UtilityClass timeAsString:msg.notifTime];
    
    //NSString *lastReply = [msg.lastReply valueForKey:@"content"];
    NSLog(@"%@", msg.lastReply);
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
    
    
    
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:[titleAndAvatar valueForKey:@"id"]];
    
    if (!iconDownloader)
    {
    
    //if ([[profileImageList objectAtIndex:indexPath.row] isEqual:@""])
    //{
        //cell.imageView.image = [UIImage imageNamed:@"girl.png"];
        cell.imageView.image = nil;
        if (tableView.dragging == NO && tableView.decelerating == NO) {
            NotifMessage *recipientWrappedInMessage = [[NotifMessage alloc] init];
            //recipientWrappedInMessage.notifID = [NSString stringWithFormat:@"%lf", rand() * rand()];
            recipientWrappedInMessage.notifID = msg.notifID;
            recipientWrappedInMessage.notifMessage = msg.notifMessage;
            recipientWrappedInMessage.notifSender = msg.notifSender;
            recipientWrappedInMessage.notifSenderId = [titleAndAvatar valueForKey:@"id"];
            recipientWrappedInMessage.notifSubject = msg.notifSubject;
            recipientWrappedInMessage.notifTime = msg.notifTime;
            recipientWrappedInMessage.notifAvater = [titleAndAvatar valueForKey:@"avatar"];
            
            [self startIconDownload:recipientWrappedInMessage forIndexPath:indexPath];
        }            
    }  else {
        //cell.imageView.image = (UIImage*)[profileImageList objectAtIndex:indexPath.row];
        cell.imageView.image = iconDownloader.userFriends.userProfileImage;
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
            [recipientNames addObject:[recipient valueForKey:@"firstName"]];
            
            NSString *recipientAvater = [recipient valueForKey:@"avatar"];
            
            NSLog(@"******* ToDo: appStore_V1 has latest code for null url avater checking******");
            if ((recipientAvater==NULL)||[recipientAvater isEqual:[NSNull null]])
            {
                recipientAvater=[[NSBundle mainBundle] pathForResource:@"thum" ofType:@"png"];
            }
            
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
    
    NSLog(@"TitleAndAvatar: Message - %@, %@", message.notifMessage, titleAndAvatar);
    
    return titleAndAvatar;
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
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //messageReply.senderImage = cell.imageView.image;
    [messageReplyList removeAllObjects];
    [messageReplyList addObject:messageReply];
    [messageReply release];
    
    [messageReplyTableView reloadData];
    [self doRightViewAnimation:messageRepiesView];
    
    msgParentID = msg.notifID;
    self.timeSinceLastUpdate = @"420";
    [self startReqForReplyMessages];
    if (!replyTimer) {
        replyTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(startReqForReplyMessages) userInfo:nil repeats:YES];
    }
}

- (void)startReqForReplyMessages
{
    if (!messageRepiesView.hidden) {
        RestClient *restClient = [[[RestClient alloc] init] autorelease];
        [restClient getReplies:@"Auth-Token" authTokenVal:smAppDelegate.authToken msgID:msgParentID since:self.timeSinceLastUpdate];
    } else {
        [replyTimer invalidate];
        replyTimer = nil;
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
        return [self getRowHeight:tableView :msgReply];
    } else if (tableViewCircle == tableView) {
        return 44;
    }
    
    return CELL_HEIGHT;
}

- (CGFloat) getRowHeight:(UITableView*)tv:(MessageReply*)msgReply {
    
    CGFloat cellRowHeight;
    
    CGSize senderStringSize = [msgReply.senderName sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:kLargeLabelFontSize]];
    CGSize msgStringSize = [msgReply.content sizeWithFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize]];

    int newLine = [[msgReply.content componentsSeparatedByString:@"\n"] count];
    
    CGFloat msgRows = ceil(msgStringSize.width / (tv.frame.size.width - SENDER_NAME_START_POSX - 45));
    
    msgRows = msgRows + newLine - 1;
    
    cellRowHeight = senderStringSize.height + msgRows*15 + 15;
    
    return (cellRowHeight < CELL_HEIGHT) ? CELL_HEIGHT: cellRowHeight;
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

- (void)startIconDownload:(NotifMessage*)msg forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:msg.notifSenderId];
   
   if (iconDownloader == nil && msg.notifAvater != nil)
   {
        iconDownloader = [[IconDownloader alloc] init];
        UserFriends *userFriends = [[UserFriends alloc] init];
        userFriends.userId = msg.notifSenderId;
        userFriends.imageUrl = msg.notifAvater;
        iconDownloader.userFriends = userFriends;
        NSLog(@"iconDownloader.userFriends.imageUrl = %@",iconDownloader.userFriends.imageUrl);
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:msg.notifSenderId];
        [iconDownloader startDownload];
        [iconDownloader release];  
        [userFriends release];
   } 
}

- (void)startReplyIconDownload:(MessageReply*)msgReply forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:msgReply.senderID];
    NSLog(@"%@", msgReply.senderName);
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        UserFriends *userFriends = [[UserFriends alloc] init];
        userFriends.userId = msgReply.senderID;
        userFriends.imageUrl = msgReply.senderAvater;
        iconDownloader.userFriends = userFriends;
        NSLog(@"iconDownloader.userFriends.imageUrl = %@",iconDownloader.userFriends.imageUrl);
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:msgReply.senderID];
        [iconDownloader startDownload];
        [iconDownloader release];  
        [userFriends release];
    } //else {
        //msgReply.senderImage = iconDownloader.userFriends.userProfileImage;
        //UITableViewCell *cell = [messageReplyTableView cellForRowAtIndexPath:indexPath];
        //UIImageView *imageViewReply = (UIImageView*) [cell viewWithTag:3006];
        //imageViewReply.image = msgReply.senderImage;
    //}
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    //pending for msgReply tableView
    if (!messageRepiesView.hidden) {
//        for (MessageReply *msgReply in messageReplyList) {
//            if (msgReply.senderID == userId) {
//                msgReply.senderImage = iconDownloader.userFriends.userProfileImage;
//            }
//        }
        
        if ([messageReplyList count] > 0)
        {
            NSArray *visiblePaths = [messageReplyTableView indexPathsForVisibleRows];
            
            for (NSIndexPath *indexPath in visiblePaths)
            {
                UIImage *replyImage = ((MessageReply*)[messageReplyList objectAtIndex:indexPath.row]).senderImage;
                NSLog(@"messageReplyList image = %@", replyImage);
                MessageReply *msgReply = [messageReplyList objectAtIndex:indexPath.row];
                if (!replyImage) // avoid the app icon download if the app already has an icon
                {
                    [self startReplyIconDownload:msgReply forIndexPath:indexPath];
                }
//                } else {
//                    //MessageReply *msgReply = [messageReplyList objectAtIndex:indexPath.row];
//                    UITableViewCell *cell = [messageReplyTableView cellForRowAtIndexPath:indexPath];
//                    UIImageView *imageViewReply = (UIImageView*) [cell viewWithTag:3006];
//                    imageViewReply.image = msgReply.senderImage;
//                }
            }
        }
        
        //[messageReplyTableView reloadData];
        return;
    }
    
    if ([profileImageList count] > 0)
    {
        NSArray *visiblePaths = [msgListTableView indexPathsForVisibleRows];
        
        for (NSIndexPath *indexPath in visiblePaths)
        {
            UIImage *profileImage = (UIImage*)[profileImageList objectAtIndex:indexPath.row];
            
            if (!profileImage || [[profileImageList objectAtIndex:indexPath.row] isEqual:@""]) // avoid the app icon download if the app already has an icon
            {
                NotifMessage *msg = [smAppDelegate.messages objectAtIndex:indexPath.row];
                
                NSDictionary *titleAndAvatar = [self buildMessageTitleAndAvatar:msg];
                NotifMessage *recipientWrappedInMessage = [[NotifMessage alloc] init];
                recipientWrappedInMessage.notifID = [NSString stringWithFormat:@"%lf", rand() * rand()];
                recipientWrappedInMessage.notifMessage = msg.notifMessage;
                recipientWrappedInMessage.notifSender = msg.notifSender;
                recipientWrappedInMessage.notifSenderId = [titleAndAvatar valueForKey:@"id"];
                recipientWrappedInMessage.notifSubject = msg.notifSubject;
                recipientWrappedInMessage.notifTime = msg.notifTime;
                recipientWrappedInMessage.notifAvater = [titleAndAvatar valueForKey:@"avatar"];
                
                [self startIconDownload:recipientWrappedInMessage forIndexPath:indexPath];
                
                //[self startIconDownload:msg forIndexPath:indexPath];
            }
        }
    }
}

- (void)setDuplicateSenderImage:(IconDownloader *)iconDownloader
{
    for (int i = 0; i < [smAppDelegate.messages count]; i++) {
        NotifMessage *msg = [smAppDelegate.messages objectAtIndex:i];
        if ([msg.notifSenderId isEqualToString:iconDownloader.userFriends.userId]) {
            if (iconDownloader.userFriends.userProfileImage) {
                [profileImageList replaceObjectAtIndex:i withObject:iconDownloader.userFriends.userProfileImage];
            } else {
                //[profileImageList replaceObjectAtIndex:i withObject:[UIImage imageNamed:@"girl.png"]];
                [profileImageList replaceObjectAtIndex:i withObject:[[UIImage alloc] init]];
            }
        }
    }
    [msgListTableView reloadData];
    NSLog(@"profileImageList = %@", profileImageList);
}

- (void)appImageDidLoadForScrollView:(UserFriends*)userFriends:(UIImage*)image:(int)scrollSubViewTag
{
    NSLog(@"appImageDidLoadForScrollView");

    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:userFriends.userId];
    if (iconDownloader) {
        [imageDownloadsInProgress setObject:iconDownloader forKey:userFriends.userId];
    } else {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.userFriends = userFriends;
        [imageDownloadsInProgress setObject:iconDownloader forKey:userFriends.userId];
        [iconDownloader release];
    }
    
    //[dicImages_msg setObject:image forKey:userFriends.imageUrl];
    
    int tag = scrollSubViewTag - 420;
    
    if (tag == 0) {
        for (UIView *view in [frndListScrollView subviews]) {
            if (view.tag == 0) {
                for (UIImageView *imageView in [view subviews]) {
                    if ([imageView isKindOfClass:[UIImageView class]]) {
                        imageView.image = image;
                        break;
                    }
                }
            }
        }
    } else {
        for (UIImageView *imageView in [[frndListScrollView viewWithTag:tag] subviews]) {
            if ([imageView isKindOfClass:[UIImageView class]]) {
                imageView.image = image;
                break;
            }
        }
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSString *)userId
{
    //[dicImages_msg setObject:@"NO_OBJECT" forKey:userFrnd.imageUrl]; 
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:userId];
    if (iconDownloader != nil)
    {
        if (!messageRepiesView.hidden) {
            for (MessageReply *msgReply in messageReplyList) {
                if (msgReply.senderID == userId) {
                    msgReply.senderImage = iconDownloader.userFriends.userProfileImage;
                }
            }
            [messageReplyTableView reloadData];
            return;
        }
        
        UITableViewCell *cell = [msgListTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
        NSLog(@"Avatar for User - %@, User id - %@ and avatar url - %@ image = %@", 
              iconDownloader.userFriends.userName,
              iconDownloader.userFriends.userId, 
              iconDownloader.userFriends.imageUrl,
              iconDownloader.userFriends.userProfileImage);
        
        cell.imageView.image = iconDownloader.userFriends.userProfileImage;
        [profileImageList replaceObjectAtIndex:iconDownloader.indexPathInTableView.row withObject:iconDownloader.userFriends.userProfileImage];
        
        [self setDuplicateSenderImage:iconDownloader];
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

-(void)setViewMovedUp:(UIView*)view
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; 
	
    CGRect rect = view.frame;
	
	rect.origin.y -= kOFFSET_FOR_KEYBOARD;
	//rect.size.height += kOFFSET_FOR_KEYBOARD;
	
    view.frame = rect;
    [UIView commitAnimations];
}

-(void)setViewMovedDown:(UIView*)view
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
	
    CGRect rect = view.frame;
	
	rect.origin.y += kOFFSET_FOR_KEYBOARD;
	//rect.size.height -= kOFFSET_FOR_KEYBOARD;
    
    view.frame = rect;
	
    [UIView commitAnimations];
}

- (void)dealloc 
{
    [messageReplyList release];
    [imageDownloadsInProgress release];
    [profileImageList release];
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
        //        else
        //        {
        //            UIView *im1=[subviews objectAtIndex:l];
        //            NSArray* subviews2 = [NSArray arrayWithArray: im1.subviews];
        //            UIImageView *im2=[subviews2 objectAtIndex:0];
        //            [im2 setAlpha:0.4];
        //            im2.layer.borderWidth=2.0;
        //            im2.layer.borderColor=[[UIColor lightGrayColor]CGColor];
        //        }
    }
    [self reloadScrolview];
}

/*
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    isDragging_msg = FALSE;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    isDecliring_msg = FALSE;
}
*/
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
        searchText=@"";
        [selectedFriendsIndex removeAllObjects];
        //[self loadFriendListsData]; TODO: commented this
        [filteredList removeAllObjects];
        filteredList = [[NSMutableArray alloc] initWithArray: friendListArr];
        [self reloadScrolview];
    }
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar 
{
    // searchBarTextDidBeginEditing is called whenever 
    // focus is given to the UISearchBar
    // call our activate method so that we can do some 
    // additional things when the UISearchBar shows.
    searchTexts=friendSearchbar.text;
    //[UIView beginAnimations:@"FadeIn" context:nil];
    //[UIView setAnimationDuration:0.5];
    //[UIView commitAnimations];
    [self beganEditing];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar 
{
    // searchBarTextDidEndEditing is fired whenever the 
    // UISearchBar loses focus
    // We don't need to do anything here.
    //    [self.eventListTableView reloadData];
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
    // Do the search and show the results in tableview
    // Deactivate the UISearchBar
    // You'll probably want to do this on another thread
    // SomeService is just a dummy class representing some 
    // api that you are using to do the search
    
    searchTexts=friendSearchbar.text;
    searchFlag=false;
    [self searchResult];
    [friendSearchbar resignFirstResponder];    
}

-(void)searchResult
{
    //[self loadDummydata];
    searchTexts = friendSearchbar.text;

    //NSLog(@"filteredList99 %@ %@  %d  %d  imageDownloadsInProgress: %@",filteredList,friendListArr,[filteredList count],[friendListArr count], dicImages_msg);
    
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
            //UserFriends *userFrnd=[[UserFriends alloc] init];
            UserFriends *userFrnd=[filteredList objectAtIndex:i];
            imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
            
            IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:userFrnd.userId];
            
            if (iconDownloader && iconDownloader.userFriends.userProfileImage.size.height > 5){
                imgView.image = iconDownloader.userFriends.userProfileImage; 
            } 
            /*
            else if([[dicImages_msg valueForKey:userFrnd.imageUrl] isKindOfClass:[UIImage class]]) 
            { 
                //If image available in dictionary, set it to imageview 
                imgView.image = [dicImages_msg valueForKey:userFrnd.imageUrl]; 
            } 
             */
            else 
            { 
                if (!isDragging_msg && !isDecliring_msg) //&&([dicImages_msg objectForKey:[ImgesName objectAtIndex:i]]==nil))
                    
                {
                    //If scroll view moves set a placeholder image and start download image. 
                    //[dicImages_msg setObject:[UIImage imageNamed:@"girl.png"] forKey:userFrnd.imageUrl]; 
                    //[dicImages_msg setObject:@"NO_OBJECT" forKey:userFrnd.imageUrl]; 
                    if (!iconDownloader) {
                        iconDownloader = [[IconDownloader alloc] init];
                    }
                    //
                    iconDownloader.userFriends = userFrnd;
                    iconDownloader.delegate = self;
                    [imageDownloadsInProgress setObject:iconDownloader forKey:userFrnd.userId];
                    //imgView.image = [[UIImage alloc] init];
                    iconDownloader.scrollSubViewTag = 420 + i;// [[frndListScrollView subviews] count];
                    [iconDownloader startDownload];
                    //  [self performSelectorInBackground:@selector(DownLoad:) withObject:[NSNumber numberWithInt:i]];  
                    //imgView.image = [UIImage imageNamed:@"girl.png"];                   
                    
                    
                }
                /*
                else 
                { 
                    // Image is not available, so set a placeholder image
                    //imgView.image = [UIImage imageNamed:@"girl.png"];                   
                    imgView.image = [[UIImage alloc] init];                   
                } 
                 */
            }

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
                else
                {
                }
                
            }
            [aView addSubview:imgView];
            [aView addSubview:name];
            UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
            tapGesture.numberOfTapsRequired = 1;
            [aView addGestureRecognizer:tapGesture];
            [tapGesture release];
            [frndListScrollView addSubview:aView];
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
/*
-(void)DownLoad:(NSNumber *)path
{
    NSLog(@"in Download");
    //NSAutoreleasePool *pl = [[NSAutoreleasePool alloc] init];
    int index = [path intValue];
    UserFriends *userFrnd=[[UserFriends alloc] init];
    userFrnd=[filteredList objectAtIndex:index];
    
    NSString *Link = userFrnd.imageUrl;
    //Start download image from url
    UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:Link]]];
    if ((img) && ([dicImages_msg objectForKey:[ImgesName objectAtIndex:index]] == NULL))
    {
        //If download complete, set that image to dictionary
        [dicImages_msg setObject:img forKey:userFrnd.imageUrl];
        [self reloadScrolview];
    }
    // Now, we need to reload scroll view to load downloaded image
    //[self performSelectorOnMainThread:@selector(reloadScrolview) withObject:path waitUntilDone:NO];
    //[pl release];
}
*/
-(void)loadDummydata
{
    UserFriends *frnds=[[UserFriends alloc] init];
    
    for (int i=0; i<[friendListGlobalArray count]; i++)
    {
        frnds=[[UserFriends alloc] init];
        frnds=[friendListGlobalArray objectAtIndex:i];
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
    NSMutableArray *userIDs = [self getUserIds];
    for (UserCircle *userCircle in selectedCircleCheckOriginalArr) 
        [userIDs addObjectsFromArray:userCircle.friends];
    
    NSLog(@"userIDs = %@", userIDs);
    
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    [restClient updateMessageRecipients:@"Auth-Token" authTokenVal:smAppDelegate.authToken msgID:msgParentID recipients:userIDs];
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
/*
    NSMutableArray *testFriends =  ((UserCircle*)[circleListGlobalArray objectAtIndex:clickedButtonPath.row]).friends;
    NSLog(@"friends %@", testFriends);
 */
}

@end

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

#define     SENDER_NAME_START_POSX  60
#define     CELL_HEIGHT             60
#define     GAP                     3 
#define     kOFFSET_FOR_KEYBOARD    215
#define     TAG_TABLEVIEW_REPLY     1001
#define     TAG_TABLEVIEW_INBOX     1002

@implementation MessageListViewController

@synthesize msgParentID;

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
    
//    UIButton *testButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    testButton.backgroundColor = [UIColor redColor];
//    testButton.frame = CGRectMake(100, 200, 30, 30);
//    testButton.userInteractionEnabled = YES;
//    
//    [testButton addTarget:self action:@selector(actionTestBtn) forControlEvents:UIControlEventTouchUpOutside];
//    
//    [self.view addSubview:testButton];
    //zubair vai 
    frndListScrollView.delegate = self;
     selectedFriendsIndex=[[NSMutableArray alloc] init];
     filteredList=[[NSMutableArray alloc] init];
    friendListArr=[[NSMutableArray alloc] init];
    dicImages_msg = [[NSMutableDictionary alloc] init];
    
    //set scroll view content size.
    [self loadDummydata];
    
    //reloading scrollview to start asynchronous download.
    [self reloadScrolview]; 
}

//- (void) actionTestBtn 
//{
//    for (MessageReply *msgReply in messageReplyList) {
//        NSLog(@"msgReply.senderImage = %@", msgReply.senderImage);
//    } 
//}


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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_REPLIES_DONE object:nil];
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
        /*
        if ([te]) {
            [textViewNewMsg resignFirstResponder];
        }else {
            
        }
        */
        [self doTopViewAnimation:messageCreationView];
    } else if ([textViewReplyMsg isFirstResponder]) {
        [textViewReplyMsg resignFirstResponder];
        [self setViewMovedDown:messageRepiesView];
    }else if (!messageRepiesView.hidden) {
        [self doLeftViewAnimation:messageRepiesView];
    }
    msgListTableView.tag = TAG_TABLEVIEW_INBOX;
    [msgListTableView reloadData];
}

- (IBAction)actionMeetUpBtn:(id)sender {
    buttonMeetUp.selected = YES;
    buttonMessage.selected = NO;
    NSLog(@"actionMeetUpBtn");
}

- (IBAction)actionNewMessageBtn:(id)sender {
    NSLog(@"actionNewMessageBtn");
    [self doBottomViewAnimation:messageCreationView];
}

- (IBAction)actionBackBtn:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
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
    [self sendMessage:sender];
    if (textViewNewMsg.isFirstResponder) {
        [textViewNewMsg resignFirstResponder];
        [self setViewMovedDown:msgWritingView];
    }
}

- (IBAction)actionSendReplyBtn:(id)sender {
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    [restClient sendReply:msgParentID content:textViewReplyMsg.text authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
}

- (void) sendMessage:(id)sender {
    
    NSString * subject = [NSString stringWithFormat:@"Message from %@ %@", smAppDelegate.userAccountPrefs.firstName,
                          smAppDelegate.userAccountPrefs.lastName];
    
    NSArray *recipientsID = [NSArray arrayWithObjects:textFieldUserID1.text, textFieldUserID2.text, textFieldUserID3.text, nil];
    NSLog(@"Message to Id:%@, from %@ %@", recipientsID, subject, textViewNewMsg.text);
    
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    [restClient sendMessage:subject content:textViewNewMsg.text recipients:recipientsID authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
}

- (void) getReplyMessages:(NSNotification *)notif {
    NSLog(@"gotReplyMessages");
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_REPLIES_DONE object:nil];
    /*if (![[msgReplies objectAtIndex:0] isKindOfClass:[MessageReply class]]) {
        return;
    }*/
    
    //[messageReplyList addObjectsFromArray:msgReplies];
    
    //for (MessageReply *msgReply in msgReplies) {
    //    [messageReplyList addObject:msgReply];
    //}
    
    NSMutableArray *msgReplies = [notif object];
    [messageReplyList addObjectsFromArray:msgReplies];
    
    /*for (int i = 0; i < [msgReplies count]; i++) {
        [messageReplyList addObject:[msgReplies objectAtIndex:i]];
    }*/
    
    for (MessageReply *eachMsgReply in messageReplyList) {
        //for (int i = 0; i < [messageReplyList count]; i++) {
            MessageReply *parentMsg = (MessageReply*)[messageReplyList objectAtIndex:0];
            if ([eachMsgReply.senderID isEqualToString:parentMsg.senderID]) {
                eachMsgReply.senderImage = parentMsg.senderImage;
            }
        //}
    }
    
    [messageReplyTableView reloadData];
    
    //if (timeSinceLastUpdate) {
    //    NSTimeInterval ti = [timeSinceLastUpdate timeIntervalSince1970];
    //}
    //timeSinceLastUpdate = [NSDate date];
    
    NSLog(@"to do: Add msg replies to msgArray");
    
    NSLog(@"start timer for reply update with since command");
    //http://203.76.126.69/social_maps/web/messages/504233b9f69c29b12c000001/replies?since=424343
    
    //[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(<#selector#>) userInfo:<#(id)#> repeats:<#(BOOL)#>
    
    
//    NSMutableArray *msg = [notif object];
//    [smAppDelegate.messages removeAllObjects];
//    [smAppDelegate.messages addObjectsFromArray:msg];
//    NSLog(@"AppDelegate: gotNotifications - %@", smAppDelegate.messages);
//    //[self displayNotificationCount];
}

//Duplicate in Notification Class
- (NSString*) timeAsString:(NSDate*)notifTime {
    NSString *timeStr = nil;
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *today = [[NSDateComponents alloc] init];
    NSDateComponents *todayComponents =
    [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit) fromDate:[NSDate date]];
    today.day = [todayComponents day];
    today.month = [todayComponents month];
    today.year = [todayComponents year];
    today.hour = 0;
    today.minute = 0;
    today.second = 0;
    NSDate *todayDate = [gregorian dateFromComponents:today];
    NSDate *yesterdayDate = [[NSDate alloc] initWithTimeInterval:-24*60*60 sinceDate:todayDate];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if ([notifTime timeIntervalSinceDate:todayDate] >= 0) {
        // Today
        [dateFormatter setDateFormat:@"HH:mm"];
        timeStr = [dateFormatter stringFromDate:notifTime];
    }else if ([notifTime timeIntervalSinceDate:yesterdayDate] >= 0){
        // Yesterday
        timeStr = @"Yesterday";
        
    } else {
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        
        timeStr = [dateFormatter stringFromDate:notifTime];
    }
    return timeStr;
}

// Tableview stuff
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == TAG_TABLEVIEW_REPLY) {
        
        MessageReply *msgReply = [messageReplyList objectAtIndex:indexPath.row];
        
        CGSize senderStringSize = [msgReply.senderName sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:kSmallLabelFontSize]];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"replyList"];
        
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
        //imageViewReply.backgroundColor = [UIColor redColor];
        
        if ([smAppDelegate.userId isEqualToString:msgReply.senderID]) {
            imageViewReply.frame = CGRectMake(10, (rowHeight - 48) / 2, 48, 48);
            //imageViewReply.backgroundColor = [UIColor blueColor];
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
        
        
        
        if ([msgReply.senderImage isEqual:@""])
        {
            imageViewReply.image = [UIImage imageNamed:@"girl.png"];
            if (tableView.dragging == NO && tableView.decelerating == NO) {
                [self startReplyIconDownload:msgReply forIndexPath:indexPath];
            }            
        }  else {
            NSLog(@"image crash = %@", msgReply.senderImage);
            imageViewReply.image = msgReply.senderImage;
//            for (MessageReply *eachMsg in messageReplyList) {
//                if (msgReply.senderID == eachMsg.senderID) {
//                    msgReply.senderImage = msgReply.senderImage;
//                }
//            }
        }
        
        lblSender.text = msgReply.senderName;
        lblTime.text = [self timeAsString:msgReply.time];
        txtMsg.text = msgReply.content;
        
        return cell;
    }
    
    NotifMessage *msg = [smAppDelegate.messages objectAtIndex:indexPath.row];
    
    CGSize senderStringSize = [msg.notifSender sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:kSmallLabelFontSize]];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"msgList"];
    
    if (cell == nil) {
    
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"msgList"] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        CGRect senderFrame = CGRectMake(SENDER_NAME_START_POSX + GAP, GAP, senderStringSize.width, senderStringSize.height);
        
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
    
    NSArray *components = [msg.notifSender componentsSeparatedByString:@" "];
    lblSender.text = ([components count] == 2) ? [components objectAtIndex:0] : msg.notifSender;
    lblTime.text = [self timeAsString:msg.notifTime];
    txtMsg.text = msg.notifMessage;
    
    if ([[profileImageList objectAtIndex:indexPath.row] isEqual:@""])
    {
        cell.imageView.image = [UIImage imageNamed:@"girl.png"];
        if (tableView.dragging == NO && tableView.decelerating == NO) {
            [self startIconDownload:msg forIndexPath:indexPath];
        }            
    }  else {
        cell.imageView.image = (UIImage*)[profileImageList objectAtIndex:indexPath.row];
    }

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    
//	UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//    MessageConversationViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"messageConversation"];
//    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //[self presentModalViewController:controller animated:YES];
    //[self.navigationController pushViewController:controller animated:YES];
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
    
    MessageReply *messageReply = [[MessageReply alloc] init];
    messageReply.content = msg.notifMessage;
    messageReply.time = msg.notifTime;
    NSArray *components = [msg.notifSender componentsSeparatedByString:@" "];
    messageReply.senderName = [components objectAtIndex:0];
    messageReply.senderID = msg.notifSenderId;
    messageReply.senderAvater = msg.notifAvater;
    messageReply.senderImage = (UIImage*)[profileImageList objectAtIndex:indexPath.row];
    [messageReplyList removeAllObjects];
    [messageReplyList addObject:messageReply];
    [messageReply release];
    
    msgParentID = msg.notifID;
    [self startReqForReplyMessages];
    
     //[self startIconDownload:msg forIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //tableView.tag = TAG_TABLEVIEW_REPLY;
    //[msgListTableView reloadData];
    //NSLog(@"msg obj = %@", [smAppDelegate.messages objectAtIndex:indexPath.row]);
    
    //[self appImageDidLoad:messageReply.senderID];
    
    [messageReplyTableView reloadData];
    [self doRightViewAnimation:messageRepiesView];
}
     
- (void)startReqForReplyMessages
{
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    [restClient getReplies:@"Auth-Token" authTokenVal:smAppDelegate.authToken msgID:msgParentID];
}
/*
- (void)startReqForReplyUpdate
{
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    [restClient getReplies:@"Auth-Token" authTokenVal:smAppDelegate.authToken msgID:msgParentID];
}
*/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (tableView.tag == TAG_TABLEVIEW_REPLY) ? [messageReplyList count] : [smAppDelegate.messages count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.tag == TAG_TABLEVIEW_REPLY) {
        MessageReply *msgReply = [messageReplyList objectAtIndex:indexPath.row];
        return [self getRowHeight:tableView :msgReply];
    }
    
    return CELL_HEIGHT;
}

- (CGFloat) getRowHeight:(UITableView*)tv:(MessageReply*)msgReply {
    
    CGFloat cellRowHeight;
    
    CGSize senderStringSize = [msgReply.senderName sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:kLargeLabelFontSize]];
    CGSize msgStringSize = [msgReply.content sizeWithFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize]];

    CGFloat msgRows = ceil(msgStringSize.width / (tv.frame.size.width - SENDER_NAME_START_POSX - 45));
    
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
   
   if (iconDownloader == nil)
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
                [self startIconDownload:msg forIndexPath:indexPath];
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
                [profileImageList replaceObjectAtIndex:i withObject:[UIImage imageNamed:@"girl.png"]];
            }
        }
    }
    [msgListTableView reloadData];
    NSLog(@"profileImageList = %@", profileImageList);
}


// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSString *)userId
{
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
    [super dealloc];
}




////zubair vai code
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
    NSLog(@"selectedFriendsIndex2 : %@",selectedFriendsIndex);
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
    [UIView beginAnimations:@"FadeIn" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView commitAnimations];
    [self beganEditing];
    NSLog(@"2");    
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
    [self reloadScrolview];
    [friendSearchbar resignFirstResponder];
    NSLog(@"3");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar 
{
    // Do the search and show the results in tableview
    // Deactivate the UISearchBar
    // You'll probably want to do this on another thread
    // SomeService is just a dummy class representing some 
    // api that you are using to do the search
    
    NSLog(@"Search button clicked");
    searchTexts=friendSearchbar.text;
    searchFlag=false;
    [self searchResult];
    [friendSearchbar resignFirstResponder];    
}

-(void)searchResult
{
    [self loadDummydata];
    searchTexts = friendSearchbar.text;
    NSLog(@"in search method..");
    //NSLog(@"filteredList99 %@ %@  %d  %d  imageDownloadsInProgress: %@",filteredList,friendListArr,[filteredList count],[friendListArr count], dicImages_msg);
    
    [filteredList removeAllObjects];
    
    if ([searchTexts isEqualToString:@""])
    {
        NSLog(@"null string");
        friendSearchbar.text=@"";
        filteredList = [[NSMutableArray alloc] initWithArray: friendListArr];
    }
    else
    {
        //NSLog(@"filteredList999 %@ %@  %d  %d  imageDownloadsInProgress: %@",filteredList,friendListArr,[filteredList count],[friendListArr count], dicImages_msg);
        
        for (UserFriends *sTemp in friendListArr)
        {
            NSRange titleResultsRange = [sTemp.userName rangeOfString:searchTexts options:NSCaseInsensitiveSearch];		
            NSLog(@"sTemp.userName: %@",sTemp.userName);
            if (titleResultsRange.length > 0)
            {
                [filteredList addObject:sTemp];
                NSLog(@"filtered friend: %@", sTemp.userName);            
            }
            else
            {
            }
        }
    }
    searchFlag=false;    
    
    //NSLog(@"filteredList %@ %@  %d  %d  imageDownloadsInProgress: %@",filteredList,friendListArr,[filteredList count],[friendListArr count], dicImages_msg);
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
        else if([view isKindOfClass :[UIImageView class]])
        {
            // [view removeFromSuperview];
        }
    }
    frndListScrollView.contentSize=CGSizeMake([filteredList count]*65, 65);
    
    for(int i=0; i<[filteredList count];i++)               
    {
        if(i< [filteredList count]) 
        { 
            UserFriends *userFrnd=[[UserFriends alloc] init];
            userFrnd=[filteredList objectAtIndex:i];
            imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
            if([dicImages_msg valueForKey:userFrnd.imageUrl]) 
            { 
                //If image available in dictionary, set it to imageview 
                imgView.image = [dicImages_msg valueForKey:userFrnd.imageUrl]; 
            } 
            else 
            { 
                if(!isDragging_msg && !isDecliring_msg) 
                    
                {
                    //If scroll view moves set a placeholder image and start download image. 
                    [dicImages_msg setObject:[UIImage imageNamed:@"girl.png"] forKey:userFrnd.imageUrl]; 
                    [self performSelectorInBackground:@selector(DownLoad:) withObject:[NSNumber numberWithInt:i]];  
                    imgView.image = [UIImage imageNamed:@"girl.png"];                   
                }
                else 
                { 
                    // Image is not available, so set a placeholder image
                    imgView.image = [UIImage imageNamed:@"girl.png"];                   
                }               
            }
            //            NSLog(@"userFrnd.imageUrl: %@",userFrnd.imageUrl);
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
                    NSLog(@"found selected: %d",[[selectedFriendsIndex objectAtIndex:c] intValue]);
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

-(void)DownLoad:(NSNumber *)path
{
    NSAutoreleasePool *pl = [[NSAutoreleasePool alloc] init];
    int index = [path intValue];
    UserFriends *userFrnd=[[UserFriends alloc] init];
    userFrnd=[filteredList objectAtIndex:index];
    
    NSString *Link = userFrnd.imageUrl;
    //Start download image from url
    UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:Link]]];
    if(img)
    {
        //If download complete, set that image to dictionary
        [dicImages_msg setObject:img forKey:userFrnd.imageUrl];
    }
    // Now, we need to reload scroll view to load downloaded image
    [self performSelectorOnMainThread:@selector(reloadScrolview) withObject:path waitUntilDone:NO];
    [pl release];
}

-(void)loadDummydata
{
    circleList=[[NSMutableArray alloc] initWithObjects:@"Friends",@"Family",@"Collegue",@"Close Friends",@"Relatives", nil];
    [circleList removeAllObjects];
    UserCircle *circle=[[UserCircle alloc]init];
    
    for (int i=0; i<[circleListGlobalArray count]; i++)
    {
        circle=[circleListGlobalArray objectAtIndex:i];
        [circleList addObject:circle.circleName];
    }
    UserFriends *frnds=[[UserFriends alloc] init];
    ImgesName = [[NSMutableArray alloc] initWithObjects:   
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005482.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005457.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005461.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005470.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005463.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005465.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005466.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005469.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005472.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005475.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005479.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005484.jpg",
                 @"http://www.cnewsvoice.com/C_NewsImage/NI00005483.jpg",nil ];    
    
    searchTexts=[[NSString alloc] initWithString:@""];
    friendsNameArr=[[NSMutableArray alloc] initWithObjects:@"karin",@"foyzul",@"dulal",@"abbas",@"gafur",@"fuad",@"robi",@"karim",@"tinki",@"suma",@"tilok",@"babu",@"imran", nil];
    friendsIDArr=[[NSMutableArray alloc] initWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13", nil];
    filteredList=[[NSMutableArray alloc] init];
    friendListArr=[[NSMutableArray alloc] init];
    
    for (int i=0; i<[friendListGlobalArray count]; i++)
    {
        frnds=[[UserFriends alloc] init];
        //        frnds.userName=[friendsNameArr objectAtIndex:i];
        //        frnds.userId=[friendsIDArr objectAtIndex:i];
        //        frnds.imageUrl=[ImgesName objectAtIndex:i];
        frnds=[friendListGlobalArray objectAtIndex:i];
        [friendListArr addObject:frnds];
    }
    filteredList=[friendListArr mutableCopy];
    NSLog(@"smAppDelegate.placeList %@",smAppDelegate.placeList);
}


@end

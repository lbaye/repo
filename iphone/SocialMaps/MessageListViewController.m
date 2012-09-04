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

#define     SENDER_NAME_START_POSX  60
#define     CELL_HEIGHT             60
#define     GAP                     3 
#define     kOFFSET_FOR_KEYBOARD    215
#define     TAG_TABLEVIEW_REPLY     1001
#define     TAG_TABLEVIEW_INBOX     1002

@implementation MessageListViewController

@synthesize msgParentID;

NSMutableDictionary *imageDownloadsInProgress;

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
        [self doTopViewAnimation:messageCreationView];
    } else if (!messageRepiesView.hidden) {
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
        imageViewReply.backgroundColor = [UIColor redColor];
        
        if ([smAppDelegate.userId isEqualToString:msgReply.senderID]) {
            imageViewReply.frame = CGRectMake(10, (rowHeight - 48) / 2, 48, 48);
            imageViewReply.backgroundColor = [UIColor blueColor];
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
        
        if (msgReply.senderImage.size.height == 0)
        {
            imageViewReply.image = [UIImage imageNamed:@"girl.png"];
            if (tableView.dragging == NO && tableView.decelerating == NO) {
                [self startReplyIconDownload:msgReply forIndexPath:indexPath];
            }            
        }  else {
            imageViewReply.image = msgReply.senderImage;
            for (MessageReply *eachMsg in messageReplyList) {
                if (msgReply.senderID == eachMsg.senderID) {
                    msgReply.senderImage = msgReply.senderImage;
                }
            }
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
    [self setViewMovedUp:msgWritingView];
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
    }
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
                if (!replyImage || [((MessageReply*)[messageReplyList objectAtIndex:indexPath.row]).senderImage isEqual:@""]) // avoid the app icon download if the app already has an icon
                {
                    MessageReply *msgReply = [messageReplyList objectAtIndex:indexPath.row];
                    [self startReplyIconDownload:msgReply forIndexPath:indexPath];
                }
            }
        }
        
        [messageReplyTableView reloadData];
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
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
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
    [super dealloc];
}

@end

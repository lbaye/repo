//
//  NotificationController.m
//  SocialMaps
//
//  Created by Arif Shakoor on 7/30/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "NotificationController.h"
#import "Constants.h"
#import "NotifMessage.h"
#import "TagNotification.h"
#import "CustomAlert.h"
#import "MapViewController.h"
#import "RestClient.h"
#import "MessageListViewController.h"
#import "UtilityClass.h"
#import "ODRefreshControl.h"
#import "Globals.h"
#import "FriendsProfileViewController.h"

@implementation NotificationController

@synthesize selectedItemIndex;
@synthesize selectedType;
@synthesize notifCount;
@synthesize msgCount;
@synthesize reqCount;
@synthesize alertCount;
@synthesize notificationItems;
@synthesize notifTabArrow;
@synthesize smAppDelegate;
@synthesize notifButton;
@synthesize msgButton;
@synthesize reqButton;
@synthesize webView;
@synthesize unreadMesg;

#define SECTION_HEADER_HEIGHT   44

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect currFrame = notifTabArrow.frame;
    CGRect newFrame = CGRectMake(-438, currFrame.origin.y, 
                                 currFrame.size.width, currFrame.size.height);
    notifTabArrow.frame = newFrame;
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    smAppDelegate.msgRead = TRUE;    
    
    if (smAppDelegate.notifRead == TRUE || smAppDelegate.notifications.count == 0) {
        alertCount.text = @"";
    } else
        alertCount.text = [NSString stringWithFormat:@"%d",smAppDelegate.notifications.count];
    
    int requestCount = smAppDelegate.friendRequests.count-smAppDelegate.ignoreCount;
    
    if (requestCount == 0)
        reqCount.text = @"";
    else
        reqCount.text   = [NSString stringWithFormat:@"%d",requestCount];
    
    // Default notification type
    selectedType = Message;
    smAppDelegate.msgRead = TRUE;
    //unreadMesg=[[NSMutableArray alloc] init];
    
    self.unreadMesg=[self getUnreadMessage:smAppDelegate.messages];
    
    // NotifRequest delegate
    NSLog(@"smAppDelegate.meetUpRequests %@",smAppDelegate.meetUpRequests);
    [self setNotificationImage];
     msgCount.text = @"";
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/minifeed.html?authToken=%@&r=%@",WS_URL,smAppDelegate.userId,smAppDelegate.authToken,[UtilityClass convertNSDateToUnix:[NSDate date]]]]]];
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.webView.scrollView];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    [refreshControl release];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_FRIEND_REQ_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_MESSAGE_WITH_ID_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_SET_MESSAGE_STATUS_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_FRIENDS_REQUEST_ACCEPTED object:nil];
    [super viewWillDisappear:animated];
}

-(void) displayNotificationCount 
{
    int totalNotif= [UtilityClass getNotificationCount];
    
    if (totalNotif == 0)
        notifCount.text = @"";
    else
        notifCount.text = [NSString stringWithFormat:@"%d",totalNotif];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    smAppDelegate.ignoreCount = 0;
    
    [self displayNotificationCount];
    
    if ([[UtilityClass getUnreadMessage:smAppDelegate.messages] count]==0)
        msgCount.text = @"";
    else
        msgCount.text = [NSString stringWithFormat:@"%d",[[UtilityClass getUnreadMessage:smAppDelegate.messages] count]];
    
    smAppDelegate.currentModelViewController = self;
    
    if (self.selectedType == Request)
        [self showFriendRequests:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotNewMessageDone:) name:NOTIF_GET_MESSAGE_WITH_ID_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotFriendRequests:) name:NOTIF_GET_FRIEND_REQ_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setMessageStatus:) name:NOTIF_SET_MESSAGE_STATUS_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendsRequestAccepted:) name:NOTIF_FRIENDS_REQUEST_ACCEPTED object:nil];
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    [restClient getFriendRequests:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
    [smAppDelegate showActivityViewer:self.view];
}

-(NSMutableArray *)getUnreadMessage:(NSMutableArray *)messageList
{
    NSMutableArray *unReadMessage=[[NSMutableArray alloc] init];
    for (int i=0; i<[messageList count]; i++)
    {
        NSString *msgSts=((NotifMessage *)[messageList objectAtIndex:i]).msgStatus;
        
        if ([msgSts isEqualToString:@"unread"])
        {
            [unReadMessage addObject:[messageList objectAtIndex:i]];
        }
    }
    
    return [unReadMessage autorelease];
}

-(void)setNotificationImage
{
    if (selectedType==0)
    {
        [webView setHidden:YES];
        [notificationItems setHidden:NO];
        [msgButton setImage:[UIImage imageNamed:@"icon_message_notification_selected.png"] forState:UIControlStateNormal];
        [reqButton setImage:[UIImage imageNamed:@"friends_rqst_icon.png"] forState:UIControlStateNormal];
        [notifButton setImage:[UIImage imageNamed:@"notify_icon.png"] forState:UIControlStateNormal];
    }
    else if (selectedType==1)
    {
        [webView setHidden:YES];
        [notificationItems setHidden:NO];
        [msgButton setImage:[UIImage imageNamed:@"message_notify_icon.png"] forState:UIControlStateNormal];
        [reqButton setImage:[UIImage imageNamed:@"icon_friend_request_selected.png"] forState:UIControlStateNormal];
        [notifButton setImage:[UIImage imageNamed:@"notify_icon.png"] forState:UIControlStateNormal];
        
    }
    else if (selectedType==2) 
    {
        [msgButton setImage:[UIImage imageNamed:@"message_notify_icon.png"] forState:UIControlStateNormal];
        [reqButton setImage:[UIImage imageNamed:@"friends_rqst_icon.png"] forState:UIControlStateNormal];
        [notifButton setImage:[UIImage imageNamed:@"icon_notify_selected.png"] forState:UIControlStateNormal];
        [webView setHidden:NO];
        [notificationItems setHidden:YES];
    }
}


- (void)viewDidUnload
{
    [self setNotifTabArrow:nil];
    [self setNotifCount:nil];
    [self setMsgCount:nil];
    [self setReqCount:nil];
    [self setAlertCount:nil];
    [self setNotificationItems:nil];
    [tabArrowImageView release];
    tabArrowImageView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)showMessages:(id)sender {
    CGRect currFrame = notifTabArrow.frame;
    CGRect newFrame = CGRectMake(-438, currFrame.origin.y, 
                                 currFrame.size.width, currFrame.size.height);
    notifTabArrow.frame = newFrame;
    selectedType = Message;
    
    if (smAppDelegate.msgRead == FALSE) {
        smAppDelegate.msgRead = TRUE;
    }
    

    [self displayNotificationCount];
    [notificationItems reloadData];
    [self setNotificationImage];
    
    tabArrowImageView.image = [UIImage imageNamed:@"tab_arrow_gray_left.png"];
}

- (IBAction)showFriendRequests:(id)sender {
    CGRect currFrame = notifTabArrow.frame;
    CGRect newFrame = CGRectMake(-336, currFrame.origin.y, 
                                 currFrame.size.width, currFrame.size.height);
    notifTabArrow.frame = newFrame;
    selectedType = Request;
    [notificationItems reloadData];
    [self setNotificationImage];
    
    tabArrowImageView.image = [UIImage imageNamed:@"tab_arrow_gray_center.png"];
}

- (IBAction)showNotifications:(id)sender 
{
    CGRect currFrame = notifTabArrow.frame;
    CGRect newFrame = CGRectMake(-226, currFrame.origin.y, 
                                 currFrame.size.width, currFrame.size.height);
    notifTabArrow.frame = newFrame;
    selectedType = Notif;
    alertCount.text   = @"";
    [self displayNotificationCount];
    [notificationItems reloadData];
    [self setNotificationImage];
    
    tabArrowImageView.image = [UIImage imageNamed:@"tab_arrow_gray_right.png"];
}

- (void)dealloc {
    [unreadMesg release];
    [webView stopLoading];
    [notifTabArrow release];    
    [msgCount release];
    [reqCount release];
    [alertCount release];
    [notificationItems release];
    [tabArrowImageView release];
    [super dealloc];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"In prepareForSegue:NotificationController");
}

// Tableview stuff
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"IndexPath:%d,%d",indexPath.section,indexPath.row);
    UITableViewCell * cell = nil;
    Notification * notif=nil;
    NotifMessage * msg=nil;
    NotifRequest * request=nil;
    TagNotification *tag=nil;
    switch (selectedType) {
        case Notif:
            notif = [smAppDelegate.notifications objectAtIndex:indexPath.row];
            if ([notif isKindOfClass:[TagNotification class]]) {
                tag = (TagNotification*) notif;
                cell = [tag getTableViewCell:tv sender:self];
            } else
                cell = [notif getTableViewCell:tv sender:self];
            break;
        case Message:
            msg = [self.unreadMesg objectAtIndex:indexPath.row];
            NSLog(@"MSG:sender = %@", msg.notifSender);
            NSLog(@"MSG:lastReply = %@", msg.lastReply);
            NSLog(@"MSG:msgContent = %@", msg.notifMessage);
            cell = [msg getTableViewCell:tv sender:self];
            break;
        case Request:
            request = [smAppDelegate.friendRequests objectAtIndex:indexPath.row];
            cell = [request getTableViewCell:tv sender:self];
            break;

        default:
            break;
    }
        
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
	selectedItemIndex = indexPath.section;
    
    NotifMessage *msg;
    notifBadgeFlag=FALSE;
    switch (selectedType) {
        case Message:
            msg = [self.unreadMesg objectAtIndex:indexPath.row];
            
            msg.msgStatus=@"read";
            
            UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            MessageListViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"messageList"];
            controller.selectedMessage = msg;
            controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
            [self presentModalViewController:nav animated:YES];
            nav.navigationBarHidden = YES;
            
            [self.unreadMesg removeObjectAtIndex:indexPath.row];
            [self.notificationItems reloadData];
            
            break;
        default:
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int numRows=0;
	switch (selectedType) {
        case Notif:
            numRows = [smAppDelegate.notifications count];
            break;
        case Message:
            numRows = [self.unreadMesg count];
            break;
        case Request:
            numRows = [smAppDelegate.friendRequests count];
            break;
            
        default:
            break;
    }
    return numRows;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat cellHeight=0.0;
    Notification *notif;
    NotifMessage * msg=nil;
    NotifRequest * request=nil;
    
	switch (selectedType) {
        case Notif:
            notif = [smAppDelegate.notifications objectAtIndex:indexPath.row];
            cellHeight = [notif getRowHeight:tableView];
            break;
        case Message:
            msg = [self.unreadMesg objectAtIndex:indexPath.row];
            cellHeight = [msg getRowHeight:tableView];
            break;
        case Request:
            request = [smAppDelegate.friendRequests objectAtIndex:indexPath.row];
            [request setDelegate:self];
            cellHeight = [request getRowHeight:tableView];
            break;
            
        default:
            break;
    }
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return SECTION_HEADER_HEIGHT+4;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	CGRect CellFrame   = CGRectMake(0, 0, tableView.frame.size.width, SECTION_HEADER_HEIGHT);
	
	UIView *header = [[UIView alloc] initWithFrame:CellFrame];

	header.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:.8];
    UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(0,0,
                                                                tableView.frame.size.width,
                                                                SECTION_HEADER_HEIGHT)];
    tempLabel.backgroundColor=[UIColor clearColor];
    if (selectedType == Message)
        tempLabel.text= @"Messages";
    else if (selectedType == Request)
        tempLabel.text= @"Friend(s) request(s)";
    else
        tempLabel.text= @"";
    [tempLabel setFont:[UIFont fontWithName:kFontNameBold size:20]];
    [header addSubview: tempLabel];
    [tempLabel release];
	
	return [header autorelease];
}

-(void)moreButtonTapped:(id)sender {
    UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.notificationItems indexPathForCell:clickedCell];
    NSLog(@"Clicked %d item in notification list", clickedButtonPath.row);
    NotifMessage *msg = [self.unreadMesg objectAtIndex:clickedButtonPath.row];
    if (msg.showDetail == TRUE)
        msg.showDetail = FALSE;
    else
        msg.showDetail = TRUE;
    [self.unreadMesg replaceObjectAtIndex:clickedButtonPath.row withObject:msg];
    [notificationItems reloadData];
}

- (void)setMessageStatus:(NSNotification *)notif
{
    NSLog(@"message sts updated.");
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];    
}


- (void)friendsRequestAccepted:(NSNotification *)notif
{
    NSLog(@"friends request accepted");
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    [restClient getUserFriendList:@"Auth-Token" tokenValue:smAppDelegate.authToken andUserId:smAppDelegate.userId];
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    [webView reload];
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [refreshControl endRefreshing];
    });
}

// NotifRequestDelegate methods
- (void) buttonClicked:(NSString*)name cellRow:(int)row {
    NSLog(@"Delegate button %@ clicked for row %d", name, row);
    
    req = [smAppDelegate.friendRequests objectAtIndex:row];
    
    if ([name isEqualToString:@"Profile"])
    {
        FriendsProfileViewController *controller =[[FriendsProfileViewController alloc] initWithNibName:@"FriendsProfileViewController" bundle:nil];
        controller.friendsId = req.notifSenderId;
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:controller animated:YES];
        [controller release];
        return;
    }
    
    if ([name isEqualToString:@"Accept"])
    {
        [CustomAlert setBackgroundColor:[UIColor grayColor] 
                        withStrokeColor:[UIColor grayColor]];
        NSString *msg = [NSString stringWithFormat:@"Congratulations! You and %@ are now friends!", req.notifSender];
        CustomAlert *acceptAlert = [[CustomAlert alloc]
                                   initWithTitle:@"Friend request accepted!"
                                   message:msg
                                   delegate:nil
                                   cancelButtonTitle:@"Done"
                                   otherButtonTitles:nil];
        
        [acceptAlert show];
        [acceptAlert autorelease];
        
        RestClient *restClient = [[[RestClient alloc] init] autorelease];
        [restClient acceptFriendRequest:req.notifSenderId authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
        
        [self setNOtificationCount];
        
        [smAppDelegate.friendRequests removeObjectAtIndex:row];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0]; // Only one section
        [notificationItems deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
    else if ([name isEqualToString:@"Ignore"])
    {
        [smAppDelegate.friendRequests removeObjectAtIndex:row];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0]; // Only one section
        [notificationItems deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
    else if ([name isEqualToString:@"Decline"])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Decline?" message:@"After declining a user there is no way to be friends with that user again." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Decline", nil];
        alertView.tag = row;
        [alertView show];
    }
    
    [notificationItems reloadData];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex)
    {
        RestClient *restClient = [[[RestClient alloc] init] autorelease];
        [restClient declineFriendRequest:req.notifSenderId authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
        [self setNOtificationCount];
        
        [smAppDelegate.friendRequests removeObjectAtIndex:alertView.tag];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:alertView.tag inSection:0]; // Only one section
        [notificationItems deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
}

- (void)setNOtificationCount
{
    int totalCount = smAppDelegate.friendRequests.count+
    self.unreadMesg.count+smAppDelegate.notifications.count-
    smAppDelegate.ignoreCount/*-ignoreCount*/;
    if (totalCount <= 0)
        notifCount.text = @"";
    else
        notifCount.text = [NSString stringWithFormat:@"%d",totalCount];
    
    int requestCount = smAppDelegate.friendRequests.count-smAppDelegate.ignoreCount;
    if (requestCount <= 0)
        reqCount.text = @"";
    else
        reqCount.text = [NSString stringWithFormat:@"%d",requestCount];
}

- (IBAction)actionBackMe:(id)sender
{
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    MapViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"mapViewController"];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];

}

- (void)gotFriendRequests:(NSNotification *)notif {
    NSMutableArray *notifs = [notif object];
    [smAppDelegate.friendRequests removeAllObjects];
    [smAppDelegate.friendRequests addObjectsFromArray:notifs];
    NSLog(@"AppDelegate: gotNotifications - %@", smAppDelegate.friendRequests);
    [notificationItems reloadData];
    
    int requestCount = smAppDelegate.friendRequests.count-smAppDelegate.ignoreCount;
    
    if (requestCount == 0)
        reqCount.text = @"";
    else
        reqCount.text   = [NSString stringWithFormat:@"%d",requestCount];
    
    [smAppDelegate hideActivityViewer];
    [self displayNotificationCount];
}

-(void)gotNewMessageDone:(NSNotification *)notif
{
    msgCount.text = [NSString stringWithFormat:@"%d",[[UtilityClass getUnreadMessage:smAppDelegate.messages] count]];
    self.unreadMesg = [self getUnreadMessage:smAppDelegate.messages];
    NSLog(@"got new message %@",self.unreadMesg);
    [notificationItems reloadData];
    [self displayNotificationCount];
}

@end

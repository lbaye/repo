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

@implementation NotificationController

@synthesize selectedItemIndex;
@synthesize selectedType;
/*@synthesize friendRequests;
@synthesize messages;
@synthesize notifications;
@synthesize msgRead;
@synthesize notifRead;
@synthesize ignoreCount;*/

@synthesize notifCount;
@synthesize msgCount;
@synthesize reqCount;
@synthesize alertCount;
@synthesize notificationItems;
@synthesize notifTabArrow;
@synthesize smAppDelegate;

#define SECTION_HEADER_HEIGHT   44

NSMutableArray *unreadMesg;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect currFrame = notifTabArrow.frame;
    CGRect newFrame = CGRectMake(-438, currFrame.origin.y, 
                                 currFrame.size.width, currFrame.size.height);
    notifTabArrow.frame = newFrame;
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setMessageStatus:) name:NOTIF_SET_MESSAGE_STATUS_DONE object:nil];
    // Dummy cotifications
    int ignoreCount = 0;
    smAppDelegate.msgRead = TRUE;
    if (smAppDelegate.msgRead == TRUE) {
        msgCount.text = @"";
        ignoreCount += [unreadMesg count];
    } else
        msgCount.text   = [NSString stringWithFormat:@"%d",unreadMesg.count];
    
    if (smAppDelegate.notifRead == TRUE || smAppDelegate.notifications.count == 0) {
        alertCount.text = @"";
        ignoreCount += [smAppDelegate.notifications count];
    } else
        alertCount.text = [NSString stringWithFormat:@"%d",smAppDelegate.notifications.count];
    
    int totalCount = smAppDelegate.friendRequests.count+unreadMesg.count+
                        smAppDelegate.notifications.count-smAppDelegate.ignoreCount-ignoreCount;
    if (totalCount == 0)
        notifCount.text = @"";
    else
        notifCount.text = [NSString stringWithFormat:@"%d", totalCount];
    
    int requestCount = smAppDelegate.friendRequests.count-smAppDelegate.ignoreCount;
    if (requestCount == 0)
        reqCount.text = @"";
    else
        reqCount.text   = [NSString stringWithFormat:@"%d",requestCount];
    
    // Default notification type
    selectedType = Message;
    smAppDelegate.msgRead = TRUE;
    unreadMesg=[[NSMutableArray alloc] init];
    unreadMesg=[self getUnreadMessage:smAppDelegate.messages];
    // NotifRequest delegate
    NSLog(@"smAppDelegate.meetUpRequests %@",smAppDelegate.meetUpRequests);
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
    
    return unReadMessage;
}

- (void)viewDidUnload
{
    [self setNotifTabArrow:nil];
    [self setNotifCount:nil];
    [self setNotifCount:nil];
    [self setMsgCount:nil];
    [self setReqCount:nil];
    [self setAlertCount:nil];
    [self setNotificationItems:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
/*
//for test remove later
- (void)actionTestMessageBtn
{
    NSLog(@"actionTestMessageBtn");
    
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    MessageListViewController *controller =[storybrd instantiateViewControllerWithIdentifier:@"messageList"];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
    [self presentModalViewController:nav animated:YES];
     nav.navigationBarHidden = YES;
}
*/
- (IBAction)showMessages:(id)sender {
    CGRect currFrame = notifTabArrow.frame;
    CGRect newFrame = CGRectMake(-438, currFrame.origin.y, 
                                 currFrame.size.width, currFrame.size.height);
    notifTabArrow.frame = newFrame;
    selectedType = Message;
    int ignoreCount = 0;
    if (smAppDelegate.msgRead == FALSE) {
        smAppDelegate.msgRead = TRUE;
    }
    if (smAppDelegate.msgRead == TRUE)
        ignoreCount += [unreadMesg count];

    if (smAppDelegate.notifRead == TRUE)
        ignoreCount += [smAppDelegate.notifications count];

    msgCount.text   = @"";
    int totalCount = smAppDelegate.friendRequests.count+
                    unreadMesg.count+smAppDelegate.notifications.count-
                    smAppDelegate.ignoreCount-ignoreCount;
    if (totalCount == 0)
        notifCount.text = @"";
    else
        notifCount.text = [NSString stringWithFormat:@"%d",totalCount];
    [notificationItems reloadData];
}

- (IBAction)showFriendRequests:(id)sender {
    CGRect currFrame = notifTabArrow.frame;
    CGRect newFrame = CGRectMake(-336, currFrame.origin.y, 
                                 currFrame.size.width, currFrame.size.height);
    notifTabArrow.frame = newFrame;
    selectedType = Request;
    [notificationItems reloadData];
}

- (IBAction)showNotifications:(id)sender {
    CGRect currFrame = notifTabArrow.frame;
    CGRect newFrame = CGRectMake(-226, currFrame.origin.y, 
                                 currFrame.size.width, currFrame.size.height);
    notifTabArrow.frame = newFrame;
    selectedType = Notif;
    int ignoreCount = 0;
    if (smAppDelegate.notifRead == FALSE) {
        smAppDelegate.notifRead = TRUE;
    }
    if (smAppDelegate.notifRead == TRUE)
        ignoreCount += [smAppDelegate.notifications count];

    if (smAppDelegate.msgRead == TRUE)
        ignoreCount += [unreadMesg count];

    alertCount.text   = @"";
    int totalCount = smAppDelegate.friendRequests.count+
    unreadMesg.count+smAppDelegate.notifications.count-
    smAppDelegate.ignoreCount-ignoreCount;
    if (totalCount == 0)
        notifCount.text = @"";
    else
        notifCount.text = [NSString stringWithFormat:@"%d",totalCount];

    [notificationItems reloadData];
}
- (void)dealloc {
    [notifTabArrow release];
    [notifCount release];
    [notifCount release];
    [msgCount release];
    [reqCount release];
    [alertCount release];
    [notificationItems release];
    [super dealloc];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    /*if ([[segue destinationViewController] isKindOfClass:[MapViewController class]]){
        MapViewController *vc = [segue destinationViewController];
        vc.messages = messages;
        vc.friendRequests = friendRequests;
        vc.notifications = notifications;
        vc.msgRead = msgRead;
        vc.notifRead = notifRead;
        vc.ignoreCount = ignoreCount;
        
    }*/
    NSLog(@"In prepareForSegue:NotificationController");
}

// Tableview stuff
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"IndexPath:%d,%d",indexPath.section,indexPath.row);
    UITableViewCell * cell = nil;
    Notification * notif=nil;
    NotifMessage * msg=nil;
    NotifRequest * req=nil;
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
            msg = [unreadMesg objectAtIndex:indexPath.row];
            NSLog(@"MSG:sender=%@",msg.notifSender);
            cell = [msg getTableViewCell:tv sender:self];
            break;
        case Request:
            req = [smAppDelegate.friendRequests objectAtIndex:indexPath.row];
            cell = [req getTableViewCell:tv sender:self];
            break;

        default:
            break;
    }
        
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
	selectedItemIndex = indexPath.section;
    /*
    NotifMessage *msg;
    
    switch (selectedType) {
        case Message:
            msg = [smAppDelegate.messages objectAtIndex:indexPath.row];
            
            break;
        default:
            break;
    }
     */
//    ((NotifMessage *)[smAppDelegate.messages objectAtIndex:indexPath.row]).notifID
    if (selectedType==0)
    {
        [smAppDelegate.window setUserInteractionEnabled:NO];
        [smAppDelegate showActivityViewer:self.view];
        NSLog(@"indexPath.row %d %d %@",selectedType,indexPath.row,((NotifMessage *)[smAppDelegate.messages objectAtIndex:indexPath.row]).notifID);
        NSString *msgId=((NotifMessage *)[unreadMesg objectAtIndex:indexPath.row]).notifID; 
        RestClient *restClient = [[[RestClient alloc] init] autorelease];
        [restClient setMessageStatus:@"Auth-Token" authTokenVal:smAppDelegate.authToken msgID:msgId status:@"read"];

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
            numRows = [unreadMesg count];
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
    NotifRequest * req=nil;
    
	switch (selectedType) {
        case Notif:
            notif = [smAppDelegate.notifications objectAtIndex:indexPath.row];
            cellHeight = [notif getRowHeight:tableView];
            break;
        case Message:
            msg = [unreadMesg objectAtIndex:indexPath.row];
            cellHeight = [msg getRowHeight:tableView];
            break;
        case Request:
            req = [smAppDelegate.friendRequests objectAtIndex:indexPath.row];
            [req setDelegate:self];
            cellHeight = [req getRowHeight:tableView];
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

	header.backgroundColor = [UIColor clearColor];
    UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(0,0,
                                                                tableView.frame.size.width,
                                                                SECTION_HEADER_HEIGHT)];
    tempLabel.backgroundColor=[UIColor clearColor];
    if (selectedType == Message)
        tempLabel.text= @"Messages";
    else if (selectedType == Request)
        tempLabel.text= @"Friend(s) request(s)";
    else
        tempLabel.text= @"Notifications";
    [tempLabel setFont:[UIFont fontWithName:kFontNameBold size:20]];
    [header addSubview: tempLabel];
    [tempLabel release];
	
	return header;
}

-(void)moreButtonTapped:(id)sender {
    UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.notificationItems indexPathForCell:clickedCell];
    NSLog(@"Clicked %d item in notification list", clickedButtonPath.row);
    NotifMessage *msg = [unreadMesg objectAtIndex:clickedButtonPath.row];
    if (msg.showDetail == TRUE)
        msg.showDetail = FALSE;
    else
        msg.showDetail = TRUE;
    [unreadMesg replaceObjectAtIndex:clickedButtonPath.row withObject:msg];
    [notificationItems reloadData];
}

- (void)setMessageStatus:(NSNotification *)notif
{
    NSLog(@"message sts updated.");
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];    
}

// NotifRequestDelegate methods
- (void) buttonClicked:(NSString*)name cellRow:(int)row {
    NSLog(@"Delegate button %@ clicked for row %d", name, row);
    NotifRequest *req = [smAppDelegate.friendRequests objectAtIndex:row];
    if ([name isEqualToString:@"Accept"]){
        [CustomAlert setBackgroundColor:[UIColor grayColor] 
                        withStrokeColor:[UIColor grayColor]];
        NSString *msg = [NSString stringWithFormat:@"Congratulations! You and %@ are now friends!", req.notifSender];
        CustomAlert *acceptAlert = [[CustomAlert alloc]
                                   initWithTitle:@"Frend request accepted!"
                                   message:msg
                                   delegate:nil
                                   cancelButtonTitle:@"Done"
                                   otherButtonTitles:nil];
        
        [acceptAlert show];
        [acceptAlert autorelease];
        
        RestClient *restClient = [[[RestClient alloc] init] autorelease];
        [restClient acceptFriendRequest:req.notifSenderId authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
        
        if (req.ignored == TRUE)
            smAppDelegate.ignoreCount--;
        [smAppDelegate.friendRequests removeObjectAtIndex:row];

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0]; // Only one section
        [notificationItems deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];

    } else if ([name isEqualToString:@"Decline"]) {
        RestClient *restClient = [[[RestClient alloc] init] autorelease];
        [restClient declineFriendRequest:req.notifSenderId authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
        
        [smAppDelegate.friendRequests removeObjectAtIndex:row];
        if (req.ignored == TRUE)
            smAppDelegate.ignoreCount--;
    
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0]; // Only one section
        [notificationItems deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    } else { // Ignore
        if (req.ignored == FALSE)
            smAppDelegate.ignoreCount++;
        req.ignored = TRUE;
    }
    int ignoreCount = 0;
    if (smAppDelegate.msgRead == TRUE)
        ignoreCount += [unreadMesg count];
    
    if (smAppDelegate.notifRead == TRUE)
        ignoreCount += [smAppDelegate.notifications count];
    int totalCount = smAppDelegate.friendRequests.count+
                        unreadMesg.count+smAppDelegate.notifications.count-
                        smAppDelegate.ignoreCount-ignoreCount;
    if (totalCount <= 0)
        notifCount.text = @"";
    else
        notifCount.text = [NSString stringWithFormat:@"%d",totalCount];
    
    int requestCount = smAppDelegate.friendRequests.count-smAppDelegate.ignoreCount;
    if (requestCount <= 0)
        reqCount.text = @"";
    else
        reqCount.text = [NSString stringWithFormat:@"%d",requestCount];
    
    [notificationItems reloadData];
}
@end

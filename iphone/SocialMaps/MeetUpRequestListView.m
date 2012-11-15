//
//  MeetUpRequestListView.m
//  SocialMaps
//
//  Created by Warif Rishi on 9/12/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "MeetUpRequestListView.h"
#import <QuartzCore/QuartzCore.h>
#import "MeetUpRequest.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "DirectionViewController.h"
#import "UtilityClass.h"
#import "Globals.h"
#import "UserFriends.h"
#import "RestClient.h"
#import "CustomAlert.h"

#define     CELL_HEIGHT             200//115

//NSMutableDictionary *imageDownloadsInProgress;

@implementation MeetUpRequestListView

- (id)initWithFrame:(CGRect)frame andParentControllder:(UIViewController*)controller
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        parentViewController = controller;
        
        NSArray* nibViews;
		nibViews = [[NSBundle mainBundle] loadNibNamed:@"MeetUpRequestListView" owner:self options:nil];
		UIView *infoView = [nibViews objectAtIndex:0];
        [self addSubview:infoView];
        
        AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        meetUpRequestList = smAppDelegate.meetUpRequests;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotMeetUpRequest:) name:NOTIF_GET_MEET_UP_REQUEST_DONE object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMeetUpRequest:) name:NOTIF_UPDATE_MEET_UP_REQUEST_DONE object:nil];
        
        imageDownloadsInProgress = [NSMutableDictionary dictionary];
        [imageDownloadsInProgress retain];
        
        tableViewMeetUps.dataSource = self;
        tableViewMeetUps.delegate = self;
    }
    return self;
}

-(void) updateMeetUpReq:(int)selectedRow :(NSString*)response
{
    AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    [restClient updateMeetUpRequest:((MeetUpRequest*)[meetUpRequestList objectAtIndex:selectedRow]).meetUpId response:response authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
}

// Tableview stuff
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MeetUpRequest *meetUpReq = [meetUpRequestList objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"meetUpList"];
    
    
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"meetUpList"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        //Thumb Image
        UIImageView *imageViewReply = [[UIImageView alloc]initWithFrame:CGRectMake(10, 2, 48, 48)];
        imageViewReply.tag = 3006;
        [imageViewReply.layer setCornerRadius:6.0f];
        [imageViewReply.layer setBorderWidth:2.0];
        [imageViewReply.layer setBorderColor:[UIColor darkGrayColor].CGColor];
        [imageViewReply.layer setMasksToBounds:YES];
        [cell addSubview:imageViewReply];
        
        UILabel *lblSenderName = [[[UILabel alloc] initWithFrame:CGRectMake(62, 50-kSmallLabelFontSize, 50, kSmallLabelFontSize)] autorelease];
        lblSenderName.tag = 3014;
        lblSenderName.textAlignment = UITextAlignmentLeft;
        lblSenderName.font = [UIFont fontWithName:@"Helvetica-Bold" size:kSmallLabelFontSize];
        lblSenderName.textColor = [UIColor blackColor];
        lblSenderName.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:lblSenderName];
        
        // Time
        UILabel *lblTime = [[[UILabel alloc] initWithFrame:CGRectMake(220, 50-kSmallLabelFontSize, 70, kSmallLabelFontSize)] autorelease];
        lblTime.tag = 3004;
        lblTime.textAlignment = UITextAlignmentRight;
        lblTime.font = [UIFont fontWithName:@"Helvetica-Oblique" size:kSmallLabelFontSize];
        lblTime.textColor = [UIColor blackColor];
        lblTime.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:lblTime];
        
        UIView *contentView = [[[UIView alloc] initWithFrame:CGRectMake(8, 55, 320-16, 125)] autorelease];
        [contentView.layer setCornerRadius:6.0f];
        [contentView.layer setBorderWidth:1.0];
        [contentView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [contentView.layer setMasksToBounds:YES];
        [cell.contentView addSubview:contentView];
        contentView.tag = 3333;
        
        UILabel *lblMessage = [[[UILabel alloc] initWithFrame:CGRectMake(10, 50, 280, 20)] autorelease];
        lblMessage.tag = 3005;
        lblMessage.textAlignment = UITextAlignmentLeft;
        lblMessage.font = [UIFont fontWithName:@"Helvetica-Oblique" size:kSmallLabelFontSize];
        lblMessage.textColor = [UIColor darkGrayColor];
        lblMessage.backgroundColor = [UIColor clearColor];
        lblMessage.numberOfLines=2;
        [contentView addSubview:lblMessage];
        
        // MeetUp Title
        UILabel *labelMeetUpTitle = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 280, 30)] autorelease];
        labelMeetUpTitle.tag = 3002;
        labelMeetUpTitle.font = [UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize];
        labelMeetUpTitle.textColor = [UIColor blackColor];
        labelMeetUpTitle.backgroundColor = [UIColor clearColor];
        [contentView addSubview:labelMeetUpTitle];
        NSLog(@"cell created. %d",indexPath.row);
        
        UIButton *buttonAddress = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonAddress.frame = CGRectMake(10, 25, 280, 20);
        [buttonAddress setTitleColor:[UIColor colorWithRed:119.0/255.0 green:184.0/255.0 blue:0.0 alpha:1.0] forState:UIControlStateNormal];
        [buttonAddress.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:kSmallLabelFontSize]];
        [buttonAddress addTarget:self action:@selector(actionAddressButton:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:buttonAddress];
        
        MeetUpListButtonsView *meetUpListButtonView = [[MeetUpListButtonsView alloc] initWithFrame:CGRectMake(10, 82, 300, 40)];
        meetUpListButtonView.backgroundColor = [UIColor clearColor];
        meetUpListButtonView.delegate = self;
        meetUpListButtonView.tag = 3007;
        [contentView addSubview:meetUpListButtonView];
        [meetUpListButtonView release];
    }
    
    //MeetUpListButtonsView  *meetUpListButtonView  = (MeetUpListButtonsView*) [cell viewWithTag:3007];
    MeetUpListButtonsView  *meetUpListButtonView  = (MeetUpListButtonsView*) [[cell viewWithTag:3333] viewWithTag:3007];
    [meetUpListButtonView adjustButtons:meetUpReq];
    
    //UILabel     *labelMeetUpTitle  = (UILabel*) [cell viewWithTag:3002];
    UILabel     *labelMeetUpTitle  = (UILabel*) [[cell viewWithTag:3333] viewWithTag:3002];
    
    UIButton *buttonAddress;
    
    //for (UIView *subView in [cell.contentView subviews]) {
    for (UIView *subView in [[cell.contentView viewWithTag:3333] subviews]) {
        if ([subView isKindOfClass:[UIButton class]]) {
            buttonAddress = (UIButton*)subView;
            break;
        }
    }
    
    buttonAddress.tag=indexPath.row;
    
    UILabel *labelTime = (UILabel*)[cell.contentView viewWithTag:3004];
    UILabel *labelSenderName = (UILabel*)[cell.contentView viewWithTag:3014];
    //UILabel *labelMsg = (UILabel*)[cell.contentView viewWithTag:3005];
    UILabel *labelMsg = (UILabel*)[[cell.contentView viewWithTag:3333] viewWithTag:3005];
    
    UIImageView *imageViewSender = (UIImageView*) [cell viewWithTag:3006];
    
    AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    if ([meetUpReq.meetUpSenderId isEqualToString:smAppDelegate.userId]) {
        labelMeetUpTitle.text = @"You have sent a request to meet-up at ";
        meetUpListButtonView.hidden = YES;
    } else {
        labelMeetUpTitle.text = [NSString stringWithFormat:@"Hi %@,\n%@ has invited you to meet-up at", smAppDelegate.userAccountPrefs.firstName, meetUpReq.meetUpSender];
        //labelMeetUpTitle.numberOfLines = 2;
        meetUpListButtonView.hidden = NO;
    }
    
    [buttonAddress setTitle:meetUpReq.meetUpAddress forState:UIControlStateNormal];
    labelTime.text =  [UtilityClass timeAsString:meetUpReq.meetUpTime];
    labelMsg.text=meetUpReq.meetUpDescription;
    labelSenderName.text = meetUpReq.meetUpSender;
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:meetUpReq.meetUpSenderId];
    
    if (!iconDownloader)
    {
        //imageViewSender.image = [UIImage imageNamed:@"thum.png"];
        imageViewSender.image = nil;
        if (tableView.dragging == NO && tableView.decelerating == NO) {
            [self startIconDownload:meetUpReq forIndexPath:indexPath];
        }            
    }  else {
        imageViewSender.image = iconDownloader.userFriends.userProfileImage;
    }
    
    return cell;
    
}

- (UserFriends*)getUserFriend:(MeetUpRequest*)meetUpReq
{
    NSLog(@"friendList %d", [friendListGlobalArray count]);
    for (int i = 0; i < [friendListGlobalArray count]; i++) {
        UserFriends  *userFriend = (UserFriends*)[friendListGlobalArray objectAtIndex:i];
        if (userFriend.userId == meetUpReq.meetUpId) {
            return userFriend;
        }
    }
    
    return nil;
}

/*
#pragma mark -
#pragma mark Table cell image support

- (void)startIconDownload:(UserFriends*)userFriend forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:userFriend.userId];
    
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        //UserFriends *userFriends = [[UserFriends alloc] init];
        //userFriends.userId = msg.notifSenderId;
        //userFriends.imageUrl = msg.notifAvater;
        //iconDownloader.userFriends = userFriends;
        NSLog(@"iconDownloader.userFriends.imageUrl = %@",iconDownloader.userFriends.imageUrl);
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:userFriend.userId];
        [iconDownloader startDownload];
        [iconDownloader release];  
        //[userFriends release];
    } 
}
*/
- (void)actionAddressButton:(id)sender
{
    NSLog(@"actionAddressButton: %d",[sender tag]);
    
    NSLog(@"get directions..");
    
    Geolocation *geoLocation = ((MeetUpRequest*)[meetUpRequestList objectAtIndex:[sender tag]]).meetUpLocation;
    
    DirectionViewController *controller = [[DirectionViewController alloc] initWithNibName: @"DirectionViewController" bundle:nil];
    CLLocationCoordinate2D theCoordinate;
	theCoordinate.latitude = [geoLocation.latitude doubleValue];
    theCoordinate.longitude = [geoLocation.longitude doubleValue];
    controller.coordinateTo = theCoordinate;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [parentViewController presentModalViewController:controller animated:YES];
    [controller release];
    
    /*
    
    
    double lat = 
    double lon = 
    
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = lat;
    theCoordinate.longitude = lon;
    
    ShowOnMapController *controller = [[ShowOnMapController alloc] initWithNibName:@"ShowOnMapController" bundle:nil andLocation:theCoordinate];
    controller.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    [parentViewController presentModalViewController:controller animated:YES];
    [controller release];
     
     */
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  
{   
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*
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
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    messageReply.senderImage = cell.imageView.image;
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
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    */
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [meetUpRequestList count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return CELL_HEIGHT;
}

- (void)gotMeetUpRequest:(NSNotification *)notif {
    NSMutableArray *notifs = [notif object];
    AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [smAppDelegate.meetUpRequests removeAllObjects];
    [smAppDelegate.meetUpRequests addObjectsFromArray:notifs];
    NSLog(@": gotMeetUpNotifications - %@", smAppDelegate.meetUpRequests);
    [tableViewMeetUps reloadData];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_MEET_UP_REQUEST_DONE object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_UPDATE_MEET_UP_REQUEST_DONE object:nil];
}

- (void)updateMeetUpRequest:(NSNotification *)notif {
    //NSMutableArray *notifs = [notif object];
    
    //[tableViewMeetUps reloadData];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_UPDATE_MEET_UP_REQUEST_DONE object:nil];
    //AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //RestClient *restClient = [[[RestClient alloc] init] autorelease];
    //[restClient getMeetUpRequest:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
}
    
- (int) getCellRow:(id)sender {
    UIButton *button = (UIButton *)sender;
    // Get the UITableViewCell which is the superview of the UITableViewCellContentView which is the superview of the UIButton
    UITableViewCell *cell = (UITableViewCell *) [[[button superview] superview] superview];
    int row = [tableViewMeetUps indexPathForCell:cell].row;
    return row;
}

- (void) buttonClicked:(NSString*)actionName cellButton:(id)sender {
    NSLog(@"actionName = %@ cellButton row = %d", actionName, [self getCellRow:sender]); 
    //if ([actionName isEqualToString:@"Accept"]){
        
        
        int row = [self getCellRow:sender];
        [self updateMeetUpReq:row :actionName];
        //[((MeetUpRequest*)[meetUpRequestList objectAtIndex:row]).meetUpRsvpNo removeObject:<#(id)#>;
        //RestClient *restClient = [[[RestClient alloc] init] autorelease];
        //[restClient acceptFriendRequest:req.notifSenderId authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
        
        //if (req.ignored == TRUE)
          //  smAppDelegate.ignoreCount--;
        //[smAppDelegate.friendRequests removeObjectAtIndex:row];
        
        //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0]; // Only one section
        //[notificationItems deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        
    //}
}

- (void)dealloc {
    //[imageDownloadsInProgress release];
    [tableViewMeetUps release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_MEET_UP_REQUEST_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_UPDATE_MEET_UP_REQUEST_DONE object:nil];
    [super dealloc];

}

#pragma mark -
#pragma mark Table cell image support

- (void)startIconDownload:(MeetUpRequest*)meetUpReq forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:meetUpReq.meetUpSenderId];
    
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        UserFriends *userFriends = [[UserFriends alloc] init];
        userFriends.userId = meetUpReq.meetUpSenderId;
        userFriends.imageUrl = meetUpReq.meetUpAvater;
        //userFriends.imageUrl = @"https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcR-9WzQL5NV_6vQ3f1Djlt7mbbUTkFTc_g4vpWKU7t0JPpMSXtZ9_qPwQ";
        iconDownloader.userFriends = userFriends;
        NSLog(@"iconDownloader.userFriends.imageUrl = %@",iconDownloader.userFriends.imageUrl);
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:meetUpReq.meetUpSenderId];
        [iconDownloader startDownload];
        [iconDownloader release];  
        [userFriends release];
    } 
}
- (void)loadImagesForOnscreenRows
{
    if ([meetUpRequestList count] > 0)
    {
        NSArray *visiblePaths = [tableViewMeetUps indexPathsForVisibleRows];
            
        for (NSIndexPath *indexPath in visiblePaths)
        {
            //UIImage *replyImage = ((MeetUpRequest*)[meetUpRequestList objectAtIndex:indexPath.row]).meetUpSenderId.senderImage;
            
            MeetUpRequest *meetUpReq = [meetUpRequestList objectAtIndex:indexPath.row];
            [self startIconDownload:meetUpReq forIndexPath:indexPath];
                
            //if (!replyImage) // avoid the app icon download if the app already has an icon
                //{
                    //[self startReplyIconDownload:msgReply forIndexPath:indexPath];
                //}
                //                } else {
                //                    //MessageReply *msgReply = [messageReplyList objectAtIndex:indexPath.row];
                //                    UITableViewCell *cell = [messageReplyTableView cellForRowAtIndexPath:indexPath];
                //                    UIImageView *imageViewReply = (UIImageView*) [cell viewWithTag:3006];
                //                    imageViewReply.image = msgReply.senderImage;
                //                }
            //}
        }
        
        //[messageReplyTableView reloadData];
        return;
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSString *)userId
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:userId];
    if (iconDownloader != nil)
    {
//        if (!messageRepiesView.hidden) {
//            for (MessageReply *msgReply in messageReplyList) {
//                if (msgReply.senderID == userId) {
//                    msgReply.senderImage = iconDownloader.userFriends.userProfileImage;
//                }
//            }
//            [messageReplyTableView reloadData];
//            return;
//        }
        
        UITableViewCell *cell = [tableViewMeetUps cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
        NSLog(@"Avatar for User - %@, User id - %@ and avatar url - %@", 
              iconDownloader.userFriends.userName,
              iconDownloader.userFriends.userId, 
              iconDownloader.userFriends.imageUrl);
        
        UIImageView *imageViewSender = (UIImageView*) [cell viewWithTag:3006];
        imageViewSender.image = iconDownloader.userFriends.userProfileImage;
        //cell.imageView.image = iconDownloader.userFriends.userProfileImage;
        
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

@end

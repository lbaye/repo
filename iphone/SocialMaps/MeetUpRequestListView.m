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
#import "ShowOnMapController.h"
#import "UtilityClass.h"
#import "IconDownloader.h"
#import "Globals.h"
#import "UserFriends.h"
#import "RestClient.h"

#define     CELL_HEIGHT             60

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
        
        RestClient *restClient = [[[RestClient alloc] init] autorelease];
        [restClient getMeetUpRequest:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
        
        //imageDownloadsInProgress = [NSMutableDictionary dictionary];
        
        tableViewMeetUps.dataSource = self;
        tableViewMeetUps.delegate = self;
    }
    return self;
}

// Tableview stuff
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MeetUpRequest *meetUpReq = [meetUpRequestList objectAtIndex:indexPath.row];
    
    /*
    CGSize senderStringSize = [msgReply.senderName sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:kSmallLabelFontSize]];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"replyList"];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    CGRect senderFrame = CGRectMake(SENDER_NAME_START_POSX + GAP, GAP, senderStringSize.width, senderStringSize.height);
    
    CGRect timeFrame = CGRectMake(senderStringSize.width + GAP, 
                                  GAP, tableView.frame.size.width - 22 - senderStringSize.width, senderStringSize.height);
    
    CGFloat rowHeight = [self getRowHeight:tableView :msgReply];
    
    CGRect msgFrame = CGRectMake(SENDER_NAME_START_POSX, senderFrame.size.height + senderFrame.origin.y + 1, tableView.frame.size.width - SENDER_NAME_START_POSX - GAP * 4, rowHeight - 22);
    */
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"meetUpList"];
    
    
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"meetUpList"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        // MeetUp Title
        UILabel *labelMeetUpTitle = [[[UILabel alloc] initWithFrame:CGRectMake(55, 10, 250, 30)] autorelease];
        labelMeetUpTitle.tag = 3002;
        labelMeetUpTitle.font = [UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize];
        labelMeetUpTitle.textColor = [UIColor blackColor];
        labelMeetUpTitle.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:labelMeetUpTitle];
        NSLog(@"cell created. %d",indexPath.row);
        
        // Time
        UILabel *lblTime = [[[UILabel alloc] initWithFrame:CGRectMake(250, 2, 40, 20)] autorelease];
        lblTime.tag = 3004;
        lblTime.textAlignment = UITextAlignmentRight;
        lblTime.font = [UIFont fontWithName:@"Helvetica-Oblique" size:kSmallLabelFontSize];
        lblTime.textColor = [UIColor blackColor];
        lblTime.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:lblTime];
        
        UILabel *lblMessage = [[[UILabel alloc] initWithFrame:CGRectMake(55, 60, 250, 20)] autorelease];
        lblMessage.tag = 3005;
        lblMessage.textAlignment = UITextAlignmentLeft;
        lblMessage.font = [UIFont fontWithName:@"Helvetica-Oblique" size:kSmallLabelFontSize];
        lblMessage.textColor = [UIColor darkGrayColor];
        lblMessage.backgroundColor = [UIColor clearColor];
        lblMessage.numberOfLines=2;
        //lblMessage.backgroundColor=[UIColor redColor];
        [cell.contentView addSubview:lblMessage];
        /*
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
        */
        //Thumb Image
        UIImageView *imageViewReply = [[UIImageView alloc]initWithFrame:CGRectMake(2, 2, 48, 48)];
        imageViewReply.tag = 3006;
        [imageViewReply.layer setCornerRadius:6.0f];
        [imageViewReply.layer setBorderWidth:2.0];
        [imageViewReply.layer setBorderColor:[UIColor darkGrayColor].CGColor];
        [imageViewReply.layer setMasksToBounds:YES];
        [cell addSubview:imageViewReply];
        
        
        UIButton *buttonAddress = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonAddress.frame = CGRectMake(55, 35, 250, 20);
        buttonAddress.titleLabel.textAlignment = UITextAlignmentLeft;
        [buttonAddress setTitleColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1] forState:UIControlStateNormal];
        [buttonAddress.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:kSmallLabelFontSize]];
        [buttonAddress addTarget:self action:@selector(actionAddressButton:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:buttonAddress];
        
    }
    
    //CGSize meetUpTitleSize = [meetUpReq.meetUpTitle sizeWithFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize]];
    
    UILabel     *labelMeetUpTitle  = (UILabel*) [cell viewWithTag:3002];
    //labelMeetUpTitle.frame = CGRectMake(10, 10, meetUpTitleSize.width, meetUpTitleSize.height);
    
    UIButton *buttonAddress;// = (UIButton*) [cell viewWithTag:3003];
    
    for (UIView *subView in [cell.contentView subviews]) {
        if ([subView isKindOfClass:[UIButton class]]) {
            buttonAddress = (UIButton*)subView;
            break;
        }
    }
    
    buttonAddress.tag=indexPath.row;
    //[buttonAddress removeTarget:self action:@selector(actionAddressButton:) forControlEvents:UIControlEventTouchUpInside];
    
    //float btnAddressStartPosX = labelMeetUpTitle.frame.origin.x + labelMeetUpTitle.frame.size.width;
    //buttonAddress.frame = CGRectMake(btnAddressStartPosX, labelMeetUpTitle.frame.origin.y, tableView.frame.size.width - btnAddressStartPosX, labelMeetUpTitle.frame.size.height);
    
    UILabel *labelTime = (UILabel*)[cell.contentView viewWithTag:3004];
    UILabel *labelMsg = (UILabel*)[cell.contentView viewWithTag:3005];

    //buttonAddress.frame = CGRectMake(btnAddressStartPosX, labelMeetUpTitle.frame.origin.y + labelMeetUpTitle.frame.size.height + 10, tableView.frame.size.width - btnAddressStartPosX, labelMeetUpTitle.frame.size.height);
    
    //UILabel     *lblTime    = (UILabel*) [cell viewWithTag:3004];
    //UITextView  *txtMsg     = (UITextView*) [cell viewWithTag:3005];
    UIImageView *imageViewSender = (UIImageView*) [cell viewWithTag:3006];
    //imageViewSender.frame = CGRectMake(10, (CELL_HEIGHT - 48) / 2, 48, 48);
    imageViewSender.image = [UIImage imageNamed:@"thum.png"];
    /*
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
    */
    
    labelMeetUpTitle.text = meetUpReq.meetUpTitle;
    [buttonAddress setTitle:meetUpReq.meetUpAddress forState:UIControlStateNormal];
    labelTime.text =  [UtilityClass timeAsString:meetUpReq.meetUpTime];
    labelMsg.text=meetUpReq.meetUpDescription;
    NSLog(@"meetUpReq.meetUpDescription: %@",meetUpReq.meetUpDescription);
    
    //UserFriends *userFriend = [self getUserFriend:meetUpReq];
    /*
    if (!userFriend) {
        return cell;
    }
    */
    //IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:meetUpReq.meetUpSenderId];
    
//    if (!iconDownloader)
//    {
//        imageViewSender.image = [UIImage imageNamed:@"thum.png"];
//        if (tableView.dragging == NO && tableView.decelerating == NO) {
//            
//            [self startIconDownload:userFriend forIndexPath:indexPath];
//        }            
//    }  else {
//        
//        imageViewSender.image = iconDownloader.userFriends.userProfileImage;
//    }
    
    
    //[buttonAddress setTitle:[meetUpReq.meetUpAddress substringToIndex:15] forState:UIControlStateNormal];
        //lblTime.text = [self timeAsString:msgReply.time];
    //txtMsg.text = msgReply.content;
    
    
    //cell.imageView.image = [UIImage imageNamed:@"thum.png"];
    
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
    
    Geolocation *geoLocation = ((MeetUpRequest*)[meetUpRequestList objectAtIndex:[sender tag]]).meetUpLocation;
    
    double lat = [geoLocation.latitude doubleValue];
    double lon = [geoLocation.longitude doubleValue];
    
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = lat;
    theCoordinate.longitude = lon;
    
    ShowOnMapController *controller = [[ShowOnMapController alloc] initWithNibName:@"ShowOnMapController" bundle:nil andLocation:theCoordinate];
    controller.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    [parentViewController presentModalViewController:controller animated:YES];
    [controller release];
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
    
    return CELL_HEIGHT + 25;
}

- (void)gotMeetUpRequest:(NSNotification *)notif {
    NSMutableArray *notifs = [notif object];
    AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [smAppDelegate.meetUpRequests removeAllObjects];
    [smAppDelegate.meetUpRequests addObjectsFromArray:notifs];
    NSLog(@": gotMeetUpNotifications - %@", smAppDelegate.meetUpRequests);
    [tableViewMeetUps reloadData];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_MEET_UP_REQUEST_DONE object:nil];
    
}
    
- (void)dealloc {
         [tableViewMeetUps release];
         [super dealloc];
}

@end

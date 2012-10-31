//
//  MapAnnotationPeople.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//
#import "MapAnnotationPeople.h"
#import "LocationItemPeople.h"
#import "LocationItemPlace.h"
#import "UIImageView+roundedCorner.h"
#import "UtilityClass.h"
#import "Constants.h"

@implementation MapAnnotationPeople

- (MKAnnotationView*) getViewForStateNormal:(LocationItem*) locItem {
    annoView = [super getViewForStateNormal:locItem];
    if ([locItem isKindOfClass:[LocationItemPeople class]])
    {
        LocationItemPeople *locItemPeople=(LocationItemPeople *)locItem;
        if ([locItemPeople.userInfo.source isEqualToString:@"facebook"])
        {
            UIImageView *sourceIcon = [[UIImageView alloc] initWithFrame:CGRectMake(38,3,12,12)];
            sourceIcon.tag=12002;
            sourceIcon.image=[UIImage imageNamed:@"icon_facebook.png"];
            [annoView addSubview:sourceIcon];
            NSLog(@"fb subview added");
            [sourceIcon release];
        }
        
    }
    return annoView;
}

- (MKAnnotationView*) getViewForStateSummary:(LocationItem*) locItem {
    annoView = [super getViewForStateSummary:locItem];
    LocationItemPeople *locItemPeople = (LocationItemPeople*) locItem;
    
    CGSize lblStringSize = [@"Firstname NAME" sizeWithFont:[UIFont fontWithName:@"Helvetica" size:11.0f]];
    UIView *infoView = [annoView viewWithTag:11002];
    
    CGRect lblNameFrame = CGRectMake(ANNO_IMG_WIDTH+2, 2, infoView.frame.size.width-4-ANNO_IMG_WIDTH, lblStringSize.height);
    UILabel *lblName = [[UILabel alloc] initWithFrame:lblNameFrame];
    
    NSString *age = [self getAgeString:locItemPeople];
    
    lblName.text = [NSString stringWithFormat:@"%@%@", locItemPeople.itemName, age];
    lblName.backgroundColor = [UIColor clearColor];
    lblName.font = [UIFont fontWithName:@"Helvetica" size:11.0f];
    [infoView addSubview:lblName];
    [lblName release];
    
    CGRect msgFrame = CGRectMake(ANNO_IMG_WIDTH+2, 2+lblStringSize.height+1, 
                                 infoView.frame.size.width-4-ANNO_IMG_WIDTH,
                                 lblStringSize.height+2);
    UIScrollView *msgView = [[UIScrollView alloc] initWithFrame:msgFrame];
    CGSize msgContentsize = CGSizeMake(msgFrame.size.width*2, msgFrame.size.height);
    msgView.contentSize = msgContentsize;
    NSString *msg;
    if ([locItemPeople.userInfo.source isEqualToString:@"facebook"])
    {
        msg=[NSString stringWithFormat:@"     at %@",locItemPeople.userInfo.lastSeenAt];;
    }
    else
    {
        msg = locItemPeople.userInfo.statusMsg;
    }
    CGSize msgSize = [msg sizeWithFont:[UIFont fontWithName:@"Helvetica" size:11.0f]];

    CGRect lblFrame = CGRectMake(0, 0, msgSize.width, msgSize.height);
    UILabel *lblMsg = [[UILabel alloc] initWithFrame:lblFrame];
    lblMsg.backgroundColor = [UIColor clearColor];
    lblMsg.font = [UIFont fontWithName:@"Helvetica" size:11.0f];
    lblMsg.textColor = [UIColor blackColor];

//    [(UIImageView*)[annoView viewWithTag:12002] removeFromSuperview];    
//    [(UIImageView*)[super.annoView viewWithTag:12002] removeFromSuperview];        
    if ([locItemPeople.userInfo.source isEqualToString:@"facebook"]) {
        UIImageView *sourceIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0,3,15,15)];
        sourceIcon.image=[UIImage imageNamed:@"fbCheckinIcon.png"];
        [msgView addSubview:sourceIcon];
        lblMsg.text = [NSString stringWithFormat:@"     at %@",locItemPeople.userInfo.lastSeenAt];;
        NSLog(@"locItemPeople.userInfo.lastSeenAtDate %@",[UtilityClass getCurrentTimeOrDate:locItemPeople.userInfo.lastSeenAtDate]);
    }
    else 
    {
        lblMsg.text = locItemPeople.userInfo.statusMsg;
    }

    [msgView addSubview:lblMsg];
    [lblMsg release];
    [infoView addSubview:msgView];
    [msgView release];
    
    // 119, 184, 0 - green
    NSString *distStr;
    if (locItemPeople.itemDistance >= 1000)
        distStr = [NSString stringWithFormat:@"%.1fkm AWAY", locItemPeople.itemDistance/1000.0];
    else
        distStr = [NSString stringWithFormat:@"%dm AWAY", (int)locItemPeople.itemDistance];
    CGSize distSize = [distStr sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0f]];
    
    CGRect distFrame = CGRectMake(ANNO_IMG_WIDTH+2, 2+lblStringSize.height+1+msgFrame.size.height+1, 
                                  distSize.width,
                                  distSize.height);
    UILabel *lblDist = [[UILabel alloc] initWithFrame:distFrame];
    if ([locItemPeople.userInfo.source isEqualToString:@"facebook"])
    {
        lblDist.text = [UtilityClass getCurrentTimeOrDate:locItemPeople.userInfo.lastSeenAtDate];   
        lblDist.textColor = [UIColor blackColor];

    }
    else
    {
        lblDist.text = distStr;
        lblDist.textColor = [UIColor colorWithRed:119.0/255.0 green:184.0/255.0 blue:0.0 alpha:1.0];
    }
    lblDist.backgroundColor = [UIColor clearColor];
    lblDist.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
    [infoView addSubview:lblDist];
    [lblDist release];

    return annoView;
}

- (NSString*) getAgeString:(LocationItemPeople*)locItemPpl
{
    NSString *age = @"";
    
    if (locItemPpl.userInfo.dateOfBirth != nil )
        age = [NSString stringWithFormat:@" - Age: %d",[UtilityClass getAgeFromBirthday:locItemPpl.userInfo.dateOfBirth]];
    else if ([locItemPpl.userInfo.age intValue] > 0)
        age = [NSString stringWithFormat:@" - Age: %@",locItemPpl.userInfo.age];
    
    if ([age isEqualToString:@" - Age: 0"]) {
        age = @"";
    }
    
    return age;
}

- (MKAnnotationView*) getViewForStateDetailed:(LocationItem*) locItem {
    annoView = [super getViewForStateDetailed:locItem];
    UIView *infoView = [annoView viewWithTag:11002];
    LocationItemPeople *locItemPeople = (LocationItemPeople*) locItem;

    // TODO: making the height smaller for appstore submission as we are removing the 
    // buttons at the bottom
//    CGRect detFrame = CGRectMake(ANNO_IMG_WIDTH+5, 2, annoView.frame.size.width-4-ANNO_IMG_WIDTH-12, annoView.frame.size.height-4-37);
    CGRect detFrame = CGRectMake(ANNO_IMG_WIDTH+5, 2, annoView.frame.size.width-4-ANNO_IMG_WIDTH-12, annoView.frame.size.height-4);
    UIWebView *detailView = [[[UIWebView alloc] initWithFrame:detFrame] autorelease];
    detailView.backgroundColor = [UIColor clearColor];
    detailView.opaque = NO;
    
    NSString *age = [self getAgeString:locItemPeople];
    NSString *detailInfoHtml;
    if ([locItemPeople.userInfo.source isEqualToString:@"facebook"])
    {
        NSString *msg=locItemPeople.userInfo.lastSeenAt;
        detailInfoHtml = [[[NSString alloc] initWithFormat:@"<html><head><title>Benefit equivalence</title></head><body style=\"font-family:Helvetica; font-size:12px; background-color:transparent; line-height:2.0\"> <b> %@ %@</b><! - Age: !><b>%@</b><br> <span style=\"line-height:1.0\"> %@ </span> <b> <br> <span style=\"color:#71ab01; font-size:12px; line-height:1.5\"> %@m AWAY <br> %@ <br> </span><span style=\"line-height:1.2\"><br></span></body></html>", 
                           locItemPeople.userInfo.firstName==nil?@"":locItemPeople.userInfo.firstName, 
                           locItemPeople.userInfo.lastName==nil?@"":locItemPeople.userInfo.lastName, 
                           age, msg==nil?@"":msg, 
                           locItemPeople.userInfo.distance==nil?@"":locItemPeople.userInfo.distance, 
                           @""// Address of current location - use CLGeocoder
                           ] autorelease];
    }
    else
    {
        detailInfoHtml = [[[NSString alloc] initWithFormat:@"<html><head><title>Benefit equivalence</title></head><body style=\"font-family:Helvetica; font-size:12px; background-color:transparent; line-height:2.0\"> <b> %@ %@</b><! - Age: !><b>%@</b><br> <span style=\"line-height:1.0\"> %@ </span> <b> <br> <span style=\"color:#71ab01; font-size:12px; line-height:1.5\"> %@m AWAY <br> %@ <br> </span> </b> <span style=\"line-height:1.2\">Gender: <b>%@</b> <br> Relationship status: <b> %@ </b> <br> Living in <b>%@</b><br> Work at <b>%@</b><br></span></body></html>", 
                           locItemPeople.userInfo.firstName==nil?@"":locItemPeople.userInfo.firstName, 
                           locItemPeople.userInfo.lastName==nil?@"":locItemPeople.userInfo.lastName, 
                           age, 
                           locItemPeople.userInfo.statusMsg==nil?@"":locItemPeople.userInfo.statusMsg, 
                           locItemPeople.userInfo.distance==nil?@"":locItemPeople.userInfo.distance, 
                           @"", // Address of current location - use CLGeocoder
                           locItemPeople.userInfo.gender==nil?@"":locItemPeople.userInfo.gender, 
                           locItemPeople.userInfo.relationsipStatus==nil?@"":locItemPeople.userInfo.relationsipStatus, 
                           locItemPeople.userInfo.city==nil?@"":locItemPeople.userInfo.city, 
                           locItemPeople.userInfo.workStatus==nil?@"":locItemPeople.userInfo.workStatus] autorelease];
    }
      
    [detailView loadHTMLString:detailInfoHtml baseURL:nil];
    detailView.delegate = self;
    [infoView addSubview:detailView];
    
    // Buttons
    // Add friend
    UIButton *addFriendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addFriendBtn.frame = CGRectMake(5, ANNO_IMG_HEIGHT+15, 53, 32);
    [addFriendBtn addTarget:self action:@selector(handleUserAction:) forControlEvents:UIControlEventTouchUpInside];
    [addFriendBtn setImage:[UIImage imageNamed:@"map_add_friend.png"] forState:UIControlStateNormal];
    addFriendBtn.backgroundColor = [UIColor clearColor];
    addFriendBtn.tag = 11003;
    [infoView addSubview:addFriendBtn];
    if (locItemPeople.userInfo.isFriend == TRUE)
        addFriendBtn.hidden = TRUE;
    else
        addFriendBtn.hidden = FALSE;
    
    
    [addFriendBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize]];
    [addFriendBtn setTitleColor:[UIColor colorWithRed:119.0/255.0 green:184.0/255.0 blue:0.0 alpha:1.0] forState:UIControlStateNormal];
    
    NSString *friendShipStatus = locItemPeople.userInfo.friendshipStatus;
    
    if ([friendShipStatus isEqualToString:@"rejected_by_me"] || [friendShipStatus isEqualToString:@"rejected_by_him"]) {
        [addFriendBtn setTitle:@"Rejected" forState:UIControlStateNormal];
        [addFriendBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [addFriendBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_light_small.png"] forState:UIControlStateNormal];
        [addFriendBtn setImage:nil forState:UIControlStateNormal];
        addFriendBtn.userInteractionEnabled = NO;
    } else if ([friendShipStatus isEqualToString:@"requested"]) {
        [addFriendBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:kSmallLabelFontSize-2]];
        [addFriendBtn setImage:nil forState:UIControlStateNormal];
        [addFriendBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_light_small.png"] forState:UIControlStateNormal];
        [addFriendBtn setTitle:@"Requested" forState:UIControlStateNormal];
        addFriendBtn.userInteractionEnabled = NO;
    } else if ([friendShipStatus isEqualToString:@"pending"]) {
        [addFriendBtn setImage:nil forState:UIControlStateNormal];
        [addFriendBtn setTitle:@"Pending" forState:UIControlStateNormal];
        [addFriendBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_light_small.png"] forState:UIControlStateNormal];
        addFriendBtn.userInteractionEnabled = NO;
    }
    
    
   

    [(UIImageView*)[annoView viewWithTag:12002] removeFromSuperview];    
    [(UIImageView*)[super.annoView viewWithTag:12002] removeFromSuperview];        

    // Message request
    if ([locItemPeople.userInfo.source isEqualToString:@"facebook"])
    {
        UIImageView *sourceIcon = [[UIImageView alloc] initWithFrame:CGRectMake(65,87,20,20)];
        sourceIcon.image=[UIImage imageNamed:@"icon_facebook.png"];
        [infoView addSubview:sourceIcon];

    }
    else {
        // Meet-up request
        UIButton *meetupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        meetupBtn.frame = CGRectMake(5, infoView.frame.size.height-15-27, 57, 27);
        [meetupBtn addTarget:self action:@selector(handleUserAction:) forControlEvents:UIControlEventTouchUpInside];
        [meetupBtn setImage:[UIImage imageNamed:@"map_meet_up.png"] forState:UIControlStateNormal];
        meetupBtn.backgroundColor = [UIColor clearColor];
        meetupBtn.tag = 11004;
        [infoView addSubview:meetupBtn];
        // TODO: hiding for appstore submission. revert back once feature is implemenetd
        meetupBtn.hidden = FALSE;
        
        // Directions request
        UIButton *directionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        directionBtn.frame = CGRectMake((infoView.frame.size.width-57)/2, infoView.frame.size.height-15-27, 57, 27);
        [directionBtn addTarget:self action:@selector(handleUserAction:) forControlEvents:UIControlEventTouchUpInside];
        [directionBtn setImage:[UIImage imageNamed:@"map_directions.png"] forState:UIControlStateNormal];
        directionBtn.backgroundColor = [UIColor clearColor];
        directionBtn.tag = 11005;
        [infoView addSubview:directionBtn];
        // TODO: hiding for appstore submission. revert back once feature is implemenetd
        directionBtn.hidden = FALSE;
        
        //Message button
        UIButton *messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        // TODO: repositioning message button for appstore submission. SInce we are hiding
        // meetup/direction we are putting this under friend request button
        messageBtn.frame = CGRectMake(infoView.frame.size.width-15-57, infoView.frame.size.height-15-27, 57, 27);
        // messageBtn.frame = CGRectMake(2, ANNO_IMG_HEIGHT+5+35, 57, 27);
        [messageBtn addTarget:self action:@selector(handleUserAction:) forControlEvents:UIControlEventTouchUpInside];
        [messageBtn setImage:[UIImage imageNamed:@"map_message.png"] forState:UIControlStateNormal];
        messageBtn.backgroundColor = [UIColor clearColor];
        messageBtn.tag = 11006;
        [infoView addSubview:messageBtn];
        
        //Profile button
        UIButton *profileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        profileBtn.frame = CGRectMake(5, ANNO_IMG_HEIGHT+30+30, 53, 27);
        [profileBtn addTarget:self action:@selector(handleUserAction:) forControlEvents:UIControlEventTouchUpInside];
        [profileBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_light_small.png"] forState:UIControlStateNormal];
        [profileBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [profileBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:12.0f]];
        [profileBtn setTitle:@"Profile" forState:UIControlStateNormal];
        profileBtn.backgroundColor = [UIColor clearColor];
        profileBtn.tag = 11008;
        [infoView addSubview:profileBtn];    
    }
    return annoView;
}

- (MKAnnotationView*) getViewForState:(MAP_ANNOTATION_STATE)state loc:(LocationItem*) locItem{
    if (locItem.currDisplayState == MapAnnotationStateNormal) {
        
        return [self getViewForStateNormal:locItem];
    } else if (locItem.currDisplayState == MapAnnotationStateSummary){
        return [self getViewForStateSummary:locItem];
    }
    else {
        return [self getViewForStateDetailed:locItem];
    }
}

// Button click events
- (void) handleUserAction:(id) sender {
    UIButton *btn = (UIButton*)sender ;
    int tag = btn.tag;
    MAP_USER_ACTION actionType;
    NSLog(@"MapAnnotationPeople: performUserAction, tag=%d", tag);
    
    switch (tag) {
        case 11003:
            actionType = MapAnnoUserActionAddFriend;
            break;
        case 11004:
            actionType = MapAnnoUserActionMeetup;
            break;    
        case 11005:
            actionType = MapAnnoUserActionDirection;
            break;
        case 11006:
            actionType = MapAnnoUserActionMessage;
            break;
        case 11008:
            actionType = MapAnnoUserActionProfile;
            break;
        default:
            return;
            break;
    }
    
    MKAnnotationView *selAnno = (MKAnnotationView*) [[sender superview] superview];
    LocationItemPlace *locItem = (LocationItemPlace*) [selAnno annotation];
    NSLog(@"Name=%@", locItem.itemName);
    
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(performUserAction:type:)]) {
        [self.delegate performUserAction:selAnno type:actionType];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
}
@end

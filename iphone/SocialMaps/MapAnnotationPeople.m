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
#import "UserFriends.h"
#import "Globals.h"

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
        
        if (!locItemPeople.userInfo.external) {
            
            UIImageView *imageViewIsOnline = [[UIImageView alloc] initWithFrame:CGRectMake(5, annoView.frame.size.height - 26, 10, 10)];
            
            if (locItemPeople.userInfo.isOnline) {
                NSArray *imageArray = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"online_dot.png"], [UIImage imageNamed:@"blank.png"], nil];
                imageViewIsOnline.animationDuration = 2;
                imageViewIsOnline.animationImages = imageArray;
                [imageViewIsOnline startAnimating];
                [imageArray release];
            } else {
                imageViewIsOnline.image = [UIImage imageNamed:@"offline_dot.png"]; 
            }
            
            [[annoView viewWithTag:11000] addSubview:imageViewIsOnline];
            
            [imageViewIsOnline release];
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
        msg=[NSString stringWithFormat:@"     at %@",[[locItemPeople.userInfo.lastSeenAt componentsSeparatedByString:@","] objectAtIndex:0]];
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

    if ([locItemPeople.userInfo.source isEqualToString:@"facebook"]) {
        UIImageView *sourceIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,15,15)];
        sourceIcon.image=[UIImage imageNamed:@"fbCheckinIcon.png"];
        [msgView addSubview:sourceIcon];
        [sourceIcon release];
        lblMsg.text = [NSString stringWithFormat:@"     at %@",[[locItemPeople.userInfo.lastSeenAt componentsSeparatedByString:@","] objectAtIndex:0]];
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
    Geolocation *geoLocation=[[Geolocation alloc] init];
    geoLocation.latitude=locItemPeople.userInfo.currentLocationLat;
    geoLocation.longitude=locItemPeople.userInfo.currentLocationLng;
    NSString *distStr=[UtilityClass getDistanceWithFormattingFromLocation:geoLocation];
    [geoLocation release];
    
    CGSize distSize = [distStr sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0f]];
    if ([locItemPeople.userInfo.source isEqualToString:@"facebook"])
    {
        distSize = [[UtilityClass getCurrentTimeOrDate:locItemPeople.userInfo.lastSeenAtDate] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0f]];
    }
    CGRect distFrame = CGRectMake(ANNO_IMG_WIDTH+2, 2+lblStringSize.height+1+msgFrame.size.height+1, 
                                  distSize.width,
                                  distSize.height);
    UILabel *lblDist = [[UILabel alloc] initWithFrame:distFrame];
    if ([locItemPeople.userInfo.source isEqualToString:@"facebook"])
    {
        lblDist.text = [UtilityClass getCurrentTimeOrDate:locItemPeople.userInfo.lastSeenAtDate];   
        lblDist.textColor = [UIColor blackColor];
        lblDist.font = [UIFont fontWithName:@"Helvetica" size:11.0f];
    }
    else
    {
        lblDist.text = distStr;
        lblDist.textColor = [UIColor colorWithRed:119.0/255.0 green:184.0/255.0 blue:0.0 alpha:1.0];
        lblDist.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
    }
    lblDist.backgroundColor = [UIColor clearColor];
    [infoView addSubview:lblDist];
    [lblDist release];
    NSLog(@"info %@",NSStringFromCGRect(infoView.frame));
    
    if (![locItemPeople.userInfo.source isEqualToString:@"facebook"])
    {
        //Profile button
        UIView *profilePicture = [annoView viewWithTag:11000];
        UIButton *profileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        profileBtn.frame = profilePicture.frame;
        [profileBtn addTarget:self action:@selector(handleUserAction:) forControlEvents:UIControlEventTouchUpInside];
        profileBtn.tag = 11008;
        [infoView addSubview:[annoView viewWithTag:1234321]]; 
        [infoView addSubview:profileBtn];
    }
  
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
    Geolocation *geoLocation=[[Geolocation alloc] init];
    geoLocation.latitude=locItemPeople.userInfo.currentLocationLat;
    geoLocation.longitude=locItemPeople.userInfo.currentLocationLng;
    NSString *distStr=[UtilityClass getDistanceWithFormattingFromLocation:geoLocation];
    [geoLocation release];
    CGRect detFrame = CGRectMake(ANNO_IMG_WIDTH+5, 2, annoView.frame.size.width-4-ANNO_IMG_WIDTH-15, annoView.frame.size.height-42);
    UIWebView *detailView = [[[UIWebView alloc] initWithFrame:detFrame] autorelease];
    UIView *sudoView=[[UIView alloc] initWithFrame:detFrame];
    [sudoView setBackgroundColor:[UIColor clearColor]];
    [detailView.window setTag:12321123];
    detailView.backgroundColor = [UIColor clearColor];
    detailView.opaque = NO;
    detailView.userInteractionEnabled=YES;
    NSString *age = [self getAgeString:locItemPeople];
    NSString *detailInfoHtml;
    if ([locItemPeople.userInfo.source isEqualToString:@"facebook"])
    {
        NSString *msg=locItemPeople.userInfo.lastSeenAt;
        detailInfoHtml = [[[NSString alloc] initWithFormat:@"<html><head><title>Benefit equivalence</title></head><body style=\"font-family:Helvetica; font-size:12px; background-color:transparent; line-height:2.0\"> <b> %@ %@</b><! - Age: !><b>%@</b><br> <span style=\"line-height:1.0\"> %@ </span> <b> <br> <span style=\"color:#71ab01; font-size:12px; line-height:1.5\"> %@ AWAY <br> %@ <br> </span><span style=\"line-height:1.2\"><br></span></body></html>", 
                           locItemPeople.userInfo.firstName==nil?@"":locItemPeople.userInfo.firstName, 
                           locItemPeople.userInfo.lastName==nil?@"":locItemPeople.userInfo.lastName, 
                           age, msg==nil?@"":msg, 
                           locItemPeople.userInfo.distance==nil?@"":distStr, 
                           @""// Address of current location - use CLGeocoder
                           ] autorelease];
    }
    else
    {
        detailInfoHtml = [[[NSString alloc] initWithFormat:@"<html><head><title>Benefit equivalence</title></head><body style=\"font-family:Helvetica; font-size:12px; background-color:transparent; line-height:2.0\"> <b> %@ %@</b><! - Age: !><span style=\"line-height:1.0\"> %@ </span ><br> <span style=\"line-height:1.0\"> %@ </span> <b> <br> <span style=\"color:#71ab01; font-size:12px; line-height:1.5\"> %@ AWAY <br> </span> </b> <span style=\"line-height:1.2\">Gender: <b>%@</b> <br> Relationship status: <b> %@ </b> <br> Living in: <b>%@</b><br> Work at: <b>%@</b><br></span></body></html>", 
                           locItemPeople.userInfo.firstName==nil?@"":locItemPeople.userInfo.firstName, 
                           locItemPeople.userInfo.lastName==nil?@"":locItemPeople.userInfo.lastName, 
                           age, 
                           locItemPeople.userInfo.statusMsg==nil?@"&nbsp;":locItemPeople.userInfo.statusMsg, 
                           locItemPeople.userInfo.distance==nil?@"":distStr,
                           locItemPeople.userInfo.gender==nil?@"":locItemPeople.userInfo.gender,
                           locItemPeople.userInfo.relationsipStatus==nil?@"":locItemPeople.userInfo.relationsipStatus, 
                           locItemPeople.userInfo.city==nil?@"":locItemPeople.userInfo.city, 
                           locItemPeople.userInfo.workStatus==nil?@"":locItemPeople.userInfo.workStatus] autorelease];
    }
    
    [detailView loadHTMLString:detailInfoHtml baseURL:nil];
    detailView.delegate = self;
    [infoView addSubview:detailView];
    [detailView setUserInteractionEnabled:YES];
    
    [detailView.scrollView performSelector:@selector(flashScrollIndicators) withObject:nil afterDelay:1];
    
    // Buttons
    UIView *profilePicture = [annoView viewWithTag:11000];
    [(UIImageView*)[annoView viewWithTag:12002] removeFromSuperview];    
    [(UIImageView*)[super.annoView viewWithTag:12002] removeFromSuperview];        

    // Message request
    if ([locItemPeople.userInfo.source isEqualToString:@"facebook"])
    {
        UIImageView *sourceIcon = [[UIImageView alloc] initWithFrame:CGRectMake(65,87,20,20)];
        sourceIcon.image=[UIImage imageNamed:@"icon_facebook.png"];
        [infoView addSubview:sourceIcon];
        [sourceIcon release];

    }
    else {
        // Meet-up request
        UIButton *meetupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        meetupBtn.frame = CGRectMake(profilePicture.frame.origin.x + 2, infoView.frame.size.height-10-27, 57, 27);
        [meetupBtn addTarget:self action:@selector(handleUserAction:) forControlEvents:UIControlEventTouchUpInside];
        [meetupBtn setImage:[UIImage imageNamed:@"map_meet_up.png"] forState:UIControlStateNormal];
        meetupBtn.backgroundColor = [UIColor clearColor];
        meetupBtn.tag = 11004;
        [infoView addSubview:meetupBtn];
        // TODO: hiding for appstore submission. revert back once feature is implemenetd
        meetupBtn.hidden = FALSE;
        
        // Directions request
        UIButton *directionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        directionBtn.frame = CGRectMake((infoView.frame.size.width-57)/2 - 2, infoView.frame.size.height-10-27, 57, 27);
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
        messageBtn.frame = CGRectMake(infoView.frame.size.width-15-57, infoView.frame.size.height-10-27, 57, 27);
        [messageBtn addTarget:self action:@selector(handleUserAction:) forControlEvents:UIControlEventTouchUpInside];
        [messageBtn setImage:[UIImage imageNamed:@"map_message.png"] forState:UIControlStateNormal];
        messageBtn.backgroundColor = [UIColor clearColor];
        messageBtn.tag = 11006;
        [infoView addSubview:messageBtn];
        
        //Profile button
        UIButton *profileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        profileBtn.frame = profilePicture.frame;
        [profileBtn addTarget:self action:@selector(handleUserAction:) forControlEvents:UIControlEventTouchUpInside];
        profileBtn.tag = 11008;
        [infoView addSubview:profileBtn];    
        
    }
    
    // Add friend
    UIButton *addFriendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addFriendBtn.frame = CGRectMake(profilePicture.frame.origin.x + 2, infoView.frame.size.height-10-30, 57, 32);
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
    NSLog(@"friendShip Status = %@", friendShipStatus);
    
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
    } else if ([friendShipStatus isEqualToString:@"friend"]) { 
        addFriendBtn.hidden = YES;
    }
    [sudoView setFrame:CGRectMake(detFrame.origin.x, detFrame.origin.y, detFrame.size.width, infoView.frame.size.height-10-27)];
    [sudoView setBackgroundColor:[UIColor clearColor]];
    [sudoView release];
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
    LocationItemPeople *locItem = (LocationItemPeople*) [selAnno annotation];
    NSLog(@"Name=%@", locItem.itemName);
    
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(performUserAction:type:)]) {
        [self.delegate performUserAction:selAnno type:actionType];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
}
@end

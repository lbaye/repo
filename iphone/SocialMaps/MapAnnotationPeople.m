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

@implementation MapAnnotationPeople

- (MKAnnotationView*) getViewForStateNormal:(LocationItem*) locItem {
    annoView = [super getViewForStateNormal:locItem];
    
    return annoView;
}

- (MKAnnotationView*) getViewForStateSummary:(LocationItem*) locItem {
    annoView = [super getViewForStateSummary:locItem];

    CGSize lblStringSize = [@"Firstname NAME" sizeWithFont:[UIFont fontWithName:@"Helvetica" size:11.0f]];
    UIView *infoView = [annoView viewWithTag:11002];
    
    CGRect lblNameFrame = CGRectMake(ANNO_IMG_WIDTH+2, 2, infoView.frame.size.width-4-ANNO_IMG_WIDTH, lblStringSize.height);
    UILabel *lblName = [[UILabel alloc] initWithFrame:lblNameFrame];
    lblName.text = [NSString stringWithFormat:@"%@ - Age: %d", locItem.itemName, 45];
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
    
    NSString *msg = @"Not doing much...Not doing much...Not doing much...";
    CGSize msgSize = [msg sizeWithFont:[UIFont fontWithName:@"Helvetica" size:11.0f]];

    CGRect lblFrame = CGRectMake(0, 0, msgSize.width, msgSize.height);
    UILabel *lblMsg = [[UILabel alloc] initWithFrame:lblFrame];
    lblMsg.text = [NSString stringWithFormat:@"Not doing much...Not doing much...Not doing much..."];
    lblMsg.backgroundColor = [UIColor clearColor];
    lblMsg.font = [UIFont fontWithName:@"Helvetica" size:11.0f];
    lblMsg.textColor = [UIColor blackColor];
    [msgView addSubview:lblMsg];
    [lblMsg release];
    [infoView addSubview:msgView];
    [msgView release];
    
    // 119, 184, 0 - green
    NSString *distStr = [NSString stringWithFormat:@"%dm AWAY", (int)locItem.itemDistance];
    CGSize distSize = [distStr sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0f]];
    
    CGRect distFrame = CGRectMake(ANNO_IMG_WIDTH+2, 2+lblStringSize.height+1+msgFrame.size.height+1, 
                                  distSize.width,
                                  distSize.height);
    UILabel *lblDist = [[UILabel alloc] initWithFrame:distFrame];
    lblDist.text = distStr;
    lblDist.backgroundColor = [UIColor clearColor];
    lblDist.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
    lblDist.textColor = [UIColor colorWithRed:119.0/255.0 green:184.0/255.0 blue:0.0 alpha:1.0];
    [infoView addSubview:lblDist];
    [lblDist release];

    return annoView;
}

- (MKAnnotationView*) getViewForStateDetailed:(LocationItem*) locItem {
    annoView = [super getViewForStateDetailed:locItem];
    UIView *infoView = [annoView viewWithTag:11002];

    CGRect detFrame = CGRectMake(ANNO_IMG_WIDTH+5, 2, annoView.frame.size.width-4-ANNO_IMG_WIDTH-12, annoView.frame.size.height-4-37);
    UIWebView *detailView = [[[UIWebView alloc] initWithFrame:detFrame] autorelease];
    detailView.backgroundColor = [UIColor clearColor];
    detailView.opaque = NO;
    
    NSString *detailInfoHtml = [[[NSString alloc] initWithFormat:@"<html><head><title>Benefit equivalence</title></head><body style=\"font-family:Helvetica; font-size:12px; background-color:transparent; line-height:2.0\"> <b> %@ %@</b> - Age: <b>%d</b><br> <span style=\"line-height:1.0\"> %@ </span> <b> <br> <span style=\"color:#71ab01; font-size:12px; line-height:1.5\"> %@ <br> %@ <br> </span> </b> <span style=\"line-height:1.2\">Gender: <b>%@</b> <br> Relationship status: <b> %@ </b> <br> Living in <b>%@</b><br> Work at <b>%@</b><br></span></body></html>", 
                                   @"Firstname", @"NAME", 45, @"Not doing much...Not doing much...Not doing much...", @"600m AWAY", @"1011 Main Street", @"male", @"single", @"Paris", @"Air France"] autorelease];  
    [detailView loadHTMLString:detailInfoHtml baseURL:nil];
    detailView.delegate = self;
    [infoView addSubview:detailView];
    
    // Buttons
    // Add friend
    UIButton *addFriendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addFriendBtn.frame = CGRectMake(5, ANNO_IMG_HEIGHT+20, 53, 32);
    [addFriendBtn addTarget:self action:@selector(addFriendClicked:) forControlEvents:UIControlEventTouchUpInside];
    [addFriendBtn setImage:[UIImage imageNamed:@"map_add_friend.png"] forState:UIControlStateNormal];
    addFriendBtn.backgroundColor = [UIColor clearColor];
    addFriendBtn.tag = 11003;
    [infoView addSubview:addFriendBtn];
    
    // Meet-up request
    UIButton *meetupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    meetupBtn.frame = CGRectMake(15, infoView.frame.size.height-15-27, 57, 27);
    [meetupBtn addTarget:self action:@selector(meetupClicked:) forControlEvents:UIControlEventTouchUpInside];
    [meetupBtn setImage:[UIImage imageNamed:@"map_meet_up.png"] forState:UIControlStateNormal];
    meetupBtn.backgroundColor = [UIColor clearColor];
    meetupBtn.tag = 11004;
    [infoView addSubview:meetupBtn];

    // Directions request
    UIButton *directionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    directionBtn.frame = CGRectMake((infoView.frame.size.width-57)/2, infoView.frame.size.height-15-27, 57, 27);
    [directionBtn addTarget:self action:@selector(directionsClicked:) forControlEvents:UIControlEventTouchUpInside];
    [directionBtn setImage:[UIImage imageNamed:@"map_directions.png"] forState:UIControlStateNormal];
    directionBtn.backgroundColor = [UIColor clearColor];
    directionBtn.tag = 11005;
    [infoView addSubview:directionBtn];
    
    // Message request
    UIButton *messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    messageBtn.frame = CGRectMake(infoView.frame.size.width-15-57, infoView.frame.size.height-15-27, 57, 27);
    [messageBtn addTarget:self action:@selector(messageClicked:) forControlEvents:UIControlEventTouchUpInside];
    [messageBtn setImage:[UIImage imageNamed:@"map_message.png"] forState:UIControlStateNormal];
    messageBtn.backgroundColor = [UIColor clearColor];
    messageBtn.tag = 11006;
    [infoView addSubview:messageBtn];
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
- (void) addFriendClicked:(id) sender {
    NSLog(@"MapAnnotation: addFriendClicked");
    MKAnnotationView *selAnno = (MKAnnotationView*) [[sender superview] superview];
    LocationItemPeople *locItem = (LocationItemPeople*) [selAnno annotation];
    NSLog(@"Name=%@", locItem.itemName);
    
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(addFriendSelected:)]) {
        [self.delegate addFriendSelected:[selAnno annotation]];
    }
}

- (void) meetupClicked:(id) sender {
    NSLog(@"MapAnnotation: meetupClicked");
    MKAnnotationView *selAnno = (MKAnnotationView*) [[sender superview] superview];
    LocationItemPeople *locItem = (LocationItemPeople*) [selAnno annotation];
    NSLog(@"Name=%@", locItem.itemName);
    
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(meetupRequestSelecetd:)]) {
        [self.delegate meetupRequestSelected:[selAnno annotation]];
    }
}

- (void) directionsClicked:(id) sender {
    NSLog(@"MapAnnotation: directionsClicked");
    MKAnnotationView *selAnno = (MKAnnotationView*) [[sender superview] superview];
    LocationItemPeople *locItem = (LocationItemPeople*) [selAnno annotation];
    NSLog(@"Name=%@", locItem.itemName);
    
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(directionSelected:)]) {
        [self.delegate directionSelected:[selAnno annotation]];
    }
}

- (void) messageClicked:(id) sender {
    NSLog(@"MapAnnotation: messageClicked");
    MKAnnotationView *selAnno = (MKAnnotationView*) [[sender superview] superview];
    LocationItemPeople *locItem = (LocationItemPeople*) [selAnno annotation];
    NSLog(@"Name=%@", locItem.itemName);
    
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(messageSelected:)]) {
        [self.delegate messageSelected:[selAnno annotation]];
    }
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
}
@end

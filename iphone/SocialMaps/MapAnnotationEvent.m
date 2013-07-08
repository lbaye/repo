//
//  MapAnnotationEvent.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 10/14/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "MapAnnotationEvent.h"
//#import "LocationItemPlace.h"
#import "Globals.h"
#import "Event.h"
#import "LocationItem.h"
#import "ViewEventDetailViewController.h"
#import "UtilityClass.h"
#define BUTTON_WIDTH 57
#define BUTTON_HEIGHT 27
@implementation MapAnnotationEvent

LocationItem *locationItem;

- (MKAnnotationView*) getViewForStateNormal:(LocationItem*) locItem {
    annoView = [super getViewForStateNormal:locItem];
    
    return annoView;
}

- (MKAnnotationView*) getViewForStateSummary:(LocationItem*) locItem {
    NSLog(@"loading summary detail.");
    annoView = [super getViewForStateSummary:locItem];
    UIView *infoView = [annoView viewWithTag:11002];
    
    CGRect sumFrame = CGRectMake(annoView.frame.origin.x, annoView.frame.origin.y, 
                                 annoView.frame.size.width, annoView.frame.size.height+25);
    if (locItem.itemType!=4) {
        annoView.frame = sumFrame;
    }
    if (locItem.itemType==4)
    {
        infoView.frame = CGRectMake(0, 0, 188, 51);
    }
    CGRect infoFrame = CGRectMake(annoView.frame.origin.x, annoView.frame.origin.y, 
                                  annoView.frame.size.width-12, annoView.frame.size.height);
    infoView.frame = infoFrame;
    if (locItem.itemType==4)
    {
        infoView.frame = CGRectMake(0, 0, 188, 51);
    }

    NSLog(@" %@",NSStringFromCGRect(infoFrame));
    // Category icon
    CGRect catIconFrame = CGRectMake(infoView.frame.size.width-33-2, 2, 33, 25);
    UIImageView *imgCatIcon = [[UIImageView alloc] initWithFrame:catIconFrame];
    
    [imgCatIcon setImage:locItem.itemBg];
    imgCatIcon.hidden = TRUE; // Temporary - until we get proper icons
    [infoView addSubview:imgCatIcon];
    [imgCatIcon release];
    
    
    // Name
    CGSize lblStringSize = [locItem.itemName sizeWithFont:[UIFont fontWithName:@"Helvetica" size:11.0f]];
    CGRect lblNameFrame = CGRectMake(ANNO_IMG_WIDTH+2, (2+catIconFrame.size.height-lblStringSize.height)/2, 
                                     infoView.frame.size.width-4-ANNO_IMG_WIDTH, lblStringSize.height);
    UILabel *lblName = [[UILabel alloc] initWithFrame:lblNameFrame];
    
    if (locItem.itemType == 4) 
    {
        lblName.text = [NSString stringWithFormat:@"%@ tagged", locItem.itemName];
    }
    else
    {
        lblNameFrame = CGRectMake(ANNO_IMG_WIDTH+2, (2+lblStringSize.height)/2, 
                                  infoView.frame.size.width-4-ANNO_IMG_WIDTH, lblStringSize.height);
        lblName.frame=lblNameFrame;
        lblName.text = [NSString stringWithFormat:@"%@", locItem.itemName];
    }
    lblName.backgroundColor = [UIColor clearColor];
    lblName.font = [UIFont fontWithName:@"Helvetica" size:11.0f];
    [infoView addSubview:lblName];
    [lblName release];
    
    // Address
    if (locItem.itemType == 4) 
    {
        lblStringSize = [[NSString stringWithFormat:@"%@",locItem.itemAddress] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:11.0f]];        
    }
    else
    {
        lblStringSize = [locItem.itemAddress sizeWithFont:[UIFont fontWithName:@"Helvetica" size:11.0f]];
    }
    CGRect addrFrame = CGRectMake(ANNO_IMG_WIDTH+2, 2+catIconFrame.size.height+1, 
                                  lblStringSize.width,
                                  lblStringSize.height+2);
    UILabel *lblAddress = [[UILabel alloc] initWithFrame:addrFrame];
    if (locItem.itemType == 4) 
    {
        addrFrame = CGRectMake(ANNO_IMG_WIDTH+2, 4+catIconFrame.size.height+1, 
                               lblStringSize.width,
                               lblStringSize.height+2);
        lblAddress.frame=addrFrame;
        NSLog(@"locItem.itemAddress %@",locItem.itemAddress);
        lblAddress.text = [NSString stringWithFormat:@"%@",locItem.itemAddress];
    }
    else
    {
        lblAddress.text = [NSString stringWithFormat:@"%@", locItem.itemAddress];
    }
    lblAddress.backgroundColor = [UIColor clearColor];
    lblAddress.font = [UIFont fontWithName:@"Helvetica" size:11.0f];
    [infoView addSubview:lblAddress];
    [lblAddress release];
    
    // 119, 184, 0 - green
    NSString *distStr;
    if (locItem.itemDistance >= 1000)
        distStr = [NSString stringWithFormat:@"%.1fkm AWAY", locItem.itemDistance/1000.0];
    else
        distStr = [NSString stringWithFormat:@"%dm AWAY", (int)locItem.itemDistance];
    CGSize distSize = [distStr sizeWithFont:[UIFont fontWithName:@"Helvetica" size:11.0f]];
    CGRect distFrame = CGRectMake(ANNO_IMG_WIDTH+2, 2+catIconFrame.size.height+1+addrFrame.size.height+1, 
                                  distSize.width,
                                  distSize.height);
    if (locItem.itemType==4) 
    {
        distSize = [[NSString stringWithFormat:@"by %@",locItem.itemCategory] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:11.0f]];
        distFrame = CGRectMake(ANNO_IMG_WIDTH+2, 3+addrFrame.size.height+1, 
                               distSize.width,
                               distSize.height);
    }
    
    UILabel *lblDist = [[UILabel alloc] initWithFrame:distFrame];
    if (locItem.itemType==4) 
    {
        NSString *msg=[NSString stringWithFormat:@"by %@",locItem.itemCategory];
        lblDist.text=msg;
        lblDist.textColor=[UIColor blackColor];
    }
    else
    {
        lblDist.text = distStr;
        lblDist.textColor = [UIColor colorWithRed:119.0/255.0 green:184.0/255.0 blue:0.0 alpha:1.0];        
    }

    lblDist.backgroundColor = [UIColor clearColor];
    lblDist.font = [UIFont fontWithName:@"Helvetica" size:11.0f];
    [infoView addSubview:lblDist];
    [lblDist release];
    
    // Event
    UIImage *eventImg = [UIImage imageNamed:@"btn_bg_light_small.png"];
    UIButton *eventBtn = (UIButton *)[annoView viewWithTag:110003];
    if (eventBtn==NULL)
    {
        eventBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    eventBtn.frame = CGRectMake(35, 2+catIconFrame.size.height+1+addrFrame.size.height+1+distFrame.size.height+1, 57, distSize.height+5);
    NSLog(@"eventBtn.frame %lf %lf %lf %lf",eventBtn.frame.origin.x,eventBtn.frame.origin.y,eventBtn.frame.size.width,eventBtn.frame.size.height);
    [eventBtn addTarget:self action:@selector(handleUserAction:) forControlEvents:UIControlEventTouchUpInside];
    [eventBtn setBackgroundImage:eventImg forState:UIControlStateNormal];
    [eventBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [eventBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:12.0f]];
    [eventBtn setTitle:@"Detail" forState:UIControlStateNormal];
    eventBtn.backgroundColor = [UIColor clearColor];
    eventBtn.tag = 110003;
    if(locItem.itemType!=4)
    [infoView addSubview:eventBtn];
    
    //direction
    UIImage *dirImg = [UIImage imageNamed:@"btn_bg_light_small.png"];
    UIButton *dirBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    dirBtn.frame = CGRectMake(eventBtn.frame.origin.x+5+eventBtn.frame.size.width, eventBtn.frame.origin.y,eventBtn.frame.size.width,eventBtn.frame.size.height);
    [dirBtn addTarget:self action:@selector(handleUserAction:) forControlEvents:UIControlEventTouchUpInside];
    [dirBtn setBackgroundImage:dirImg forState:UIControlStateNormal];
    [dirBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:12.0f]];
    [dirBtn setTitle:@"Directions" forState:UIControlStateNormal];
    [dirBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    dirBtn.backgroundColor = [UIColor clearColor];
    dirBtn.tag = 11005;
    if(locItem.itemType!=4)
    [infoView addSubview:dirBtn];
    
    locationItem = locItem;
    return annoView;
}

- (MKAnnotationView*) getViewForStateDetailed:(LocationItem*) locItem {
    annoView = [self getViewForStateSummary:locItem];
    locationItem=[[LocationItem alloc] init];
    UIView *infoView = [annoView viewWithTag:11002];
    
    CGRect detFrame = CGRectMake(annoView.frame.origin.x, annoView.frame.origin.y, 
                                 (BUTTON_WIDTH+2)*4+20, annoView.frame.size.height+64);
    annoView.frame = detFrame;
    
    CGRect infoFrame = CGRectMake(annoView.frame.origin.x, annoView.frame.origin.y, 
                                  annoView.frame.size.width-12, annoView.frame.size.height);
    infoView.frame = infoFrame;
    
    // Buttons
    int numRow = 0;
    
    // Event
    UIImage *eventImg = [UIImage imageNamed:@"place_event.png"];
    UIButton *eventBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    eventBtn.frame = CGRectMake(5, infoView.frame.size.height-5-BUTTON_HEIGHT*(2-numRow)-2, eventImg.size.width, BUTTON_HEIGHT);
    [eventBtn addTarget:self action:@selector(handleUserAction:) forControlEvents:UIControlEventTouchUpInside];
    [eventBtn setImage:eventImg forState:UIControlStateNormal];
    eventBtn.backgroundColor = [UIColor clearColor];
    eventBtn.tag = 11003;
    [infoView addSubview:eventBtn];
    
    // Plan
    UIImage *planImg = [UIImage imageNamed:@"place_plan.png"];
    UIButton *planBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    planBtn.frame = CGRectMake(eventBtn.frame.origin.x+eventBtn.frame.size.width+2, 
                               infoView.frame.size.height-5-BUTTON_HEIGHT*(2-numRow)-2, planImg.size.width, BUTTON_HEIGHT);
    [planBtn addTarget:self action:@selector(handleUserAction:) forControlEvents:UIControlEventTouchUpInside];
    [planBtn setImage:planImg forState:UIControlStateNormal];
    planBtn.backgroundColor = [UIColor clearColor];
    planBtn.tag = 11004;
    [infoView addSubview:planBtn];
    
    // Directions
    UIImage *dirImg = [UIImage imageNamed:@"place_direction.png"];
    UIButton *dirBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    dirBtn.frame = CGRectMake(planBtn.frame.origin.x+planBtn.frame.size.width+1, 
                              infoView.frame.size.height-5-BUTTON_HEIGHT*(2-numRow)-2, dirImg.size.width, BUTTON_HEIGHT);
    [dirBtn addTarget:self action:@selector(handleUserAction:) forControlEvents:UIControlEventTouchUpInside];
    [dirBtn setImage:dirImg forState:UIControlStateNormal];
    dirBtn.backgroundColor = [UIColor clearColor];
    dirBtn.tag = 11005;
    [infoView addSubview:dirBtn];
    
    // Recommend
    UIImage *recommendImg = [UIImage imageNamed:@"place_recommend.png"];
    UIButton *recommendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    recommendBtn.frame = CGRectMake(dirBtn.frame.origin.x+dirBtn.frame.size.width+1, 
                                    infoView.frame.size.height-5-BUTTON_HEIGHT*(2-numRow)-2, recommendImg.size.width, BUTTON_HEIGHT);
    [recommendBtn addTarget:self action:@selector(handleUserAction:) forControlEvents:UIControlEventTouchUpInside];
    [recommendBtn setImage:recommendImg forState:UIControlStateNormal];
    recommendBtn.backgroundColor = [UIColor clearColor];
    recommendBtn.tag = 11006;
    [infoView addSubview:recommendBtn];
    
    //
    numRow++;
    
    // Review
    UIImage *reviewImg = [UIImage imageNamed:@"place_review.png"];
    UIButton *reviewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    reviewBtn.frame = CGRectMake(5, infoView.frame.size.height-5-BUTTON_HEIGHT*(2-numRow), reviewImg.size.width, BUTTON_HEIGHT);
    [reviewBtn addTarget:self action:@selector(handleUserAction:) forControlEvents:UIControlEventTouchUpInside];
    [reviewBtn setImage:reviewImg forState:UIControlStateNormal];
    reviewBtn.backgroundColor = [UIColor clearColor];
    reviewBtn.tag = 11007;
    [infoView addSubview:reviewBtn];
    
    // Save place
    UIImage *saveImg = [UIImage imageNamed:@"place_save.png"];
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(reviewBtn.frame.origin.x+reviewBtn.frame.size.width+1, 
                               infoView.frame.size.height-5-BUTTON_HEIGHT*(2-numRow), saveImg.size.width, BUTTON_HEIGHT);
    [saveBtn addTarget:self action:@selector(handleUserAction:) forControlEvents:UIControlEventTouchUpInside];
    [saveBtn setImage:saveImg forState:UIControlStateNormal];
    saveBtn.backgroundColor = [UIColor clearColor];
    saveBtn.tag = 11008;
    [infoView addSubview:saveBtn];
    
    // Meet-up
    UIImage *meetupImg = [UIImage imageNamed:@"place_meetup.png"];
    UIButton *meetupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    meetupBtn.frame = CGRectMake(saveBtn.frame.origin.x+saveBtn.frame.size.width+1, 
                                 infoView.frame.size.height-5-BUTTON_HEIGHT*(2-numRow), meetupImg.size.width, BUTTON_HEIGHT);
    [meetupBtn addTarget:self action:@selector(handleUserAction:) forControlEvents:UIControlEventTouchUpInside];
    [meetupBtn setImage:meetupImg forState:UIControlStateNormal];
    meetupBtn.backgroundColor = [UIColor clearColor];
    meetupBtn.tag = 11009;
    [infoView addSubview:meetupBtn];
    
    // Chechkin
    UIImage *checkinImg = [UIImage imageNamed:@"place_checkin.png"];
    UIButton *checkinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    checkinBtn.frame = CGRectMake(meetupBtn.frame.origin.x+meetupBtn.frame.size.width+1, 
                                  infoView.frame.size.height-5-BUTTON_HEIGHT*(2-numRow), checkinImg.size.width, BUTTON_HEIGHT);
    [checkinBtn addTarget:self action:@selector(handleUserAction:) forControlEvents:UIControlEventTouchUpInside];
    [checkinBtn setImage:checkinImg forState:UIControlStateNormal];
    checkinBtn.backgroundColor = [UIColor clearColor];
    checkinBtn.tag = 11010;
    [infoView addSubview:checkinBtn];
    
    UIButton *btn = (UIButton*) [annoView viewWithTag:11001];
    btn.frame = CGRectMake(detFrame.size.width-24, 23, 23, 23);
    [btn setImage:[UIImage imageNamed: @"map_info_collapse.png"] forState:UIControlStateNormal];
    [annoView bringSubviewToFront:btn];
    
    return annoView;
}

- (MKAnnotationView*) getViewForState:(MAP_ANNOTATION_STATE)state loc:(LocationItem*) locItem{
    if (locItem.currDisplayState == MapAnnotationStateNormal) 
    {
        NSLog(@"normal state");
        return [self getViewForStateNormal:locItem];
    } else if (locItem.currDisplayState == MapAnnotationStateSummary)
    {
        NSLog(@"summary state");
        return [self getViewForStateSummary:locItem];
    }
    else
    {
        NSLog(@"detail state");
        return [self getViewForStateDetailed:locItem];
    }
}

// Button click events
- (void) handleUserAction:(id) sender {
    UIButton *btn = (UIButton*)sender ;
    int tag = btn.tag;
    MAP_USER_ACTION actionType;
    NSLog(@"MapAnnotationEvent: performUserAction, tag=%d", tag);
    
    switch (tag) {
        case 110003:
            actionType = MapAnnoUserActionEvent;
            break;
        case 11004:
            actionType = MapAnnoUserActionPlan;
            break;    
        case 11005:
            actionType = MapAnnoUserActionDirection;
            break;
        case 11006:
            actionType = MapAnnoUserActionRecommend;
            break;
        case 11007:
            actionType = MapAnnoUserActionReview;
            break;
        case 11008:
            actionType = MapAnnoUserActionSave;
            break;
        case 11009:
            actionType = MapAnnoUserActionMeetupPlace;
            break;
        case 11010:
            actionType = MapAnnoUserActionCheckin;
            break;
        default:
            return;
            break;
    }
    
    MKAnnotationView *selAnno = (MKAnnotationView*) [[sender superview] superview];
    LocationItem *locItem = (LocationItem*) [selAnno annotation];
    NSLog(@"Name=%@", locItem.itemName);
    
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(performUserAction:type:)]) {
        [self.delegate performUserAction:selAnno type:actionType];
    }
}

@end

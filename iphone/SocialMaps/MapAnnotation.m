//
//  MapAnnotation.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "MapAnnotation.h"
#import "LocationItemPeople.h"
#import "LocationItemPlace.h"
#import "UIImageView+roundedCorner.h"
#import "AppDelegate.h"

@implementation MapAnnotation
@synthesize currState;
@synthesize changeState;
@synthesize itemImage;
@synthesize annoView;
@synthesize delegate;

- (MKAnnotationView *)mapView:(MKMapView *)newMapView viewForAnnotation:(id <MKAnnotation>)newAnnotation item:(LocationItem*)locItem {
    NSString *reuseIdent = @"locAnno";
    if ([locItem isKindOfClass:[LocationItemPeople class]]) 
        reuseIdent = @"locAnnoPeople";
    else if ([locItem isKindOfClass:[LocationItemPlace class]]) 
        reuseIdent = @"locAnnoPlace";
    else
        reuseIdent = @"loggedInUser";
    annoView = [newMapView dequeueReusableAnnotationViewWithIdentifier:reuseIdent];
    if ( annoView == nil ) {
        NSLog(@"MapAnnotation:New MKAnnotationView");
        annoView = [ [ MKAnnotationView alloc ] initWithAnnotation:newAnnotation reuseIdentifier: reuseIdent ];
    }
    if ([newAnnotation isKindOfClass:[LocationItem class]]) {
        LocationItem *locItem = (LocationItem*) newAnnotation;
        return [self getViewForState:locItem.currDisplayState loc:locItem];
    } else {
        AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        CGRect imgFrame = CGRectMake(5, 5, ANNO_IMG_WIDTH, ANNO_IMG_HEIGHT);
        UIImageView *locImage = [UIImageView imageViewForMapAnnotation:imgFrame andImage:smAppDelegate.userAccountPrefs.icon withCornerradius:10.0f];
        [locImage setBorderColor:[UIColor blueColor]];
        locImage.tag = 11000;
        CGRect annoFrame = CGRectMake(0, 0, ANNO_IMG_WIDTH+12, ANNO_IMG_HEIGHT);
        annoView.frame = annoFrame;
        annoView.backgroundColor = [UIColor clearColor];
        [annoView.layer setCornerRadius:5.0f];
        [annoView.layer setMasksToBounds:YES];
        [annoView addSubview:locImage];
        [locImage release];
        return annoView;
    }
    return nil;
}

- (MKAnnotationView*) getViewForStateNormal:(LocationItem*) locItem {
    [[annoView viewWithTag:11000] removeFromSuperview];
    [[annoView viewWithTag:11001] removeFromSuperview];
    [[annoView viewWithTag:11002] removeFromSuperview];
    
    CGRect imgFrame = CGRectMake(5, 5, ANNO_IMG_WIDTH, ANNO_IMG_HEIGHT);
    UIImageView *locImage = [UIImageView imageViewForMapAnnotation:imgFrame andImage:locItem.itemIcon withCornerradius:10.0f];
    locImage.tag = 11000;
    CGRect annoFrame = CGRectMake(0, 0, ANNO_IMG_WIDTH+12, ANNO_IMG_HEIGHT);
    annoView.frame = annoFrame;
    annoView.backgroundColor = [UIColor clearColor];
    [annoView.layer setCornerRadius:5.0f];
    [annoView.layer setMasksToBounds:YES];
    [annoView addSubview:locImage];
    [locImage release];
    
    annoView.canShowCallout = NO;
    
    changeState = [UIButton buttonWithType:UIButtonTypeCustom];
    changeState.frame = CGRectMake(imgFrame.size.width-12, 23, 23, 23);
    [changeState addTarget:self action:@selector(changeStateClicked:) forControlEvents:UIControlEventTouchUpInside];
    [changeState setImage:[UIImage imageNamed:@"map_right_arrow.png"] forState:UIControlStateNormal];
    changeState.backgroundColor = [UIColor clearColor];
    changeState.tag = 11001;
    [annoView addSubview:changeState]; 
    annoView.centerOffset = CGPointMake(0.0, 0.0);
     
    return annoView;
}

- (MKAnnotationView*) getViewForStateSummary:(LocationItem*) locItem {
    annoView = [self getViewForStateNormal:locItem];
    CGRect annoFrame = CGRectMake(0, 0, 200, ANNO_IMG_HEIGHT);
    annoView.frame = annoFrame;

    CGRect infoFrame = CGRectMake(0, 0, 200-12, 51);
    UIView *infoView = [[UIView alloc] initWithFrame:infoFrame];
    infoView.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
    infoView.tag = 11002;
    [infoView.layer setCornerRadius:5.0f];
    [infoView.layer setMasksToBounds:YES];
    [infoView.layer setBorderWidth:1.0f];
    [infoView.layer setBorderColor:[UIColor lightGrayColor].CGColor];

    
    [annoView addSubview:infoView];
    [annoView sendSubviewToBack:infoView];
    
    UIButton *btn = (UIButton*) [annoView viewWithTag:11001];
    btn.frame = CGRectMake(annoFrame.size.width-24, 23, 23, 23);
    
    // For external users don't show details
    if ([locItem isKindOfClass:[LocationItemPeople class]]) {
        LocationItemPeople *locItemPeople = (LocationItemPeople*) locItem;
        if (locItemPeople.userInfo.external == false) 
            [btn setImage:[UIImage imageNamed: @"map_info_expand.png"] forState:UIControlStateNormal];
        else
            [btn setImage:[UIImage imageNamed: @"map_info_collapse.png"] forState:UIControlStateNormal];

    } else if ([locItem isKindOfClass:[LocationItemPlace class]]) {
        [btn setImage:[UIImage imageNamed: @"map_info_expand.png"] forState:UIControlStateNormal];
    }else {
        //locItem.currDisplayState = MapAnnotationStateNormal;
        [btn setImage:[UIImage imageNamed: @"map_info_collapse.png"] forState:UIControlStateNormal];
    }

    [annoView bringSubviewToFront:btn];
    CGPoint annoOffset = CGPointMake((200-(ANNO_IMG_WIDTH+12))/2, 0);
    annoView.centerOffset = annoOffset;
    
    return annoView;
}

- (MKAnnotationView*) getViewForStateDetailed:(LocationItem*) locItem {
    annoView = [self getViewForStateSummary:locItem];
    UIView *infoView = [annoView viewWithTag:11002];
    [infoView removeFromSuperview];
    
    UIImageView *imgView = (UIImageView*)[annoView viewWithTag:11000];
    imgView.frame = CGRectMake(8, 8, ANNO_IMG_WIDTH, ANNO_IMG_HEIGHT);
    
    CGRect annoFrame = CGRectMake(0, 0, 250, ANNO_IMG_HEIGHT+150);
    annoView.frame = annoFrame;
    
    CGRect infoFrame = CGRectMake(0, 0, 250-12, ANNO_IMG_HEIGHT+150);
    infoView = [[UIView alloc] initWithFrame:infoFrame];
    infoView.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0]; 
    infoView.tag = 11002;
    [infoView.layer setCornerRadius:5.0f];
    [infoView.layer setMasksToBounds:YES];
    [infoView.layer setBorderWidth:1.0f];
    [infoView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    
    [annoView addSubview:infoView];
    [annoView sendSubviewToBack:infoView];
    
    UIButton *btn = (UIButton*) [annoView viewWithTag:11001];
    btn.frame = CGRectMake(annoFrame.size.width-24, 23, 23, 23);
    [btn setImage:[UIImage imageNamed: @"map_info_collapse.png"] forState:UIControlStateNormal];
    [annoView bringSubviewToFront:btn];

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

- (void) changeStateClicked:(id) sender {
    NSLog(@"MapAnnotation: changeStateClicked");
    MKAnnotationView *selAnno = (MKAnnotationView*) [sender superview];
    LocationItem *locItem = (LocationItem*) [selAnno annotation];
    NSLog(@"changeStateClicked Name=%@", locItem.itemName);
    
    switch (locItem.currDisplayState) {
        case MapAnnotationStateNormal:
            locItem.currDisplayState = MapAnnotationStateSummary;
            break;
        case MapAnnotationStateSummary:
            // Don't show details for non-SM users
            if ([locItem isKindOfClass:[LocationItemPeople class]]) {
                LocationItemPeople *locItemPeople = (LocationItemPeople*) locItem;
                if (locItemPeople.userInfo.external == false) 
                    locItem.currDisplayState = MapAnnotationStateDetailed;
                else
                    locItem.currDisplayState = MapAnnotationStateNormal;
            } else if ([locItem isKindOfClass:[LocationItemPlace class]]) {
                locItem.currDisplayState = MapAnnotationStateDetailed;
            } else {
                locItem.currDisplayState = MapAnnotationStateNormal;
            }
            break;    
        case MapAnnotationStateDetailed:
            locItem.currDisplayState = MapAnnotationStateNormal;
            break;
        default:
            break;
    }
    selAnno.selected=TRUE;

    [selAnno setNeedsDisplay];
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(mapAnnotationChanged:)]) {
        [self.delegate mapAnnotationChanged:[selAnno annotation]];
    }
}

@end

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
#import "UIImageView+Cached.h"
#import "AppDelegate.h"
#import "MapAnnotationEvent.h"

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
    else if([locItem isKindOfClass:[LocationItem class]]) 
        reuseIdent = @"locAnnoPlace";
    else
        reuseIdent = @"loggedInUser";
    annoView = [newMapView dequeueReusableAnnotationViewWithIdentifier:reuseIdent];
    if ( annoView == nil ) {
        NSLog(@"MapAnnotation:New MKAnnotationView");
        annoView = [ [ MKAnnotationView alloc ] initWithAnnotation:newAnnotation reuseIdentifier: reuseIdent ];
    } else 
        [(UIImageView*)[annoView viewWithTag:12002] removeFromSuperview];
    
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
        
        return annoView;
    }
    return nil;
}

- (MKAnnotationView*) getViewForStateNormal:(LocationItem*) locItem {
    [[annoView viewWithTag:11000] removeFromSuperview];
    [[annoView viewWithTag:11001] removeFromSuperview];
    [[annoView viewWithTag:11002] removeFromSuperview];
    
    CGRect imgFrame = CGRectMake(0, 0, ANNO_IMG_WIDTH, ANNO_IMG_HEIGHT);
    
    UIImageView *locImage = [[UIImageView alloc] initWithFrame:imgFrame];
    UIImageView *locImageSquare ;
    if ([locItem isKindOfClass:[LocationItemPeople class]]) {
        locImage.image = [UIImage imageNamed:@"user_thumb_only.png"];
        locImageSquare = [[UIImageView alloc] initWithFrame:CGRectMake(2.5, 2, ANNO_IMG_WIDTH - 6, ANNO_IMG_WIDTH - 6)];
    }
    else
    {
        locImage.image = [UIImage imageNamed:@"user_thumb_only_gray.png"];
        locImageSquare = [[UIImageView alloc] initWithFrame:CGRectMake(2.5, 3, ANNO_IMG_WIDTH - 8, ANNO_IMG_WIDTH - 8)];
        
    }
    locImage.tag = 11000;
    
    [locImage addSubview:locImageSquare];
    //locImageSquare.image = locItem.itemIcon;
    ///////[locImageSquare loadFromURL:[NSURL URLWithString:locItem.itemAvaterURL]];
    [locImageSquare setImageForUrlIfAvailable:[NSURL URLWithString:locItem.itemAvaterURL]];
    [locImageSquare.layer setCornerRadius:4.0f];
    [locImageSquare.layer setMasksToBounds:YES];
    locImageSquare.tag = 110001;
    
    [locImageSquare release];
    
    CGRect annoFrame = CGRectMake(0, 0, ANNO_IMG_WIDTH+12, ANNO_IMG_HEIGHT);
    annoView.frame = annoFrame;
    annoView.backgroundColor = [UIColor clearColor];
    [annoView.layer setCornerRadius:5.0f];
    [annoView.layer setMasksToBounds:YES];
    [annoView addSubview:locImage];
    [locImage release];
    
    annoView.canShowCallout = NO;
    
    [(UIButton *)[annoView viewWithTag:1234321] removeTarget:self action:@selector(doNothing:) forControlEvents:UIControlEventTouchUpInside];
    [(UIButton *)[annoView viewWithTag:1234321] removeFromSuperview];
    
    changeState = [UIButton buttonWithType:UIButtonTypeCustom];
    changeState.frame = CGRectMake(imgFrame.size.width-14, 21, 26, 26);
    [changeState addTarget:self action:@selector(changeStateClicked:) forControlEvents:UIControlEventTouchUpInside];
    [changeState setImage:[UIImage imageNamed:@"map_right_arrow.png"] forState:UIControlStateNormal];
    changeState.backgroundColor = [UIColor clearColor];
    changeState.tag = 11001;
    [annoView addSubview:changeState]; 
    annoView.centerOffset = CGPointMake(0.0, 0.0);
    [[annoView viewWithTag:1234321] removeFromSuperview];
    return annoView;
}

-(void)doNothing:(id)sender
{
    NSLog(@"do nothing");
    [sender setNeedsDisplay];
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

    [[annoView viewWithTag:1234321] removeFromSuperview];
    UIButton *button= [[UIButton alloc] initWithFrame:annoView.frame];
    [button removeTarget:self action:@selector(doNothing:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(doNothing:) forControlEvents:UIControlEventTouchUpInside];
    button.tag=1234321;
    [annoView addSubview:button];
    [button release];
    
    [annoView addSubview:infoView];
    [annoView sendSubviewToBack:infoView];
    [infoView release];
    UIButton *btn = (UIButton*) [annoView viewWithTag:11001];
    btn.frame = CGRectMake(annoFrame.size.width-26, 21, 26, 26);
    
    // For external users don't show details
    if ([locItem isKindOfClass:[LocationItemPeople class]]) {
        LocationItemPeople *locItemPeople = (LocationItemPeople*) locItem;
        if (locItemPeople.userInfo.external == false) 
            [btn setImage:[UIImage imageNamed: @"map_info_expand.png"] forState:UIControlStateNormal];
        else
            [btn setImage:[UIImage imageNamed: @"map_info_collapse.png"] forState:UIControlStateNormal];

    } else if ([locItem isKindOfClass:[LocationItemPlace class]]) {
        // TODO: for appstore submission do not show detailed annotation
        [btn setImage:[UIImage imageNamed: @"map_info_expand.png"] forState:UIControlStateNormal];
    } else if ([locItem isKindOfClass:[LocationItem class]]) {
            // TODO: for appstore submission do not show detailed annotation
            [btn setImage:[UIImage imageNamed: @"map_info_collapse.png"] forState:UIControlStateNormal];
        }else{
        [btn setImage:[UIImage imageNamed: @"map_info_collapse.png"] forState:UIControlStateNormal];
    }

    [annoView bringSubviewToFront:btn];
    CGPoint annoOffset = CGPointMake((200-(ANNO_IMG_WIDTH+12))/2, 0);
    annoView.centerOffset = annoOffset;
    annoView.tag=12211221;
    return annoView;
}

- (MKAnnotationView*) getViewForStateDetailed:(LocationItem*) locItem {
    annoView = [self getViewForStateSummary:locItem];
    UIView *infoView = [annoView viewWithTag:11002];
    [infoView removeFromSuperview];
    
    
    UIImageView *imgView = (UIImageView*)[annoView viewWithTag:11000];
    imgView.frame = CGRectMake(8, 8, ANNO_IMG_WIDTH, ANNO_IMG_HEIGHT);
    
    // TODO: temporary change for appstore submission
    CGRect annoFrame = CGRectMake(0, 0, 250, ANNO_IMG_HEIGHT+150);
//    CGRect annoFrame = CGRectMake(0, 0, 250, ANNO_IMG_HEIGHT+100);
    annoView.frame = annoFrame;
    
    // TODO: temporary change for appstore submission
    CGRect infoFrame = CGRectMake(0, 0, 250-12, ANNO_IMG_HEIGHT+150);
    if ([locItem isKindOfClass:[LocationItemPeople class]])
    {
        LocationItemPeople *locItemPeople = (LocationItemPeople*) locItem;
        if ([locItemPeople.userInfo.source isEqualToString:@"facebook"])
        {
            infoFrame = CGRectMake(0, 0, 250-12, ANNO_IMG_HEIGHT+100);
        }
        else
        {
            infoFrame = CGRectMake(0, 0, 250-12, ANNO_IMG_HEIGHT+100);
            annoView.frame = CGRectMake(0, 0, 250, ANNO_IMG_HEIGHT+100);;
        }
    }
    infoView = [[UIView alloc] initWithFrame:infoFrame];
    infoView.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0]; 
    infoView.tag = 11002;
    [infoView.layer setCornerRadius:5.0f];
    [infoView.layer setMasksToBounds:YES];
    [infoView.layer setBorderWidth:1.0f];
    [infoView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [[annoView viewWithTag:1234321] removeFromSuperview];
    UIButton *button= [[UIButton alloc] initWithFrame:annoView.frame];
    [button removeTarget:self action:@selector(doNothing:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(doNothing:) forControlEvents:UIControlEventTouchUpInside];
    button.tag=1234321;
    button.frame=[annoView frame];
    [button release];
    [annoView addSubview:infoView];
    [annoView sendSubviewToBack:infoView];
    UIButton *btn = (UIButton*) [annoView viewWithTag:11001];
    btn.frame = CGRectMake(annoFrame.size.width-26, 23, 26, 26);
    [btn setImage:[UIImage imageNamed: @"map_info_collapse.png"] forState:UIControlStateNormal];
    [annoView bringSubviewToFront:btn];
    [btn bringSubviewToFront:annoView];
    NSLog(@"annoview: %@ %@",annoView,[annoView subviews]);
    annoView.tag=12211221;
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
            NSLog(@"goto summary state");
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
                // TODO: for appstore submission do not show detailed annotation
                locItem.currDisplayState = MapAnnotationStateDetailed;
            }
            else if ([locItem isKindOfClass:[LocationItem class]])
            {
                NSLog(@"event annotation");
                locItem.currDisplayState = MapAnnotationStateNormal;
            }
            else {
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
    
    NSLog(@"self.delegate %@",self.delegate);
    [selAnno setNeedsDisplay];
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(mapAnnotationChanged:)]) {
        [self.delegate mapAnnotationChanged:[selAnno annotation]];
    }    
}

- (void) changeStateToDetails:(id) anno {
    NSLog(@"MapAnnotation: changeStateToDetails");
    LocationItem *locItem = (LocationItem*)anno;
    
    NSLog(@"changeStateToDetails Name=%@", locItem.itemName);
    
    // Don't show details for non-SM users
    if ([locItem isKindOfClass:[LocationItemPeople class]]) {
        LocationItemPeople *locItemPeople = (LocationItemPeople*) locItem;
        if (locItemPeople.userInfo.external == false) 
            locItem.currDisplayState = MapAnnotationStateDetailed;
        else
            locItem.currDisplayState = MapAnnotationStateSummary;
    } else if ([locItem isKindOfClass:[LocationItemPlace class]]) {
        locItem.currDisplayState = MapAnnotationStateSummary;
    }
    else if ([locItem isKindOfClass:[LocationItem class]]) {
        locItem.currDisplayState = MapAnnotationStateSummary;
    }
}

- (void) changeStateToSummary:(id) anno 
{
    NSLog(@"MapAnnotation: changeStateToSummary");
    LocationItem *locItem = (LocationItem*)anno;
    locItem.currDisplayState = MapAnnotationStateSummary;
}

- (void) changeStateToNormal:(id) anno
{
    LocationItem *locItem = (LocationItem*)anno;
    locItem.currDisplayState = MapAnnotationStateNormal;
}

@end

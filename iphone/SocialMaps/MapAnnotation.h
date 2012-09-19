//
//  MapAnnotation.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import "LocationItem.h"

#define ANNO_IMG_WIDTH  53
#define ANNO_IMG_HEIGHT 63
typedef enum _MAP_USER_ACTION {
    MapAnnoUserActionAddFriend=0,
    MapAnnoUserActionMeetup,
    MapAnnoUserActionDirection,
    MapAnnoUserActionMessage,
    MapAnnoUserActionEvent,
    MapAnnoUserActionPlan,
    MapAnnoUserActionDirectionPlace,
    MapAnnoUserActionRecommend,
    MapAnnoUserActionReview,
    MapAnnoUserActionSave,
    MapAnnoUserActionMeetupPlace,
    MapAnnoUserActionCheckin,
    MapAnnoUserActionGeotag
} MAP_USER_ACTION;

@protocol MapAnnotationDelegate <NSObject>
- (void) performUserAction:(MKAnnotationView*)annoView type:(MAP_USER_ACTION) actionType;
- (void) mapAnnotationChanged:(id <MKAnnotation>) anno;
@end

@interface MapAnnotation : NSObject {
    MKAnnotationView        *annoView;
    MAP_ANNOTATION_STATE    currState;
    UIImage                 *itemImage;
    UIButton                *changeState;
    id<MapAnnotationDelegate>    delegate;
}
@property (assign) MAP_ANNOTATION_STATE currState;
@property (nonatomic, retain) UIImage *itemImage;
@property (nonatomic, retain) UIButton *changeState;
@property (nonatomic, retain) MKAnnotationView *annoView;
@property (nonatomic,assign) id<MapAnnotationDelegate>    delegate;

- (void) changeStateClicked:(id) sender;
- (void) changeStateClicked2:(id) sender;
- (MKAnnotationView*) getViewForStateNormal:(LocationItem*) locItem;
- (MKAnnotationView*) getViewForStateSummary:(LocationItem*) locItem;
- (MKAnnotationView*) getViewForStateDetailed:(LocationItem*) locItem;
- (MKAnnotationView*) getViewForState:(MAP_ANNOTATION_STATE)state loc:(LocationItem*)loc;
- (MKAnnotationView *)mapView:(MKMapView *)newMapView viewForAnnotation:(id <MKAnnotation>)newAnnotation item:(LocationItem*)locItem;
@end

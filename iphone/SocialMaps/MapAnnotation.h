//
//  MapAnnotation.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file MapAnnotation.h
 * @brief Creates map annotation for people place, geotag and event.
 */

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
    MapAnnoUserActionGeotag,
    MapAnnoUserActionProfile,
    MapAnnoUserActionCreateEvent
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

/**
 * @brief Change state of annotation
 * @param (id) - Action sender
 * @retval none
 */
- (void) changeStateClicked:(id) sender;

/**
 * @brief Change annotation state to detail state
 * @param (id) - Annotation
 * @retval none
 */
- (void) changeStateToDetails:(id) anno;

/**
 * @brief Change annotation state to normal state
 * @param (id) - Annotation
 * @retval none
 */
- (void) changeStateToNormal:(id) anno;

/**
 * @brief Change annotation state to summary state
 * @param (id) - Annotation
 * @retval none
 */
- (void) changeStateToSummary:(id) anno;

/**
 * @brief Get annotation view for normal state
 * @param (LocationItem) - Location item map annotation
 * @retval (MKAnnotationView) - Annotation view
 */
- (MKAnnotationView*) getViewForStateNormal:(LocationItem*) locItem;

/**
 * @brief Get annotation view for summary view
 * @param (LocationItem) - Location item map annotation
 * @retval (MKAnnotationView) - Annotation view
 */
- (MKAnnotationView*) getViewForStateSummary:(LocationItem*) locItem;

/**
 * @brief Get annotation view for detail state
 * @param (LocationItem) - Location item map annotation
 * @retval (MKAnnotationView) - Annotation view
 */
- (MKAnnotationView*) getViewForStateDetailed:(LocationItem*) locItem;

/**
 * @brief Get annotation view for a desire state
 * @param (MAP_ANNOTATION_STATE) - Desired state
 * @param (LocationItem) - Location item map annotation
 * @retval (MKAnnotationView) - Annotation view
 */
- (MKAnnotationView*) getViewForState:(MAP_ANNOTATION_STATE)state loc:(LocationItem*)loc;

/**
 * @brief Get view for annotation
 * @param (MKMapView) - Map view
 * @param (MKAnnotation) - Map annotation
 * @param (LocationItem) - Location item
 * @retval (MKAnnotationView) - Annotation view
 */
- (MKAnnotationView *)mapView:(MKMapView *)newMapView viewForAnnotation:(id <MKAnnotation>)newAnnotation item:(LocationItem*)locItem;

@end

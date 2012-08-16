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

@protocol MapAnnotationDelegate <NSObject>

- (void) mapAnnotationChanged:(id <MKAnnotation>)anno;
- (void) addFriendSelected:(id <MKAnnotation>)anno;
- (void) meetupRequestSelected:(id <MKAnnotation>)anno;
- (void) directionSelected:(id <MKAnnotation>)anno;
- (void) messageSelected:(id <MKAnnotation>)anno;

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
- (MKAnnotationView*) getViewForStateNormal:(LocationItem*) locItem;
- (MKAnnotationView*) getViewForStateSummary:(LocationItem*) locItem;
- (MKAnnotationView*) getViewForStateDetailed:(LocationItem*) locItem;
- (MKAnnotationView*) getViewForState:(MAP_ANNOTATION_STATE)state loc:(LocationItem*)loc;
- (MKAnnotationView *)mapView:(MKMapView *)newMapView viewForAnnotation:(id <MKAnnotation>)newAnnotation item:(LocationItem*)locItem;
@end

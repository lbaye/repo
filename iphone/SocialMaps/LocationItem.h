//
//  LocationItems.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/13/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

//#import "ListViewController.h"
@class ListViewController;

typedef enum _OBJECT_TYPES {
    ObjectTypePeople = 0,
    ObjectTypePlace,
    ObjectTypeDeal
} OBJECT_TYPES;

typedef enum _MAP_ANNOTATION_STATE {
    MapAnnotationStateNormal = 0,
    MapAnnotationStateSummary,
    MapAnnotationStateDetailed
} MAP_ANNOTATION_STATE;

@interface LocationItem : NSObject <MKAnnotation> {
    NSString *itemName;
    NSString *itemAddress;
    OBJECT_TYPES itemType;
    NSString    *itemCategory;
    CLLocationCoordinate2D coordinate;
    float       itemDistance;
    UIImage     *itemIcon;
    UIImage     *itemBg;
    NSString    *cellIdent;
    MAP_ANNOTATION_STATE currDisplayState;
}

@property (copy) NSString *itemName;
@property (copy) NSString *itemAddress;
@property (copy) NSString *itemCategory;
@property (nonatomic) OBJECT_TYPES itemType;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic) float itemDistance;
@property (nonatomic, retain) UIImage *itemIcon;
@property (nonatomic, retain) UIImage *itemBg;
@property (nonatomic, retain) NSString *cellIdent;
@property (nonatomic) MAP_ANNOTATION_STATE currDisplayState;

- (id)initWithName:(NSString*)name address:(NSString*)address type:(OBJECT_TYPES)type
          category:(NSString*)category coordinate:(CLLocationCoordinate2D)coordinate dist:(float)dist icon:(UIImage*)icon bg:(UIImage*)bg;
- (NSComparisonResult) compareDistance:(LocationItem*) other;
- (UITableViewCell*) getTableViewCell:(UITableView*)tv sender:(ListViewController*)controller;
- (CGFloat) getRowHeight:(UITableView*)tv;

@end

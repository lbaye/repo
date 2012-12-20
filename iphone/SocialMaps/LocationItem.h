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

typedef enum _LOCATION_ACTION_TYPE {
    LocationActionTypePlaceReview=0,
    LocationActionTypeGotoMap
}LOCATION_ACTION_TYPE;

@protocol LocationItemDelegate<NSObject>
- (void) buttonClicked:(LOCATION_ACTION_TYPE)action row:(int)row;
@end

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
    id<LocationItemDelegate> delegate;
    NSString *typeName;
    NSURL   *itemCoverPhotoUrl;
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
@property (assign) id<LocationItemDelegate> delegate;
@property (nonatomic,retain)    NSString *typeName;
@property (nonatomic, retain) NSURL *itemCoverPhotoUrl;

/**
 * @brief Initialize location item object
 * @param (NSString) - Item name
 * @param (NSString) - Item address
 * @param (OBJECT_TYPES) - Item object type
 * @param (NSString) - Item category
 * @param (CLLocationCoordinate2D) - Item position coordinate
 * @param (float) - Item distance
 * @param (UIImage) - Item icon
 * @param (UIImage) - Item image
 * @param (NSURL) - Item cover photo url
 * @retval (id) - Location item object
 */
- (id)initWithName:(NSString*)name address:(NSString*)address type:(OBJECT_TYPES)type
          category:(NSString*)category coordinate:(CLLocationCoordinate2D)coord dist:(float)dist icon:(UIImage*)icon bg:(UIImage*)bg itemCoverPhotoUrl:(NSURL*)_coverPhotoUrl;

/**
 * @brief Compare distance with other location item object
 * @param (LocationItem) - Another location item object
 * @retval (NSComparisonResult) - Comparison result
 */
- (NSComparisonResult) compareDistance:(LocationItem*) other;

/**
 * @brief Get location item table cell
 * @param (UITableView) - Parent trable view for table cell
 * @param (ListViewController) - Sender view controller
 * @retval (UITableViewCell) - Table cell with location item
 */
- (UITableViewCell*) getTableViewCell:(UITableView*)tv sender:(ListViewController*)controller;

/**
 * @brief Get row height of table view
 * @param (UITableView) - Parent table view
 * @retval (CGFloat) - Table cell height
 */
- (CGFloat) getRowHeight:(UITableView*)tv;

/**
 * @brief Show location item on map view
 * @param (id) - Action sender
 * @retval none
 */
- (void) showInMapview:(id)sender;

@end

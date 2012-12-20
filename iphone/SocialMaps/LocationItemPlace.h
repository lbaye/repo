//
//  LocationItemPlace.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/14/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "LocationItem.h"
#import "Places.h"

@interface LocationItemPlace : LocationItem {
    UIImageView     *catIcon;
    UIButton        *showReview;
    Places          *placeInfo;
}
@property (nonatomic, retain) UIImageView *catIcon;
@property (nonatomic, retain) UIButton *showReview;
@property (nonatomic, retain) Places *placeInfo;

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
          category:(NSString*)category coordinate:(CLLocationCoordinate2D)coordinate dist:(float)dist icon:(UIImage*)icon bg:(UIImage*)bg itemCoverPhotoUrl:(NSURL*)_coverPhotoUrl;

/**
 * @brief Get icon for category
 * @param (NSString) - Icon category
 * @retval (UIImage) - Icon for category
 */
+ (UIImage*) getIconForCategory:(NSString*)cat;
@end

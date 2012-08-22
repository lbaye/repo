//
//  LocationItemPlace.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/14/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "LocationItem.h"
#import "Places.h"

@protocol LocationItemPlaceDelegate<NSObject>
- (void) showLocationReview:(int)row;
@end

@interface LocationItemPlace : LocationItem {
    UIImageView     *catIcon;
    UIButton        *showReview;
    id<LocationItemPlaceDelegate> delegate;
    Places          *placeInfo;
}
@property (nonatomic, retain) UIImageView *catIcon;
@property (nonatomic, retain) UIButton *showReview;
@property (assign) id<LocationItemPlaceDelegate> delegate;
@property (nonatomic, retain) Places *placeInfo;

- (id)initWithName:(NSString*)name address:(NSString*)address type:(OBJECT_TYPES)type
          category:(NSString*)category coordinate:(CLLocationCoordinate2D)coordinate dist:(float)dist icon:(UIImage*)icon bg:(UIImage*)bg;
@end

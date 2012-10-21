//
//  NewLocationItem.h
//  SocialMaps
//
//  Created by Arif Shakoor on 10/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Geofence.h"

#define TEXTAREA_WIDTH 180
#define TEXTAREA_HEIGHT 35

@protocol NewLocationItemDelegate <NSObject>

- (void) newLocationCreated:(Geofence*)loc sender:(id)sender;

@end

@interface NewLocationItem : UIView <UITextFieldDelegate> {
    NSString    *titleString;
    NSString    *locationName;
    UILabel     *lblTitle;
    UITextField  *txtName;
    MKMapView   *locMap;
    int            btnTag;
    id              parent;
    CLLocationCoordinate2D locCoord;
    UILabel     *lblAddress;
    id<NewLocationItemDelegate> delegate;
}

@property (nonatomic, retain) NSString    *titleString;
@property (nonatomic, retain) NSString    *locationName;
@property (nonatomic, retain) UILabel     *lblTitle;
@property (nonatomic, retain) UITextField  *txtName;
@property (nonatomic, retain) MKMapView   *locMap;
@property (nonatomic) int btnTag;
@property (nonatomic, retain) id parent;
@property (nonatomic) CLLocationCoordinate2D locCoord;
@property (nonatomic, retain) UILabel     *lblAddress;
@property (nonatomic, retain) id<NewLocationItemDelegate> delegate;

- (id)initWithFrame:(CGRect)frame title:(NSString*)titleStr sender:(id) sender tag:(int)tag;
- (void) getAddress;

@end

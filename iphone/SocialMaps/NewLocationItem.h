//
//  NewLocationItem.h
//  SocialMaps
//
//  Created by Arif Shakoor on 10/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#define TEXTAREA_WIDTH 180
#define TEXTAREA_HEIGHT 40

@interface NewLocationItem : UIView <UITextFieldDelegate> {
    NSString    *titleString;
    NSString    *locationName;
    UILabel     *lblTitle;
    UITextField  *txtName;
    MKMapView   *locMap;
    int            btnTag;
    id              parent;
    CLLocationCoordinate2D locCoord;
}
@property (nonatomic, retain) NSString    *titleString;
@property (nonatomic, retain) NSString    *locationName;
@property (nonatomic, retain) UILabel     *lblTitle;
@property (nonatomic, retain) UITextField  *txtName;
@property (nonatomic, retain) MKMapView   *locMap;
@property (nonatomic) int btnTag;
@property (nonatomic, retain) id parent;
@property (nonatomic) CLLocationCoordinate2D locCoord;

- (id)initWithFrame:(CGRect)frame title:(NSString*)titleStr sender:(id) sender tag:(int)tag;

@end

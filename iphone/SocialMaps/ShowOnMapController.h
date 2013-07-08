//
//  ShowOnMapController.h
//  SocialMaps
//
//  Created by Warif Rishi on 9/8/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mapkit/Mapkit.h>
#import "Geolocation.h"

@interface ShowOnMapController : UIViewController {

    CLLocationCoordinate2D theCoordinate;
}


@property (retain, nonatomic) IBOutlet MKMapView *mapViewLoacation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andLocation:(CLLocationCoordinate2D)coordinate;
- (IBAction)actionBackButton:(id)sender;

@end

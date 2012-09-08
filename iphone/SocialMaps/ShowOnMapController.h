//
//  ShowOnMapController.h
//  SocialMaps
//
//  Created by Warif Rishi on 9/8/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mapkit/Mapkit.h>

@class LocationItem;

@interface ShowOnMapController : UIViewController {
    LocationItem  *locationItem;
}


@property (retain, nonatomic) IBOutlet MKMapView *mapViewLoacation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andLocation:(LocationItem*)locItem;
- (IBAction)actionBackButton:(id)sender;

@end

//
//  DirectionViewController.h
//  SocialMaps
//
//  Created by Warif Rishi on 10/29/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomRadioButton.h"
#import <Mapkit/Mapkit.h>

@class DDAnnotation;
@class AppDelegate;

@interface DirectionViewController : UIViewController <CustomRadioButtonDelegate, UITableViewDataSource, UITableViewDelegate>
{    
    IBOutlet    UIScrollView   *scrollViewMain;
    IBOutlet    UIScrollView   *scrollViewTransport;
    IBOutlet    UILabel        *labelAddressTo;
    IBOutlet    UILabel        *labelAddressFrom;
    IBOutlet    UILabel        *totalNotifCount;
    IBOutlet    UITableView    *tableViewPlacesFrom;
    IBOutlet    UITableView    *tableViewPlacesTo;
    IBOutlet    MKMapView      *pointOnMapViewFrom;
    IBOutlet    MKMapView      *pointOnMapViewTo;
    
    DDAnnotation    *annotationFrom;
    DDAnnotation    *annotationTo;
    AppDelegate     *smAppDelegate;
    NSMutableArray  *myPlacesArray;
    int             selectedPlaceIndexFrom;
    int             selectedPlaceIndexTo;
    int             transportMode;
}

@property (nonatomic, retain) NSString *currentAddress;
@property (nonatomic, assign) CLLocationCoordinate2D coordinateTo;

- (void)displayNotificationCount; 
- (IBAction)actionBackMe:(id)sender;
- (IBAction)gotoNotification:(id)sender;
- (IBAction)actionCancelButton:(id)sender;
- (IBAction)actionOkButton:(id)sender;
- (void)setAddressLabelFromLatLon:(DDAnnotation*)annotation;

@end

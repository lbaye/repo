//
//  DirectionViewController.h
//  SocialMaps
//
//  Created by Warif Rishi on 10/29/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file DirectionViewController.h
 * @brief Create direction from source to destinatin coordinate. Close socilamaps and open map app installed in device.
 */

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

/**
 * @brief Display total notification count
 * @param none
 * @retval none
 */
- (void)displayNotificationCount; 

/**
 * @brief Navigate user to previous screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionBackMe:(id)sender;

/**
 * @brief Navigate to notificaiton screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoNotification:(id)sender;

/**
 * @brief Cancel button pressed and goto previous screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionCancelButton:(id)sender;

/**
 * @brief Ok button pressed, close socialmaps and open map app installed on device
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionOkButton:(id)sender;

/**
 * @brief Set address from latitude and longitude
 * @param (DDAnnotation) - Annotation for which address is required
 * @retval none
 */
- (void)setAddressLabelFromLatLon:(DDAnnotation*)annotation;

@end

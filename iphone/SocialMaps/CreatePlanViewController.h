//
//  CreatePlanViewController.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 11/19/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Plan.h"
#import "CustomRadioButton.h"
#import <Mapkit/Mapkit.h>

@interface CreatePlanViewController : UIViewController<CustomRadioButtonDelegate>
{
    IBOutlet UITextView *descriptionTextView;
    IBOutlet UILabel *addressLabel;
    IBOutlet UILabel *dateLabel;
    IBOutlet UIButton *dateButton;
    IBOutlet UIView *customView;
    IBOutlet MKMapView *mapView;
    IBOutlet UIView *mapContainerView;
    BOOL isDragging_msg;
    BOOL isDecliring_msg;
    IBOutlet UITableView *circleTableView;
    IBOutlet UIScrollView *frndsScrollView;
    IBOutlet UISegmentedControl *segmentControl;
    IBOutlet UISearchBar *friendSearchbar;
    IBOutlet UILabel *totalNotifCount;
    Plan *plan;
    NSString *planEditFlag;
    NSIndexPath *editIndexPath;
    IBOutlet UILabel *titleLabel;
    IBOutlet UIButton *saveButton;    
}

@property(nonatomic,strong) NSString *planEditFlag;
@property(nonatomic,retain) IBOutlet MKMapView *mapView;
@property(nonatomic,retain) IBOutlet UIView *customView;
@property(nonatomic,retain) IBOutlet UILabel *addressLabel;
@property(nonatomic,retain) IBOutlet UITextView *descriptionTextView;
@property(nonatomic,retain) IBOutlet UILabel *dateLabel;
@property(nonatomic,retain) IBOutlet UIButton *dateButton;
@property(nonatomic,retain) IBOutlet UIView *mapContainerView;
@property(nonatomic,retain) IBOutlet UITableView *circleTableView;
@property(nonatomic,retain) IBOutlet UIScrollView *frndsScrollView;
@property(nonatomic,retain) IBOutlet UISegmentedControl *segmentControl;
@property(nonatomic,retain) IBOutlet UISearchBar *friendSearchbar;
@property(nonatomic,retain) Plan *plan;
@property(nonatomic,retain) IBOutlet UILabel *totalNotifCount;
@property(nonatomic,retain) NSIndexPath *editIndexPath;
@property(nonatomic,retain) IBOutlet UILabel *titleLabel;
@property(nonatomic,retain) IBOutlet UIButton *saveButton;    

/**
 * @brief create a plan
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)savePlan:(id)sender;

/**
 * @brief Cancel plan and navigate user to previous screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)cancelPlan:(id)sender;

/**
 * @brief Prompt user to select plan date
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)selecDate:(id)sender;

/**
 * @brief Navigate user to previous screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)back:(id)sender;

/**
 * @brief Save plan location on map
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)saveMapLocation:(id)sender;

/**
 * @brief Cancel plan location selection option
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)cancelMapLocation:(id)sender;

/**
 * @brief Change segment for friends or circle selection
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)segmentChanged:(id)sender;

/**
 * @brief Navigate user to notification screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoNotification:(id)sender;

/**
 * @brief Notify user whether plan updated successfully or not
 * @param (NSNotification) - Notification object
 * @retval action
 */
- (void)updatePlanDone:(NSNotification *)notif;

/**
 * @brief Notify user whether plan created successfully or not
 * @param (NSNotification) - Notification object
 * @retval action
 */
- (void)createPlanDone:(NSNotification *)notif;

@end

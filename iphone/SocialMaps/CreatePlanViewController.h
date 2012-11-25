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


-(IBAction)savePlan:(id)sender;
-(IBAction)cancelPlan:(id)sender;
-(IBAction)selecDate:(id)sender;
-(IBAction)back:(id)sender;
-(IBAction)saveMapLocation:(id)sender;
-(IBAction)cancelMapLocation:(id)sender;
-(IBAction)segmentChanged:(id)sender;
-(IBAction)gotoNotification:(id)sender;
- (void)updatePlanDone:(NSNotification *)notif;
- (void)createPlanDone:(NSNotification *)notif;

@end

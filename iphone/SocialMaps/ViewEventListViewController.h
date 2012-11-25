//
//  ViewEventListViewController.h
//  Event
//
//  Created by Abdullah Md. Zubair on 8/24/12.
//  Copyright (c) 2012 Genweb2 Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mapkit/Mapkit.h>
#import "EventImageDownloader.h"
#import "CustomRadioButton.h"

@interface ViewEventListViewController : UIViewController<EventImageDownloaderDelegate,CustomRadioButtonDelegate>
{
    IBOutlet UITableView *eventListTableView;
    IBOutlet UISearchBar *eventSearchBar;
    bool rsvpFlag;
    IBOutlet NSDictionary *downloadedImageDict;
    IBOutlet NSMutableDictionary *dicIcondownloaderEvents;
    IBOutlet UIView *mapContainer;
    IBOutlet MKMapView *mapView;
    IBOutlet UIButton *newEventButton;
    
    IBOutlet UIButton *dateButton;
    IBOutlet UIButton *distanceButton;
    IBOutlet UIButton *friendsEventButton;
    IBOutlet UIButton *myEventButton;
    IBOutlet UIButton *publicEventButton;
    IBOutlet UILabel *totalNotifCount;

}
@property(nonatomic,retain) IBOutlet UITableView *eventListTableView;
@property(nonatomic,retain) IBOutlet UISearchBar *eventSearchBar;
@property(nonatomic,retain) IBOutlet NSDictionary *downloadedImageDict;
@property(nonatomic,retain) IBOutlet NSMutableDictionary *dicIcondownloaderEvents;
@property(nonatomic,retain) IBOutlet UIView *mapContainer;
@property(nonatomic,retain) IBOutlet MKMapView *mapView;
@property(nonatomic,retain) IBOutlet UIButton *newEventButton;

@property(nonatomic,retain) IBOutlet UIButton *dateButton;
@property(nonatomic,retain) IBOutlet UIButton *distanceButton;
@property(nonatomic,retain) IBOutlet UIButton *friendsEventButton;
@property(nonatomic,retain) IBOutlet UIButton *myEventButton;
@property(nonatomic,retain) IBOutlet UIButton *publicEventButton;
@property(nonatomic,retain) IBOutlet UILabel *totalNotifCount;


-(IBAction)dateAction:(id)sender;
-(IBAction)distanceAction:(id)sender;
-(IBAction)friendsEventAction:(id)sender;
-(IBAction)myEventAction:(id)sender;
-(IBAction)publicEventAction:(id)sender;
-(IBAction)newEventAction:(id)sender;

-(IBAction)yesButton:(id)sender;
-(IBAction)noButton:(id)sender;
-(IBAction)maybeButton:(id)sender;
-(IBAction)viewLocationButton:(id)sender;

-(IBAction)closeMapView:(id)sender;
-(IBAction)backButton:(id)sender;
-(NSMutableArray *)loadDummyData;
- (void)appImageDidLoad:(NSString *)eventID;
-(IBAction)gotoNotification:(id)sender;

@end

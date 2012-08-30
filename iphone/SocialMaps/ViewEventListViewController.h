//
//  ViewEventListViewController.h
//  Event
//
//  Created by Abdullah Md. Zubair on 8/24/12.
//  Copyright (c) 2012 Genweb2 Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewEventListViewController : UIViewController
{
    IBOutlet UITableView *eventListTableView;
    IBOutlet UISearchBar *eventSearchBar;
    bool rsvpFlag;
    IBOutlet NSDictionary *downloadedImageDict;
}
@property(nonatomic,retain) IBOutlet UITableView *eventListTableView;
@property(nonatomic,retain) IBOutlet UISearchBar *eventSearchBar;
@property(nonatomic,retain) IBOutlet NSDictionary *downloadedImageDict;

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

-(NSMutableArray *)loadDummyData;

@end

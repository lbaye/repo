//
//  ViewCircleListViewController.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 9/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewCircleListViewController : UIViewController
{
    IBOutlet UITableView *circleListTableView;
    IBOutlet UISearchBar *circleSearchBar;
    NSDictionary *downloadedImageDict;
    IBOutlet UIView *msgView;
    IBOutlet UITextView *textViewNewMsg;
    IBOutlet UILabel *labelNotifCount;
}

@property(nonatomic,retain) IBOutlet UITableView *circleListTableView;
@property(nonatomic,retain) IBOutlet UISearchBar *circleSearchBar;
@property(nonatomic,retain) NSDictionary *downloadedImageDict;
@property (retain, nonatomic) IBOutlet UIView *listPulldownMenu;
@property (retain, nonatomic) IBOutlet UIButton *listPulldown;
@property (retain, nonatomic) IBOutlet UIView *listViewfilter;
@property (nonatomic,retain)  IBOutlet UIView *msgView;
@property (nonatomic,retain) IBOutlet UITextView *textViewNewMsg;

-(IBAction)gotoTabBar:(id)sender;
-(IBAction)gotoInvites:(id)sender;
-(IBAction)gotoCircles:(id)sender;
-(IBAction)gotoBlockUnBlock:(id)sender;
-(IBAction)sendMsg:(id)sender;
-(IBAction)cancelMsg:(id)sender;
- (IBAction)actionNotificationButton:(id)sender;
-(IBAction)showSearch:(id)sender;

@end

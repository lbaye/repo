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
}

@property(nonatomic,retain) IBOutlet UITableView *circleListTableView;
@property(nonatomic,retain) IBOutlet UISearchBar *circleSearchBar;
@property(nonatomic,retain) NSDictionary *downloadedImageDict;

-(IBAction)gotoTabBar:(id)sender;

@end

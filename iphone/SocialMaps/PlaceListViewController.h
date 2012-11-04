//
//  PlaceListViewController.h
//  SocialMaps
//
//  Created by Warif Rishi on 11/3/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface PlaceListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    IBOutlet    UITableView *tableViewPlaceList;
    
    NSMutableArray      *placeList;
    AppDelegate         *smAppDelegate;
}

- (IBAction)actionBackMe:(id)sender;

@end

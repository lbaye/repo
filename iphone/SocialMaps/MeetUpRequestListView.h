//
//  MeetUpRequestListView.h
//  SocialMaps
//
//  Created by Warif Rishi on 9/12/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file MeetUpRequestListView.h
 * @brief Show list of meetup requests for own user.
 */

#import <UIKit/UIKit.h>
#import "MeetUpListButtonsView.h"
#import "IconDownloader.h"

@interface MeetUpRequestListView : UIView <UITableViewDelegate, UITableViewDataSource, MeetUpListButtonsDelegate, IconDownloaderDelegate>{
    
    NSMutableArray *meetUpRequestList;
    UIViewController *parentViewController;
    IBOutlet UITableView *tableViewMeetUps;
    NSMutableDictionary *imageDownloadsInProgress;
}

/**
 * @brief Initialize view
 * @param (CGrect) - Frame for view
 * @param (UIViewController) - Parent view controller of the view
 * @retval self
 */
- (id)initWithFrame:(CGRect)frame andParentControllder:(UIViewController*)controller;


@end

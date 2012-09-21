//
//  MeetUpRequestListView.h
//  SocialMaps
//
//  Created by Warif Rishi on 9/12/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeetUpListButtonsView.h"
#import "IconDownloader.h"

@interface MeetUpRequestListView : UIView <UITableViewDelegate, UITableViewDataSource, MeetUpListButtonsDelegate, IconDownloaderDelegate>{
    
    NSMutableArray *meetUpRequestList;
    UIViewController *parentViewController;
    //int selectedRow;
    IBOutlet UITableView *tableViewMeetUps;
    NSMutableDictionary *imageDownloadsInProgress;
}

- (id)initWithFrame:(CGRect)frame andParentControllder:(UIViewController*)controller;


@end

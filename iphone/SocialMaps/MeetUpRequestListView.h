//
//  MeetUpRequestListView.h
//  SocialMaps
//
//  Created by Warif Rishi on 9/12/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeetUpListButtonsView.h"

@interface MeetUpRequestListView : UIView <UITableViewDelegate, UITableViewDataSource, MeetUpListButtonsDelegate>{
    
    NSMutableArray *meetUpRequestList;
    UIViewController *parentViewController;
    //int selectedRow;
    IBOutlet UITableView *tableViewMeetUps;
}

- (id)initWithFrame:(CGRect)frame andParentControllder:(UIViewController*)controller;


@end

//
//  FriendListViewController.h
//  SocialMaps
//
//  Created by Warif Rishi on 9/19/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _FILTER_BY {
    AtoZ = 0,
    Distance,
    Circle
} FILTER_BY;

@class EachFriendInList;

@interface FriendListViewController : UIViewController {
    
    IBOutlet UIScrollView *scrollViewFriendList;
    IBOutlet UISearchBar  *searchBarFriendList;
    
    NSMutableArray *eachFriendList;
    NSMutableArray *circleList;
    NSMutableArray *filteredList;
    
}

- (IBAction)actionBackMe:(id)sender;

@end

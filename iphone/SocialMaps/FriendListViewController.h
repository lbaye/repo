//
//  FriendListViewController.h
//  SocialMaps
//
//  Created by Warif Rishi on 9/19/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendListViewController : UIViewController {
    
    IBOutlet UIScrollView *scrollViewFriendList;
    NSMutableArray *friendList;
    
}
- (IBAction)actionBackMe:(id)sender;

@end

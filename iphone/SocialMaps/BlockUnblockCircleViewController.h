//
//  BlockUnblockCircleViewController.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 9/20/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlockUnblockCircleViewController : UIViewController
{
    IBOutlet UITableView *blockTableView;
    IBOutlet UISearchBar *circleSearchBar;
    NSDictionary *downloadedImageDict;
}

@property(nonatomic,retain) IBOutlet UITableView *blockTableView;
@property(nonatomic,retain) IBOutlet UISearchBar *circleSearchBar;
@property(nonatomic,retain) NSDictionary *downloadedImageDict;
@end

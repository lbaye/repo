//
//  NewsFeedViewController.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 11/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsFeedViewController : UIViewController
{
    IBOutlet UIWebView *newsFeedView;
    IBOutlet UILabel *totalNotifCount;
    IBOutlet UIScrollView *newsFeedScroller;
}
@property(nonatomic,retain) IBOutlet UIWebView *newsFeedView;
@property(nonatomic,retain) IBOutlet UILabel *totalNotifCount;
@property(nonatomic,retain) IBOutlet UIScrollView *newsFeedScroller;

-(IBAction)backButton:(id)sender;
-(IBAction)gotoNotification:(id)sender;

@end

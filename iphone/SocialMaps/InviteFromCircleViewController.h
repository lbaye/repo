//
//  InviteFromCircleViewController.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 9/30/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InviteFromCircleViewController : UIViewController
{
    IBOutlet UITableView *inviteTableView;
    IBOutlet UISearchBar *inviteSearchBar;
    NSDictionary *downloadedImageDict;
    IBOutlet UIView *msgView;
    IBOutlet UITextView *textViewNewMsg;

    IBOutlet UILabel *labelNotifCount;
}

@property(nonatomic,retain) IBOutlet UITableView *inviteTableView;
@property(nonatomic,retain) IBOutlet UISearchBar *inviteSearchBar;
@property(nonatomic,retain) NSDictionary *downloadedImageDict;
@property (nonatomic,retain)  IBOutlet UIView *msgView;
@property (nonatomic,retain) IBOutlet UITextView *textViewNewMsg;

-(IBAction)cancel:(id)sender;
-(IBAction)selectedUser:(id)sender;
-(IBAction)selectAllpeople:(id)sender;

-(IBAction)sendMsg:(id)sender;
-(IBAction)cancelMsg:(id)sender;

- (IBAction)actionNotificationButton:(id)sender;

@end
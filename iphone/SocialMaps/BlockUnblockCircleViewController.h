//
// BlockUnblockCircleViewController.h
// SocialMaps
//
// Created by Abdullah Md. Zubair on 9/20/12.
// Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleImageDownloader.h"

@interface BlockUnblockCircleViewController : UIViewController
{
    IBOutlet UITableView *blockTableView;
    IBOutlet UISearchBar *blockSearchBar;
    NSDictionary *downloadedImageDict;
    IBOutlet UIView *msgView;
    IBOutlet UITextView *textViewNewMsg;

}

@property(nonatomic,retain) IBOutlet UITableView *blockTableView;
@property(nonatomic,retain) IBOutlet UISearchBar *blockSearchBar;
@property(nonatomic,retain) NSDictionary *downloadedImageDict;

@property (nonatomic,retain)  IBOutlet UIView *msgView;
@property (nonatomic,retain) IBOutlet UITextView *textViewNewMsg;

-(IBAction)sendMsg:(id)sender;
-(IBAction)cancelMsg:(id)sender;

-(IBAction)cancel:(id)sender;
-(IBAction)selectedUser:(id)sender;
-(IBAction)selectAllpeople:(id)sender;

@end
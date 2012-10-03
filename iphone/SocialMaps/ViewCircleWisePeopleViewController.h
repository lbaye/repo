//
//  ViewCircleWisePeopleViewController.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 9/20/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "SectionHeaderView.h"

@class CircleListTableCell;
@interface ViewCircleWisePeopleViewController : UIViewController <MFMailComposeViewControllerDelegate, SectionHeaderViewDelegate>
{
    IBOutlet UITableView *circleTableView;
    IBOutlet UISearchBar *circleSearchBar;
    IBOutlet UIView *circleCreateView;
    IBOutlet UITableView *circleSelectTableView;
    IBOutlet UITextField *circleNameTextField;
    IBOutlet UIView *msgView;
    IBOutlet UITextView *textViewNewMsg;

}

@property(nonatomic,retain) IBOutlet UITableView *circleTableView;
@property(nonatomic,retain) IBOutlet UISearchBar *circleSearchBar;

@property (nonatomic, strong) NSArray* userCircle;
@property (nonatomic, strong) IBOutlet CircleListTableCell *circleListTableCell;
@property (nonatomic,retain) IBOutlet UIView *circleCreateView;
@property(nonatomic,retain) IBOutlet UITableView *circleSelectTableView;
@property(nonatomic,retain) IBOutlet UITextField *circleNameTextField;
@property (nonatomic,retain)  IBOutlet UIView *msgView;
@property (nonatomic,retain) IBOutlet UITextView *textViewNewMsg;

-(IBAction)sendMsg:(id)sender;
-(IBAction)cancelMsg:(id)sender;

-(IBAction)addCircleAction:(id)sender;
-(IBAction)okAction:(id)sender;
-(IBAction)cancelAction:(id)sender;
@end

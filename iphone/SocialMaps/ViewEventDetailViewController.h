//
//  ViewEventDetailViewController.h
//  Event
//
//  Created by Abdullah Md. Zubair on 8/23/12.
//  Copyright (c) 2012 Genweb2 Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewEventDetailViewController : UIViewController
{
    IBOutlet UILabel *eventName;
    IBOutlet UILabel *eventDate;
    IBOutlet UILabel *eventShortDetail;
    IBOutlet UILabel *eventAddress;
    IBOutlet UILabel *eventDistance;    
    
    IBOutlet UIButton *yesButton;
    IBOutlet UIButton *noButton;
    IBOutlet UIButton *maybeButton;    
    IBOutlet UITextView *descriptionView;
    
    IBOutlet UIScrollView *guestScrollView;
    IBOutlet UIView *rsvpView;
    IBOutlet UIView *detailView;
    
    BOOL isDragging_msg,isDecliring_msg;
    NSMutableDictionary *dicImages_msg;
    NSMutableArray *ImgesName; 
}

@property(nonatomic,retain) IBOutlet UILabel *eventName;
@property(nonatomic,retain) IBOutlet UILabel *eventDate;
@property(nonatomic,retain) IBOutlet UILabel *eventShortDetail;
@property(nonatomic,retain) IBOutlet UILabel *eventAddress;
@property(nonatomic,retain) IBOutlet UILabel *eventDistance;    

@property(nonatomic,retain) IBOutlet UIButton *yesButton;
@property(nonatomic,retain) IBOutlet UIButton *noButton;
@property(nonatomic,retain) IBOutlet UIButton *maybeButton;
@property(nonatomic,retain) IBOutlet UITextView *descriptionView;

@property(nonatomic,retain) IBOutlet UIScrollView *guestScrollView;
@property(nonatomic,retain) IBOutlet UIView *rsvpView;
@property(nonatomic,retain) IBOutlet UIView *detailView;

@property(nonatomic,retain) NSDictionary *results;
@property(nonatomic,retain) NSMutableArray *ImgesName;
-(void)DownLoad:(NSNumber *)path;
-(void) reloadScrolview;

-(IBAction)viewMapButton:(id)sender;
-(IBAction)yesAttendAction:(id)sender;
-(IBAction)noAttendAction:(id)sender;
-(IBAction)maybeAttendAction:(id)sender;

-(IBAction)guestList:(id)sender;
-(IBAction)invitePeople:(id)sender;
-(IBAction)deleteEvent:(id)sender;
-(IBAction)editEvent:(id)sender;
- (IBAction)menuTapped;

-(void)resetButton:(int)index;
-(void)loadScrollView;

@end

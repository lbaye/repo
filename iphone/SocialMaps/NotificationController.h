//
//  NotificationController.h
//  SocialMaps
//
//  Created by Arif Shakoor on 7/30/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotifRequest.h"
#import "AppDelegate.h"

typedef enum _NOTIFY_TYPES {
    Message=0,
    Request,
    Notif
} NOTIFY_TYPES;

@interface NotificationController : UIViewController<UITableViewDelegate, UITableViewDataSource, NotifRequestDelegate> {
    int    selectedItemIndex;
    NOTIFY_TYPES selectedType;
    AppDelegate     *smAppDelegate;
}

@property (nonatomic) int selectedItemIndex;
@property (atomic) NOTIFY_TYPES selectedType;
@property (nonatomic, retain) AppDelegate * smAppDelegate;

@property (retain, nonatomic) IBOutlet UIImageView *notifTabArrow;
@property (retain, nonatomic) IBOutlet UILabel *notifCount;
@property (retain, nonatomic) IBOutlet UILabel *msgCount;
@property (retain, nonatomic) IBOutlet UILabel *reqCount;
@property (retain, nonatomic) IBOutlet UILabel *alertCount;
@property (retain, nonatomic) IBOutlet UITableView *notificationItems;

@property (nonatomic,retain) IBOutlet UIButton *notifButton;
@property (nonatomic,retain) IBOutlet UIButton *msgButton;
@property (nonatomic,retain) IBOutlet UIButton *reqButton;

- (IBAction)showMessages:(id)sender;
- (IBAction)showFriendRequests:(id)sender;
- (IBAction)showNotifications:(id)sender;
- (void)moreButtonTapped:(id)sender;
- (void) buttonClicked:(NSString*)name cellRow:(int)row;
- (IBAction)actionBackMe:(id)sender;

@end

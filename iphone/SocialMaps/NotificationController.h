//
//  NotificationController.h
//  SocialMaps
//
//  Created by Arif Shakoor on 7/30/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file NotificationController.h
 * @brief Display user's notification, friend request and unread messages through this view controller.
 */

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
    IBOutlet UIWebView *webView;
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
@property (nonatomic,retain) IBOutlet UIWebView *webView;

@property (nonatomic, retain) NSMutableArray *unreadMesg;

/**
 * @brief Make selection type message and display unread message
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)showMessages:(id)sender;

/**
 * @brief Make selection type friend request and display all friend request
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)showFriendRequests:(id)sender;

/**
 * @brief Make selection type notification and display all notifications
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)showNotifications:(id)sender;

/**
 * @brief Make an unread message read
 * @param (id) - Action sender
 * @retval none
 */
- (void)moreButtonTapped:(id)sender;

/**
 * @brief Accept/ Decline friend request
 * @param (NSString) - Operation name accept/decline
 * @param (int) - Selected table row
 * @retval none
 */
- (void) buttonClicked:(NSString*)name cellRow:(int)row;

/**
 * @brief Navigate user to previous screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionBackMe:(id)sender;

@end

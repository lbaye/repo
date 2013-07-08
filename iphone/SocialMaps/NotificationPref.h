//
//  NotificationPref.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/13/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationPref : NSObject
{
bool friend_requests_sm;
bool posts_by_friends_sm;
bool comments_sm;
bool messages_sm;
bool proximity_alerts_sm; 
bool recommendations_sm;
bool friend_requests_mail;
bool posts_by_friends_mail;
bool comments_mail;
bool messages_mail;
bool proximity_alerts_mail; 
bool recommendations_mail;
bool offline_notifications_mail;    
bool offline_notifications_sm;
int  proximity_radius;
}
@property(atomic) bool friend_requests_sm;
@property(atomic) bool posts_by_friends_sm;
@property(atomic) bool comments_sm;
@property(atomic) bool messages_sm;
@property(atomic) bool proximity_alerts_sm; 
@property(atomic) bool recommendations_sm;
@property(atomic) bool friend_requests_mail;
@property(atomic) bool posts_by_friends_mail;
@property(atomic) bool comments_mail;
@property(atomic) bool messages_mail;
@property(atomic) bool proximity_alerts_mail; 
@property(atomic) bool recommendations_mail;
@property(atomic) bool offline_notifications_mail;    
@property(atomic) bool offline_notifications_sm;
@property(atomic) int  proximity_radius;

@end

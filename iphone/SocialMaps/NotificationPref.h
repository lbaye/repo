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
NSString *friend_requests_sm;
NSString *posts_by_friends_sm;
NSString *comments_sm;
NSString *messages_sm;
NSString *proximity_alerts_sm; 
NSString *recommendations_sm;
NSString *friend_requests_mail;
NSString *posts_by_friends_mail;
NSString *comments_mail;
NSString *messages_mail;
NSString *proximity_alerts_mail; 
NSString *recommendations_mai;
}
@property(nonatomic,retain) NSString *friend_requests_sm;
@property(nonatomic,retain) NSString *posts_by_friends_sm;
@property(nonatomic,retain) NSString *comments_sm;
@property(nonatomic,retain) NSString *messages_sm;
@property(nonatomic,retain) NSString *proximity_alerts_sm; 
@property(nonatomic,retain) NSString *recommendations_sm;
@property(nonatomic,retain) NSString *friend_requests_mail;
@property(nonatomic,retain) NSString *posts_by_friends_mail;
@property(nonatomic,retain) NSString *comments_mail;
@property(nonatomic,retain) NSString *messages_mail;
@property(nonatomic,retain) NSString *proximity_alerts_mail; 
@property(nonatomic,retain) NSString *recommendations_mai;

@end

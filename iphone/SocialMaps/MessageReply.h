//
//  MessageReply.h
//  SocialMaps
//
//  Created by Warif Rishi on 9/2/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageReply : NSObject 
{    
    NSString    *content;
    NSDate      *time;
    NSString    *senderName;
    NSString    *senderID;
    NSString    *senderAvater;
    UIImage     *senderImage;
    NSString    *msgId;
}

@property (nonatomic, retain) NSString  *content;
@property (nonatomic, retain) NSDate    *time;
@property (nonatomic, retain) NSString  *senderName;
@property (nonatomic, retain) NSString  *senderID;
@property (nonatomic, retain) NSString  *senderAvater;
@property (nonatomic, retain) UIImage   *senderImage;
@property (nonatomic, retain) NSString  *msgId;

@end

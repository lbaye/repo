//
//  MeetUpRequest.h
//  SocialMaps
//
//  Created by Warif Rishi on 9/11/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Geolocation.h"

@interface MeetUpRequest : NSObject 
{
    NSString    *meetUpId;
    NSString    *meetUpSenderId;
    NSString    *meetUpSender;
    NSDate      *meetUpTime;
    NSString    *meetUpDescription;
    NSString    *meetUpTitle;
    Geolocation *meetUpLocation;
    NSString    *meetUpAddress;
    NSMutableArray *meetUpRsvpYes;
    NSMutableArray *meetUpRsvpNo;
    NSMutableArray *meetUpRsvpIgnore;
}

@property (nonatomic,retain) NSString *meetUpId;
@property (nonatomic,retain) NSString *meetUpSenderId;
@property (nonatomic,retain) NSString *meetUpSender;
@property (nonatomic,retain) NSDate   *meetUpTime;
@property (nonatomic,retain) NSString *meetUpDescription;
@property (nonatomic,retain) NSString *meetUpTitle;
@property (nonatomic,retain) Geolocation *meetUpLocation;
@property (nonatomic,retain) NSString *meetUpAddress;
@property (nonatomic,retain) NSMutableArray *meetUpRsvpYes;
@property (nonatomic,retain) NSMutableArray *meetUpRsvpNo;
@property (nonatomic,retain) NSMutableArray *meetUpRsvpIgnore;

@end

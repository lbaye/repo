//
//  CircleImageDownloader.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 9/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UserFriends;
@class ViewCircleListViewController;

@protocol CircleImageDownloaderDelegate;

@interface CircleImageDownloader : NSObject
{
UserFriends *userFriend;
NSIndexPath *indexPathInTableView;
id <CircleImageDownloaderDelegate> delegate;

NSMutableData *activeDownload;
NSURLConnection *imageConnection;
}

@property (nonatomic, retain) UserFriends *userFriend;
@property (nonatomic, retain) NSIndexPath *indexPathInTableView;
@property (nonatomic, assign) id <CircleImageDownloaderDelegate> delegate;

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;

- (void)startDownload;
- (void)cancelDownload;

@end

@protocol EventImageDownloaderDelegate 

//- (void)appImageDidLoad:(NSIndexPath *)indexPath;
- (void)appImageDidLoad:(NSString *)userId;

@end
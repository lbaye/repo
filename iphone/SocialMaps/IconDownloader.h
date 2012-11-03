//
//  IconDownloader.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/8/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//


@class UserFriends;
@class MapViewController;

@protocol IconDownloaderDelegate;

@interface IconDownloader : NSObject
{
    UserFriends *userFriends;
    NSIndexPath *indexPathInTableView;
    id <IconDownloaderDelegate> delegate;
    
    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
}

@property (nonatomic, retain) UserFriends *userFriends;
@property (nonatomic, retain) NSIndexPath *indexPathInTableView;
@property (nonatomic, assign) id <IconDownloaderDelegate> delegate;
@property (nonatomic, assign) int scrollSubViewTag;

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;

- (void)startDownload;
- (void)cancelDownload;

@end

@protocol IconDownloaderDelegate 

//- (void)appImageDidLoad:(NSIndexPath *)indexPath;
- (void)appImageDidLoad:(NSString *)userId;

@optional
- (void)appImageDidLoadForScrollView:(UserFriends*)userFriends:(UIImage*)image:(int)scrollSubViewTag;

@end
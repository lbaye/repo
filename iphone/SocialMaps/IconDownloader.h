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

/**
 * @brief Start downloading an image
 * @param none
 * @retval none
 */
- (void)startDownload;

/**
 * @brief Cancel downloading of images
 * @param none
 * @retval none
 */
- (void)cancelDownload;

@end

@protocol IconDownloaderDelegate 

/**
 * @brief Delegate method, performs when image downloaded
 * @param (NSString) - User id
 * @retval none
 */
- (void)appImageDidLoad:(NSString *)userId;

@optional

/**
 * @brief Delegate method for scroll view, performs when image downloaded for scroll view
 * @param (UserFriends) - User friend object
 * @param (UIImage) - Downloaded image
 * @param (int) - Tag number of subview of scroll view 
 * @retval none
 */
- (void)appImageDidLoadForScrollView:(UserFriends*)userFriends:(UIImage*)image:(int)scrollSubViewTag;

@end
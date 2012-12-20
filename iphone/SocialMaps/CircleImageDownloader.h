//
//  CircleImageDownloader.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 9/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LocationItemPeople;
@class ViewCircleListViewController;
@class InviteFromCircleViewController;

@protocol CircleImageDownloaderDelegate;

@interface CircleImageDownloader : NSObject
{
LocationItemPeople *people;
NSIndexPath *indexPathInTableView;
id <CircleImageDownloaderDelegate> delegate;

NSMutableData *activeDownload;
NSURLConnection *imageConnection;
}

@property (nonatomic, retain) LocationItemPeople *people;
@property (nonatomic, retain) NSIndexPath *indexPathInTableView;
@property (nonatomic, assign) id <CircleImageDownloaderDelegate> delegate;

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;

/**
 * @brief Navigate user to previous screen
 * @param (id) - Action sender
 * @retval action
 */
- (void)startDownload;

/**
 * @brief Navigate user to previous screen
 * @param (id) - Action sender
 * @retval action
 */
- (void)cancelDownload;

@end

@protocol EventImageDownloaderDelegate 

/**
 * @brief Delegate method, performed when image loaded
 * @param (NSString) - User id
 * @retval none
 */
- (void)appImageDidLoad:(NSString *)userId;

@end
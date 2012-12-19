//
//  EventImageDownloader.h
//  Event
//
//  Created by Abdullah Md. Zubair on 8/27/12.
//  Copyright (c) 2012 Genweb2 Limited. All rights reserved.
//

@class Event;
@class ViewEventListViewController;

@protocol EventImageDownloaderDelegate<NSObject>
- (void)appImageDidLoad:(NSString *)eventId;
@end

@interface EventImageDownloader : NSObject
{
    Event *event;
    NSIndexPath *indexPathInTableView;
    id <EventImageDownloaderDelegate> delegate;
    
    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
}

@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) NSIndexPath *indexPathInTableView;
@property (nonatomic, assign) id <EventImageDownloaderDelegate> delegate;

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;

/**
 * @brief start download of an event image
 * @param (id) - action sender
 * @retval action
 */
- (void)startDownload;

/**
 * @brief cancel download of an event image
 * @param (id) - action sender
 * @retval action
 */
- (void)cancelDownload;

@end
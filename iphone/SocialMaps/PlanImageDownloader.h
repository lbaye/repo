//
//  PlanImageDownloader.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 11/22/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file PlanImageDownloader.h
 * @brief Downloads image for plan.
 */

#import <Foundation/Foundation.h>

@class Plan;
@class PlanListViewController;

@protocol PlanImageDownloaderDelegate<NSObject>
- (void)appImageDidLoad:(NSString *)eventId;
@end

@interface PlanImageDownloader : NSObject
{
    Plan *plan;
    NSIndexPath *indexPathInTableView;
    id <PlanImageDownloaderDelegate> delegate;
    
    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
}

@property (nonatomic, retain) Plan *plan;
@property (nonatomic, retain) NSIndexPath *indexPathInTableView;
@property (nonatomic, assign) id <PlanImageDownloaderDelegate> delegate;

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;

/**
 * @brief Start download of plan image
 * @param none
 * @retval none
 */
- (void)startDownload;

/**
 * @brief Cancel download of plan image
 * @param none
 * @retval none
 */
- (void)cancelDownload;

@end

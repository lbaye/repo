//
//  CachedImages.h
//  SocialMaps
//
//  Created by Warif Rishi on 10/20/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file CachedImages.h
 * @brief Cache images in dictionary against url key.
 */

#import <Foundation/Foundation.h>

@class ImageInfo;

@interface CachedImages : NSObject {

}

/**
 * @brief Get image from a given url. Download image if not present.
 * @param (NSURL) - URL of an image
 * @retval (ImageInfo) - ImageInfo contains UIImage and URL
 */
+ (ImageInfo*)getImageFromURL:(NSURL*)URL;

/**
 * @brief Get image only if downloaded before else nil
 * @param (NSURL) - URL of an image
 * @retval (ImageInfo) - ImageInfo contains UIImage and URL
 */
+ (ImageInfo*)getImageFromURLIfAvailable:(NSURL*)URL;

/**
 * @brief Remove all cached images
 * @param none
 * @retval none
 */
+ (void) removeAllCache;

@end

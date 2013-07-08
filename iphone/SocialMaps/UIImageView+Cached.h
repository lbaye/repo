//  UIImageView+Cached.h
//
//  Created by Lane Roathe
//  Copyright 2009 Ideas From the Deep, llc. All rights reserved.

/**
 * @file UIImageView+Cached.h
 * @brief UIImageView methods added for download image from server and set image only if available.
 */

@class ImageInfo;

@interface UIImageView (Cached)

@property (nonatomic, retain) ImageInfo *imageInfo;

/**
 * @brief Get imageinfo
 * @param none
 * @retval (ImageInfo*) - Contains image and imageURL.
 */
- (ImageInfo*)getImageInfo;

/**
 * @brief Set image by downloading from server or from cache if available
 * @param (NSURL) - URL that contains image
 * @retval none
 */
-(void)loadFromURL:(NSURL*)url;

/**
 * @brief Set image by downloading from server or from temporary cache if available
 * @param (NSURL) - URL that contains image
 * @retval none
 */
-(void)loadFromURLTemporaryCache:(NSURL *)url;

/**
 * @brief Set image only if availabel in cache.
 * @param (NSURL) - URL that contains image
 * @retval none
 */
-(void)setImageForUrlIfAvailable:(NSURL *)url;

@end


//
//  CachedImages.h
//  SocialMaps
//
//  Created by Warif Rishi on 10/20/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ImageInfo;

@interface CachedImages : NSObject {

}

+ (ImageInfo*)getImageFromURL:(NSURL*)URL;
+ (ImageInfo*)getImageFromURLIfAvailable:(NSURL*)URL;

@end

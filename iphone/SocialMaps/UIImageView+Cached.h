//  UIImageView+Cached.h
//
//  Created by Lane Roathe
//  Copyright 2009 Ideas From the Deep, llc. All rights reserved.

@class ImageInfo;

@interface UIImageView (Cached)

@property (nonatomic, retain) ImageInfo *imageInfo;

- (ImageInfo*)getImageInfo;

-(void)loadFromURL:(NSURL*)url;
-(void)loadFromURL:(NSURL*)url afterDelay:(float)delay;
-(void)setImageForUrlIfAvailable:(NSURL *)url;

@end


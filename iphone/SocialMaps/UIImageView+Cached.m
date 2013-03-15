//  UIImageView+Cached.h
//
//  Created by Lane Roathe
//  Copyright 2009 Ideas From the Deep, llc. All rights reserved.

#import <objc/runtime.h>
#import "UIImageView+Cached.h"
#import "CachedImages.h"
#import "ImageInfo.h"

static char const * const ObjectTagKey = "ObjectTag";

#pragma mark -
#pragma mark --- Threaded & Cached image loading ---

@implementation UIImageView (Cached)

@dynamic imageInfo;

#define TAG_INDICATOR_VIEW	420

- (ImageInfo*)getImageInfo {
    ImageInfo *imageInfoObj = (ImageInfo*)objc_getAssociatedObject(self, ObjectTagKey);
    return imageInfoObj;
}

- (void)setImageInfo:(ImageInfo *)imageInfo {
    objc_setAssociatedObject(self, ObjectTagKey, imageInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    if ([keyPath isEqual:@"image"]) {
        [self performSelectorOnMainThread:@selector(setImage:) withObject:((ImageInfo*)object).image waitUntilDone:YES];
        [self canclePreviousDownload];
        [[self viewWithTag:TAG_INDICATOR_VIEW] removeFromSuperview];
        //NSLog(@"remove indicator");
    }
}

- (void)canclePreviousDownload 
{
    if ([self getImageInfo]) {
        @try{
            [[self getImageInfo] removeObserver:self forKeyPath:@"image"];
        }@catch(id anException){
            NSLog(@"Cannot remove observer");
        }
    } 
    //[self setImageInfo:imageInfo];
    //[imageInfo addObserver:self forKeyPath:@"image" options:0 context:NULL];
}

-(void)loadFromURLTemporaryCache:(NSURL *)url
{
    if (url) {
        self.image = nil;
        ImageInfo *imageInfo = ((ImageInfo*)[CachedImages getImageFromURLTemporaryCache:url]);
        
        if (imageInfo.image != NULL) {
            self.image = imageInfo.image;
        } else {
            [self setImageInfo:imageInfo];
            [imageInfo addObserver:self forKeyPath:@"image" options:0 context:NULL];
            
            if (![self viewWithTag:TAG_INDICATOR_VIEW])
            {
                UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                activityIndicator.center = self.center;
                [activityIndicator startAnimating];
                activityIndicator.tag = TAG_INDICATOR_VIEW;
                [self addSubview:activityIndicator];
                [activityIndicator release];
            }
        }
    }
}

// Methods to load and cache an image from a URL on a separate thread
-(void)loadFromURL:(NSURL *)url
{
    if (url) {
        self.image = nil;
        ImageInfo *imageInfo = ((ImageInfo*)[CachedImages getImageFromURL:url]);

        [self canclePreviousDownload];
        
        if (imageInfo.image != NULL) {
            self.image = imageInfo.image;
        } else {
            [self setImageInfo:imageInfo];
            [imageInfo addObserver:self forKeyPath:@"image" options:0 context:NULL];
        }
    } else {
        [self canclePreviousDownload];
    }
}

-(void)setImageForUrlIfAvailable:(NSURL *)url
{
    //[[self viewWithTag:TAG_INDICATOR_VIEW] removeFromSuperview];
    self.image = nil;
    if (url) {
        ImageInfo *imageInfo = ((ImageInfo*)[CachedImages getImageFromURLIfAvailable:url]);
        if (imageInfo.image != NULL) {
            self.image = imageInfo.image;
        }
        [self canclePreviousDownload];
    }
}

-(void)dealloc
{
    [self canclePreviousDownload];
    [super dealloc];
}

@end

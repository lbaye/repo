//
//  CachedImages.m
//  SocialMaps
//
//  Created by Warif Rishi on 10/20/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "CachedImages.h"
#import "ImageInfo.h"


#define MAX_CACHED_IMAGES	80
//NSCache should autometically handle releasing cached objects when a memory warning is received

@implementation CachedImages

// method to return a static cache reference (ie, no need for an init method)
+ (NSMutableDictionary*)cache
{
    static NSMutableDictionary* _cache = nil;
	
	if( !_cache ){
        _cache = [[NSMutableDictionary alloc] init];
    }

	assert(_cache);
	return _cache;
}

+ (NSMutableArray*)keyArray
{
	static NSMutableArray* _keyArray = nil;
	
	if( !_keyArray ){
        _keyArray = [[NSMutableArray alloc] init];
    }
    
	assert(_keyArray);
	return _keyArray;
}

+ (ImageInfo*)getImageFromURL:(NSURL*)URL {
    
    ImageInfo *imageInfo = [[self cache] objectForKey:URL.description];
    
    if (!imageInfo) {
        imageInfo = [[[ImageInfo alloc] init] autorelease];
        imageInfo.imagePath = URL;
        //[self cacheFromURL:imageInfo]; //If icondonwloader2 used
        [self performSelectorInBackground:@selector(cacheFromURL:) withObject:imageInfo];
    } 
     
    return imageInfo;
}

+ (ImageInfo*)getImageFromURLIfAvailable:(NSURL*)URL {
    
    ImageInfo *imageInfo = [[self cache] objectForKey:URL.description];
    
    if (!imageInfo) {
        return nil;
    } 
    
    return imageInfo;
}

// Loads an image from a URL, caching it for later loads
+ (void)cacheFromURL:(ImageInfo*)imageInfo;
{
    NSURL *url = imageInfo.imagePath;
        
    UIImage* newImage = imageInfo.image;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
    if( !newImage ) {
        
		NSLog(@"Image From Server.......");
        
        
        if( [[self cache] count] >= MAX_CACHED_IMAGES ) {
            [[self cache] removeObjectForKey:[[self keyArray] objectAtIndex:0]];
            [[self keyArray] removeObjectAtIndex:0];
            NSLog(@"Remove cache");
            //[[self cache] removeAllObjects];
            
        }
        
        [[self cache] setObject:imageInfo forKey:url.description];
        [[self keyArray] addObject:url.description];
		
       
		NSError *err = nil;
		
		newImage = /*[*/[UIImage imageWithData: [NSData dataWithContentsOfURL:url options:0 error:&err]] /*retain]*/;
		if( newImage )
		{
			// check to see if we should flush existing cached items before adding this new item
			//if( [[self cache] count] >= MAX_CACHED_IMAGES )
				//[[self cache] removeAllObjects];
            
			//[[self cache] setValue:newImage forKey:url.description];
			//[self performSelectorOnMainThread:@selector(assignImageToImageView:) withObject:newImage waitUntilDone:YES];
		}
		else
			NSLog( @"UIImageView:LoadImage Failed: %@", err );
		
	}
    
	if (newImage) {
        NSLog(@"Image From Cache.......");
        ImageInfo *imageInfoValid = [[self cache] objectForKey:url.description];
        
        if (imageInfoValid) {
            imageInfo.image = newImage;
        } 
        
	}
    
    [pool drain];
}

+ (void) removeAllCache 
{
    [[self cache] removeAllObjects];
    [[self keyArray] removeAllObjects];
}

@end

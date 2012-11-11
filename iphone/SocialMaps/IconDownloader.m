//
//  IconDownloader.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 8/8/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//


#import "IconDownloader.h"
#import "UserFriends.h"

#define kAppIconHeight 48


@implementation IconDownloader

@synthesize userFriends;
@synthesize indexPathInTableView;
@synthesize delegate;
@synthesize activeDownload;
@synthesize imageConnection;
@synthesize scrollSubViewTag;

#pragma mark

- (void)dealloc
{
    [UserFriends release];
    [indexPathInTableView release];
    
    [activeDownload release];
    
    [imageConnection cancel];
    [imageConnection release];
    
    [super dealloc];
}

- (void)startDownload
{
    self.activeDownload = [NSMutableData data];
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:
                              [NSURL URLWithString:userFriends.imageUrl]] delegate:self];
    NSLog(@"userFriends.imageUrl %@", userFriends.imageUrl);
    self.imageConnection = conn;
    [conn release];
}

- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
    self.delegate = nil;
}


#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Set appIcon and clear temporary data/image
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
    
    if (image.size.width != kAppIconHeight && image.size.height != kAppIconHeight)
	{
        CGSize itemSize = CGSizeMake(kAppIconHeight, kAppIconHeight);
		UIGraphicsBeginImageContext(itemSize);
		CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
		[image drawInRect:imageRect];
		self.userFriends.userProfileImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
    }
    else
    {
        self.userFriends.userProfileImage = image;
    }
    
    self.activeDownload = nil;
    
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
    
    if (delegate != nil && image != nil && scrollSubViewTag) {
        [delegate appImageDidLoadForScrollView:userFriends:image:scrollSubViewTag];
        return;
    }
    
    [image release]; image = nil;
    
    // call our delegate and tell it that our icon is ready for display
    //[delegate appImageDidLoad:self.indexPathInTableView];
    if (delegate != nil)
        [delegate appImageDidLoad:self.userFriends.userId];
}

@end


//
//  ImageInfo.h
//  SocialMaps
//
//  Created by Warif Rishi on 10/20/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageInfo : NSObject {
    NSURL   *imagePath;
    UIImage *image;
}

@property (nonatomic, retain) NSURL     *imagePath;
@property (nonatomic, retain) UIImage   *image;

@end

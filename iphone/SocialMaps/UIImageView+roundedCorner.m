//
//  UIImageView+roundedCorner.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/13/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+roundedCorner.h"

@implementation UIImageView (roundedCorner)
+(UIImageView*) imageViewWithRect:(CGRect)frame andImage:(NSString*)file withCornerradius:(NSInteger)rad {
    UIImageView *imgView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:file]];
    imgView.frame = frame;
    [imgView.layer setMasksToBounds:YES];
    [imgView.layer setCornerRadius:10.0];
    [imgView.layer setBorderWidth:2.5f];
    [imgView.layer setBorderColor:[UIColor clearColor].CGColor];    
    
    return imgView;
}

+(UIImageView*) imageViewWithRectImage:(CGRect)frame andImage:(UIImage*)img withCornerradius:(NSInteger)rad {
    UIImageView *imgView = [[UIImageView alloc] initWithImage: img];
    imgView.frame = frame;
    [imgView.layer setMasksToBounds:YES];
    [imgView.layer setCornerRadius:10.0];
    [imgView.layer setBorderWidth:2.5f];
    [imgView.layer setBorderColor:[UIColor clearColor].CGColor];    
    
    return imgView;  
}
+ (UIImage*) scaleImage:(UIImage*) img toSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+(UIImageView*) imageViewForMapAnnotation:(CGRect)frame andImage:(UIImage*)img withCornerradius:(NSInteger)rad {
    UIImage *maskImage = [UIImage imageNamed:@"user_thumb_only2.png"];

    CGImageRef maskRef = maskImage.CGImage; 
    UIImage *scaledImage = [self scaleImage:img toSize:maskImage.size];
    
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);


    CGImageRef masked = CGImageCreateWithMask([scaledImage CGImage], mask);
    
	return [[UIImageView alloc]  initWithImage:[UIImage imageWithCGImage:masked]];
}

-(void) setBorderColor:(UIColor*)color {
    [self.layer setBorderColor:color.CGColor];
}
@end

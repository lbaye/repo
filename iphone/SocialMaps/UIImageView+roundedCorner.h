//
//  UIImageView+roundedCorner.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/13/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (roundedCorner)
+(UIImageView*) imageViewWithRect:(CGRect)frame andImage:(NSString*)file withCornerradius:(NSInteger)rad;
+(UIImageView*) imageViewWithRectImage:(CGRect)frame andImage:(UIImage*)img withCornerradius:(NSInteger)rad;
+(UIImageView*) imageViewForMapAnnotation:(CGRect)frame andImage:(UIImage*)img withCornerradius:(NSInteger)rad;
-(void) setBorderColor:(UIColor*)color;
+ (UIImage*) scaleImage:(UIImage*) img toSize:(CGSize)newSize;
@end

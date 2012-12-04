//
//  PhotoPickerOriginalImage.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 11/13/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol PhotoPickerOriginalImageDelegate <NSObject>

- (void) photoPickerDone:(bool)status image:(UIImage*)img;

@end

@interface PhotoPickerOriginalImage : UIViewController < UINavigationControllerDelegate, 
UIImagePickerControllerDelegate,
UIActionSheetDelegate> {
    UIImagePickerController *picSel;
    UIImage         *regPhoto;
    id<PhotoPickerOriginalImageDelegate> delegate;
    CGSize          imgSize;
    UIActionSheet *userOption;
}

@property (nonatomic, retain) UIImagePickerController *picSel;
@property (nonatomic, retain) UIImage *regPhoto;
@property (nonatomic, retain) id<PhotoPickerOriginalImageDelegate> delegate;
@property (nonatomic) CGSize imgSize;
@property (nonatomic, retain) UIActionSheet *userOption;

- (void) getPhoto:(id)sender;
- (void)takePhoto:(id)sender imgSize:(CGSize)size;
- (void)selectPhoto:(id)sender imgSize:(CGSize)size;
- (UIImage*) scaleImage:(UIImage*) img toSize:(CGSize)newSize;
- (UIImage *)imageByScalingProportionallyToSize:(UIImage *)sourceImage;

@end

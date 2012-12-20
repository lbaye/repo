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

/**
 * @brief Send message to delegate that image selection done with the image and status whether image selected successfully or not
 * @param (bool) - Status whether image selected successfully or not
 * @param (UIImage) - Selected image
 * @retval none
 */
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

/**
 * @brief Prompt user whether capture image or select image from gallery 
 * @param (id) - Action sender
 * @retval none
 */
- (void) getPhoto:(id)sender;

/**
 * @brief Capture image using camera
 * @param (CGSize) - Image size
 * @retval none
 */
- (void)takePhoto:(id)sender imgSize:(CGSize)size;

/**
 * @brief Select image from gallery
 * @param (CGSize) - Image size
 * @retval none
 */
- (void)selectPhoto:(id)sender imgSize:(CGSize)size;

/**
 * @brief Resize image to specific size
 * @param (UIImage) - Image which will be resized
 * @param (CGSize) - Image size in which dimension image will be resized
 * @retval (UIImage) - Resized image
 */
- (UIImage*) scaleImage:(UIImage*) img toSize:(CGSize)newSize;

/**
 * @brief Resize image proportionally according to height and width
 * @param (UIImage) - Image which will be resized
 * @retval (UIImage) - Resized image
 */
- (UIImage *)imageByScalingProportionallyToSize:(UIImage *)sourceImage;

@end

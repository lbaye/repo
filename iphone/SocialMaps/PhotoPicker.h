//
//  PhotoPicker.h
//  SocialMaps
//
//  Created by Arif Shakoor on 8/8/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoPickerDelegate <NSObject>

- (void) photoPickerDone:(bool)status image:(UIImage*)img;

@end

@interface PhotoPicker : UIViewController < UINavigationControllerDelegate, 
                                            UIImagePickerControllerDelegate,
                                            UIActionSheetDelegate> {
    UIImagePickerController *picSel;
    UIImage         *regPhoto;
    id<PhotoPickerDelegate> delegate;
    CGSize          imgSize;
    UIActionSheet *userOption;
}

@property (nonatomic, retain) UIImagePickerController *picSel;
@property (nonatomic, retain) UIImage *regPhoto;
@property (nonatomic, retain) id<PhotoPickerDelegate> delegate;
@property (nonatomic) CGSize imgSize;
@property (nonatomic, retain) UIActionSheet *userOption;

- (void) getPhoto:(id)sender;
- (void)takePhoto:(id)sender imgSize:(CGSize)size;
- (void)selectPhoto:(id)sender imgSize:(CGSize)size;
- (UIImage*) scaleImage:(UIImage*) img toSize:(CGSize)newSize;
@end

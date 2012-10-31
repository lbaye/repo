//
//  UploadNewPhotoViewController.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 10/29/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomRadioButton.h"
#import "PhotoPicker.h"
#import "Photo.h"

@interface UploadNewPhotoViewController : UIViewController<CustomRadioButtonDelegate,UIPickerViewDataSource, 
UIPickerViewDelegate,
UITextFieldDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,PhotoPickerDelegate,UIScrollViewDelegate>
{
    IBOutlet UIImageView *photoImageView;
    IBOutlet UIScrollView *mainScrollView;
    IBOutlet UIView *upperView;
    IBOutlet UIView *lowerView;
    IBOutlet UILabel *labelNotifCount;
    IBOutlet UILabel *addressLabel;
    IBOutlet UILabel *addressDetailLabel;
    PhotoPicker *photoPicker;
    UIImagePickerController *picSel;
    Photo *photo;
    IBOutlet UITextView *commentView;
}
@property(nonatomic,retain) IBOutlet UIImageView *photoImageView;
@property(nonatomic,retain) IBOutlet UIScrollView *mainScrollView;
@property(nonatomic,retain) IBOutlet UIView *upperView;
@property(nonatomic,retain) IBOutlet UIView *lowerView;    
@property(nonatomic,retain) IBOutlet UILabel *labelNotifCount;
@property(nonatomic,retain) IBOutlet UILabel *addressLabel;
@property(nonatomic,retain) IBOutlet UILabel *addressDetailLabel;
@property(nonatomic,retain) PhotoPicker *photoPicker;
@property(nonatomic,retain) UIImagePickerController *picSel;
@property(nonatomic,retain) Photo *photo;
@property(nonatomic,retain) IBOutlet UITextView *commentView;

-(IBAction)myPhotos:(id)sender;
-(IBAction)addTakePhotos:(id)sender;
-(IBAction)uploadPhotos:(id)sender;
-(IBAction)cancel:(id)sender;
- (IBAction)actionNotificationButton:(id)sender;
- (IBAction)backButtonAction:(id)sender;

@end

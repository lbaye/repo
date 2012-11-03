//
//  PlaceViewController.h
//  SocialMaps
//
//  Created by Warif Rishi on 11/1/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoPicker.h"

@class Place;
@class PhotoPicker;

@interface PlaceViewController : UIViewController <PhotoPickerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    
    IBOutlet UILabel        *totalNotifCount;
    IBOutlet UILabel        *labelSavePlace;
    IBOutlet UILabel        *labelAddress;
    IBOutlet UIImageView    *imageViewPlace;
    IBOutlet UIButton       *buttonAddPhoto;
    IBOutlet UIButton       *buttonName;
    IBOutlet UIButton       *buttonDescription;
    IBOutlet UIButton       *buttonCategory;
    IBOutlet UITextField    *textField;
    
    Place                   *place;
    PhotoPicker             *photoPicker;
    UIImagePickerController *picSel;
    NSMutableArray          *categoryName;
    int                     selectedCatetoryIndex;
}

@property (nonatomic, retain) Place *place;

- (IBAction)actionBackMe:(id)sender;
- (IBAction)actionNameButton:(id)sender;
- (IBAction)gotoNotification:(id)sender;
- (IBAction)actionCategoryButton:(id)sender;
- (IBAction)actionSavePlaceButton:(id)sender;
- (IBAction)actionDescriptionButton:(id)sender;
- (IBAction)actionAddPhotoButton:(id)sender;
- (IBAction)actionDeletePhotoButton:(id)sender;

- (void)displayNotificationCount; 
- (void)setAddressLabelFromLatLon:(Place*)_place;

@end

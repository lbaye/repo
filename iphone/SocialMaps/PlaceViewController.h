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
    IBOutlet UIView         *viewEditEvent;
    IBOutlet UIView         *viewTextInput;
    
    Place                   *place;
    Place                   *placeEdit;
    PhotoPicker             *photoPicker;
    UIImagePickerController *picSel;
    NSMutableArray          *categoryName;
    int                     selectedCatetoryIndex;
    BOOL                    isEdidtingMode;
}

@property (nonatomic, retain) Place *place;
@property (nonatomic, assign) BOOL isEditingMode;

- (IBAction)actionBackMe:(id)sender;
- (IBAction)actionNameButton:(id)sender;
- (IBAction)gotoNotification:(id)sender;
- (IBAction)actionCategoryButton:(id)sender;
- (IBAction)actionSavePlaceButton:(id)sender;
- (IBAction)actionDescriptionButton:(id)sender;
- (IBAction)actionAddPhotoButton:(id)sender;
- (IBAction)actionDeletePhotoButton:(id)sender;
- (IBAction)actionDeleteEventButton:(id)sender;
- (IBAction)actionUpdateEventButton:(id)sender;
- (IBAction)actionSaveTextInput:(id)sender;
- (IBAction)actionCancelTextInput:(id)sender;

- (void)displayNotificationCount; 
- (void)setAddressLabelFromLatLon:(Place*)_place;

@end

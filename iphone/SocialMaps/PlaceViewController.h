//
//  PlaceViewController.h
//  SocialMaps
//
//  Created by Warif Rishi on 11/1/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

/**
 * @file PlaceViewController.h
 * @brief Save, delete and edit user's own Place.
 */

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

/**
 * @brief Navigate user to previous screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionBackMe:(id)sender;

/**
 * @brief Pressed name button
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionNameButton:(id)sender;

/**
 * @brief Navigate to notification screen
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)gotoNotification:(id)sender;

/**
 * @brief Pressed category button
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionCategoryButton:(id)sender;

/**
 * @brief Pressed save place button
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionSavePlaceButton:(id)sender;

/**
 * @brief Pressed description button
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionDescriptionButton:(id)sender;

/**
 * @brief Pressed add photo button
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionAddPhotoButton:(id)sender;

/**
 * @brief Pressed delete photo button
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionDeletePhotoButton:(id)sender;

/**
 * @brief Pressed delete place button
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionDeleteEventButton:(id)sender;

/**
 * @brief Pressed update place button
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionUpdateEventButton:(id)sender;

/**
 * @brief Pressed save text input button
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionSaveTextInput:(id)sender;

/**
 * @brief Cancel save text input button
 * @param (id) - Action sender
 * @retval action
 */
- (IBAction)actionCancelTextInput:(id)sender;

/**
 * @brief Display total notification count
 * @param none
 * @retval none
 */
- (void)displayNotificationCount; 

/**
 * @brief Set address from latitude and longitude
 * @param (Place) - place for which address is required
 * @retval none
 */
- (void)setAddressLabelFromLatLon:(Place*)_place;

@end

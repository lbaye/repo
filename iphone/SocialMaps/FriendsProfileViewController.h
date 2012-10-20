//
//  FriendsProfileViewController.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 10/18/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PhotoPicker.h"

@interface FriendsProfileViewController : UIViewController<UIPickerViewDataSource, 
UIPickerViewDelegate,
UITextFieldDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,PhotoPickerDelegate,MKMapViewDelegate,UIScrollViewDelegate>
{
    IBOutlet UIImageView *coverImageView;
    IBOutlet UIImageView *profileImageView;
    IBOutlet UILabel *nameLabl;
    IBOutlet UILabel *statusMsgLabel;
    IBOutlet UILabel *addressOrvenueLabel;
    IBOutlet UILabel *distanceLabel;
    IBOutlet UILabel *ageLabel;
    IBOutlet UILabel *relStsLabel;
    IBOutlet UILabel *livingPlace;
    IBOutlet UILabel *worksLabel;
    IBOutlet UIButton *regStatus;
    IBOutlet UIScrollView *userItemScrollView;
    IBOutlet MKMapView *mapView;
    IBOutlet UIView *mapContainer;
    IBOutlet UIView *statusContainer;
    IBOutlet UITextField *entityTextField;
    PhotoPicker *photoPicker;
    
    
    BOOL isDragging_msg,isDecliring_msg;
    NSMutableDictionary *dicImages_msg;
    NSMutableArray *ImgesName; 
    BOOL isBackgroundTaskRunning;
    UIImage *coverImage;
    UIImage *profileImage;
    IBOutlet UILabel *totalNotifCount;
    int entityFlag;
    NSString *friendsId;
    IBOutlet UIView *msgView;
    IBOutlet UITextView *textViewNewMsg;
    IBOutlet UIButton *frndStatusButton;
    IBOutlet UIButton *addFrndButton;
}
@property(nonatomic,retain) IBOutlet UIImageView *coverImageView;
@property(nonatomic,retain) IBOutlet UIImageView *profileImageView;
@property(nonatomic,retain) IBOutlet UILabel *nameLabl;
@property(nonatomic,retain) IBOutlet UILabel *statusMsgLabel;
@property(nonatomic,retain) IBOutlet UILabel *addressOrvenueLabel;
@property(nonatomic,retain) IBOutlet UILabel *distanceLabel;
@property(nonatomic,retain) IBOutlet UILabel *ageLabel;
@property(nonatomic,retain) IBOutlet UILabel *relStsLabel;
@property(nonatomic,retain) IBOutlet UILabel *livingPlace;
@property(nonatomic,retain) IBOutlet UILabel *worksLabel;
@property(nonatomic,retain) IBOutlet UIButton *regStatus;
@property(nonatomic,retain) IBOutlet UIScrollView *userItemScrollView;
@property(nonatomic,retain) IBOutlet MKMapView *mapView;
@property(nonatomic,retain) IBOutlet UIView *mapContainer;
@property(nonatomic,retain) IBOutlet UIView *statusContainer;
@property(nonatomic,retain) IBOutlet UITextField *entityTextField;

@property(nonatomic,retain) PhotoPicker *photoPicker;
@property(nonatomic,retain) UIImage *coverImage;
@property(nonatomic,retain) UIImage *profileImage;
@property(nonatomic, retain) UIImagePickerController *picSel;
@property(nonatomic,retain) NSString *friendsId;
@property(nonatomic,retain) IBOutlet UILabel *totalNotifCount;

@property(nonatomic,retain) IBOutlet UIView *msgView;
@property(nonatomic,retain) IBOutlet UITextView *textViewNewMsg;
@property(nonatomic,retain) IBOutlet UIButton *frndStatusButton;
@property(nonatomic,retain) IBOutlet UIButton *addFrndButton;

-(IBAction)editCoverButton:(id)sender;
-(IBAction)editProfilePicButton:(id)sender;
-(IBAction)editStatusButton:(id)sender;
-(IBAction)geotagButton:(id)sender;
-(IBAction)uploadPhotoButton:(id)sender;
-(IBAction)viewOnMapButton:(id)sender;
-(IBAction)closeMap:(id)sender;
-(IBAction)saveEntity:(id)sender;
-(IBAction)cancelEntity:(id)sender;
-(IBAction)backButton:(id)sender;
-(IBAction)hideKeyboard:(id)sender;
-(IBAction)gotoNotification:(id)sender;
-(IBAction)ageButtonAction:(id)sender;
-(IBAction)realstsButtonAction:(id)sender;
-(IBAction)liveatButtonAction:(id)sender;
-(IBAction)workatButtonAction:(id)sender;
-(IBAction)sendMsg:(id)sender;
-(IBAction)cancelMsg:(id)sender;
-(IBAction)showMsgView:(id)sender;
-(IBAction)getDirection:(id)sender;

@end

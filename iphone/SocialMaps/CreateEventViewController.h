//
//  CreateEventViewController.h
//  Event
//
//  Created by Abdullah Md. Zubair on 8/28/12.
//  Copyright (c) 2012 Genweb2 Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserFriends.h"
#import "PhotoPicker.h"
#import <Mapkit/Mapkit.h>

@interface CreateEventViewController : UIViewController<UIPickerViewDataSource, 
UIPickerViewDelegate,
UITextFieldDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,PhotoPickerDelegate,MKMapViewDelegate>
{
    IBOutlet UILabel *createLabel;
    IBOutlet UIButton *createButton;
    
    IBOutlet UIButton *curLoc;
    IBOutlet UIButton *myPlace;    
    IBOutlet UIButton *neamePlace;
    IBOutlet UIButton *pointOnMap;    

    IBOutlet UIButton *friends;
    IBOutlet UIButton *degreeFriends;    
    IBOutlet UIButton *people;
    IBOutlet UIButton *custom;        
    
    IBOutlet UIButton *nameButton;
    IBOutlet UIButton *summaryButton;    
    IBOutlet UIButton *descriptionButton;
    IBOutlet UIButton *dateButton;    
    IBOutlet UIButton *photoButton;
    IBOutlet UIButton *deleteButton; 
    IBOutlet UIImageView *eventImagview;

    IBOutlet UIButton *guestCanInviteButton;
    
    IBOutlet UIScrollView *frndListScrollView;
    IBOutlet UISearchBar *friendSearchbar;
    
    BOOL isDragging_msg;
    BOOL isDecliring_msg;
    NSMutableDictionary *dicImages_msg;
    NSMutableArray *ImgesName;
    
    CGFloat animatedDistance;
    NSMutableArray *selectedFriendsIndex;
    IBOutlet UIView *createView;
    PhotoPicker *photoPicker;
    UIImage *eventImage;
    UIImagePickerController *picSel;
    IBOutlet UITextField *entryTextField;
    IBOutlet MKMapView *mapView;
    IBOutlet UIView *mapContainerView;
    IBOutlet UILabel *addressLabel;
}

@property(nonatomic,retain) IBOutlet UILabel *createLabel;
@property(nonatomic,retain) IBOutlet UIButton *createButton;

@property(nonatomic,retain) IBOutlet UIButton *curLoc;
@property(nonatomic,retain) IBOutlet UIButton *myPlace;    
@property(nonatomic,retain) IBOutlet UIButton *neamePlace;
@property(nonatomic,retain) IBOutlet UIButton *pointOnMap;

@property(nonatomic,retain) IBOutlet UIButton *friends;
@property(nonatomic,retain) IBOutlet UIButton *degreeFriends;    
@property(nonatomic,retain) IBOutlet UIButton *people;
@property(nonatomic,retain) IBOutlet UIButton *custom;        

@property(nonatomic,retain) IBOutlet UIButton *nameButton;
@property(nonatomic,retain) IBOutlet UIButton *summaryButton;    
@property(nonatomic,retain) IBOutlet UIButton *descriptionButton;
@property(nonatomic,retain) IBOutlet UIButton *dateButton;    
@property(nonatomic,retain) IBOutlet UIButton *photoButton;
@property(nonatomic,retain) IBOutlet UIButton *deleteButton;    
@property(nonatomic,retain) IBOutlet UIImageView *eventImagview;

@property(nonatomic,retain) IBOutlet UIButton *guestCanInviteButton;
@property(nonatomic,retain) IBOutlet UIScrollView *frndListScrollView;
@property(nonatomic,retain) IBOutlet UISearchBar *friendSearchbar;

@property(nonatomic,retain) IBOutlet UIView *createView;
@property(nonatomic,retain) PhotoPicker *photoPicker;
@property(nonatomic,retain) UIImage *eventImage;
@property (nonatomic, retain) UIImagePickerController *picSel;

@property(nonatomic,retain) IBOutlet UITextField *entryTextField;
@property(nonatomic,retain) IBOutlet MKMapView *mapView;
@property(nonatomic,retain) IBOutlet UIView *mapContainerView;

@property(nonatomic,retain) IBOutlet UILabel *addressLabel;

-(IBAction)nameButtonAction;
-(IBAction)summaryButtonAction;    
-(IBAction)descriptionButtonAction;
-(IBAction)dateButtonAction:(id)sender;
-(IBAction)photoButtonAction;
-(IBAction)deleteButtonAction;    

-(IBAction)friendsButtonAction;
-(IBAction)degreeFriendsButtonAction;    
-(IBAction)peopleButtonAction;
-(IBAction)customButtonAction;        

-(IBAction)curLocButtonAction;
-(IBAction)myPlaceButtonAction;    
-(IBAction)neamePlaceButtonAction:(id)sender;
-(IBAction)pointOnMapButtonAction;    

-(IBAction)showCircle:(id)sender;

-(IBAction)guestCanInvite:(id)sender;
-(IBAction)unSelectAll:(id)sender;
-(IBAction)addAll:(id)sender;
-(IBAction)createEvent:(id)sender;
-(IBAction)cancelEvent:(id)sender;

-(IBAction)saveEntity:(id)sender;
-(IBAction)cancelEntity:(id)sender;

-(IBAction)saveMapLoc:(id)sender;
-(IBAction)cancelMapLoc:(id)sender;

-(void)beganEditing;
-(void)endEditing;
-(IBAction)backButton:(id)sender;

@end

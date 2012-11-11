//
//  GeotagViewController.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 10/11/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserFriends.h"
#import "PhotoPicker.h"
#import "CustomRadioButton.h"
#import <Mapkit/Mapkit.h>

@interface GeotagViewController : UIViewController<UIPickerViewDataSource, 
UIPickerViewDelegate,
UITextFieldDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,PhotoPickerDelegate,MKMapViewDelegate,UIScrollViewDelegate,CustomRadioButtonDelegate>
{
    IBOutlet UILabel *createLabel;
    IBOutlet UIButton *createButton;
    
    IBOutlet UIButton *curLoc;
    IBOutlet UIButton *myPlace;    
    IBOutlet UIButton *neamePlace;
    IBOutlet UIButton *pointOnMap;    
    
    IBOutlet UIButton *private;
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
    NSMutableArray *selectedFriendsIndex, *customSelectedPhotoIndex;
    IBOutlet UIView *createView;
    PhotoPicker *photoPicker;
    UIImage *eventImage;
    UIImagePickerController *picSel;
    IBOutlet UITextField *entryTextField;
    IBOutlet MKMapView *mapView;
    IBOutlet UIView *mapContainerView;
    IBOutlet UILabel *addressLabel;
    IBOutlet UIView *circleView;
    IBOutlet UITableView *circleTableView;
    IBOutlet UIView *customSelectionView;
    IBOutlet UISegmentedControl *segmentControl;
    IBOutlet UIScrollView *customScrollView;
    IBOutlet UISearchBar *customSearchBar;
    IBOutlet UITableView *customTableView;
    
    IBOutlet UILabel *totalNotifCount;
    
    IBOutlet UIView *upperView;
    IBOutlet UIView *lowerView;    
    IBOutlet UIScrollView *viewContainerScrollView;
    IBOutlet UITextView *commentsView;
    IBOutlet UIScrollView *photoScrollView;
    
    IBOutlet UIButton *saveButton;
    IBOutlet UIButton *cancelButton;
    IBOutlet UIButton *deletePhotoButton;
    IBOutlet UIButton *uploadPhotoButton;
    IBOutlet UIView *zoomView;
    IBOutlet UITextField *titleTextField;
}

@property(nonatomic,retain) IBOutlet UILabel *createLabel;
@property(nonatomic,retain) IBOutlet UIButton *createButton;

@property(nonatomic,retain) IBOutlet UIButton *private;
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

@property(nonatomic,retain) IBOutlet UIView *circleView;
@property(nonatomic,retain) IBOutlet UITableView *circleTableView;

@property(nonatomic,retain) IBOutlet UIView *customSelectionView;
@property(nonatomic,retain) IBOutlet UISegmentedControl *segmentControl;

@property(nonatomic,retain) IBOutlet UIScrollView *customScrollView;
@property(nonatomic,retain) IBOutlet UISearchBar *customSearchBar;
@property(nonatomic,retain) IBOutlet UITableView *customTableView;

@property(nonatomic,retain) IBOutlet UILabel *totalNotifCount;

@property(nonatomic,retain) IBOutlet UIView *upperView;
@property(nonatomic,retain) IBOutlet UIView *lowerView;    
@property(nonatomic,retain) IBOutlet UIScrollView *viewContainerScrollView;    
@property(nonatomic,retain) IBOutlet UITextView *commentsView;
@property(nonatomic,retain) IBOutlet UIButton *line;
@property(nonatomic,retain) IBOutlet UIScrollView *photoScrollView;
@property(nonatomic,retain) IBOutlet UIButton *saveButton;
@property(nonatomic,retain) IBOutlet UIButton *cancelButton;
@property(nonatomic,retain) IBOutlet UIButton *deletePhotoButton;
@property(nonatomic,retain) IBOutlet UIButton *uploadPhotoButton;
@property(nonatomic,retain) IBOutlet UIView *zoomView;
@property(nonatomic,retain) IBOutlet UIButton *nextButton;
@property(nonatomic,retain) IBOutlet UIButton *prevButton;
@property(nonatomic,retain) IBOutlet UIScrollView *largePhotoScroller;
@property(nonatomic,retain) IBOutlet UITextField *titleTextField;

-(IBAction)nameButtonAction;
-(IBAction)dateButtonAction:(id)sender;
-(IBAction)photoButtonAction;
-(IBAction)categoriesButtonAction:(id)sender;

-(IBAction)deleteButtonAction;    

-(IBAction)privateButtonAction;
-(IBAction)friendsButtonAction;
-(IBAction)degreeFriendsButtonAction;    
-(IBAction)peopleButtonAction;
-(IBAction)customButtonAction;        

-(IBAction)showCircle:(id)sender;

-(IBAction)unSelectAll:(id)sender;
-(IBAction)addAll:(id)sender;
-(IBAction)createEvent:(id)sender;
-(IBAction)cancelEvent:(id)sender;

-(IBAction)saveEntity:(id)sender;
-(IBAction)cancelEntity:(id)sender;

-(IBAction)saveMapLoc:(id)sender;
-(IBAction)cancelMapLoc:(id)sender;

-(IBAction)saveCircle:(id)sender;
-(IBAction)cancelCircle:(id)sender;

-(IBAction)saveCustom:(id)sender;
-(IBAction)cancelCustom:(id)sender;
-(IBAction)customSegment:(id)sender;

-(void)beganEditing:(UISearchBar *)searchBar;
-(void)endEditing;
-(void)scrollToPage:(int)page:(BOOL)animated;
-(IBAction)backButton:(id)sender;

-(IBAction)gotoNotification:(id)sender;

-(IBAction)saveComments:(id)sender;
-(IBAction)cancelComments:(id)sender;

-(IBAction)savePhoto:(id)sender;
-(IBAction)cancelPhoto:(id)sender;
-(IBAction)closeZoomView:(id)sender;

-(IBAction)viewPrevImage:(id)sender;

-(IBAction)viewNextImage:(id)sender;
-(IBAction)hideKeyboard:(id)sender;

@end
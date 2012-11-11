//
//  FriendsPhotosViewController.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 11/1/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsPhotosViewController : UIViewController
{
    IBOutlet UIScrollView *photoScrollView;
    IBOutlet UIScrollView *customScrollView;
    IBOutlet UIView *zoomView;
    IBOutlet UILabel *labelNotifCount;
    IBOutlet UIButton *photoLabel;
    NSString *userName;
    NSString *userId;
    IBOutlet UIButton *nextButton;
    IBOutlet UIButton *prevButton;    

}

@property(nonatomic,retain) IBOutlet UILabel *labelNotifCount;
@property(nonatomic,retain) IBOutlet UIScrollView *photoScrollView;
@property(nonatomic,retain) IBOutlet UIScrollView *customScrollView;
@property(nonatomic,retain) IBOutlet UIView *zoomView;
@property(nonatomic,retain) IBOutlet UIButton *photoLabel;
@property(nonatomic,retain) NSString *userName;
@property(nonatomic,retain) NSString *userId;
@property(nonatomic,retain) IBOutlet UIButton *nextButton;
@property(nonatomic,retain) IBOutlet UIButton *prevButton;    

-(IBAction)myPhotosAction:(id)sender;
-(IBAction)uploadNewPhotoAction:(id)sender;
-(IBAction)deleteSelectedPhotosAction:(id)sender;

-(IBAction)closeZoomView:(id)sender;
-(IBAction)viewPrevImage:(id)sender;
-(IBAction)viewNextImage:(id)sender;
- (IBAction)actionNotificationButton:(id)sender;
- (IBAction)backButtonAction:(id)sender;

@end

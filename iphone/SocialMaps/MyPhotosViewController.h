//
//  MyPhotosViewController.h
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 10/29/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyPhotosViewController : UIViewController
{
    IBOutlet UIScrollView *photoScrollView;
    IBOutlet UIScrollView *customScrollView;
    IBOutlet UIView *zoomView;
    IBOutlet UILabel *labelNotifCount;
}

@property(nonatomic,retain) IBOutlet UILabel *labelNotifCount;
@property(nonatomic,retain) IBOutlet UIScrollView *photoScrollView;
@property(nonatomic,retain) IBOutlet UIScrollView *customScrollView;
@property(nonatomic,retain) IBOutlet UIView *zoomView;

-(IBAction)myPhotosAction:(id)sender;
-(IBAction)uploadNewPhotoAction:(id)sender;
-(IBAction)deleteSelectedPhotosAction:(id)sender;

-(IBAction)closeZoomView:(id)sender;
-(IBAction)viewPrevImage:(id)sender;
-(IBAction)viewNextImage:(id)sender;
- (IBAction)actionNotificationButton:(id)sender;
- (IBAction)backButtonAction:(id)sender;

@end

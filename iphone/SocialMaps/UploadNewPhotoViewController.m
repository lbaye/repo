//
//  UploadNewPhotoViewController.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 10/29/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "UploadNewPhotoViewController.h"
#import "NotificationController.h"
#import "UtilityClass.h"
#include <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "LocationItemPlace.h"
#import "ActionSheetPicker.h"
#import <Foundation/Foundation.h>
#import "RestClient.h"

@interface UploadNewPhotoViewController ()

@end

@implementation UploadNewPhotoViewController
@synthesize photoImageView,mainScrollView,upperView,lowerView,labelNotifCount,addressLabel,photoPicker,addressDetailLabel,picSel;
@synthesize photo,commentView;

AppDelegate *smAppDelegate;
NSMutableArray *neearMeAddressArr;
NSString *curAddress;
RestClient *rc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [upperView removeFromSuperview];
    [lowerView removeFromSuperview];
    upperView.frame=CGRectMake(0,  0, upperView.frame.size.width, upperView.frame.size.height) ;
    lowerView.frame=CGRectMake(0,  upperView.frame.size.height, lowerView.frame.size.width, lowerView.frame.size.height) ;
    [mainScrollView setContentSize:CGSizeMake(320, upperView.frame.size.height+lowerView.frame.size.height)];
    [mainScrollView addSubview:upperView];
    [mainScrollView addSubview:lowerView];
    labelNotifCount.text = [NSString stringWithFormat:@"%d", [UtilityClass getNotificationCount]];
    rc=[[RestClient alloc] init];
    photo=[[Photo alloc] init];
    // test kCGColorSpaceDeviceCMYK
    CGColorSpaceRef cmykSpace = CGColorSpaceCreateDeviceCMYK();
    CGFloat cmykValue[] = {.38, .02, .98, .05, 1};      // blue
    CGColorRef colorCMYK = CGColorCreate(cmykSpace, cmykValue);
    CGColorSpaceRelease(cmykSpace);
    NSLog(@"colorCMYK: %@", colorCMYK);
    photoImageView.layer.borderWidth=5.0;
    photoImageView.layer.cornerRadius=5.0;
    photoImageView.layer.borderColor = [[UIColor colorWithCGColor:colorCMYK] CGColor];
    
    CustomRadioButton *radio = [[CustomRadioButton alloc] initWithFrame:CGRectMake(20, 77, 280, 21) numButtons:3 labels:[NSArray arrayWithObjects:@"Current location",@"Places near to me",@"Checked in venue",nil]  default:0 sender:self tag:2000];
    radio.delegate = self;
    [lowerView addSubview:radio];
    smAppDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    neearMeAddressArr=[[NSMutableArray alloc] init];
    for (int i=0; i<[smAppDelegate.placeList count]; i++)
    {
        LocationItemPlace *aPlaceItem = (LocationItemPlace*)[smAppDelegate.placeList objectAtIndex:i];
        [neearMeAddressArr addObject:aPlaceItem.placeInfo.name];
        NSLog(@"aPlaceItem.placeInfo.name %@  %@ %@",aPlaceItem.placeInfo.name,aPlaceItem.placeInfo.location.latitude,aPlaceItem.placeInfo.location.longitude);
    }
    
    self.photoPicker = [[[PhotoPicker alloc] initWithNibName:nil bundle:nil] autorelease];
    self.photoPicker.delegate = self;
    self.picSel = [[UIImagePickerController alloc] init];
	self.picSel.allowsEditing = YES;
	self.picSel.delegate = self;
    
    [commentView.layer setCornerRadius:8.0f];
    [commentView.layer setBorderWidth:0.5];
    [commentView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [commentView.layer setMasksToBounds:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadPhotoDone:) name:NOTIF_DO_UPLOAD_PHOTO object:nil];
    curAddress=[[NSString alloc] init];
    [self performSelector:@selector(getCurrentAddress) withObject:nil afterDelay:0];
}

-(IBAction)myPhotos:(id)sender
{
    NSLog(@"my photo");
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)addTakePhotos:(id)sender
{
    NSLog(@"add take photo");
    [commentView resignFirstResponder];
    [self.photoPicker getPhoto:self];
}

-(IBAction)uploadPhotos:(id)sender
{
    photo.title=@"Test";
    photo.comment=commentView.text;
    [commentView resignFirstResponder];
    NSLog(@"upload photo %@ %@ %@ %@",photo.title,photo.description,photo.comment,photo.image);
    [rc uploadPhoto:@"Auth-Token" :smAppDelegate.authToken :photo];
    [smAppDelegate showActivityViewer:self.view];
    [smAppDelegate.window setUserInteractionEnabled:NO];
}

-(IBAction)cancel:(id)sender
{
    NSLog(@"cancel");
    [commentView resignFirstResponder];
}

- (IBAction)actionNotificationButton:(id)sender {
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    NotificationController *controller =[storybrd instantiateViewControllerWithIdentifier:@"notificationViewController"];
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
}

- (IBAction)backButtonAction:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void) radioButtonClicked:(int)indx sender:(id)sender {
    NSLog(@"radioButtonClicked index = %d", indx);
    [commentView resignFirstResponder];
    switch (indx) {
           case 2:
            [UtilityClass showAlert:@"Social Maps" :@"You have no checked in venue"];
            break;
        case 1:
            [ActionSheetPicker displayActionPickerWithView:sender data:neearMeAddressArr selectedIndex:0 target:self action:@selector(placeWasSelected::) title:@"Places near to me"];
            break;
        case 0:
            [self performSelector:@selector(getCurrentAddress) withObject:nil afterDelay:0];
            NSLog(@"curAddress: %@",curAddress);
            break;
        default:
            break;
    }
}

- (void) photoPickerDone:(bool)status image:(UIImage*)img
{
    NSLog(@"PersonalInformation:photoPickerDone, status=%d", status);
    if (status == TRUE) 
    {
        [photoImageView setImage:img];
        NSData *imgdata = UIImagePNGRepresentation(img);
        NSString *imgBase64Data = [imgdata base64EncodedString];
        photo.image=imgBase64Data;
    } 
    [photoPicker.view removeFromSuperview];
}

-(void)placeWasSelected:(NSNumber *)selectedIndex:(id)element 
{
    int selectedLocation=[selectedIndex intValue];
    NSLog(@"selectedLocation %d",selectedLocation);
    LocationItemPlace *aPlaceItem = (LocationItemPlace*)[smAppDelegate.placeList objectAtIndex:selectedLocation];
    addressLabel.text=aPlaceItem.placeInfo.name;
    addressDetailLabel.text=aPlaceItem.itemAddress;
    photo.address=aPlaceItem.itemAddress;
    photo.location.latitude=aPlaceItem.placeInfo.location.latitude;
    photo.location.longitude=aPlaceItem.placeInfo.location.longitude;
}

-(void)getCurrentAddress
{
    addressDetailLabel.text=@"";
    if ((![curAddress isEqualToString:@""]) && (curAddress))
    {
        addressLabel.text=curAddress;
        NSLog(@"use existing add");
    }
    else 
    {
        NSLog(@"load new add");
        addressLabel.text = @"Loading current address...";
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            curAddress=[UtilityClass getAddressFromLatLon:[smAppDelegate.currPosition.latitude doubleValue] withLongitude:[smAppDelegate.currPosition.longitude doubleValue]];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"get current address.");
            });
        });
    }
    photo.address=curAddress;
    photo.location.latitude=smAppDelegate.currPosition.latitude;
    photo.location.longitude=smAppDelegate.currPosition.longitude;

}

- (void)uploadPhotoDone:(NSNotification *)notif
{
    NSLog(@"[notif object] %@",[notif object]);
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [UtilityClass beganEditing:(UIControl *)textView];
    if (!(textView.textColor == [UIColor blackColor])) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    return YES;
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
    [UtilityClass endEditing];
    if (!(textView.textColor == [UIColor lightGrayColor])) {
//        textView.text = @"Your comments...";
        textView.textColor = [UIColor lightGrayColor];
    }
    photo.comment=commentView.text;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

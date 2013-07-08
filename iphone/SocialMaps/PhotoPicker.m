//
//  PhotoPicker.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/8/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "PhotoPicker.h"
#import "CustomAlert.h"
#import "AppDelegate.h"

@implementation PhotoPicker
@synthesize picSel;
@synthesize regPhoto;
@synthesize delegate;
@synthesize imgSize;
@synthesize userOption;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.picSel = [[UIImagePickerController alloc] initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        self.picSel.allowsEditing = YES;
        self.picSel.delegate = self;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)takePhoto:(id)sender imgSize:(CGSize)size {
    imgSize = size;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.picSel.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentModalViewController:self.picSel animated:YES];
    } else {
        [CustomAlert setBackgroundColor:[UIColor redColor] 
                        withStrokeColor:[UIColor redColor]];
        CustomAlert *loginAlert = [[CustomAlert alloc]
                                   initWithTitle:@"Cannot take picture!"
                                   message:@"No capture device available!"
                                   delegate:nil
                                   cancelButtonTitle:@"Done"
                                   otherButtonTitles:nil];
        
        [loginAlert show];
        [loginAlert autorelease];
        // Call delegate method photoPickerDone:(bool)status image:(UIImage*)img
        if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(photoPickerDone:image:)]) {
            [self.delegate photoPickerDone:FALSE  image:nil];
        }
    }
}

- (void)selectPhoto:(id)sender imgSize:(CGSize)size {
    imgSize = size;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        self.picSel.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:self.picSel animated:YES];
    } else {
        [CustomAlert setBackgroundColor:[UIColor redColor] 
                        withStrokeColor:[UIColor redColor]];
        CustomAlert *loginAlert = [[CustomAlert alloc]
                                   initWithTitle:@"Cannot take picture!"
                                   message:@"No capture device available!"
                                   delegate:nil
                                   cancelButtonTitle:@"Done"
                                   otherButtonTitles:nil];
        
        [loginAlert show];
        [loginAlert autorelease];
        // Call delegate method photoPickerDone:(bool)status image:(UIImage*)img
        if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(photoPickerDone:image:)]) {
            [self.delegate photoPickerDone:FALSE  image:nil];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:NO];   
    // Call delegate method photoPickerDone:(bool)status image:(UIImage*)img
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(photoPickerDone:image:)]) {
        [self.delegate photoPickerDone:FALSE  image:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    NSLog(@"After image selection: width=%f, height=%f",
          selectedImage.size.width, selectedImage.size.height);
    UIImage *scaledImage = [self scaleImage:selectedImage toSize:imgSize];
    scaledImage=[self imageByScalingProportionallyToSize:scaledImage];
    NSLog(@"After image scaled: width=%f, height=%f",
          scaledImage.size.width, scaledImage.size.height);    
    regPhoto = scaledImage;
	[self dismissModalViewControllerAnimated:NO];
    // Call delegate method photoPickerDone:(bool)status image:(UIImage*)img
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(photoPickerDone:image:)]) {
        [self.delegate photoPickerDone:TRUE  image:regPhoto];
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
    
    UIImage *scaledImage = [self scaleImage:img toSize:imgSize];
    
    regPhoto = scaledImage;
    
    [self dismissModalViewControllerAnimated:NO];
    // Call delegate method photoPickerDone:(bool)status image:(UIImage*)img
    if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(photoPickerDone:image:)]) {
        [self.delegate photoPickerDone:TRUE  image:regPhoto];
    }
}

- (UIImage*) scaleImage:(UIImage*) img toSize:(CGSize)newSize {
    newSize = img.size;
    UIGraphicsBeginImageContext(newSize);
    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (UIImage *)imageByScalingProportionallyToSize:(UIImage *)sourceImage
{
    
    UIImage *newImage = nil;
    CGSize targetSize=CGSizeMake(sourceImage.size.width/2, sourceImage.size.height/2);
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor < heightFactor) 
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        
        if (widthFactor < heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    
    return newImage ;
}

//
- (void) takePhoto:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[appDelegate window] addSubview:self.view];
    [[appDelegate window] bringSubviewToFront:self.view];
    
    [self viewWillAppear:YES];
    [self takePhoto:sender imgSize:CGSizeMake(320, 214)];
}

- (void) choosePhoto:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[appDelegate window] addSubview:self.view];
    [[appDelegate window] bringSubviewToFront:self.view];

    [self viewWillAppear:YES];
    [self selectPhoto:sender imgSize:CGSizeMake(320, 214)];
}

- (void) getPhoto:(id)sender {
    NSLog(@"PersonalInformation:picButtonClicked called");
    userOption = [[UIActionSheet alloc] initWithTitle:@"Please take a picture or select from album!"
                                             delegate:self
                                    cancelButtonTitle:@"Cancel"
                               destructiveButtonTitle:nil
                                    otherButtonTitles:@"Take photo", @"Select photo", nil];
    
    // Show the sheet
    [userOption showInView:self.view];
    [userOption release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button %d", buttonIndex);
    switch (buttonIndex) {
        case 0:
            [self takePhoto:delegate];
            break;
            
        case 1:
            [self choosePhoto:delegate];
            break; 
            
        default:
            break;
    }
}

@end

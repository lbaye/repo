//
//  PlaceViewController.m
//  SocialMaps
//
//  Created by Warif Rishi on 11/1/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "PlaceViewController.h"
#import "NotificationController.h"
#import "ActionSheetPicker.h"
#import "NSData+Base64.h"
#import "UtilityClass.h"
#import "RestClient.h"
#import "Place.h"

@implementation PlaceViewController

@synthesize place;
@synthesize isEditingMode;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self displayNotificationCount];
    
    photoPicker = [[PhotoPicker alloc] initWithNibName:nil bundle:nil];
    photoPicker.delegate = self;
    picSel = [[UIImagePickerController alloc] init];
	picSel.allowsEditing = YES;
	picSel.delegate = self;
    
    categoryName = [[NSMutableArray alloc] initWithObjects:@"",
                                    @"Accounting",
                                    @"Airport",
                                    @"Amusement park",
                                    @"Aquarium",
                                    @"Art gallery",
                                    @"ATM",
                                    @"Bakery",
                                    @"Bank",
                                    @"Bar",
                                    @"Beauty salon",
                                    @"Bicycle store",
                                    @"Book store",
                                    @"Bowling alley",
                                    @"Bus station",
                                    @"Cafe",
                                    @"Campground",
                                    @"Car dealer",
                                    @"Car rental",
                                    @"Car repair",
                                    @"Car wash",
                                    @"Casino",
                                    @"Cemetery",
                                    @"Church",
                                    @"City hall",
                                    @"Clothing store",
                                    @"Convenience store",
                                    @"Courthouse",
                                    @"Dentist",
                                    @"Department store",
                                    @"Doctor",
                                    @"Electrician",
                                    @"Electronics store",
                                    @"Embassy",
                                    @"Establishment",
                                    @"Finance",
                                    @"Fire station",
                                    @"Florist",
                                    @"Food",
                                    @"Funeral home",
                                    @"Furniture store",
                                    @"Gas station",
                                    @"General contractor",
                                    @"Grocery or supermarket",
                                    @"Gym",
                                    @"Hair care",
                                    @"Hardware store",
                                    @"Health",
                                    @"Hindu temple",
                                    @"Home goods store",
                                    @"Hospital",
                                    @"Insurance agency",
                                    @"Jewelry store",
                                    @"Laundry",
                                    @"Lawyer",
                                    @"Library",
                                    @"Liquor store",
                                    @"Local government office",
                                    @"Locksmith",
                                    @"Lodging",
                                    @"Meal delivery",
                                    @"Meal takeaway",
                                    @"Mosque",
                                    @"Movie rental",
                                    @"Movie theater",
                                    @"Moving company",
                                    @"Museum",
                                    @"Night club",
                                    @"Painter",
                                    @"Park",
                                    @"Parking",
                                    @"Pet store",
                                    @"Pharmacy",
                                    @"Physiotherapist",
                                    @"Place of worship",
                                    @"Plumber",
                                    @"Police",
                                    @"Post office",
                                    @"Real estate agency",
                                    @"Restaurant",
                                    @"Roofing contractor",
                                    @"Rv park",
                                    @"School",
                                    @"Shoe store",
                                    @"Shopping mall",
                                    @"Spa",
                                    @"Stadium",
                                    @"Storage",
                                    @"Store",
                                    @"Subway station",
                                    @"Synagogue",
                                    @"Taxi stand",
                                    @"Train station",
                                    @"Travel agency",
                                    @"University",
                                    @"Veterinary care",
                                    @"Zoo",nil];
    
    if (isEditingMode) 
    {
        labelSavePlace.text = @"Edit Place";
        viewEditEvent.hidden = FALSE;
        placeEdit = [[Place alloc] init];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    smAppDelegate.currentModelViewController = self;
}

-(void) displayNotificationCount 
{
    int totalNotif= [UtilityClass getNotificationCount];
    if (totalNotif == 0)
        totalNotifCount.text = @"";
    else
        totalNotifCount.text = [NSString stringWithFormat:@"%d",totalNotif];
}

- (void)setAddressLabelFromLatLon:(Place*)_place
{
    self.place = _place;
    placeEdit.placeID = self.place.placeID;
    imageViewPlace.image = self.place.photo;
    if (imageViewPlace.image)
        [buttonAddPhoto setTitle:@"Edit photo..." forState:UIControlStateNormal];
    labelAddress.text = self.place.address;
    
    selectedCatetoryIndex = 0;
    
    if (place.category) 
    {
        for (int i = 0; i < [categoryName count]; i++) 
        {
            NSString *categoryString = [[[categoryName objectAtIndex:i] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
            if ([categoryString isEqualToString:place.category] || [[categoryName objectAtIndex:i] isEqualToString:place.category]) 
            {
                selectedCatetoryIndex = i;
                break;
            }
        }
    }
}

- (void)viewDidUnload
{
    [totalNotifCount release];
    totalNotifCount = nil;
    [imageViewPlace release];
    imageViewPlace = nil;
    [labelSavePlace release];
    labelSavePlace = nil;
    [buttonAddPhoto release];
    buttonAddPhoto = nil;
    [textField release];
    textField = nil;
    [buttonName release];
    buttonName = nil;
    [buttonDescription release];
    buttonDescription = nil;
    [buttonCategory release];
    buttonCategory = nil;
    [labelAddress release];
    labelAddress = nil;
    [viewEditEvent release];
    viewEditEvent = nil;
    [viewTextInput release];
    viewTextInput = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)gotoNotification:(id)sender 
{
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    NotificationController *controller =[storybrd instantiateViewControllerWithIdentifier:@"notificationViewController"];
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
}

- (void)resetButtons:(UIButton*)sender
{
    buttonName.selected = NO;
    buttonCategory.selected = NO;
    buttonDescription.selected = NO;

    sender.selected = YES;
}

- (IBAction)actionSavePlaceButton:(id)sender 
{
    AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];   
    
    if ([place.name isEqualToString:@""]) {
        [UtilityClass showAlert:@"" :@"Please enter a place name"];
        return;
    }
    
    if (selectedCatetoryIndex == 0) {
        [UtilityClass showAlert:@"" :@"Please select a category"];
        return;
    }
    
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    [restClient SavePlace:place authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)actionBackMe:(id)sender 
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)actionNameButton:(id)sender 
{
    textField.placeholder = @"Name";
    textField.text = self.place.name;
    viewTextInput.hidden = NO;
    [textField becomeFirstResponder];
}

- (IBAction)actionDescriptionButton:(id)sender 
{
    textField.placeholder = @"Description";
    textField.text = self.place.description;
    viewTextInput.hidden = NO;
    [textField becomeFirstResponder];
}

- (IBAction)actionAddPhotoButton:(id)sender 
{
    [photoPicker getPhoto:self];
}

- (IBAction)actionDeletePhotoButton:(id)sender 
{
    imageViewPlace.image = nil;
    [buttonAddPhoto setTitle:@"Add photo..." forState:UIControlStateNormal];
}

//Delete place button action
- (IBAction)actionDeleteEventButton:(id)sender 
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"Do you want to delete %@?", place.name] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alertView show];
    [alertView release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; 
        RestClient *restClient = [[[RestClient alloc] init] autorelease];
        [restClient deletePlaceByPlaceId:@"Auth-Token" :smAppDelegate.authToken :place.placeID];
        [self dismissModalViewControllerAnimated:YES];
        [self.presentingViewController performSelector:@selector(deletePlace:) withObject:place afterDelay:.8];
    }
}

//Update place buttton action
- (IBAction)actionUpdateEventButton:(id)sender 
{
    AppDelegate *smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];   
    
    if (!placeEdit.name && !placeEdit.category && !placeEdit.base64Image && !placeEdit.description) {
        [UtilityClass showAlert:@"" :@"No change to update"];
        return;
    }
    
    if (placeEdit.name)
        place.name = placeEdit.name;
    if (placeEdit.description)
        place.description = placeEdit.description;
    if (placeEdit.category)
        place.category = placeEdit.category;
    if (imageViewPlace.image) 
        place.photo = imageViewPlace.image;

    [self.presentingViewController performSelector:@selector(reloadTableView)];
    
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    [restClient updatePlaces:@"Auth-Token" :smAppDelegate.authToken :placeEdit];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)actionSaveTextInput:(id)sender 
{
    if ([textField.placeholder isEqualToString:@"Name"]) 
    {
        if (self.isEditingMode)
            placeEdit.name = textField.text;
        else 
            self.place.name = textField.text;
            
    } 
    else if ([textField.placeholder isEqualToString:@"Description"]) 
    {
        if (self.isEditingMode)
            placeEdit.description = textField.text;
        else
            self.place.description = textField.text;
        
    }
    
    viewTextInput.hidden = YES;
    [textField resignFirstResponder];
}

- (IBAction)actionCancelTextInput:(id)sender 
{
    [textField resignFirstResponder];
    viewTextInput.hidden = YES;
}

- (IBAction)actionCategoryButton:(id)sender 
{
    [ActionSheetPicker displayActionPickerWithView:self.view data:categoryName selectedIndex:selectedCatetoryIndex target:self action:@selector(didSelectCategory::) title:@"Select a category"];
}

- (void) photoPickerDone:(bool)status image:(UIImage*)img {
    NSLog(@"PersonalInformation:photoPickerDone, status=%d", status);
    if (status == TRUE) {
        imageViewPlace.image = img;
        [buttonAddPhoto setTitle:@"Edit photo..." forState:UIControlStateNormal];
        
        NSData *imgdata = UIImagePNGRepresentation(img);
        NSString *imgBase64Data = [imgdata base64EncodedString];
        
        if (self.isEditingMode)
            placeEdit.base64Image = imgBase64Data;
        else
            place.base64Image = imgBase64Data;
    } 
    
    [photoPicker.view removeFromSuperview];
}

- (BOOL)textFieldShouldReturn:(UITextField *)_textField 
{
    if ([_textField.placeholder isEqualToString:@"Name"]) {
        self.place.name = _textField.text;
    } else if ([_textField.placeholder isEqualToString:@"Description"]) {
        self.place.description = _textField.text;
    } else if ([_textField.placeholder isEqualToString:@"Category"]) {
        self.place.category = _textField.text;
    }
    
    [_textField resignFirstResponder];
    _textField.frame = CGRectMake(11, 321, _textField.frame.size.width, textField.frame.size.height);
    
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)_textField
{
    _textField.frame = CGRectMake(11, 121, _textField.frame.size.width, textField.frame.size.height);
}

-(void)didSelectCategory:(NSNumber *)selectedIndex:(id)element 
{
    selectedCatetoryIndex = [selectedIndex intValue];
    
    if (self.isEditingMode)
        placeEdit.category = [[[categoryName objectAtIndex:selectedCatetoryIndex] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    else 
        place.category = [[[categoryName objectAtIndex:selectedCatetoryIndex] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        
    
    NSLog(@"Place.category = %@", place.category);
}
     
- (void)dealloc {
    [totalNotifCount release];
    [imageViewPlace release];
    [labelSavePlace release];
    [buttonAddPhoto release];
    [textField release];
    [buttonName release];
    [buttonDescription release];
    [buttonCategory release];
    
    [place release];
    [photoPicker release];
    [picSel release];
    
    [labelAddress release];
    [viewEditEvent release];
    [viewTextInput release];
    [super dealloc];
}
@end

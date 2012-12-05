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
#import "Globals.h"
#import "UserFriends.h"
#import "SelectCircleTableCell.h"
#import "Globals.h"

@interface UploadNewPhotoViewController ()
-(void)searchResult;
-(void) reloadScrollview;
@end

@implementation UploadNewPhotoViewController
@synthesize photoImageView,mainScrollView,upperView,lowerView,labelNotifCount,addressLabel,photoPicker,addressDetailLabel,picSel;
@synthesize photo,commentView;
@synthesize circleTableView;
@synthesize frndsScrollView,customView,segmentControl,friendSearchbar;

bool isBgTaskRunning;

AppDelegate *smAppDelegate;
NSMutableArray *neearMeAddressArr;
NSString *curAddress;
RestClient *rc;
NSMutableArray *selectedFriends;
NSMutableArray *selectedCircleCheckArr;
NSMutableArray *circleList, *ImgesName, *friendListArr, *friendsIDArr, *friendsNameArr;
NSString *searchTexts;
NSMutableArray *FriendList;
NSString *searchText;
int uploadPhotoCounter=0;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.presentingViewController retain];
    isBgTaskRunning=true;
    [self loadDummydata];    
    [self reloadScrollview];
    [customView removeFromSuperview];
    smAppDelegate.currentModelViewController = self;
    uploadPhotoCounter=0;
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
    selectedFriends=[[NSMutableArray alloc] init];
    selectedCircleCheckArr = [[NSMutableArray alloc] init];
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

    CustomRadioButton *shareRadio = [[CustomRadioButton alloc] initWithFrame:CGRectMake(25, 335, 280, 21) numButtons:5 labels:[NSArray arrayWithObjects:@"Private",@"Friends",@"Circles",@"Public",@"Custom",nil]  default:0 sender:self tag:2001];
    shareRadio.delegate = self;

    NSArray *subviews = [self.friendSearchbar subviews];
    NSLog(@"%@",subviews);
    UIButton *cancelButton = [subviews objectAtIndex:2];
    cancelButton.tintColor = [UIColor grayColor];
    [lowerView addSubview:radio];
    [lowerView addSubview:shareRadio];
    smAppDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    neearMeAddressArr=[[NSMutableArray alloc] init];
    for (int i=0; i<[smAppDelegate.placeList count]; i++)
    {
        LocationItemPlace *aPlaceItem = (LocationItemPlace*)[smAppDelegate.placeList objectAtIndex:i];
        [neearMeAddressArr addObject:aPlaceItem.placeInfo.name];
        NSLog(@"aPlaceItem.placeInfo.name %@  %@ %@",aPlaceItem.placeInfo.name,aPlaceItem.placeInfo.location.latitude,aPlaceItem.placeInfo.location.longitude);
    }
    
    self.photoPicker = [[[PhotoPickerOriginalImage alloc] init] autorelease];
    self.photoPicker.delegate = self;
    self.picSel = [[UIImagePickerController alloc] init];
	self.picSel.allowsEditing = YES;
	self.picSel.delegate = self;
    
    [commentView.layer setCornerRadius:8.0f];
    [commentView.layer setBorderWidth:0.5];
    [commentView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [commentView.layer setMasksToBounds:YES];
    
    [customView.layer setCornerRadius:8.0f];
    [customView.layer setBorderWidth:1.0];
    [customView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [customView.layer setMasksToBounds:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadPhotoDone:) name:NOTIF_DO_UPLOAD_PHOTO object:nil];
    curAddress=[[NSString alloc] init];
    [self performSelector:@selector(getCurrentAddress) withObject:nil afterDelay:0];
    
    [self reloadScrollview];
    [circleTableView setHidden:YES];
    [frndsScrollView setHidden:NO];
    [friendSearchbar setHidden:NO];
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
    NSMutableString *msg=[[NSMutableString alloc] initWithString:@"Please select"];
    
    if (photo.image == NULL) {
        [msg appendString:@" image,"];
    }
    
    if ([addressLabel.text isEqualToString:@"Loading current address..."]) 
    {
        [msg appendString:@" address,"];
    }
    
    if (([commentView.text isEqualToString:@""])||([commentView.text isEqualToString:@"Image description..."]))
    {
        photo.comment=@"";
    }

    for (int i=0; i<[selectedFriends count]; i++)
    {
        [photo.permittedUsers addObject:((UserFriends *)[selectedFriends objectAtIndex:i]).userId];
    }
    for (int i=0; i<[selectedCircleCheckArr count]; i++)
    {
        UserCircle *circle=[circleListGlobalArray objectAtIndex:((NSIndexPath *)[selectedCircleCheckArr objectAtIndex:i]).row];
        NSString *circleId=circle.circleID;
        [photo.permittedCircles addObject:circleId];
        [circle release];
        [circleId release];
    }
    NSLog(@"photo.permittedUsers: %@,photo.permittedCircles: %@",photo.permittedUsers,photo.permittedCircles);
    
    if (msg.length>13)
    {
        [UtilityClass showAlert:@"Social Maps" :msg];
    }
    else {
        [rc uploadPhoto:@"Auth-Token" :smAppDelegate.authToken :photo];
        [smAppDelegate showActivityViewer:self.view];
        [smAppDelegate.window setUserInteractionEnabled:NO];
    }
}

-(IBAction)cancel:(id)sender
{
    NSLog(@"cancel");
    [commentView resignFirstResponder];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)actionNotificationButton:(id)sender {
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    NotificationController *controller =[storybrd instantiateViewControllerWithIdentifier:@"notificationViewController"];
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
}

- (IBAction)backButtonAction:(id)sender
{
    NSLog(@"self.presentedViewController %@,self.presentingViewController %@",self.presentedViewController,self.presentingViewController);
    [self dismissModalViewControllerAnimated:YES];
}

-(void)dissmissView
{
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)segmentChanged:(id)sender
{
    if (segmentControl.selectedSegmentIndex==0) {
        [circleTableView setHidden:YES];
        [frndsScrollView setHidden:NO];
        [friendSearchbar setHidden:NO];
    }
    else if (segmentControl.selectedSegmentIndex==1) {
        [circleTableView setHidden:NO];
        [frndsScrollView setHidden:YES];
        [friendSearchbar setHidden:YES];
    }
}

- (void) radioButtonClicked:(int)indx sender:(id)sender {
    NSLog(@"radioButtonClicked index = %d %d", indx,[sender tag]);
    [commentView resignFirstResponder];
    
    if ([sender tag] == 2000) {
        switch (indx) {
            case 2:
                [UtilityClass showAlert:@"Social Maps" :@"You have no checked in venue"];
                break;
            case 1:
                [ActionSheetPicker displayActionPickerWithView:sender data:neearMeAddressArr selectedIndex:0 target:self action:@selector(placeWasSelected::) title:@"Places near to me"];
                break;
            case 0:
                [self performSelector:@selector(getCurrentAddress) withObject:nil afterDelay:0];
                break;
            default:
                break;
        }
    }
    else if ([sender tag]==2001) 
    {
        switch (indx) {
            case 4:
                NSLog(@"index %d",indx);
            photo.permission=@"custom";
            [self.view addSubview:customView];
                break;
            case 3:
                NSLog(@"index %d",indx);
            photo.permission=@"public";
                break;
            case 2:
                NSLog(@"index %d",indx);
            photo.permission=@"circles";                
                break;
            case 1:
                NSLog(@"index %d",indx);
            photo.permission=@"friends";                
                break;
            case 0:
                NSLog(@"index %d",indx);
            photo.permission=@"private";                
                break;
            default:
                break;
        }
    }
}

-(IBAction)saveCustom:(id)sender
{
    [customView removeFromSuperview];
}

-(IBAction)cancelCustom:(id)sender
{
    [customView removeFromSuperview];
}

- (void) photoPickerDone:(bool)status image:(UIImage*)img
{
    NSLog(@"PersonalInformation:photoPickerDone, status=%d  %@", status,img);
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
//    if ((![curAddress isEqualToString:@""]) && (curAddress))
//    {
//        addressLabel.text=curAddress;
//        NSLog(@"use existing add");
//    }
//    else 
//    {
        NSLog(@"load new add");
        addressLabel.text = @"Loading current address...";
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSString *address=[UtilityClass getAddressFromLatLon:[smAppDelegate.currPosition.latitude doubleValue] withLongitude:[smAppDelegate.currPosition.longitude doubleValue]];
            if ((![address isEqual:[NSNull null]]) ||(address != NULL))
            {
                curAddress=address;
            }
            photo.address=curAddress;
            photo.location.latitude=smAppDelegate.currPosition.latitude;
            photo.location.longitude=smAppDelegate.currPosition.longitude;
            addressLabel.text=curAddress;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"get current address.");
            });
        });
//    }
}

- (void)uploadPhotoDone:(NSNotification *)notif
{
    if(uploadPhotoCounter==0)
    {
        NSLog(@"Photo [notif object] %@  %d %@ %@",[notif object],uploadPhotoCounter,self,self.presentingViewController);
        if ([notif.object isKindOfClass:[Photo class]])
        {            
            [smAppDelegate.myPhotoList addObject:notif.object];
            [UtilityClass showAlert:@"Social Maps" :@"Photo uploaded successfully"];
            willLoadPhotoData = TRUE;

        }
        else
        {
            [UtilityClass showAlert:@"" :@"Photo upload failed"];
        }
    }
    uploadPhotoCounter++;
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    [self performSelectorOnMainThread:@selector(dissmissView) withObject:nil waitUntilDone:YES];

}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [UtilityClass beganEditing:(UIControl *)textView];
    if (!(textView.textColor == [UIColor blackColor])) {
        if ([textView.text isEqualToString:@"Image description..."])
        {
            textView.text = @"";
        }

        textView.textColor = [UIColor blackColor];
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    else
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

-(void) reloadScrollview
{
    NSLog(@"upload create scroll init");
    if (isBgTaskRunning==true)
    {
        int x=0; //declared for imageview x-axis point    
        NSArray* subviews = [NSArray arrayWithArray: frndsScrollView.subviews];
        UIImageView *imgView;
        for (UIView* view in subviews) 
        {
            if([view isKindOfClass :[UIView class]])
            {
                [view removeFromSuperview];
            }
            else if([view isKindOfClass :[UIImageView class]])
            {
                // [view removeFromSuperview];
            }
        }  
        
        frndsScrollView.contentSize=CGSizeMake([FriendList count]*80, 100);        
        NSLog(@"event create isBgTaskRunning %i, %d",isBgTaskRunning,[FriendList count]);
        for(int i=0; i<[FriendList count];i++)               
        {
            if(i< [FriendList count]) 
            { 
                UserFriends *userFrnd=[[UserFriends alloc] init];
                userFrnd=[FriendList objectAtIndex:i];
                imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
                
                if ((userFrnd.imageUrl==NULL)||[userFrnd.imageUrl isEqual:[NSNull null]])
                {
                    imgView.image = [UIImage imageNamed:@"blank.png"];
                } 
                else if([dicImages_msg valueForKey:userFrnd.imageUrl]) 
                { 
                    //If image available in dictionary, set it to imageview 
                    imgView.image = [dicImages_msg valueForKey:userFrnd.imageUrl]; 
                } 
                else 
                { 
                    if((!isDragging_msg && !isDecliring_msg)&&([dicImages_msg objectForKey:userFrnd.imageUrl]==nil))
                        
                    {
                        //If scroll view moves set a placeholder image and start download image. 
                        [dicImages_msg setObject:[UIImage imageNamed:@"blank.png"] forKey:userFrnd.imageUrl]; 
                        [self performSelectorInBackground:@selector(DownLoad:) withObject:[NSNumber numberWithInt:i]];  
                        imgView.image = [UIImage imageNamed:@"blank.png"];                   
                    }
                    else 
                    { 
                        // Image is not available, so set a placeholder image
                        imgView.image = [UIImage imageNamed:@"blank.png"];                   
                    }               
                }
                //            NSLog(@"userFrnd.imageUrl: %@",userFrnd.imageUrl);
                UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(x, 0, 80, 80)];
                //                UIView *secView=[[UIView alloc] initWithFrame:CGRectMake(x, 0, 65, 65)];
                UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(0, 70, 80, 20)];
                [name setFont:[UIFont fontWithName:@"Helvetica-Light" size:10]];
                [name setNumberOfLines:0];
                [name setText:userFrnd.userName];
                [name setBackgroundColor:[UIColor clearColor]];
                imgView.userInteractionEnabled = YES;
                imgView.tag = i;
                aView.tag=i;
                imgView.exclusiveTouch = YES;
                imgView.clipsToBounds = NO;
                imgView.opaque = YES;
                imgView.layer.borderColor=[[UIColor clearColor] CGColor];
                imgView.userInteractionEnabled=YES;
                imgView.layer.borderWidth=2.0;
                imgView.layer.masksToBounds = YES;
                [imgView.layer setCornerRadius:7.0];
                imgView.layer.borderColor=[[UIColor lightGrayColor] CGColor];                    
                for (int c=0; c<[selectedFriends count]; c++)
                {
                    if ([[FriendList objectAtIndex:i] isEqual:[selectedFriends objectAtIndex:c]]) 
                    {
                        imgView.layer.borderColor=[[UIColor greenColor] CGColor];
                        NSLog(@"found selected: %@",[selectedFriends objectAtIndex:c]);
                    }
                    else
                    {
                    }
                }
                [aView addSubview:imgView];
                [aView addSubview:name];
                UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
                tapGesture.numberOfTapsRequired = 1;
                [aView addGestureRecognizer:tapGesture];
                [tapGesture release];           
                [frndsScrollView addSubview:aView];
            }        
            x+=80;
        }
    }
}

-(void)DownLoad:(NSNumber *)path
{
    if (isBgTaskRunning==true)
    {
        //    NSAutoreleasePool *pl = [[NSAutoreleasePool alloc] init];
        int index = [path intValue];
        UserFriends *userFrnd=[[UserFriends alloc] init];
        userFrnd=[FriendList objectAtIndex:index];
        
        NSString *Link = userFrnd.imageUrl;
        //Start download image from url
        UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:Link]]];
        if(img)
        {
            //If download complete, set that image to dictionary
            [dicImages_msg setObject:img forKey:userFrnd.imageUrl];
            [self reloadScrollview];
        }
        // Now, we need to reload scroll view to load downloaded image
        //    [self performSelectorOnMainThread:@selector(reloadScrollview) withObject:path waitUntilDone:NO];
        //    [pl release];
    }
}

//handling selection from scroll view of friends selection
-(IBAction) handleTapGesture:(UIGestureRecognizer *)sender
{
    //    int imageIndex =((UITapGestureRecognizer *)sender).view.tag;
    NSArray* subviews = [NSArray arrayWithArray: frndsScrollView.subviews];
    if ([selectedFriends containsObject:[FriendList objectAtIndex:[sender.view tag]]])
    {
        [selectedFriends removeObject:[FriendList objectAtIndex:[sender.view tag]]];
    } 
    else 
    {
        [selectedFriends addObject:[FriendList objectAtIndex:[sender.view tag]]];
    }
    UserFriends *frnds=[[UserFriends alloc] init];
    frnds=[FriendList objectAtIndex:[sender.view tag]];
    NSLog(@"selectedFriends : %@ %@",selectedFriends,frndsScrollView);
    for (int l=0; l<[subviews count]; l++)
    {
        UIView *im=[subviews objectAtIndex:l];
        NSArray* subviews1 = [NSArray arrayWithArray: im.subviews];
        UIImageView *im1=[subviews1 objectAtIndex:0];
        
        if ([im1.image isEqual:frnds.userProfileImage])
        {
            [im1 setAlpha:1.0];
            im1.layer.borderWidth=2.0;
            im1.layer.masksToBounds = YES;
            [im1.layer setCornerRadius:7.0];
            im1.layer.borderColor=[[UIColor greenColor]CGColor];
        }
        //        else
        //        {
        //            UIView *im1=[subviews objectAtIndex:l];
        //            NSArray* subviews2 = [NSArray arrayWithArray: im1.subviews];
        //            UIImageView *im2=[subviews2 objectAtIndex:0];
        //            [im2 setAlpha:0.4];
        //            im2.layer.borderWidth=2.0;
        //            im2.layer.borderColor=[[UIColor lightGrayColor]CGColor];
        //        }
    }
    [self reloadScrollview];
}

//table view delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [circleList count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"circleTableCell";
    
    SelectCircleTableCell *cell = [circleTableView
                                   dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil)
    {
        cell = [[SelectCircleTableCell alloc]
                initWithStyle:UITableViewCellStyleDefault 
                reuseIdentifier:CellIdentifier];
        
    }
    
    // Configure the cell...
    if ([[circleList objectAtIndex:indexPath.row] isEqual:[NSNull null]]) 
    {
        cell.circrcleName.text=[NSString stringWithFormat:@"Custom (%d)",[((UserCircle *)[circleListGlobalArray objectAtIndex:indexPath.row]).friends count]] ;
    }
    else 
    {
        [((UserCircle *)[circleListGlobalArray objectAtIndex:indexPath.row]).friends count];
        cell.circrcleName.text=[NSString stringWithFormat:@"%@ (%d)",[circleList objectAtIndex:indexPath.row],[((UserCircle *)[circleListGlobalArray objectAtIndex:indexPath.row]).friends count]] ;
    }
    
    if ([selectedCircleCheckArr containsObject:indexPath]) 
    {
        [cell.circrcleCheckbox setImage:[UIImage imageNamed:@"people_checked.png"] forState:UIControlStateNormal];
    }
    else
    {
        [cell.circrcleCheckbox setImage:[UIImage imageNamed:@"list_uncheck.png"] forState:UIControlStateNormal];
    }
    
    [cell.circrcleCheckbox addTarget:self action:@selector(handleTableViewCheckbox:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)handleTableViewCheckbox:(id)sender
{
    SelectCircleTableCell *clickedCell = (SelectCircleTableCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.circleTableView indexPathForCell:clickedCell];
    //    [clickedCell.9 setImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
    if ([selectedCircleCheckArr containsObject:clickedButtonPath])
    {
        [selectedCircleCheckArr removeObject:clickedButtonPath];
        [clickedCell.circrcleCheckbox setImage:[UIImage imageNamed:@"list_uncheck.png"] forState:UIControlStateNormal];
    }
    else
    {
        [selectedCircleCheckArr addObject:clickedButtonPath];
        [clickedCell.circrcleCheckbox setImage:[UIImage imageNamed:@"people_checked.png"] forState:UIControlStateNormal];
    }
    NSLog(@"selectedCircleCheckArr: %@",selectedCircleCheckArr);    
}

-(void)loadDummydata
{
    circleList=[[NSMutableArray alloc] init];
    [circleList removeAllObjects];
    UserCircle *circle=[[UserCircle alloc]init];
    for (int i=0; i<[circleListGlobalArray count]; i++)
    {
        circle=[circleListGlobalArray objectAtIndex:i];
        [circleList addObject:circle.circleName];
    }
    UserFriends *frnds=[[UserFriends alloc] init];
    ImgesName = [[NSMutableArray alloc] init];    
    searchTexts=[[NSString alloc] initWithString:@""];
    friendsNameArr=[[NSMutableArray alloc] init];
    friendsIDArr=[[NSMutableArray alloc] init];
    FriendList=[[NSMutableArray alloc] init];
    friendListArr=[[NSMutableArray alloc] init];

    for (int i=0; i<[friendListGlobalArray count]; i++)
    {
        frnds=[[UserFriends alloc] init];
        frnds=[friendListGlobalArray objectAtIndex:i];
        if ((frnds.imageUrl==NULL)||[frnds.imageUrl isEqual:[NSNull null]])
        {
            frnds.imageUrl=[[NSBundle mainBundle] pathForResource:@"blank" ofType:@"png"];
            NSLog(@"img url null %d",i);
        }
        else
        {
            NSLog(@"img url not null %d",i);            
        }
        NSLog(@"frnds.imageUrl %@  frnds.userName %@ frnds.userId %@",frnds.imageUrl,frnds.userName,frnds.userId);
        [friendListArr addObject:frnds];
    }    
    FriendList=[friendListArr mutableCopy];
    //    NSLog(@"smAppDelegate.placeList %@",smAppDelegate.placeList);
    
}

//search bar delegate method starts
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText 
{
    // We don't want to do anything until the user clicks 
    // the 'Search' button.
    // If you wanted to display results as the user types 
    // you would do that here.
    //[self loadFriendListsData]; TODO: commented this
    if (searchBar==friendSearchbar)
    {
        searchText=friendSearchbar.text;
        
        if ([searchText length]>0) 
        {
            [self performSelector:@selector(searchResult) withObject:nil afterDelay:0.1];
            NSLog(@"searchText  %@",searchText);
        }
        else
        {
            searchText=@"";
            //[self loadFriendListsData]; TODO: commented this
            [FriendList removeAllObjects];
            FriendList = [[NSMutableArray alloc] initWithArray: friendListArr];
            [self reloadScrollview];
        }
        
        
    }
    else
    {
        
    }
    searchText=friendSearchbar.text;
    
    if ([searchText length]>0) 
    {
        [self performSelector:@selector(searchResult) withObject:nil afterDelay:0.1];
        NSLog(@"searchText  %@",searchText);
    }
    else
    {
        searchText=@"";
        //[self loadFriendListsData]; TODO: commented this
        [FriendList removeAllObjects];
        FriendList = [[NSMutableArray alloc] initWithArray: friendListArr];
        [self reloadScrollview];
    }
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar 
{
    // searchBarTextDidBeginEditing is called whenever 
    // focus is given to the UISearchBar
    // call our activate method so that we can do some 
 
        searchTexts=friendSearchbar.text;
        [UtilityClass beganEditing:(UIControl *)friendSearchbar];
        
 
    [UIView beginAnimations:@"FadeIn" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView commitAnimations];
    NSLog(@"2");    
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar 
{
    // searchBarTextDidEndEditing is fired whenever the 
    // UISearchBar loses focus
    // We don't need to do anything here.
    //    [self.eventListTableView reloadData];
    [UtilityClass endEditing];
    [friendSearchbar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // Clear the search text
    // Deactivate the UISearchBar
        friendSearchbar.text=@"";
        searchTexts=@"";    
        [FriendList removeAllObjects];
        FriendList = [[NSMutableArray alloc] initWithArray: friendListArr];
        [self reloadScrollview];
        [friendSearchbar resignFirstResponder];
        NSLog(@"3");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar 
{
    // Do the search and show the results in tableview
    // Deactivate the UISearchBar
    // You'll probably want to do this on another thread
    // SomeService is just a dummy class representing some 
    // api that you are using to do the search
    {
        NSLog(@"Search button clicked");
        searchTexts=friendSearchbar.text;
        [self searchResult];
        [friendSearchbar resignFirstResponder];    
    }
}

-(void)searchResult
{
    [self loadDummydata];
    searchTexts = friendSearchbar.text;
    NSLog(@"in search method..");
    
    [FriendList removeAllObjects];
    
    if ([searchTexts isEqualToString:@""])
    {
        NSLog(@"null string");
        friendSearchbar.text=@"";
        FriendList = [[NSMutableArray alloc] initWithArray: friendListArr];
    }
    else
    {
        NSLog(@"filteredList999 %@ %@  %d  %d  imageDownloadsInProgress: %@",FriendList,friendListArr,[FriendList count],[friendListArr count], dicImages_msg);
        
        for (UserFriends *sTemp in friendListArr)
        {
            NSRange titleResultsRange = [sTemp.userName rangeOfString:searchTexts options:NSCaseInsensitiveSearch];		
            NSLog(@"sTemp.userName: %@",sTemp.userName);
            if (titleResultsRange.length > 0)
            {
                [FriendList addObject:sTemp];
                NSLog(@"filtered friend: %@", sTemp.userName);            
            }
            else
            {
            }
        }
    }
    
    NSLog(@"filteredList %@ %@  %d  %d  imageDownloadsInProgress: %@",FriendList,friendListArr,[FriendList count],[friendListArr count], dicImages_msg);
    [self reloadScrollview];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    isBgTaskRunning=false;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_DO_UPLOAD_PHOTO object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

//
//  MyPhotosViewController.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 10/29/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "MyPhotosViewController.h"
#import "UserFriends.h"
#import "Globals.h"
#import "NotificationController.h"
#include <QuartzCore/QuartzCore.h>
#import "UtilityClass.h"
#import "RestClient.h"
#import "AppDelegate.h"
#import "Globals.h"

@interface MyPhotosViewController ()
-(void)scrollToPage:(int)page:(BOOL)animated;
@end

@implementation MyPhotosViewController
@synthesize photoScrollView,customScrollView,zoomView,labelNotifCount;
@synthesize prevButton,nextButton;
NSMutableArray *selectedFriendsIndex, *filteredList1, *filteredList2, *customSelectedFriendsIndex;

BOOL isBackgroundTaskRunning,isDragging_msg,isDecliring_msg;
int zoomIndex,getAllPhotoCounter=0;
RestClient *rc;
AppDelegate *smAppdelegate;
NSMutableDictionary *photoDic;

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
    selectedFriendsIndex=[[NSMutableArray alloc] init];
    filteredList1=[[NSMutableArray alloc] init];
    filteredList2=[[NSMutableArray alloc] init];
    customSelectedFriendsIndex=[[NSMutableArray alloc] init];
    isBackgroundTaskRunning=true;
    [prevButton setHidden:YES];
    photoDic = [[NSMutableDictionary alloc] init];
    rc=[[RestClient alloc] init];
    smAppdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUserAllPhotoDone:) name:NOTIF_GET_USER_ALL_PHOTO object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePhotoDone:) name:NOTIF_DELETE_USER_PHOTO_DONE object:nil];
    [smAppdelegate showActivityViewer:self.view];
    [smAppdelegate.window setUserInteractionEnabled:NO];
    [rc getPhotos:@"Auth-Token" :smAppdelegate.authToken];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self displayNotificationCount];
    [zoomView removeFromSuperview];
    isBackgroundTaskRunning=true;
    getAllPhotoCounter=0;
    if (willLoadPhotoData==TRUE)
    {
        [self loadData:smAppdelegate.myPhotoList];
        [self reloadScrolview];
    }
    else
    {
        [self reloadScrolview];
    }
    
    smAppdelegate.currentModelViewController = self;
}

-(void) displayNotificationCount {
    int totalNotif= [UtilityClass getNotificationCount];
    if (totalNotif == 0)
        labelNotifCount.text = @"";
    else
        labelNotifCount.text = [NSString stringWithFormat:@"%d",totalNotif];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    isBackgroundTaskRunning=false;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [photoDic release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_USER_ALL_PHOTO object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_DELETE_USER_PHOTO_DONE object:nil];
    // Release any retained subviews of the main view.
}

-(void) dealloc
{
    [super dealloc];
    photoDic = nil;
}

- (IBAction)backButtonAction:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)actionNotificationButton:(id)sender {
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    NotificationController *controller =[storybrd instantiateViewControllerWithIdentifier:@"notificationViewController"];
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
}


-(IBAction)closeZoomView:(id)sender
{
    CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];	
	[[self.view layer] addAnimation:animation forKey:@"layerAnimation"];
    [zoomView removeFromSuperview];
}

-(IBAction)viewPrevImage:(id)sender
{
    NSLog(@"view previous img");
    [self scrollToPage:zoomIndex-1:YES];
}

-(IBAction)viewNextImage:(id)sender
{
    NSLog(@"view next img");
    [self scrollToPage:zoomIndex+1:YES];
}

-(IBAction)myPhotosAction:(id)sender
{
    NSLog(@"my photos");
}

-(IBAction)uploadNewPhotoAction:(id)sender
{
    NSLog(@"upload photos");   
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"PhotoStoryboard" bundle:nil];
    UIViewController* initialHelpView = [storyboard instantiateViewControllerWithIdentifier:@"uploadNewPhotoViewController"];
    
    initialHelpView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:initialHelpView animated:YES];
}

-(IBAction)deleteSelectedPhotosAction:(id)sender
{
    NSLog(@"delete photos");
    if ([selectedFriendsIndex count]>0) {
        [smAppdelegate.window setUserInteractionEnabled:NO];
        [smAppdelegate showActivityViewer:self.view];
        [rc deletePhotoByPhotoId:@"Auth-Token" :smAppdelegate.authToken :((Photo *)[selectedFriendsIndex objectAtIndex:0]).photoId];
    }
    else if ([filteredList1 count]==0)
    {
        [UtilityClass showAlert:@"" :@"You have no photo"];    }
    else
    {
        [UtilityClass showAlert:@"" :@"Please select a photo"];
    }
}

-(IBAction)gotoZoomView:(id)sender
{
    [self scrollToPage:[sender tag]:NO];
    CGFloat xpos = self.view.frame.origin.x;
    CGFloat ypos = self.view.frame.origin.y;
    zoomView.frame = CGRectMake(xpos+100,ypos+150,5,5);
    [UIView beginAnimations:@"Zoom" context:NULL];
     [UIView setAnimationDuration:0.8];
     zoomView.frame = CGRectMake(xpos, ypos-20, 320, 460);
     [UIView commitAnimations];
    [self.view addSubview:zoomView];
    NSLog(@"tag: %d",[sender tag]);
}
//lazy scroller

-(void) reloadScrolview
{
    NSLog(@"event create scroll init");
    if (isBackgroundTaskRunning==true)
    {
        int x=0; //declared for imageview x-axis point    
        int x2=0; //declared for imageview x-axis point
        int y=0;
        NSArray* subviews = [NSArray arrayWithArray:photoScrollView.subviews];
        UIImageView *imgView;
        for (UIView* view in subviews) 
        {
            if([view isKindOfClass :[UIView class]])
            {
                [view removeFromSuperview];
            }
            else if([view isKindOfClass :[UIImageView class]])
            {
            }
        }
        NSArray* subviews1 = [NSArray arrayWithArray: customScrollView.subviews];
        for (UIView* view in subviews1) 
        {
            if([view isKindOfClass :[UIView class]])
            {
                [view removeFromSuperview];
            }
            else if([view isKindOfClass :[UIImageView class]])
            {
            }
        }   
        
        photoScrollView.contentSize=CGSizeMake(320,(ceilf([filteredList1 count]/4.0))*90);
        customScrollView.contentSize=CGSizeMake([filteredList2 count]*320, 460);
        
        NSLog(@"event create isBackgroundTaskRunning %i",isBackgroundTaskRunning);
        for(int i=0; i<[filteredList1 count];i++)               
        {
            if(i< [filteredList1 count]) 
            { 
                Photo *photo=[filteredList1 objectAtIndex:i];
                imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
                if ([photo isKindOfClass:[Photo class]]) {
                if ((photo.photoThum==NULL)||[photo.photoThum isEqual:[NSNull null]])
                {
                    imgView.image = [UIImage imageNamed:@"blank.png"];
                } 
                else if([photoDic valueForKey:photo.photoThum]) 
                { 
                    //If image available in dictionary, set it to imageview 
                    imgView.image = [photoDic valueForKey:photo.photoThum]; 
                } 
                else 
                { 
                    if((!isDragging_msg && !isDecliring_msg)&&([photoDic objectForKey:photo.photoThum]==nil))
                        
                    {
                        //If scroll view moves set a placeholder image and start download image. 
                        [photoDic setObject:[UIImage imageNamed:@"blank.png"] forKey:photo.photoThum];
                        [self performSelectorInBackground:@selector(DownLoadThum:) withObject:[NSNumber numberWithInt:i]];  
                        imgView.image = [UIImage imageNamed:@"blank.png"];                   
                    }
                    else 
                    { 
                        // Image is not available, so set a placeholder image
                        imgView.image = [UIImage imageNamed:@"blank.png"];                   
                    }               
                }
                x=(i%4)*80;
                y=(i/4)*90;
                UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(x+5, y, 80, 80)];
                UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(0, 70, 80, 20)];
                name.textAlignment=UITextAlignmentCenter;
                UIButton *zoomButton= [UIButton buttonWithType:UIButtonTypeCustom];;
                zoomButton.tag=i;
                zoomButton.frame=CGRectMake(45, 45, 20, 20);
                [zoomButton setBackgroundImage:[UIImage imageNamed:@"zoom_icon.png"] forState:UIControlStateNormal];
                [zoomButton addTarget:self action:@selector(gotoZoomView:) forControlEvents:UIControlEventTouchUpInside];
                [name setFont:[UIFont fontWithName:@"Helvetica-Light" size:10]];
                [name setNumberOfLines:0];
                [name setText:photo.description];
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
                imgView.contentMode=UIViewContentModeScaleAspectFit;
                imgView.layer.masksToBounds = YES;
                [imgView.layer setCornerRadius:7.0];
                imgView.layer.borderColor=[[UIColor lightGrayColor] CGColor];                    
                for (int c=0; c<[selectedFriendsIndex count]; c++)
                {
                    if ([[filteredList1 objectAtIndex:i] isEqual:[selectedFriendsIndex objectAtIndex:c]]) 
                    {
                        imgView.layer.borderColor=[[UIColor greenColor] CGColor];
                        NSLog(@"found selected: %@",[selectedFriendsIndex objectAtIndex:c]);
                    }
                    else
                    {
                    }
                }
                [aView addSubview:imgView];
                [aView addSubview:zoomButton];
                [aView addSubview:name];
                UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
                tapGesture.numberOfTapsRequired = 1;
                [imgView addGestureRecognizer:tapGesture];
                [tapGesture release];           
                [photoScrollView addSubview:aView];
                [name release];
                [imgView release];
                [aView release];
                }
            }
        }
        
        //handling custom scroller
        for(int i=0; i<[filteredList2 count];i++)               
        {
            if(i< [filteredList2 count]) 
            { 
                Photo *photo=[filteredList2 objectAtIndex:i];
                if ([photo isKindOfClass:[Photo class]]) {
                imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
                if (photo.imageUrl == nil) 
                {
                    imgView.image = [UIImage imageNamed:@"blank.png"];
                } 
                else if([photoDic valueForKey:photo.imageUrl])
                { 
                    //If image available in dictionary, set it to imageview 
                    imgView.image = [photoDic valueForKey:photo.imageUrl]; 
                } 
                else 
                { 
                    if((!isDragging_msg && !isDecliring_msg)&&([photoDic objectForKey:photo.imageUrl]==nil))
                        
                    {
                        //If scroll view moves set a placeholder image and start download image. 
                        [photoDic setObject:[photoDic valueForKey:photo.photoThum] forKey:photo.imageUrl];
                        [self performSelectorInBackground:@selector(DownLoad:) withObject:[NSNumber numberWithInt:i]];  
                        imgView.image = [photoDic valueForKey:photo.photoThum];
                        NSLog(@"scroll if %@",[photoDic valueForKey:photo.photoThum]);
                    }
                    else 
                    { 
                        // Image is not available, so set a placeholder image
                        imgView.image =[photoDic valueForKey:photo.photoThum];
                        NSLog(@"scroll else");
                    }               
                }
                UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(x2, 0, 320, 460)];
                UILabel *name=[[UILabel alloc] initWithFrame:CGRectMake(0, 45, 60, 20)];
                [name setFont:[UIFont fontWithName:@"Helvetica-Light" size:10]];
                [name setNumberOfLines:0];
                [name setText:photo.description];
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
                imgView.contentMode=UIViewContentModeScaleAspectFit;
                imgView.layer.masksToBounds = YES;
                imgView.layer.borderColor=[[UIColor lightGrayColor] CGColor];                    
                for (int c=0; c<[customSelectedFriendsIndex count]; c++)
                {
                    if ([[filteredList2 objectAtIndex:i] isEqual:[customSelectedFriendsIndex objectAtIndex:c]]) 
                    {
                        imgView.layer.borderColor=[[UIColor greenColor] CGColor];
                        NSLog(@"found selected: %@",[customSelectedFriendsIndex objectAtIndex:c]);
                    }
                    else
                    {
                    }
                }
                [aView addSubview:imgView];
                [customScrollView addSubview:aView];
                [aView release];
                [name release];
                [imgView release];
                }
            }
            x2+=320;
        }
    }
}

-(void)scrollToPage:(int)page:(BOOL)animated
{
    CGRect frame = customScrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [customScrollView scrollRectToVisible:frame animated:animated];
}

-(void)loadData:(NSMutableArray *)photoListArr
{
    smAppdelegate.myPhotoList=photoListArr;
    filteredList1=[photoListArr mutableCopy];
    filteredList2=[photoListArr mutableCopy];
    [filteredList1 retain];
    [filteredList2 retain];
    [selectedFriendsIndex retain];
    NSLog(@"filtered count: %d",[filteredList1 count]);
}

-(void)DownLoad:(NSNumber *)path
{
    if (isBackgroundTaskRunning==true)
    {
        int index = [path intValue];
        Photo *photo=[filteredList1 objectAtIndex:index];
        NSLog(@"DL large image called");
        NSString *Link = photo.imageUrl;
        //Start download image from url
        UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:Link]]];
        if(img)
        {
            //If download complete, set that image to dictionary
            [photoDic setObject:img forKey:photo.imageUrl];
            [self reloadScrolview];
        }
        [img release];
        // Now, we need to reload scroll view to load downloaded image
    }
}

-(void)DownLoadThum:(NSNumber *)path
{
    if (isBackgroundTaskRunning==true)
    {
        int index = [path intValue];
        Photo *photo=[filteredList1 objectAtIndex:index];
        
        NSString *Link = photo.photoThum;
        //Start download image from url
        UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:Link]]];
        if(img)
        {
            //If download complete, set that image to dictionary
            [photoDic setObject:img forKey:photo.photoThum];
            [self reloadScrolview];
        }
        [img release];
        // Now, we need to reload scroll view to load downloaded image
    }
}

//handling selection from scroll view of friends selection
-(IBAction) handleTapGesture:(UIGestureRecognizer *)sender
{
    [selectedFriendsIndex retain];
    NSArray* subviews = [NSArray arrayWithArray: photoScrollView.subviews];
    if ([selectedFriendsIndex containsObject:[filteredList1 objectAtIndex:[sender.view tag]]])
    {
        [selectedFriendsIndex removeObject:[filteredList1 objectAtIndex:[sender.view tag]]];
    } 
    else 
    {
        [selectedFriendsIndex removeAllObjects];
        [selectedFriendsIndex addObject:[filteredList1 objectAtIndex:[sender.view tag]]];
    }
    Photo *photo=[filteredList1 objectAtIndex:[sender.view tag]];
    NSLog(@"selectedFriendsIndex2 : %@",selectedFriendsIndex);
    for (int l=0; l<[subviews count]; l++)
    {
        UIView *im=[subviews objectAtIndex:l];
        NSArray* subviews1 = [NSArray arrayWithArray: im.subviews];
        UIImageView *im1=[subviews1 objectAtIndex:0];
        
        if ([im1.image isEqual:photo.photoImage])
        {
            [im1 setAlpha:1.0];
            im1.layer.borderWidth=2.0;
            im1.layer.masksToBounds = YES;
            [im1.layer setCornerRadius:7.0];
            im1.layer.borderColor=[[UIColor greenColor]CGColor];
        }
    }
    [self reloadScrolview];
}

//handling selection from custom scroll view of friends selection
-(IBAction) customScrollhandleTapGesture:(UIGestureRecognizer *)sender
{
    NSArray* subviews = [NSArray arrayWithArray: customScrollView.subviews];
    if ([customSelectedFriendsIndex containsObject:[filteredList2 objectAtIndex:[sender.view tag]]])
    {
        [customSelectedFriendsIndex removeObject:[filteredList2 objectAtIndex:[sender.view tag]]];
    } 
    else 
    {
        [customSelectedFriendsIndex addObject:[filteredList2 objectAtIndex:[sender.view tag]]];
    }
    UserFriends *frnds=[filteredList2 objectAtIndex:[sender.view tag]];
    NSLog(@"selectedFriendsIndex2 : %@",selectedFriendsIndex);
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
    }
    [self reloadScrolview];
}

- (void)getUserAllPhotoDone:(NSNotification *)notif
{
    NSLog(@"get user all photo %d",[[notif object] count]);
    willLoadPhotoData = FALSE;
    [smAppdelegate.window setUserInteractionEnabled:YES];
    [smAppdelegate hideActivityViewer];
    if (getAllPhotoCounter==0)
    {
        if ([notif.object isKindOfClass:[NSMutableArray class]])
        {
            if ([[notif object] count]==0)
            {
                [UtilityClass showAlert:@"Social Maps" :@"No photos found"];
            }
            [self loadData:[notif object]];
            [self reloadScrolview];
        }
        else
        {
            [UtilityClass showAlert:@"Social Maps" :@"Network error, please try again"];
        }
    }
}

- (void)deletePhotoDone:(NSNotification *)notif
{
    NSLog(@"delete done %@",selectedFriendsIndex);
    [UtilityClass showAlert:@"Social Maps" :[notif object]];
    willLoadPhotoData = FALSE;
    [smAppdelegate.window setUserInteractionEnabled:YES];
    [smAppdelegate hideActivityViewer];
    [filteredList1 removeObject:[selectedFriendsIndex objectAtIndex:0]];
    [filteredList2 removeObject:[selectedFriendsIndex objectAtIndex:0]];
    [smAppdelegate.myPhotoList removeObject:[selectedFriendsIndex objectAtIndex:0]];
    [selectedFriendsIndex removeAllObjects];
    [self reloadScrolview];
}


//scroll view delegate method
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    isDragging_msg = FALSE;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    isDecliring_msg = FALSE;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    isDragging_msg = TRUE;
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    isDecliring_msg = TRUE;
}
- (void)scrollViewDidScroll:(UIScrollView *)sender 
{
    if (sender==customScrollView) {
        CGFloat pageWidth = customScrollView.frame.size.width;
        int page = floor((customScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        zoomIndex=page;
        if (page==0) 
        {
            [nextButton setHidden:NO];
            [prevButton setHidden:YES];
        }
        else if (page==[filteredList2 count]-1) {
            [nextButton setHidden:YES];
            [prevButton setHidden:NO];
        }
        else {
            [prevButton setHidden:NO];
            [nextButton setHidden:NO];
        }
    }
    // Switch the indicator when more than 50% of the previous/next page is visible
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    // A possible optimization would be to unload the views+controllers which are no longer visible
}
//lazy load method ends

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

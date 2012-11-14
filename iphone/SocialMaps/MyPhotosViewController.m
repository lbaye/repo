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
NSMutableDictionary *dicImages_msg;
NSMutableArray *selectedFriendsIndex, *filteredList1, *filteredList2, *customSelectedFriendsIndex;

BOOL isBackgroundTaskRunning,isDragging_msg,isDecliring_msg;
int zoomIndex;
RestClient *rc;
AppDelegate *smAppdelegate;

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
    dicImages_msg=[[NSMutableDictionary alloc] init];
    selectedFriendsIndex=[[NSMutableArray alloc] init];
    filteredList1=[[NSMutableArray alloc] init];
    filteredList2=[[NSMutableArray alloc] init];
    customSelectedFriendsIndex=[[NSMutableArray alloc] init];
    isBackgroundTaskRunning=true;
    [prevButton setHidden:YES];
    rc=[[RestClient alloc] init];
    smAppdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUserAllPhotoDone:) name:NOTIF_GET_USER_ALL_PHOTO object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePhotoDone:) name:NOTIF_DELETE_USER_PHOTO_DONE object:nil];
    //    [self reloadScrolview];
    [smAppdelegate showActivityViewer:self.view];
    [smAppdelegate.window setUserInteractionEnabled:NO];
    [rc getPhotos:@"Auth-Token" :smAppdelegate.authToken];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    labelNotifCount.text = [NSString stringWithFormat:@"%d", [UtilityClass getNotificationCount]];
    [zoomView removeFromSuperview];
    isBackgroundTaskRunning=true;
    
    if (willLoadPhotoData==TRUE)
    {
        [smAppdelegate showActivityViewer:self.view];
        [smAppdelegate.window setUserInteractionEnabled:NO];
        NSLog(@"load all photos");
        [rc getPhotos:@"Auth-Token" :smAppdelegate.authToken];
    }
    else
    {
        [self reloadScrolview];
    }
    
    smAppdelegate.currentModelViewController = self;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    isBackgroundTaskRunning=false;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
    [UIView beginAnimations:@"FadeIn" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView commitAnimations];
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
//    ((Photo *)[selectedFriendsIndex objectAtIndex:0]).photoId
    [smAppdelegate.window setUserInteractionEnabled:NO];
    [smAppdelegate showActivityViewer:self.view];
    [rc deletePhotoByPhotoId:@"Auth-Token" :smAppdelegate.authToken :((Photo *)[selectedFriendsIndex objectAtIndex:0]).photoId];
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
                // [view removeFromSuperview];
            }
        }
        NSArray* subviews1 = [[NSArray arrayWithArray: customScrollView.subviews] mutableCopy];
        for (UIView* view in subviews1) 
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
        
        photoScrollView.contentSize=CGSizeMake(320,(ceilf([filteredList1 count]/4.0))*90);
        customScrollView.contentSize=CGSizeMake([filteredList2 count]*320, 460);
        
        NSLog(@"event create isBackgroundTaskRunning %i",isBackgroundTaskRunning);
        for(int i=0; i<[filteredList1 count];i++)               
        {
            if(i< [filteredList1 count]) 
            { 
                Photo *photo=[[Photo alloc] init];
                photo=[filteredList1 objectAtIndex:i];
                imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
                
                if ((photo.imageUrl==NULL)||[photo.imageUrl isEqual:[NSNull null]])
                {
                    imgView.image = [UIImage imageNamed:@"blank.png"];
                } 
                else if([dicImages_msg valueForKey:photo.imageUrl]) 
                { 
                    //If image available in dictionary, set it to imageview 
                    imgView.image = [dicImages_msg valueForKey:photo.imageUrl]; 
                } 
                else 
                { 
                    if((!isDragging_msg && !isDecliring_msg)&&([dicImages_msg objectForKey:photo.imageUrl]==nil))
                        
                    {
                        //If scroll view moves set a placeholder image and start download image. 
                        [dicImages_msg setObject:[UIImage imageNamed:@"blank.png"] forKey:photo.imageUrl]; 
                        [self performSelectorInBackground:@selector(DownLoad:) withObject:[NSNumber numberWithInt:i]];  
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
            }        
        }
        
        //handling custom scroller
        for(int i=0; i<[filteredList2 count];i++)               
        {
            if(i< [filteredList2 count]) 
            { 
                Photo *photo=[[Photo alloc] init];
                photo=[filteredList2 objectAtIndex:i];
                imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
                if (photo.imageUrl == nil) 
                {
                    imgView.image = [UIImage imageNamed:@"blank.png"];
                } 
                else if([dicImages_msg valueForKey:photo.imageUrl]) 
                { 
                    //If image available in dictionary, set it to imageview 
                    imgView.image = [dicImages_msg valueForKey:photo.imageUrl]; 
                } 
                else 
                { 
                    if((!isDragging_msg && !isDecliring_msg)&&([dicImages_msg objectForKey:photo.imageUrl]==nil)) 
                        
                    {
                        //If scroll view moves set a placeholder image and start download image. 
                        [dicImages_msg setObject:[UIImage imageNamed:@"blank.png"] forKey:photo.imageUrl]; 
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
                UIView *aView=[[UIView alloc] initWithFrame:CGRectMake(x2, 0, 320, 460)];
                //                UIView *secView=[[UIView alloc] initWithFrame:CGRectMake(x2, 0, 65, 65)];
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
                imgView.layer.masksToBounds = YES;
                [imgView.layer setCornerRadius:7.0];
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
//                [aView addSubview:name];
//                UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(customScrollhandleTapGesture:)];
//                tapGesture.numberOfTapsRequired = 1;
//                [aView addGestureRecognizer:tapGesture];
//                [tapGesture release];           
                [customScrollView addSubview:aView];
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
    Photo *photo=[[Photo alloc] init];
    filteredList1=[[NSMutableArray alloc] init];
//    for (int i=0; i<[photoListArr count]; i++)
//    {
//        photo=[[Photo alloc] init];
//        [photoListArr addObject:photo];
//        NSLog(@"photo.imageUrl %@  photo.desc %@ photo.imgId %@",photo.imageUrl,photo.description,photo.photoId);
//    }
    filteredList1=[photoListArr mutableCopy];
    filteredList2=[photoListArr mutableCopy];
    NSLog(@"filtered count: %d",[filteredList1 count]);
}

-(void)DownLoad:(NSNumber *)path
{
    if (isBackgroundTaskRunning==true)
    {
        //    NSAutoreleasePool *pl = [[NSAutoreleasePool alloc] init];
        int index = [path intValue];
        Photo *photo=[[Photo alloc] init];
        photo=[filteredList1 objectAtIndex:index];
        
        NSString *Link = photo.imageUrl;
        //Start download image from url
        UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:Link]]];
        if(img)
        {
            //If download complete, set that image to dictionary
            [dicImages_msg setObject:img forKey:photo.imageUrl];
            [self reloadScrolview];
        }
        // Now, we need to reload scroll view to load downloaded image
        //    [self performSelectorOnMainThread:@selector(reloadScrolview) withObject:path waitUntilDone:NO];
        //    [pl release];
    }
}

//handling selection from scroll view of friends selection
-(IBAction) handleTapGesture:(UIGestureRecognizer *)sender
{
    //    int imageIndex =((UITapGestureRecognizer *)sender).view.tag;
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
    Photo *photo=[[Photo alloc] init];
    photo=[filteredList1 objectAtIndex:[sender.view tag]];
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
    [self reloadScrolview];
}

//handling selection from custom scroll view of friends selection
-(IBAction) customScrollhandleTapGesture:(UIGestureRecognizer *)sender
{
    //    int imageIndex =((UITapGestureRecognizer *)sender).view.tag;
    NSArray* subviews = [NSArray arrayWithArray: customScrollView.subviews];
    if ([customSelectedFriendsIndex containsObject:[filteredList2 objectAtIndex:[sender.view tag]]])
    {
        [customSelectedFriendsIndex removeObject:[filteredList2 objectAtIndex:[sender.view tag]]];
    } 
    else 
    {
        [customSelectedFriendsIndex addObject:[filteredList2 objectAtIndex:[sender.view tag]]];
    }
    UserFriends *frnds=[[UserFriends alloc] init];
    frnds=[filteredList2 objectAtIndex:[sender.view tag]];
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
    if ([[notif object] count]==0) 
    {
        [UtilityClass showAlert:@"Social Maps" :@"No photos found"];
    }
    [self loadData:[notif object]];
    [self reloadScrolview];
}

- (void)deletePhotoDone:(NSNotification *)notif
{
    [UtilityClass showAlert:@"Social Maps" :[notif object]];
    willLoadPhotoData = FALSE;
    [smAppdelegate.window setUserInteractionEnabled:YES];
    [smAppdelegate hideActivityViewer];
    [filteredList1 removeObject:[selectedFriendsIndex objectAtIndex:0]];
    [filteredList2 removeObject:[selectedFriendsIndex objectAtIndex:0]];
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

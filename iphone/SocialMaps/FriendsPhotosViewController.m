//
//  FriendsPhotosViewController.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 11/1/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "FriendsPhotosViewController.h"
#import "UserFriends.h"
#import "Globals.h"
#import "NotificationController.h"
#include <QuartzCore/QuartzCore.h>
#import "UtilityClass.h"
#import "RestClient.h"
#import "AppDelegate.h"
#import "Globals.h"
#import "UIImageView+Cached.h"
#import "CachedImages.h"

@interface FriendsPhotosViewController ()
-(void)scrollToPage:(int)page:(BOOL)animated;
@end

@implementation FriendsPhotosViewController

@synthesize photoScrollView, zoomScrollView, zoomView, labelNotifCount, photoLabel;
@synthesize userName, userId, nextButton, prevButton;
@synthesize photoList;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    restClient = [[RestClient alloc] init];
    smAppdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFriendsAllPhotoDone:) name:NOTIF_GET_FRIENDS_ALL_PHOTO object:nil];
    
    [photoLabel setTitle:[NSString stringWithFormat:@"Photos of %@",userName] forState:UIControlStateNormal];
    
    [smAppdelegate showActivityViewer:self.view];
    
    [restClient getFriendsPhotos:@"Auth-Token" :smAppdelegate.authToken:userId];
    
    [nextButton setHidden:NO];
    [prevButton setHidden:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self displayNotificationCount];
    [zoomView removeFromSuperview];

    smAppdelegate.currentModelViewController = self;
}

-(void) displayNotificationCount {
    int totalNotif= [UtilityClass getNotificationCount];
    if (totalNotif == 0)
        labelNotifCount.text = @"";
    else
        labelNotifCount.text = [NSString stringWithFormat:@"%d",totalNotif];
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

- (void)reloadScrolview
{
    int x = 0;
    int y = 0;
    int x2 = 0; //for zoomView
    
    [photoScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [zoomScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    photoScrollView.contentSize=CGSizeMake(320,(ceilf([photoList count]/4.0))*90);
    zoomScrollView.contentSize=CGSizeMake([photoList count]*320, 460);
    
    for(int i=0; i<[photoList count];i++)
    {
        if(i< [photoList count])
        {
            Photo *photo = [photoList objectAtIndex:i];
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
            
            if(!isDragging_msg && !isDecliring_msg)
                [imgView loadFromURL:[NSURL URLWithString:photo.photoThum]];
            
            x = (i%4) * 80;
            y = (i/4) * 90;
            
            UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(x+5, y, 80, 80)];
            
            UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(-1, 70, 80, 20)];
            name.textAlignment = UITextAlignmentCenter;
            [name setFont:[UIFont fontWithName:@"Helvetica-Light" size:10]];
            [name setNumberOfLines:0];
            [name setText:photo.description];
            [name setBackgroundColor:[UIColor clearColor]];
            
            UIButton *zoomButton = [UIButton buttonWithType:UIButtonTypeCustom];;
            zoomButton.tag = i;
            zoomButton.frame = CGRectMake(45, 45, 20, 20);
            [zoomButton setBackgroundImage:[UIImage imageNamed:@"zoom_icon.png"] forState:UIControlStateNormal];
            [zoomButton addTarget:self action:@selector(gotoZoomView:) forControlEvents:UIControlEventTouchUpInside];
            
            imgView.userInteractionEnabled = YES;
            imgView.tag = i;
            aView.tag = i;
            imgView.exclusiveTouch = YES;
            imgView.clipsToBounds = NO;
            imgView.opaque = YES;
            imgView.userInteractionEnabled=YES;
            imgView.layer.borderWidth=2.0;
            imgView.contentMode=UIViewContentModeScaleAspectFit;
            imgView.layer.masksToBounds = YES;
            [imgView.layer setCornerRadius:7.0];
            imgView.layer.borderColor=[[UIColor lightGrayColor] CGColor];
            
            [aView addSubview:imgView];
            [aView addSubview:zoomButton];
            [aView addSubview:name];
            
            [photoScrollView addSubview:aView];
            
            [name release];
            [imgView release];
            [aView release];
            
            //Big image
            UIImageView *bigImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
            UIView *viewForBigImage = [[UIView alloc] initWithFrame:CGRectMake(x2, 0, 320, 460)];
            
            bigImageView.image = nil;
            bigImageView.userInteractionEnabled = YES;
            bigImageView.tag = i;
            viewForBigImage.tag = i;
            bigImageView.exclusiveTouch = YES;
            bigImageView.clipsToBounds = NO;
            bigImageView.opaque = YES;
            bigImageView.layer.borderColor = [[UIColor clearColor] CGColor];
            bigImageView.userInteractionEnabled = YES;
            bigImageView.layer.borderWidth = 2.0;
            bigImageView.contentMode = UIViewContentModeScaleAspectFit;
            bigImageView.layer.masksToBounds = YES;
            bigImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            [viewForBigImage addSubview:bigImageView];
            [zoomScrollView addSubview:viewForBigImage];
            [viewForBigImage release];
            [bigImageView release];
        }
        
        x2 += 320;
    }
}

- (void)downloadImageAtIndex:(int)page
{
    BOOL foundImageView = FALSE;
    
    UIImageView *imgView;
    for (UIView *aView in zoomScrollView.subviews) {
        for (UIView *subView in aView.subviews) {
            if ([subView isKindOfClass:[UIImageView class]] && subView.tag == page) {
                imgView = (UIImageView*)[subView viewWithTag:page];
                foundImageView = TRUE;
                break;
            }
        }
        
        if (foundImageView) {
            break;
        }
    }
    
    if (!imgView.image)
        [imgView loadFromURLTemporaryCache:[NSURL URLWithString:[(Photo*)[photoList objectAtIndex:page] imageUrl]]];
}

-(void)scrollToPage:(int)page:(BOOL)animated
{
    [self downloadImageAtIndex:page];
    
    CGRect frame = zoomScrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [zoomScrollView scrollRectToVisible:frame animated:animated];
}

-(void)loadData:(NSMutableArray *)photoListArr
{
    self.photoList = photoListArr;
}

- (void)getFriendsAllPhotoDone:(NSNotification *)notif
{
    [smAppdelegate hideActivityViewer];
    
    if ([notif.object isKindOfClass:[NSMutableArray class]]) {
        
        if ([[notif object] count]==0)
        {
            [UtilityClass showAlert:@"Social Maps" :@"No photos found"];
        }
        else
        {
            [self loadData:[[notif object] mutableCopy]];
            [self reloadScrolview];
        }
    }
    else
    {
        [UtilityClass showAlert:@"Social Maps" :@"Network error, please try again"];
    }
    
}

//scroll view delegate method
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    isDragging_msg = FALSE;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    isDecliring_msg = FALSE;
    
    if (scrollView == zoomScrollView)
    {
        CGFloat pageWidth = zoomScrollView.frame.size.width;
        int page = floor((zoomScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        [self downloadImageAtIndex:page];
    }
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
    if (sender==zoomScrollView) {
        CGFloat pageWidth = zoomScrollView.frame.size.width;
        int page = floor((zoomScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        zoomIndex=page;
        if (page==0) 
        {
            [nextButton setHidden:NO];
            [prevButton setHidden:YES];
        }
        else if (page==[photoList count]-1) {
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

- (void)didReceiveMemoryWarning
{
    [CachedImages removeAllCache];
    
    [super didReceiveMemoryWarning];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_FRIENDS_ALL_PHOTO object:nil];
    [photoList release];
    [CachedImages removeTemporaryCache];
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

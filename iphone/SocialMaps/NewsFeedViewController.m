//
//  NewsFeedViewController.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 11/15/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "NewsFeedViewController.h"
#import "NotificationController.h"
#import "RestClient.h"
#import "UtilityClass.h"
#import "AppDelegate.h"
#import "ODRefreshControl.h"
#import "Globals.h"
#import "FriendsProfileViewController.h"
#import "UserBasicProfileViewController.h"

@interface NewsFeedViewController ()

@end

@implementation NewsFeedViewController
@synthesize newsFeedView,totalNotifCount,newsFeedScroller;

@synthesize newsfeedImgView;
@synthesize newsfeedImgFullView;
@synthesize activeDownload;
@synthesize newsFeedImageIndicator;

AppDelegate *smAppDelegate;
int newsFeedscrollHeight, reloadNewsFeedCounter=0;
UILabel *statusLabel;

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
//    newsFeedView.scrollView.delegate=self;
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:newsFeedScroller];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
//    statusLabel=[[UILabel alloc] initWithFrame:CGRectMake(120, -30, 80, 15)];
//    statusLabel.backgroundColor=[UIColor clearColor];
//    statusLabel.text=@"refresh...";
//    statusLabel.textColor=[UIColor darkGrayColor];
//    [newsFeedScroller addSubview:statusLabel];
    // Do any additional setup after loading the view from its nib.
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    double delayInSeconds = 3.0;
    [newsFeedView reload];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [refreshControl endRefreshing];
    });
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];    
    [smAppDelegate showActivityViewer:self.view];
     NSString *urlStr=[NSString stringWithFormat:@"%@/me/newsfeed.html?authToken=%@&r=%@",WS_URL,smAppDelegate.authToken,[UtilityClass convertNSDateToUnix:[NSDate date]]];
    NSLog(@"urlStr %@",urlStr);
    [self displayNotificationCount];
    [newsFeedView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];    
    smAppDelegate.currentModelViewController = self;
    [newsfeedImgFullView removeFromSuperview];
    
}

- (BOOL)webView: (UIWebView*)webView shouldStartLoadWithRequest: (NSURLRequest*)request navigationType: (UIWebViewNavigationType)navigationType {
    NSString *fragment, *scheme;
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [webView stopLoading];
        fragment = [[request URL] fragment];
        scheme = [[request URL] scheme];
        NSString *dataStr=[[request URL] absoluteString];
        NSLog(@"Data String: %@",dataStr);
        NSString *tagStr=[[dataStr componentsSeparatedByString:@":"] objectAtIndex:2];
        NSLog(@"Tag String: %@",tagStr);
        if ([tagStr isEqualToString:@"image"])
        {
            NSString *urlStr=[NSString stringWithFormat:@"%@:%@",[[dataStr componentsSeparatedByString:@":"] objectAtIndex:3],[[dataStr componentsSeparatedByString:@":"] objectAtIndex:4]];
            CGFloat xpos = self.view.frame.origin.x;
            CGFloat ypos = self.view.frame.origin.y;
            newsfeedImgFullView.frame = CGRectMake(xpos+100,ypos+150,5,5);
            [UIView beginAnimations:@"Zoom" context:NULL];
            [UIView setAnimationDuration:0.8];
            newsfeedImgFullView.frame = CGRectMake(xpos, ypos-20, 320, 460);
            [UIView commitAnimations];
            [self.view addSubview:newsfeedImgFullView];
            [newsfeedImgView setImage:[UIImage imageNamed:@"sm_icon@2x.png"]];
            [newsFeedImageIndicator startAnimating];
            [self performSelectorInBackground:@selector(loadNewsFeedImage:) withObject:urlStr];
        }
        else if ([tagStr isEqualToString:@"profile"])
        {
            NSString *userId=[[dataStr componentsSeparatedByString:@":"] objectAtIndex:3];
            NSLog(@"userID string: %@",userId);
            if ([userId isEqualToString:smAppDelegate.userId])
            {
                NSLog(@"own profile");
                UserBasicProfileViewController *controller =[[UserBasicProfileViewController alloc] init];
                controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentModalViewController:controller animated:YES];
            }
            else
            {
                FriendsProfileViewController *controller =[[FriendsProfileViewController alloc] init];
                controller.friendsId=userId;
                controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentModalViewController:controller animated:YES];
                
            }
        }
        else if ([tagStr isEqualToString:@"geotag"])
        {
            NSString *userId=[[dataStr componentsSeparatedByString:@":"] objectAtIndex:3];
            NSLog(@"geotag string: %@",userId);
        }
        
        return NO;
        [[UIApplication sharedApplication] openURL: [request URL]];
    }
    
    return YES;
}


-(void)loadNewsFeedImage:(NSString *)imageUrlStr
{
    [[newsfeedImgFullView viewWithTag:12345654] removeFromSuperview];
    NSLog(@"from dic %@",[dicImages_msg objectForKey:imageUrlStr]);
    if ([dicImages_msg objectForKey:imageUrlStr])
    {
        newsfeedImgView.image=[dicImages_msg objectForKey:imageUrlStr];
        NSLog(@"load from dic");
    }
    else
    {
        NSAutoreleasePool *pl=[[NSAutoreleasePool alloc] init];
        NSLog(@"newsfeed image url: %@",imageUrlStr);
        UIImage *img=[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrlStr]]];
        if (img)
        {
            newsfeedImgView.image=img;
            [dicImages_msg setObject:img forKey:imageUrlStr];
        }
        else
        {
            newsfeedImgView.image=[UIImage imageNamed:@"blank.png"];
        }
        
        NSLog(@"image setted after download newsfeed image. %@",img);
        [pl drain];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    reloadNewsFeedCounter=0;
    [smAppDelegate hideActivityViewer];
    CGRect frame = aWebView.frame;
    frame.size.height = 1;
    aWebView.frame = frame;
    CGSize fittingSize = [aWebView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    aWebView.frame = frame;
    newsFeedscrollHeight=newsFeedView.frame.size.height;
    NSLog(@"webview size: %f, %f", fittingSize.width, fittingSize.height);
    [newsFeedView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"];
    [newsFeedView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout = 'none'"];
    [smAppDelegate hideActivityViewer];
    [newsFeedScroller setContentSize:CGSizeMake(320, fittingSize.height)];
    NSLog(@"Frame %@ %@",NSStringFromCGSize(newsFeedScroller.contentSize),NSStringFromCGRect(newsFeedView.frame));
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [smAppDelegate hideActivityViewer];
}

-(IBAction)closeNewsfeedImgView:(id)sender
{
    CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];	
	[[self.view layer] addAnimation:animation forKey:@"layerAnimation"];
    [newsFeedImageIndicator stopAnimating];
    [newsfeedImgFullView removeFromSuperview];
}


//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
////    NSLog(@"did scroll %f",newsFeedView.scrollView.contentOffset.y);
//    if (scrollView==newsFeedScroller)
//    {
//        if (scrollView.contentOffset.y < -60 || (scrollView.contentOffset.y>(newsFeedscrollHeight+60)))
//        {
//            reloadNewsFeedCounter++;
//            if (reloadNewsFeedCounter==1) {
//                NSLog(@"At the top or bottom %f %d",scrollView.contentOffset.y,newsFeedscrollHeight);
//                [smAppDelegate showActivityViewer:self.view];
//                [newsFeedView reload];
//            }
//        }
//    }
//    else if (scrollView==newsFeedView.scrollView)
//    {
//        if (scrollView.contentOffset.y < -60 || (scrollView.contentOffset.y>(newsFeedscrollHeight+60)))
//        {
//            reloadNewsFeedCounter++;
//            if (reloadNewsFeedCounter==1) {
//                NSLog(@"At the top or bottom %f %d",scrollView.contentOffset.y,newsFeedscrollHeight);
//                [smAppDelegate showActivityViewer:self.view];
//                [newsFeedView reload];
//            }
//        }
//    }
//    
//}

-(IBAction)backButton:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)gotoNotification:(id)sender
{
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    NotificationController *controller =[storybrd instantiateViewControllerWithIdentifier:@"notificationViewController"];
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
    
}

-(void) displayNotificationCount {
    int totalNotif= [UtilityClass getNotificationCount];
    if (totalNotif == 0)
        totalNotifCount.text = @"";
    else
        totalNotifCount.text = [NSString stringWithFormat:@"%d",totalNotif];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

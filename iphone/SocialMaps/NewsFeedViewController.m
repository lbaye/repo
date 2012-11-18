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

@interface NewsFeedViewController ()

@end

@implementation NewsFeedViewController
@synthesize newsFeedView,totalNotifCount,newsFeedScroller;
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
    newsFeedView.scrollView.delegate=self;
//    statusLabel=[[UILabel alloc] initWithFrame:CGRectMake(120, -30, 80, 15)];
//    statusLabel.backgroundColor=[UIColor clearColor];
//    statusLabel.text=@"refresh...";
//    statusLabel.textColor=[UIColor darkGrayColor];
//    [newsFeedScroller addSubview:statusLabel];
    // Do any additional setup after loading the view from its nib.
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
    
}

- (BOOL)webView: (UIWebView*)webView shouldStartLoadWithRequest: (NSURLRequest*)request navigationType: (UIWebViewNavigationType)navigationType {
    NSString *fragment, *scheme;
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [webView stopLoading];
        fragment = [[request URL] fragment];
        scheme = [[request URL] scheme];
        NSLog(@"%@ scheme",[[request URL] absoluteString]);
//        [newsFeedView stringByEvaluatingJavaScriptFromString:@" window.prompt('sometext','defaultvalue');"];
        if ([[[[request URL] absoluteString] componentsSeparatedByString:@"1"] count]>0) {
            // Do custom code
            NSLog(@"got button %@",scheme);
            return NO;
        } 
        if ([scheme isEqualToString: @"button"] && [self respondsToSelector: NSSelectorFromString(fragment)]) {
            [self performSelector: NSSelectorFromString(fragment)];
            return NO;
        }
        
        [[UIApplication sharedApplication] openURL: [request URL]];
    }
    
    return YES;
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"did scroll %f",newsFeedView.scrollView.contentOffset.y);
    if (scrollView==newsFeedScroller)
    {
        if (scrollView.contentOffset.y < -60 || (scrollView.contentOffset.y>(newsFeedscrollHeight+60)))
        {
            reloadNewsFeedCounter++;
            if (reloadNewsFeedCounter==1) {
                NSLog(@"At the top or bottom %f %d",scrollView.contentOffset.y,newsFeedscrollHeight);
                [smAppDelegate showActivityViewer:self.view];
                [newsFeedView reload];
            }
        }
    }
    else if (scrollView==newsFeedView.scrollView)
    {
        if (scrollView.contentOffset.y < -60 || (scrollView.contentOffset.y>(newsFeedscrollHeight+60)))
        {
            reloadNewsFeedCounter++;
            if (reloadNewsFeedCounter==1) {
                NSLog(@"At the top or bottom %f %d",scrollView.contentOffset.y,newsFeedscrollHeight);
                [smAppDelegate showActivityViewer:self.view];
                [newsFeedView reload];
            }
        }
    }
    
}

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

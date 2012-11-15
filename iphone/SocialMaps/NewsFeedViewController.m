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
    NSString *urlStr=[NSString stringWithFormat:@"%@/me/newsfeed.html?authToken=%@",WS_URL,smAppDelegate.authToken];
    urlStr=@"http://192.168.1.212:8888/me/newsfeed.html?authToken=1edbca500599e2eb4d3437326931ca167f52736f";
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
    CGRect frame = aWebView.frame;
    frame.size.height = 1;
    aWebView.frame = frame;
    CGSize fittingSize = [aWebView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    aWebView.frame = frame;
    
    NSLog(@"webview size: %f, %f", fittingSize.width, fittingSize.height);
    [newsFeedView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"];
    [newsFeedView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout = 'none'"];
    [smAppDelegate hideActivityViewer];
    newsFeedScroller.contentSize=CGSizeMake(320, fittingSize.height);
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

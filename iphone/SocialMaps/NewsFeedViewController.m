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
#import "ReportContent.h"

@interface NewsFeedViewController ()

@end

@implementation NewsFeedViewController

@synthesize newsFeedView,totalNotifCount;
@synthesize newsfeedImgView;
@synthesize newsfeedImgFullView;
@synthesize newsFeedImageIndicator;

AppDelegate *smAppDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    ODRefreshControl *refreshControl = [[[ODRefreshControl alloc] initInScrollView:newsFeedView.scrollView] autorelease];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
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
     NSString *urlStr = [NSString stringWithFormat:@"%@/me/network/newsfeed.html?authToken=%@&r=%@",WS_URL,smAppDelegate.authToken,[UtilityClass convertNSDateToUnix:[NSDate date]]];

    NSLog(@"urlStr %@",urlStr);
    [self displayNotificationCount];
    [newsFeedView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];    
    smAppDelegate.currentModelViewController = self;
    [newsfeedImgFullView removeFromSuperview];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [dicImages_msg removeAllObjects];
    [super viewDidDisappear:animated];
}

- (BOOL)webView: (UIWebView*)webView shouldStartLoadWithRequest: (NSURLRequest*)request navigationType: (UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [webView stopLoading];
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
                [controller release];
            }
            else
            {
                FriendsProfileViewController *controller =[[FriendsProfileViewController alloc] init];
                controller.friendsId=userId;
                controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentModalViewController:controller animated:YES];
                [controller release];
            }
        }
        else if ([tagStr isEqualToString:@"geotag"])
        {
            NSString *userId=[[dataStr componentsSeparatedByString:@":"] objectAtIndex:3];
            NSLog(@"geotag string: %@",userId);
        }
        else if ([tagStr isEqualToString:@"expand"])
        {
            [self performSelector:@selector(reloadNewsFeedScrollView) withObject:nil afterDelay:3.0];
        }
        else if ([tagStr isEqualToString:@"report"])
        {
            NSString *contentType = [[dataStr componentsSeparatedByString:@":"] objectAtIndex:3];
            NSString *contentId = [[dataStr componentsSeparatedByString:@":"] objectAtIndex:4];
            
            [ReportContent reportContentId:contentId withContentType:contentType authTokenValue:smAppDelegate.authToken authTokenKey:@"Auth-Token" parentView:self.view title:@"Report this post"];
        }
        return NO;
        //[[UIApplication sharedApplication] openURL: [request URL]]; //why
    }

    return YES;
}


-(void)reloadNewsFeedScrollView
{
    CGRect frame = newsFeedView.frame;
    frame.size.height = 1;
    newsFeedView.frame = frame;
    CGSize fittingSize = [newsFeedView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    newsFeedView.frame = frame;
    //newsFeedscrollHeight=newsFeedView.frame.size.height;
    NSLog(@"webview size: %f, %f", fittingSize.width, fittingSize.height);
    [newsFeedView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"];
    [newsFeedView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout = 'none'"];
    [smAppDelegate hideActivityViewer];
    NSLog(@"Frame %@ ",NSStringFromCGRect(newsFeedView.frame));

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
        [img release];
        NSLog(@"image setted after download newsfeed image. %@",img);
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    //reloadNewsFeedCounter=0;
    [smAppDelegate hideActivityViewer];
    /*
    CGRect frame = aWebView.frame;
    frame.size.height = 1;
    //aWebView.frame = frame;
    CGSize fittingSize = [aWebView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    //aWebView.frame = frame;
     
    newsFeedscrollHeight=newsFeedView.frame.size.height;
    */
    [newsFeedView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"];
    [newsFeedView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout = 'none'"];
    [smAppDelegate hideActivityViewer];
    //[newsFeedScroller setContentSize:CGSizeMake(320, fittingSize.height)];
    //NSLog(@"Frame %@ %@",NSStringFromCGSize(newsFeedScroller.contentSize),NSStringFromCGRect(newsFeedView.frame));
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

-(IBAction)backButton:(id)sender
{
    [newsFeedView stopLoading];
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

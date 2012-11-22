//
//  FriendsPlanListViewController.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 11/22/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "PlanImageDownloader.h"
#import "FriendsPlanListViewController.h"
#import "PlanListTableCell.h"
#import "RestClient.h"
#import "AppDelegate.h"
#import "RestClient.h"
#import "UtilityClass.h"
#import "UILabel+Decoration.h"
#import "NotificationController.h"
#import "PlanListViewController.h"
#import "CreatePlanViewController.h"
#import "Globals.h"

@interface FriendsPlanListViewController ()
- (void)startIconDownload:(Plan *)plan forIndexPath:(NSIndexPath *)indexPath;
@end

@implementation FriendsPlanListViewController
@synthesize planListTableView, totalNotifCount,userInfo;
NSMutableArray *planListArr;
AppDelegate *smAppDelegate;
RestClient *rc;
NSMutableDictionary *dicIcondownloaderPlans;

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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    rc=[[RestClient alloc] init];
    smAppDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [smAppDelegate showActivityViewer:self.view];
    NSLog(@"userInfo %@",userInfo);
    [rc getFriendsAllplans:userInfo.userId:@"Auth-Token" :smAppDelegate.authToken];
    planListArr=[[NSMutableArray alloc] init];
    dicIcondownloaderPlans=[[NSMutableDictionary alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMyPlanes:) name:NOTIF_GET_FRIENDS_PLANS_DONE object:nil];    
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
    return [planListArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"planListTableCell";
    
    PlanListTableCell *cell = [planListTableView
                               dequeueReusableCellWithIdentifier:CellIdentifier];
    
    int nodeCount = [planListArr count];
    if (cell == nil)
    {
        cell = [[PlanListTableCell alloc]
                initWithStyle:UITableViewCellStyleDefault 
                reuseIdentifier:CellIdentifier];
    }
    //    [self decorateTableCell:cell];
    Plan *plan=[planListArr objectAtIndex:indexPath.row];
    cell.planDescriptionView.text=[NSString stringWithFormat:@"%@ has planned to %@ at %@ %@",smAppDelegate.userAccountPrefs.lastName,plan.planDescription,[[plan.planAddress componentsSeparatedByString:@","] objectAtIndex:0],[UtilityClass getCurrentTimeOrDate:plan.planeDate]];
    cell.addressLabel.text=plan.planAddress;
    CGSize lblStringSize1 = [plan.planAddress sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:12.0f]];
    
    cell.addressLabel.frame=CGRectMake(cell.addressLabel.frame.origin.x, 3, lblStringSize1.width, lblStringSize1.height);
    cell.addressScroller.contentSize=cell.addressLabel.frame.size;
    cell.distanceLabel.text=[UtilityClass getDistanceWithFormattingFromLocation:plan.planGeolocation];
    cell.tag=[indexPath row];
    cell.pointOnMap.tag=indexPath.row;
    cell.editPlanButton.tag=indexPath.row;
    cell.deletePlanButton.tag=indexPath.row;
    [cell.addressBg makeRoundCornerWithColor:[UIColor darkGrayColor]];
    [cell.pointOnMap addTarget:self action:@selector(pointOnMapAction:) forControlEvents:UIControlEventTouchUpInside];    
    [cell.editPlanButton addTarget:self action:@selector(editPlanAction:) forControlEvents:UIControlEventTouchUpInside];    
    [cell.deletePlanButton addTarget:self action:@selector(deletePlanAction:) forControlEvents:UIControlEventTouchUpInside];
    //initializing lazy loading
    // Leave cells empty if there's no data yet
    if (nodeCount > 0)
	{
        // Only load cached images; defer new downloads until scrolling ends
        NSLog(@"nodeCount > 0 %@",plan.planImageUrl);
        if (![dicImages_msg objectForKey:plan.planId])
        {
            NSLog(@"!userFriends.userProfileImage");
            if (self.planListTableView.dragging == NO && self.planListTableView.decelerating == NO)
            {
                [self startIconDownload:plan forIndexPath:indexPath];
                NSLog(@"Downloading for index=%d",indexPath.row);
            }
            //            else if(searchFlags==true)
            //            {
            //                NSLog(@"search flag true start download");
            //                [self startIconDownload:plan forIndexPath:indexPath];
            //            }
            
            NSLog(@"plans %@   %@",plan.planImage,plan.planImageUrl);
            // if a download is deferred or in progress, return a placeholder image
            cell.planBgImg.image=[UIImage imageNamed:@"blank.png"];
        }
        
        if ([dicImages_msg objectForKey:plan.planId])
        {
            cell.planBgImg.image=[dicImages_msg objectForKey:plan.planId];      
        }
        else
        {
            cell.planBgImg.image=[UIImage imageNamed:@"blank.png"];
        }
    }
    return cell;
}

-(void)decorateTableCell:(PlanListTableCell *)cell
{
    [cell.addressLabel setLabelGlowEffect];
    [cell.distanceLabel setLabelGlowEffect];
    [cell.addressBg setLabelGlowEffect];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//Lazy loading method starts

#pragma mark -
#pragma mark Table cell image support

- (void)startIconDownload:(Plan *)plan forIndexPath:(NSIndexPath *)indexPath
{
    PlanImageDownloader *iconDownloader = [dicIcondownloaderPlans objectForKey:plan.planId];
    if (iconDownloader == nil)
    {
        iconDownloader = [[PlanImageDownloader alloc] init];
        iconDownloader.plan = plan;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [dicIcondownloaderPlans setObject:iconDownloader forKey:plan.planId];
        NSLog(@"imageDownloadsInProgress %@",dicIcondownloaderPlans);
        [iconDownloader startDownload];
        //[downloadedImageDict setValue:iconDownloader.event.eventImage forKey:event.eventID];
        NSLog(@"start downloads ... %@ %d",plan.planId, indexPath.row);
        [iconDownloader release];   
    }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([planListArr count] > 0)
    {
        NSArray *visiblePaths = [self.planListTableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            Plan *plan = [planListArr objectAtIndex:indexPath.row];
            
            if (!plan.planImage) // avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:plan forIndexPath:indexPath];
            }
        }
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSString *)planID
{
    PlanImageDownloader *iconDownloader = [dicIcondownloaderPlans objectForKey:planID];
    if (iconDownloader != nil)
    {
        Plan *plan = [planListArr objectAtIndex:iconDownloader.indexPathInTableView.row];
        plan.planImage = iconDownloader.plan.planImage;
        
        PlanListTableCell *cell = (PlanListTableCell *)[self.planListTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
        // Display the newly loaded image
        [dicImages_msg setValue:iconDownloader.plan.planImage forKey:planID];
        cell.planBgImg.image = iconDownloader.plan.planImage;
        //[userProfileCopyImageArray replaceObjectAtIndex:indexPath.row withObject:iconDownloader.userFriends.userProfileImage];
        [self.planListTableView reloadData];
    }
}

#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

//Lazy loading method ends.

- (void)getMyPlanes:(NSNotification *)notif
{
    planListArr=[notif object];
    if ([planListArr count]==0)
    {
        [UtilityClass showAlert:@"" :[NSString stringWithFormat:@"%@ have no plans",userInfo.lastName]];
    }
    [planListTableView reloadData];
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
}

- (void)deletePlan:(NSNotification *)notif
{
    [UtilityClass showAlert:@"" :@"deleted successfully"];
    [planListTableView reloadData];
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
}

-(IBAction)backButtonAction:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)pointOnMapAction:(id)sender
{
    NSLog(@"tag %d",[sender tag]);
    pointOnMapFlag=TRUE;
    [self.presentingViewController performSelector:@selector(showPinOnMapViewPlan:) withObject:[planListArr objectAtIndex:[sender tag]]];
    [self dismissModalViewControllerAnimated:NO];
}

-(IBAction)editPlanAction:(id)sender
{
    NSLog(@"tag %d",[sender tag]);  
    Plan *aPlan=[planListArr objectAtIndex:[sender tag]];
    globalPlan=aPlan;
    NSIndexPath *index=[NSIndexPath indexPathForRow:[sender tag] inSection:0];
    CreatePlanViewController *createPlanViewController;
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"PlanStoryboard" bundle:nil];
    createPlanViewController = [storyboard instantiateViewControllerWithIdentifier:@"createPlanViewController"];
    
    createPlanViewController.editIndexPath=index;
    createPlanViewController.planEditFlag=@"yes";
    createPlanViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:createPlanViewController animated:YES];
}

-(IBAction)deletePlanAction:(id)sender
{
    [smAppDelegate showActivityViewer:self.view];
    [smAppDelegate.window setUserInteractionEnabled:NO];
    NSLog(@"tag %d",[sender tag]);    
    [rc deletePlans:@"Auth-Token" :smAppDelegate.authToken :((Plan *)[planListArr objectAtIndex:[sender tag]]).planId];
    [planListArr removeObjectAtIndex:[sender tag]];
}

-(void) displayNotificationCount {
    int totalNotif= [UtilityClass getNotificationCount];
    if (totalNotif == 0)
        totalNotifCount.text = @"";
    else
        totalNotifCount.text = [NSString stringWithFormat:@"%d",totalNotif];
}

-(IBAction)gotoNotification:(id)sender
{
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    NotificationController *controller =[storybrd instantiateViewControllerWithIdentifier:@"notificationViewController"];
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSArray *allDownloads = [dicIcondownloaderPlans allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

//
//  SettingsController.m
//  SocialMaps
//
//  Created by Arif Shakoor on 8/6/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import "SettingsController.h"
#import "CustomCheckbox.h"
#import "InfoSharing.h"
#import "AccountSettings.h"
#import "CustomRadioButton.h"
#import "LocationSharing.h"
#import "RadioButtonItem.h"
#import "SelectFriends.h"
#import "RestClient.h"
#import "FriendListViewController.h"
#import "NotificationController.h"
#import "UtilityClass.h"
#import "FacebookHelper.h"
#import "UserDefault.h"
#import "FacebookHelper.h"

@implementation SettingsController
@synthesize settingsScrollView;
@synthesize platformView;
@synthesize layersView;
@synthesize settingsHeader;
@synthesize notifCount;
@synthesize settingsMainHeader;
@synthesize backButton;
@synthesize smAppDelegate,totalNotifCount;
UserDefault *userDefault;
FacebookHelper *fbHelper;
Facebook *facebookApi;
int connectFBCounter=0, fbLoginCallbackCounter=0;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}   

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // Dummy notification
    int ignoreCount = 0;
    if (smAppDelegate.msgRead == TRUE)
        ignoreCount += [smAppDelegate.messages count];
    
    if (smAppDelegate.notifRead == TRUE)
        ignoreCount += [smAppDelegate.notifications count];
    
    int totalNotif = smAppDelegate.friendRequests.count+
    smAppDelegate.messages.count+smAppDelegate.notifications.count-smAppDelegate.ignoreCount-ignoreCount;
    
    if (totalNotif == 0)
        notifCount.text = @"";
    else
        notifCount.text = [NSString stringWithFormat:@"%d",totalNotif];
    
    [self displayNotificationCount];
    userDefault=[[UserDefault alloc] init];
    facebookApi = [[FacebookHelper sharedInstance] facebookApi];
    fbHelper=[[FacebookHelper alloc] init];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self displayNotificationCount];
    
    smAppDelegate.currentModelViewController = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectFBDone:) name:NOTIF_DO_CONNECT_FB_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getConnectwithFB:) name:NOTIF_DO_CONNECT_WITH_FB object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveSettingsDone:) name:SET_SHARE_LOCATION_DONE object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_DO_CONNECT_WITH_FB object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_DO_CONNECT_FB_DONE object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SET_SHARE_LOCATION_DONE object:nil];
}

- (void)saveSettingsDone:(NSNotification *)notif
{
    [smAppDelegate hideActivityViewer];
    ShareLocation *shareLocation = notif.object;
    if (shareLocation) {
        smAppDelegate.locSharingPrefs = shareLocation;
        [UtilityClass showAlert:@"" :@"Location sharing data saved successfully."];
        [self goBack:nil];
    } else {
        [UtilityClass showAlert:@"" :@"Error saving changes, please try again."];
    }
}

- (void)getConnectwithFB:(NSNotification *)notif
{
    NSLog(@"(smAppDelegate.facebookLogin: %i smAppDelegate.smLogin: %i",smAppDelegate.facebookLogin,smAppDelegate.smLogin);
    if ((smAppDelegate.smLogin==TRUE) && fbLoginCallbackCounter==0)
    {

        NSLog(@"");
        RestClient *rc=[[RestClient alloc] init];
        [smAppDelegate showActivityViewer:self.view];
        NSLog(@"fb access token in map: 1: %@ 2: %@ 3: %@",[notif object],smAppDelegate.fbId,[userDefault readFromUserDefaults:@"FBUserId"]);
        [fbHelper inviteFriends:nil];
        NSLog(@"invite friends from callback if");
        if ([smAppDelegate.fbId isEqualToString:@""])
        {
            smAppDelegate.fbId=[userDefault readFromUserDefaults:@"FBUserId"];
        }
        
        NSLog(@"smAppDelegate.fbId %@",smAppDelegate.fbId);
        if (smAppDelegate.fbAccessToken) 
        {
            [rc doConnectFB:@"Auth-Token" :smAppDelegate.authToken :smAppDelegate.fbId :smAppDelegate.fbAccessToken];
            NSLog(@"got access token");
        }
        else if ([userDefault readFromUserDefaults:@"FBAccessTokenKey"]) 
        {
            [rc doConnectFB:@"Auth-Token" :smAppDelegate.authToken :smAppDelegate.fbId :[userDefault readFromUserDefaults:@"FBAccessTokenKey"]];
            NSLog(@"got accees token from user default");
        }
        else
        {
            [smAppDelegate hideActivityViewer];
        }
    }
    fbLoginCallbackCounter++;
}

- (void)connectFBDone:(NSNotification *)notif
{
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    
    [userDefault writeToUserDefaults:@"connectWithFB" withString:@"FBConnect"];
    NSLog(@"Connected with fb :D %@",[notif object]);
    if (connectFBCounter==0)
    {
        [UtilityClass showAlert:@"Social Maps" :[notif object]];
    }
    connectFBCounter++;
}

-(IBAction)connectWithFB:(id)sender
{

}

- (void)viewDidUnload
{
    [self setSettingsScrollView:nil];
    [self setPlatformView:nil];
    [self setLayersView:nil];
    [self setSettingsHeader:nil];
    [self setNotifCount:nil];
    [self setSettingsMainHeader:nil];
    [self setBackButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [settingsScrollView release];
    [platformView release];
    [layersView release];
    [settingsHeader release];
    [notifCount release];
    [settingsMainHeader release];
    [backButton release];
    [super dealloc];
}

- (void) collapsePlatformSettings:(id) sender {
    // Change button image
    UIButton *btn = (UIButton*) sender;
    [btn setImage:[UIImage imageNamed:@"icon_arrow_down.png"] forState:UIControlStateNormal];
    // Reset callback
    [btn removeTarget:self action:@selector(collapsePlatformSettings:) forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:@selector(expandPlatformSettings:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *rowView = (UIView*) [sender superview];
    CustomCheckbox *chkBox = (CustomCheckbox*) [[btn superview] viewWithTag:1001];
    CGRect rowFrame = CGRectMake(rowView.frame.origin.x, rowView.frame.origin.y, 
                                 rowView.frame.size.width, rowView.frame.size.height/2);
    // New scrool view content size    
    settingsScrollView.contentSize = CGSizeMake(310, settingsScrollView.frame.size.height-rowView.frame.size.height/2);
    rowView.frame = rowFrame;
    
    // Shift Layers settings row up
    rowFrame = CGRectMake(layersView.frame.origin.x, layersView.frame.origin.y-chkBox.frame.size.height, layersView.frame.size.width, 
                          layersView.frame.size.height);
    layersView.frame = rowFrame;
    
    UIImageView *lineView = (UIImageView*) [[btn superview] viewWithTag:1002];
    [chkBox removeFromSuperview];
    [lineView removeFromSuperview];
}

- (IBAction)expandPlatformSettings:(id)sender {
    // Change button image
    UIButton *btn = (UIButton*) sender;
    [btn setImage:[UIImage imageNamed:@"icon_arrow_up.png"] forState:UIControlStateNormal];
    // Reset callback
    [btn removeTarget:self action:@selector(expandPlatformSettings:) forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:@selector(collapsePlatformSettings:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *rowView = (UIView*) [sender superview];
    
    CGRect rowFrame = CGRectMake(rowView.frame.origin.x, rowView.frame.origin.y, 
                                 rowView.frame.size.width, rowView.frame.size.height*2);
    CGRect chkboxFrame = CGRectMake(0, rowView.frame.size.height+7, 
                                    rowView.frame.size.width, rowView.frame.size.height-7);
     
    // Create the line with image line_arrow_down_left.png
    CGRect lineFrame = CGRectMake(0, rowView.frame.size.height, 310, 7);
    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:lineFrame];
    lineImage.image = [UIImage imageNamed:@"line_arrow_down_left.png"];
    lineImage.tag   = 1002;  
    [rowView addSubview:lineImage];
    
    UIButton *buttonInviteFBFriend = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonInviteFBFriend.frame = chkboxFrame;
    buttonInviteFBFriend.tag = 1001;
    userDefault=[[UserDefault alloc] init];
    if ((![userDefault readFromUserDefaults:@"connectWithFBDone"]) && (smAppDelegate.smLogin==TRUE) && (![facebookApi isSessionValid]))
    {
        [buttonInviteFBFriend setTitle:@"Connect with facebook" forState:UIControlStateNormal];
    }
    else
    {
        [buttonInviteFBFriend setTitle:@"Invite facebook friends" forState:UIControlStateNormal];
    }
    [buttonInviteFBFriend addTarget:self action:@selector(actionInviteFriendButton:) forControlEvents:UIControlEventTouchUpInside];
    [buttonInviteFBFriend setBackgroundImage:[UIImage imageNamed:@"img_settings_list_bg_solid.png"] forState:UIControlStateNormal];
    [buttonInviteFBFriend setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [buttonInviteFBFriend.titleLabel setFont: [UIFont fontWithName:@"Helvetica" size:14.0]];
    [rowView addSubview:buttonInviteFBFriend];
    
    // New scrool view content size    
    settingsScrollView.contentSize = CGSizeMake(310, settingsScrollView.frame.size.height+rowView.frame.size.height);
    
    // reset row size
    rowView.frame = rowFrame;
    
    // Shift Layers settings row down
    rowFrame = CGRectMake(layersView.frame.origin.x, layersView.frame.origin.y+chkboxFrame.size.height, layersView.frame.size.width, 
                         layersView.frame.size.height);
    layersView.frame = rowFrame;
    
}

- (void)actionInviteFriendButton:(id)sender
{
    NSLog(@"Invite Facebook Friends");
    UIButton *inviteButton=(UIButton *)([self.view viewWithTag:1001]);
    [inviteButton setTitle:@"Invite facebook friends" forState:UIControlStateNormal];
    if ((![userDefault readFromUserDefaults:@"connectWithFBDone"]) && (smAppDelegate.smLogin==TRUE))
    {
        NSLog(@"do connect fb");
        if ([facebookApi isSessionValid])
        {
            [fbHelper inviteFriends:nil];
            NSLog(@"invite friends valid session");
        }
        else
        {
            NSArray *permissions = [[NSArray alloc] initWithObjects:
                                    @"email",
                                    @"user_likes", 
                                    @"user_photos", 
                                    @"publish_checkins", 
                                    @"photo_upload", 
                                    @"user_location",
                                    @"user_birthday",
                                    @"user_about_me",
                                    @"publish_stream",
                                    @"read_stream",
                                    @"friends_status",
                                    @"user_checkins",
                                    @"friends_checkins",
                                    nil];
            [facebookApi authorize:permissions];
            [permissions release];
        }
        [userDefault writeToUserDefaults:@"connectWithFB" withString:@"FBConnect"];
        [userDefault writeToUserDefaults:@"connectWithFBDone" withString:@"FBConnectedDone"];
    }
    else
    {
        Facebook *facebookApi = [[FacebookHelper sharedInstance] facebookApi];
        if ([facebookApi isSessionValid])
        {
        [fbHelper inviteFriends:nil];
        NSLog(@"invite friends in else");
        }
        else
        {
            NSArray *permissions = [[NSArray alloc] initWithObjects:
                                    @"email",
                                    @"user_likes",
                                    @"user_photos",
                                    @"publish_checkins",
                                    @"photo_upload",
                                    @"user_location",
                                    @"user_birthday",
                                    @"user_about_me",
                                    @"publish_stream",
                                    @"read_stream",
                                    @"friends_status",
                                    @"user_checkins",
                                    @"friends_checkins",
                                    nil];
            [facebookApi authorize:permissions];
            [permissions release];
        }
    }
}

- (void)actionTestFriendListButton
{
    FriendListViewController *controller = [[FriendListViewController alloc] initWithNibName:@"FriendListViewController" bundle:nil];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

- (void) collapseLayersSettings:(id) sender {
    // Change button image
    UIButton *btn = (UIButton*) sender;
    [btn setImage:[UIImage imageNamed:@"icon_arrow_down.png"] forState:UIControlStateNormal];
    // Reset callback
    [btn removeTarget:self action:@selector(collapseLayersSettings:) forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:@selector(expandLayersSettings:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *rowView = (UIView*) [sender superview];
    CustomCheckbox *chkBox = (CustomCheckbox*) [[btn superview] viewWithTag:1003];
    CGRect rowFrame = CGRectMake(rowView.frame.origin.x, rowView.frame.origin.y, 
                                 rowView.frame.size.width, rowView.frame.size.height/2);
    // New scrool view content size    
    settingsScrollView.contentSize = CGSizeMake(310, settingsScrollView.frame.size.height-rowView.frame.size.height/2);
    rowView.frame = rowFrame;
        
    UIImageView *lineView = (UIImageView*) [[btn superview] viewWithTag:1004];
    [chkBox removeFromSuperview];
    [lineView removeFromSuperview];
}

- (IBAction)expandLayersSettings:(id)sender {
    // Change button image
    UIButton *btn = (UIButton*) sender; 
    [btn setImage:[UIImage imageNamed:@"icon_arrow_up.png"] forState:
        UIControlStateNormal];
    // Reset callback
    [btn removeTarget:self action:@selector(expandLayersSettings:) forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:@selector(collapseLayersSettings:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *rowView = (UIView*) [sender superview];
    CGRect rowFrame = CGRectMake(rowView.frame.origin.x, rowView.frame.origin.y, 
                                 rowView.frame.size.width, rowView.frame.size.height*2);
    CGRect chkboxFrame = CGRectMake(0, rowView.frame.size.height+7, 
                                    rowView.frame.size.width, rowView.frame.size.height-7);
    // Create the line with image line_arrow_down_left.png
    CGRect lineFrame = CGRectMake(0, rowView.frame.size.height, 310, 7);
    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:lineFrame];
    lineImage.image = [UIImage imageNamed:@"line_arrow_down_left.png"];
    lineImage.tag   = 1004;  
    [rowView addSubview:lineImage];
    
    NSArray *layers = [NSArray arrayWithObjects:@"Wikipedia", @"Tripadvisor", @"Foodspotting", nil];
    NSArray *def    = [NSArray arrayWithObjects:[NSNumber numberWithBool: smAppDelegate.layerPrefs.wikipedia], 
                       [NSNumber numberWithBool: smAppDelegate.layerPrefs.tripadvisor],
                       [NSNumber numberWithBool: smAppDelegate.layerPrefs.foodspotting], nil];
                       
    CustomCheckbox *chkBox = [[CustomCheckbox alloc] initWithFrame:chkboxFrame boxLocType:LabelPositionRight numBoxes:[layers count] default:def labels:layers];
    chkBox.tag = 1003;
    chkBox.backgroundColor = [UIColor clearColor];
    chkBox.delegate = self;
    [rowView addSubview:chkBox];
    
    // New scroll view content size    
    settingsScrollView.contentSize = CGSizeMake(310, settingsScrollView.frame.size.height+rowView.frame.size.height);
    
    // reset row size
    rowView.frame = rowFrame;
}

// img_settings_list_bg.png
- (IBAction)setInfoSharing:(id)sender
{
    [self performSelector:@selector(setaInfoSharingMethod) withObject:nil afterDelay:.5];
}

-(void)setaInfoSharingMethod
{
    UILabel *settingsHdrLabel = (UILabel*)[settingsHeader viewWithTag:2];    
    settingsHdrLabel.text = @"Information sharing";
    
    CGRect scrollFrame = CGRectMake(5, 80, 310, 380);
    UIScrollView *scrollView = [[InfoSharing alloc] initWithFrame:scrollFrame infoList:smAppDelegate.infoList defList:smAppDelegate.defInfoPref sender:self];
    scrollView.backgroundColor = [UIColor colorWithRed:247.0/255.0 
                                                 green:247.0/255.0 
                                                  blue:247.0/255.0 
                                                 alpha:1.0];
    scrollView.tag = 4001;
    [self.view addSubview:scrollView];
    [self.view bringSubviewToFront:settingsHeader];

}

- (IBAction)setAccountSettings:(id)sender 
{
    [self performSelector:@selector(setAccountSettingsMethod) withObject:nil afterDelay:.5];
}

-(void)setAccountSettingsMethod
{
    UILabel *settingsHdrLabel = (UILabel*)[settingsHeader viewWithTag:2];    
    settingsHdrLabel.text = @"Account settings";
    
    CGRect scrollFrame = CGRectMake(5, 100, 310, 360);
    AccountSettings *scrollView = [[AccountSettings alloc] initWithFrame:scrollFrame];
    scrollView.backgroundColor = [UIColor colorWithRed:247.0/255.0 
                                                 green:247.0/255.0 
                                                  blue:247.0/255.0 
                                                 alpha:1.0];
    scrollView.tag = 3001;
    [self.view addSubview:scrollView];
    [self.view bringSubviewToFront:settingsHeader];
    [self.view bringSubviewToFront:settingsMainHeader];

}

- (IBAction)goBack:(id)sender {
    
    UIView *view;
   
    if ((view = [self.view viewWithTag:420]))
        [view removeFromSuperview];
    else if ((view = [self.view viewWithTag:4007]))
        [view removeFromSuperview];
    else if ((view = [self.view viewWithTag:4001]))
        [self closeSharingInfo:nil];
    else if ((view = [self.view viewWithTag:5001]))
        [self closeLocationSharing:nil];
    else if ((view = [self.view viewWithTag:6001]))
        [self closeNotifSettings:nil];
    else if ((view = [self.view viewWithTag:3001]))
        [self closeAccountSettings:nil];
    
    if (!view) [self dismissModalViewControllerAnimated:YES];
    
}

- (IBAction)setLocationSharing:(id)sender
{
    [self performSelector:@selector(setLocationSharingMethod) withObject:nil afterDelay:.5];
}

-(void)setLocationSharingMethod
{
    UILabel *settingsHdrLabel = (UILabel*)[settingsHeader viewWithTag:2];    
    settingsHdrLabel.text = @"Location sharing";
    
    CGRect scrollFrame = CGRectMake(05, 100, 310, 360);
    LocationSharing *scrollView = [[LocationSharing alloc] initWithFrame:scrollFrame];
    scrollView.backgroundColor = [UIColor colorWithRed:247.0/255.0 
                                                 green:247.0/255.0 
                                                  blue:247.0/255.0 
                                                 alpha:1.0];
    scrollView.tag = 5001;
    [self.view addSubview:scrollView];
    [self.view bringSubviewToFront:settingsHeader];
    [self.view bringSubviewToFront:settingsMainHeader];

}

- (IBAction)setNotifSettings:(id)sender {

}

// CustomCheckboxDelegate methods
- (void) checkboxClicked:(int)indx withState:(int)clicked sender:(id)sender {
    NSLog(@"index=%d state=%d", indx, clicked);
    CustomCheckbox *chkBox = (CustomCheckbox*) sender;
    if (chkBox.tag == 1001) {
        switch (indx) {
            case 0:
                smAppDelegate.platformPrefs.facebook = clicked;
                break;
            case 1:
                smAppDelegate.platformPrefs.twitter = clicked;
                break;
            case 2:
                smAppDelegate.platformPrefs.fourSquare = clicked;
                break;
            default:
                break;
        }
    } else if (chkBox.tag == 1003) {
        switch (indx) {
            case 0:
                smAppDelegate.layerPrefs.wikipedia = clicked;
                break;
            case 1:
                smAppDelegate.layerPrefs.tripadvisor = clicked;
                break;
            case 2:
                smAppDelegate.layerPrefs.foodspotting = clicked;
                break;
            default:
                break;
        }
        [smAppDelegate.defLayers replaceObjectAtIndex:indx withObject:[NSNumber numberWithInt:clicked]];
    } else if (chkBox.tag >= 10000) {
        int indx = chkBox.tag - 10000; // Auto tagging starts at 10000
        [smAppDelegate.defInfoPref replaceObjectAtIndex:indx withObject:[NSNumber numberWithInt:clicked]];
    }
}

- (void) closeLocationSharing:(id) sender {
    UILabel *settingsHdrLabel = (UILabel*)[settingsHeader viewWithTag:2];    
    settingsHdrLabel.text = @"Settings";
    UIScrollView *scrollView = (UIScrollView*) [self.view viewWithTag:5001];
    [scrollView removeFromSuperview];
}


- (void) closeSharingInfo:(id) sender {
    UILabel *settingsHdrLabel = (UILabel*)[settingsHeader viewWithTag:2];    
    settingsHdrLabel.text = @"Settings";
    UIScrollView *scrollView = (UIScrollView*) [self.view viewWithTag:4001];
    [scrollView removeFromSuperview];
}

- (void) closeAccountSettings:(id) sender {
    UILabel *settingsHdrLabel = (UILabel*)[settingsHeader viewWithTag:2];    
    settingsHdrLabel.text = @"Settings";
    AccountSettings *scrollView = (AccountSettings*) [self.view viewWithTag:3001];
    [scrollView removeFromSuperview];
    
}

- (void) closeNotifSettings:(id) sender {
    UILabel *settingsHdrLabel = (UILabel*)[settingsHeader viewWithTag:2];    
    settingsHdrLabel.text = @"Settings";
    AccountSettings *scrollView = (AccountSettings*) [self.view viewWithTag:6001];
    [scrollView removeFromSuperview];
    
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

@end

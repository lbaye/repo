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

@implementation SettingsController
@synthesize settingsScrollView;
@synthesize platformView;
@synthesize layersView;
@synthesize settingsHeader;
@synthesize notifCount;
@synthesize settingsMainHeader;
@synthesize backButton;
@synthesize defPlatforms;
@synthesize smAppDelegate;

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    //settingsScrollView.contentSize = CGSizeMake(310, 960);
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    defPlatforms = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:1], 
                             [NSNumber numberWithInt:0],
                             [NSNumber numberWithInt:0], nil] ;
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
    //btn.imageView.image = [UIImage imageNamed:@"settings_arrow_light.png"];
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
    //btn.imageView.image = [UIImage imageNamed:@"settings_arrow.png"];
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
    
    NSArray *platforms = [NSArray arrayWithObjects:@"Facebook", @"Twitter", @"Foursquare", nil];
    CustomCheckbox *chkBox = [[CustomCheckbox alloc] initWithFrame:chkboxFrame boxLocType:LabelPositionRight numBoxes:[platforms count] default:smAppDelegate.defPlatforms labels:platforms];
    chkBox.tag = 1001;
    chkBox.backgroundColor = [UIColor clearColor];
    chkBox.delegate = self;
    [rowView addSubview:chkBox];
    
    // New scrool view content size    
    settingsScrollView.contentSize = CGSizeMake(310, settingsScrollView.frame.size.height+rowView.frame.size.height);
    
    // reset row size
    rowView.frame = rowFrame;
    
    // Shift Layers settings row down
    rowFrame = CGRectMake(layersView.frame.origin.x, layersView.frame.origin.y+chkboxFrame.size.height, layersView.frame.size.width, 
                         layersView.frame.size.height);
    layersView.frame = rowFrame;

}

- (void) collapseLayersSettings:(id) sender {
    // Change button image
    UIButton *btn = (UIButton*) sender;
    [btn setImage:[UIImage imageNamed:@"icon_arrow_down.png"] forState:UIControlStateNormal];
    //btn.imageView.image = [UIImage imageNamed:@"icon_arrow_down.png"];
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
    //UIControlStateNormal|UIControlStateSelected|UIControlStateHighlighted];
    //btn.imageView.image = [UIImage imageNamed:@"icon_arrow_up.png"];
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
    
    NSArray *layers = [NSArray arrayWithObjects:@"Wikipedia", @"Tripadvisor", @"Yelp", nil];
    CustomCheckbox *chkBox = [[CustomCheckbox alloc] initWithFrame:chkboxFrame boxLocType:LabelPositionRight numBoxes:[layers count] default:smAppDelegate.defLayers labels:layers];
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
- (IBAction)setInfoSharing:(id)sender {
    UILabel *settingsHdrLabel = (UILabel*)[settingsHeader viewWithTag:2];    
    settingsHdrLabel.text = @"Information sharing";
    
    CGRect scrollFrame = CGRectMake(5, 80, 310, 380);
    UIScrollView *scrollView = [[InfoSharing alloc] initWithFrame:scrollFrame infoList:smAppDelegate.infoList defList:smAppDelegate.defInfoPref sender:self];
    scrollView.backgroundColor = [UIColor colorWithRed:247.0/255.0 
                                                 green:247.0/255.0 
                                                  blue:247.0/255.0 
                                                 alpha:1.0];
    scrollView.tag = 4001;
    CGRect closeFrame = CGRectMake(settingsHeader.frame.size.width-15-5, 
                                   5, 15, 15);
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = closeFrame;
    closeButton.tag   = 4002;
    [closeButton addTarget:self 
                    action:@selector(closeSharingInfo:)
          forControlEvents:UIControlEventTouchUpInside];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"xlose_icon.png"]
                           forState:UIControlStateNormal];
    
    
    [settingsHeader addSubview:closeButton];
    [self.view addSubview:scrollView];
    [self.view bringSubviewToFront:settingsHeader];
}

- (IBAction)setAccountSettings:(id)sender {
    UILabel *settingsHdrLabel = (UILabel*)[settingsHeader viewWithTag:2];    
    settingsHdrLabel.text = @"Account settings";
    
    CGRect scrollFrame = CGRectMake(5, 80, 310, 380);
    AccountSettings *scrollView = [[AccountSettings alloc] initWithFrame:scrollFrame];
    scrollView.backgroundColor = [UIColor colorWithRed:247.0/255.0 
                                                 green:247.0/255.0 
                                                  blue:247.0/255.0 
                                                 alpha:1.0];
    scrollView.tag = 3001;
    CGRect closeFrame = CGRectMake(settingsHeader.frame.size.width-15-5, 
                                   5, 15, 15);
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = closeFrame;
    closeButton.tag   = 3002;
    [closeButton addTarget:self 
                    action:@selector(closeAccountSettings:)
          forControlEvents:UIControlEventTouchUpInside];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"xlose_icon.png"]
                           forState:UIControlStateNormal];
    
    
    [settingsHeader addSubview:closeButton];
    [self.view addSubview:scrollView];
    [self.view bringSubviewToFront:settingsHeader];
    [self.view bringSubviewToFront:settingsMainHeader];
}

- (IBAction)goBack:(id)sender {
}

- (IBAction)setLocationSharing:(id)sender {
    UILabel *settingsHdrLabel = (UILabel*)[settingsHeader viewWithTag:2];    
    settingsHdrLabel.text = @"Location sharing";
    
//    CGRect topRow = CGRectMake(5, 80, 310, 62);
//    RadioButtonItem *enableSharing = [[RadioButtonItem alloc] initWithFrame:topRow title:@"Location sharing" subTitle:@"" labels:[NSArray arrayWithObjects:@"Off", @"On", nil] sender:self tag:5003];
//    UIImageView *bgImageView = [[UIImageView alloc] 
//                                initWithFrame:CGRectMake(0, 0, enableSharing.frame.size.width, enableSharing.frame.size.height) ];
//    [bgImageView setContentMode:UIViewContentModeScaleToFill];
//    
//    bgImageView.image = [UIImage imageNamed:@"img_settings_list_bg.png"];
//    [enableSharing addSubview:bgImageView];
//    [enableSharing sendSubviewToBack:bgImageView];
//    [self.view addSubview:enableSharing];

    CGRect scrollFrame = CGRectMake(05, 80, 310, 380);
    LocationSharing *scrollView = [[LocationSharing alloc] initWithFrame:scrollFrame];
    scrollView.backgroundColor = [UIColor colorWithRed:247.0/255.0 
                                                 green:247.0/255.0 
                                                  blue:247.0/255.0 
                                                 alpha:1.0];
    scrollView.tag = 5001;
    CGRect closeFrame = CGRectMake(settingsHeader.frame.size.width-15-5, 
                                   5, 15, 15);
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = closeFrame;
    closeButton.tag   = 5002;
    [closeButton addTarget:self 
                    action:@selector(closeLocationSharing:)
          forControlEvents:UIControlEventTouchUpInside];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"xlose_icon.png"]
                           forState:UIControlStateNormal];
    
    
    [settingsHeader addSubview:closeButton];
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
    if (chkBox.tag == 1001)
        [smAppDelegate.defPlatforms replaceObjectAtIndex:indx withObject:[NSNumber numberWithInt:clicked]];
    else if (chkBox.tag == 1003)
        [smAppDelegate.defLayers replaceObjectAtIndex:indx withObject:[NSNumber numberWithInt:clicked]];
    else if (chkBox.tag >= 10000) {
        int indx = chkBox.tag - 10000; // Auto tagging starts at 10000
        [smAppDelegate.defInfoPref replaceObjectAtIndex:indx withObject:[NSNumber numberWithInt:clicked]];
    }
}

- (void) closeLocationSharing:(id) sender {
    UILabel *settingsHdrLabel = (UILabel*)[settingsHeader viewWithTag:2];    
    settingsHdrLabel.text = @"Settings";
    
    UIButton *closeButton = (UIButton*) (sender);
    [closeButton removeFromSuperview];
    UIScrollView *scrollView = (UIScrollView*) [self.view viewWithTag:5001];
    [scrollView removeFromSuperview];
}


- (void) closeSharingInfo:(id) sender {
    UILabel *settingsHdrLabel = (UILabel*)[settingsHeader viewWithTag:2];    
    settingsHdrLabel.text = @"Settings";
    
    UIButton *closeButton = (UIButton*) (sender);
    [closeButton removeFromSuperview];
    UIScrollView *scrollView = (UIScrollView*) [self.view viewWithTag:4001];
    [scrollView removeFromSuperview];
}

- (void) closeAccountSettings:(id) sender {
    UILabel *settingsHdrLabel = (UILabel*)[settingsHeader viewWithTag:2];    
    settingsHdrLabel.text = @"Settings";
    
    UIButton *closeButton = (UIButton*) (sender);
    [closeButton removeFromSuperview];
    AccountSettings *scrollView = (AccountSettings*) [self.view viewWithTag:3001];
    [scrollView removeFromSuperview];
    
}

- (void) closeNotifSettings:(id) sender {
    UILabel *settingsHdrLabel = (UILabel*)[settingsHeader viewWithTag:2];    
    settingsHdrLabel.text = @"Settings";
    
    UIButton *closeButton = (UIButton*) (sender);
    [closeButton removeFromSuperview];
    AccountSettings *scrollView = (AccountSettings*) [self.view viewWithTag:6001];
    [scrollView removeFromSuperview];
    
}



@end

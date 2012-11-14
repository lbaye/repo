//
//  ViewCircleWisePeopleViewController.m
//  SocialMaps
//
//  Created by Abdullah Md. Zubair on 9/20/12.
//  Copyright (c) 2012 Genweb2. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewCircleWisePeopleViewController.h"
#import "SectionInfo.h"
#import "SectionHeaderView.h"
#import "CircleListTableCell.h"
#import "UserCircle.h"
#import "LocationItemPeople.h"
#import "Globals.h"
#import "UserFriends.h"
#import "Constants.h"
#import "RestClient.h"
#import "AppDelegate.h"
#import "SelectCircleTableCell.h"
#import "UtilityClass.h"
#import "RestClient.h"
#import "NotificationController.h"

#pragma mark -
#pragma mark EmailMenuItem


@interface EmailMenuItem : UIMenuItem
@property (nonatomic, strong) NSIndexPath* indexPath;
@end

@implementation EmailMenuItem
@synthesize indexPath;
@end


#pragma mark -
#pragma mark TableViewController


@interface ViewCircleWisePeopleViewController ()
@property (nonatomic, strong) NSMutableArray* sectionInfoArray;
@property (nonatomic, strong) NSIndexPath* pinchedIndexPath;
@property (nonatomic, assign) NSInteger openSectionIndex;
@property (nonatomic, assign) CGFloat initialPinchHeight;

// Use the uniformRowHeight property if the pinch gesture should change all row heights simultaneously.
@property (nonatomic, assign) NSInteger uniformRowHeight;

-(void)updateForPinchScale:(CGFloat)scale atIndexPath:(NSIndexPath*)indexPath;

-(void)emailMenuButtonPressed:(UIMenuController*)menuController;
-(void)sendEmailForEntryAtIndexPath:(NSIndexPath*)indexPath;

@end

#define DEFAULT_ROW_HEIGHT 100
#define HEADER_HEIGHT 45

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
CGFloat animatedDistance;

@implementation ViewCircleWisePeopleViewController
@synthesize circleTableView,circleSearchBar,circleSelectTableView;
@synthesize userCircle=userCircle_, sectionInfoArray=sectionInfoArray_, circleListTableCell=newsCell_, pinchedIndexPath=pinchedIndexPath_, uniformRowHeight=rowHeight_, openSectionIndex=openSectionIndex_, initialPinchHeight=initialPinchHeight_;

@synthesize circleCreateView,circleNameTextField;
@synthesize msgView;
@synthesize textViewNewMsg,renameTextField,renameUIView;

AppDelegate *smAppDelegate;
NSMutableArray *selectedCircleCheckArr;
RestClient *rc;
NSString *userID;
NSString *renameCircleName;
int renameCircleOndex;

-(BOOL)canBecomeFirstResponder {
    
    return YES;
}


- (void)viewDidLoad {
	
    [super viewDidLoad];
    
    userID=[[NSString alloc] init];
    self.userCircle=circleListDetailGlobalArray;
    selectedCircleCheckArr=[[NSMutableArray alloc] init];
    rc=[[RestClient alloc] init];
    // add people list here
    NSLog(@"circleListDetailGlobalArray %@",circleListDetailGlobalArray);
    // Add a pinch gesture recognizer to the table view.
	UIPinchGestureRecognizer* pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	[self.circleTableView addGestureRecognizer:pinchRecognizer];
    
    // Set up default values.
    self.circleTableView.sectionHeaderHeight = HEADER_HEIGHT;
	/*
     The section info array is thrown away in viewWillUnload, so it's OK to set the default values here. If you keep the section information etc. then set the default values in the designated initializer.
     */
    smAppDelegate=[[AppDelegate alloc] init];
    smAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [smAppDelegate showActivityViewer:self.view];
    [smAppDelegate.window setUserInteractionEnabled:NO];
    RestClient *rc=[[RestClient alloc] init];
    [rc getAllCircles:@"Auth-Token" :smAppDelegate.authToken];
    rowHeight_ = DEFAULT_ROW_HEIGHT;
    openSectionIndex_ = NSNotFound;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllCircleDone:) name:NOTIF_GET_ALL_CIRCLES_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createCircleDone:) name:NOTIF_CREATE_CIRCLE_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCircleDone:) name:NOTIF_UPDATE_CIRCLE_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteCircleDone:) name:NOTIF_DELETE_USER_CIRCLE_DONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renameCircleDone:) name:NOTIF_RENAME_USER_CIRCLE_DONE object:nil];

    labelNotifCount.text = [NSString stringWithFormat:@"%d", [UtilityClass getNotificationCount]];
}


- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
    [renameUIView removeFromSuperview];
    [circleCreateView removeFromSuperview];
    [msgView removeFromSuperview];
    [self initData];
}

-(void)initData
{
    /*
     Check whether the section info array has been created, and if so whether the section count still matches the current section count. In general, you need to keep the section info synchronized with the rows and section. If you support editing in the table view, you need to appropriately update the section info during editing operations.
     */
    //	if ((self.sectionInfoArray == nil) || ([self.sectionInfoArray count] != [self numberOfSectionsInTableView:self.circleTableView]))
    {
		
        // For each play, set up a corresponding SectionInfo object to contain the default height for each row.
		NSMutableArray *infoArray = [[NSMutableArray alloc] init];
		//DATA SOURCE IS HERE
		for (UserCircle *userCircle in self.userCircle)
        {
			
			SectionInfo *sectionInfo = [[SectionInfo alloc] init];
			sectionInfo.userCircle = userCircle;
			sectionInfo.open = NO;
			
            NSNumber *defaultRowHeight = [NSNumber numberWithInteger:DEFAULT_ROW_HEIGHT];
			NSInteger countOfQuotations = [[sectionInfo.userCircle friends] count];
			for (NSInteger i = 0; i < countOfQuotations; i++)
            {
				[sectionInfo insertObject:defaultRowHeight inRowHeightsAtIndex:i];
			}
			NSLog(@"circle.name %@ circle.friends %@",userCircle.circleName,userCircle.friends);
			[infoArray addObject:sectionInfo];
		}
		
		self.sectionInfoArray = infoArray;
	}
	
}

-(void)loadRenameView
{
    UIView *renameView = [[UIView alloc] initWithFrame:CGRectMake(0, 45, 320, 96)];
    [self.view addSubview:renameView];
}

-(IBAction)addCircleAction:(id)sender
{
    if ([circleNameTextField.text isEqualToString:@""]) {
        [UtilityClass showAlert:@"Social Maps" :@"Enter circle name"];
    }
    else
    {
        UserCircle *userCircle=[[UserCircle alloc] init];
        userCircle.circleName=circleNameTextField.text;
        [smAppDelegate showActivityViewer:self.view];
        [smAppDelegate.window setUserInteractionEnabled:NO];
        [rc createCircle:@"Auth-Token" :smAppDelegate.authToken :userCircle];
        circleNameTextField.text=@"";
        [circleCreateView removeFromSuperview];
    }
}

-(IBAction)okAction:(id)sender
{
    NSLog(@"selected circle %@",selectedCircleCheckArr);
    RestClient *rc=[[RestClient alloc] init];
    //get user id
    //get selected circle list
    NSLog(@"userID: %@",userID);
    NSMutableArray* circleArr=selectedCircleCheckArr;
    for (int i=0; i<[circleArr count]; i++)
    {
        if (((UserCircle*)[circleArr objectAtIndex:i]).type ==0)
        {
            [circleArr removeObject:[circleArr objectAtIndex:i]];
            NSLog(@"removed system");
        }
    }
    NSLog(@"circleArr: %@",circleArr);
    [rc updateCircle:@"Auth-Token" :smAppDelegate.authToken :userID :circleArr];
    [circleCreateView removeFromSuperview];
    [smAppDelegate showActivityViewer:self.view];
    [smAppDelegate.window setUserInteractionEnabled:NO];
}

-(IBAction)cancelAction:(id)sender
{
    [circleCreateView removeFromSuperview];    
}

- (IBAction)actionNotificationButton:(id)sender {
    UIStoryboard *storybrd = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    NotificationController *controller =[storybrd instantiateViewControllerWithIdentifier:@"notificationViewController"];
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
}

- (void)viewDidUnload {
    
    [labelNotifCount release];
    labelNotifCount = nil;
    [super viewDidUnload];
    
    // To reduce memory pressure, reset the section info array if the view is unloaded.
	self.sectionInfoArray = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_GET_ALL_CIRCLES_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_CREATE_CIRCLE_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_UPDATE_CIRCLE_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_DELETE_USER_CIRCLE_DONE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_RENAME_USER_CIRCLE_DONE object:nil];    
    NSLog(@"Circlewise view did unload called");
}


#pragma mark Table view data source and delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    if (tableView==circleTableView) {
        return [self.userCircle count];
    }
    else
    {
        return 1;
    }
}


-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView==circleTableView) {
        SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
        NSInteger numStoriesInSection = [[sectionInfo.userCircle friends] count];
        
        return sectionInfo.open ? numStoriesInSection : 0;
    }
    else
    {
        return [circleListDetailGlobalArray count];
    }
}


-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    
    if (tableView==self.circleTableView) 
    {
        static NSString *QuoteCellIdentifier = @"circleListTableCell";
        
        CircleListTableCell *cell = (CircleListTableCell*)[self.circleTableView dequeueReusableCellWithIdentifier:QuoteCellIdentifier];
        
        if (!cell) {
            
            UINib *quoteCellNib = [UINib nibWithNibName:@"CircleListTableCell" bundle:nil];
            [quoteCellNib instantiateWithOwner:self options:nil];
            cell = self.circleListTableCell;
            self.circleListTableCell = nil;
            
            if ([MFMailComposeViewController canSendMail]) {
                UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
                [cell addGestureRecognizer:longPressRecognizer];
            }
            else {
                NSLog(@"Mail not available");
            }
        }
        
        SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:indexPath.section];
        UserFriends *userFrnd=[sectionInfo.userCircle.friends objectAtIndex:indexPath.row];
        UserCircle *circle=[circleListDetailGlobalArray objectAtIndex:indexPath.section];
        userFrnd=[circle.friends objectAtIndex:indexPath.row];
        NSLog(@"userFrnd %@",userFrnd);
        cell.firstNameLabel.text=userFrnd.userName;
        if (userFrnd.statusMsg)
        {
            cell.addressLabel.text=userFrnd.statusMsg;
        }
        else
        {
            cell.addressLabel.text=@"";
        }
        [cell.footerView.layer setCornerRadius:6.0f];
        [cell.footerView.layer setMasksToBounds:YES];
        cell.footerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.6];
        cell.distanceLabel.text=[NSString stringWithFormat:@"%.2lfm",userFrnd.distance];
        [cell.inviteButton addTarget:self action:@selector(addToCircle:) forControlEvents:UIControlEventTouchUpInside];
//        [cell.inviteButton addTarget:self action:@selector(removeFromCircle:) forControlEvents:UIControlEventTouchUpInside];
        [cell.messageButton addTarget:self action:@selector(messageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.showOnMapButton.hidden=YES;
        cell.profilePicImgView.image=[self getImageFromPeopleListByuserId:userFrnd.userId];
        NSLog(@"userFrnd.userId %@",userFrnd.userId);
        cell.profilePicImgView.layer.borderColor=[[UIColor lightTextColor] CGColor];
        cell.profilePicImgView.userInteractionEnabled=YES;
        cell.profilePicImgView.layer.borderWidth=1.0;
        cell.profilePicImgView.layer.masksToBounds = YES;
        [cell.regStsImgView.layer setCornerRadius:5.0];
        [cell.inviteButton.layer setCornerRadius:6.0f];
        [cell.inviteButton.layer setMasksToBounds:YES];
        [cell.messageButton.layer setCornerRadius:6.0f];
        [cell.messageButton.layer setMasksToBounds:YES];

        cell.coverPicImgView.image=[UIImage imageNamed:@"cover_pic_default.png"];
        if ([userFrnd.regMedia isEqualToString:@"fb"]) 
        {
            cell.regStsImgView.image=[UIImage imageNamed:@"icon_facebook.png"];
        }
        else
        {
            cell.regStsImgView.image=[UIImage imageNamed:@"sm_icon@2x.png"];
        }
        //    cell.actAndSceneLabel.text=@"actAndScene";
        //    cell.quotationTextView.text=@"Quotation";
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"circleTableCell";
        SelectCircleTableCell *cell2 = [self.circleSelectTableView
                                        dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell2)
        {
            cell2 = [[SelectCircleTableCell alloc]
                     initWithStyle:UITableViewCellStyleDefault
                     reuseIdentifier:CellIdentifier];
        }
        NSString *circleName;
        if (((UserCircle *)[circleListDetailGlobalArray objectAtIndex:indexPath.row]).circleName !=NULL)
        {
            circleName = [NSString stringWithFormat:@"%@ (%d)",((UserCircle *)[circleListDetailGlobalArray objectAtIndex:indexPath.row]).circleName,[((UserCircle *)[circleListDetailGlobalArray objectAtIndex:indexPath.row]).friends count]];
            cell2.circrcleName.text=circleName;
        }
        else
        {
            circleName = [NSString stringWithFormat:@"Custom (%d)",[((UserCircle *)[circleListDetailGlobalArray objectAtIndex:indexPath.row]).friends count]];
            cell2.circrcleName.text=circleName;
        }
        
        //if in circle set selected
        if ([selectedCircleCheckArr containsObject:[circleListDetailGlobalArray objectAtIndex:indexPath.row]])
        {
            [cell2.circrcleCheckbox setImage:[UIImage imageNamed:@"checkbox_checked.png"] forState:UIControlStateNormal];
        }
        else
        {
            [cell2.circrcleCheckbox setImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
        }
        
        if (((UserCircle *)[circleListDetailGlobalArray objectAtIndex:indexPath.row]).type==0)
        {
            [cell2.circrcleCheckbox setUserInteractionEnabled:NO];
        }
        else
        {
            [cell2.circrcleCheckbox setUserInteractionEnabled:YES];
        }
        
        [cell2.circrcleCheckbox addTarget:self action:@selector(handleTableViewCheckbox:) forControlEvents:UIControlEventTouchUpInside];
        NSLog(@"return SelectCircleTableCell");
        return cell2;
    }
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    
    /*
     Create the section header views lazily.
     */
    if (tableView==self.circleTableView) {
//        NSLog(@"self.sectionInfoArray %@",self.sectionInfoArray);
        SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
        if (!sectionInfo.headerView) {
            NSString *circleName;
            if (((UserCircle *)[circleListDetailGlobalArray objectAtIndex:section]).circleName !=NULL) 
            {
                circleName = [NSString stringWithFormat:@"%@ (%d)",((UserCircle *)[circleListDetailGlobalArray objectAtIndex:section]).circleName,[((UserCircle *)[circleListDetailGlobalArray objectAtIndex:section]).friends count]];
            }
            else
            {
                circleName = [NSString stringWithFormat:@"Custom (%d)",[((UserCircle *)[circleListDetailGlobalArray objectAtIndex:section]).friends count]];
                
            }
            sectionInfo.headerView = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.circleTableView.bounds.size.width, HEADER_HEIGHT) title:circleName section:section delegate:self];
        }
        
        return sectionInfo.headerView;
    }
    return nil;
}


-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (tableView==circleTableView) {
        SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:indexPath.section];
        return [[sectionInfo objectInRowHeightsAtIndex:indexPath.row] floatValue];
    }
    else
    {
        return 44;
    }
    // Alternatively, return rowHeight.
}


-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"indexPath %@",indexPath);
}


#pragma mark Section header delegate

-(void)sectionHeaderView:(SectionHeaderView*)sectionHeaderView sectionOpened:(NSInteger)sectionOpened {
	
	SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:sectionOpened];
	sectionInfo.open = YES;
    
    /*
     Create an array containing the index paths of the rows to insert: These correspond to the rows for each quotation in the current section.
     */
    NSInteger countOfRowsToInsert = [sectionInfo.userCircle.friends count];
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < countOfRowsToInsert; i++) {
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:sectionOpened]];
    }

	NSLog(@"countOfRowsToInsert: %d",countOfRowsToInsert);
    
    /*
     Create an array containing the index paths of the rows to delete: These correspond to the rows for each quotation in the previously-open section, if there was one.
     */
    NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
    
    NSInteger previousOpenSectionIndex = self.openSectionIndex;
    if (previousOpenSectionIndex != NSNotFound) {
		
		SectionInfo *previousOpenSection = [self.sectionInfoArray objectAtIndex:previousOpenSectionIndex];
        previousOpenSection.open = NO;
        [previousOpenSection.headerView toggleOpenWithUserAction:NO];
        NSInteger countOfRowsToDelete = [previousOpenSection.userCircle.friends count];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:previousOpenSectionIndex]];
        }
    }
    
    // Style the animation so that there's a smooth flow in either direction.
    UITableViewRowAnimation insertAnimation;
    UITableViewRowAnimation deleteAnimation;
    if (previousOpenSectionIndex == NSNotFound || sectionOpened < previousOpenSectionIndex) {
        insertAnimation = UITableViewRowAnimationTop;
        deleteAnimation = UITableViewRowAnimationBottom;
    }
    else {
        insertAnimation = UITableViewRowAnimationBottom;
        deleteAnimation = UITableViewRowAnimationTop;
    }
    
    // Apply the updates.
    [self.circleTableView beginUpdates];
    [self.circleTableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:insertAnimation];
    [self.circleTableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:deleteAnimation];
    [self.circleTableView endUpdates];
    self.openSectionIndex = sectionOpened;
    
}


-(void)sectionHeaderView:(SectionHeaderView*)sectionHeaderView sectionClosed:(NSInteger)sectionClosed {
    
    /*
     Create an array of the index paths of the rows in the section that was closed, then delete those rows from the table view.
     */
	SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:sectionClosed];
	
    sectionInfo.open = NO;
    NSInteger countOfRowsToDelete = [self.circleTableView numberOfRowsInSection:sectionClosed];
    
    if (countOfRowsToDelete > 0) {
        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:sectionClosed]];
        }
        [self.circleTableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationTop];
    }
    self.openSectionIndex = NSNotFound;
}


#pragma mark Handling pinches


-(void)handlePinch:(UIPinchGestureRecognizer*)pinchRecognizer {
    
    /*
     There are different actions to take for the different states of the gesture recognizer.
     * In the Began state, use the pinch location to find the index path of the row with which the pinch is associated, and keep a reference to that in pinchedIndexPath. Then get the current height of that row, and store as the initial pinch height. Finally, update the scale for the pinched row.
     * In the Changed state, update the scale for the pinched row (identified by pinchedIndexPath).
     * In the Ended or Canceled state, set the pinchedIndexPath property to nil.
     */
    
    if (pinchRecognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint pinchLocation = [pinchRecognizer locationInView:self.circleTableView];
        NSIndexPath *newPinchedIndexPath = [self.circleTableView indexPathForRowAtPoint:pinchLocation];
		self.pinchedIndexPath = newPinchedIndexPath;
        
		SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:newPinchedIndexPath.section];
        self.initialPinchHeight = [[sectionInfo objectInRowHeightsAtIndex:newPinchedIndexPath.row] floatValue];
        // Alternatively, set initialPinchHeight = uniformRowHeight.
        
        [self updateForPinchScale:pinchRecognizer.scale atIndexPath:newPinchedIndexPath];
    }
    else {
        if (pinchRecognizer.state == UIGestureRecognizerStateChanged) {
            [self updateForPinchScale:pinchRecognizer.scale atIndexPath:self.pinchedIndexPath];
        }
        else if ((pinchRecognizer.state == UIGestureRecognizerStateCancelled) || (pinchRecognizer.state == UIGestureRecognizerStateEnded)) {
            self.pinchedIndexPath = nil;
        }
    }
}


-(void)updateForPinchScale:(CGFloat)scale atIndexPath:(NSIndexPath*)indexPath {
    
    if (indexPath && (indexPath.section != NSNotFound) && (indexPath.row != NSNotFound)) {
        
		CGFloat newHeight = round(MAX(self.initialPinchHeight * scale, DEFAULT_ROW_HEIGHT));
        
		SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:indexPath.section];
        [sectionInfo replaceObjectInRowHeightsAtIndex:indexPath.row withObject:[NSNumber numberWithFloat:newHeight]];
        // Alternatively, set uniformRowHeight = newHeight.
        
        /*
         Switch off animations during the row height resize, otherwise there is a lag before the user's action is seen.
         */
        BOOL animationsEnabled = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled:NO];
        [self.circleTableView beginUpdates];
        [self.circleTableView endUpdates];
        [UIView setAnimationsEnabled:animationsEnabled];
    }
}


#pragma mark Handling long presses

-(void)handleLongPress:(UILongPressGestureRecognizer*)longPressRecognizer {
    
    /*
     For the long press, the only state of interest is Began.
     When the long press is detected, find the index path of the row (if there is one) at press location.
     If there is a row at the location, create a suitable menu controller and display it.
     */
    if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
        
        NSIndexPath *pressedIndexPath = [self.circleTableView indexPathForRowAtPoint:[longPressRecognizer locationInView:self.circleTableView]];
        
        if (pressedIndexPath && (pressedIndexPath.row != NSNotFound) && (pressedIndexPath.section != NSNotFound)) {
            [self becomeFirstResponder];
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            EmailMenuItem *menuItem = [[EmailMenuItem alloc] initWithTitle:@"Email" action:@selector(emailMenuButtonPressed:)];
            menuItem.indexPath = pressedIndexPath;
            menuController.menuItems = [NSArray arrayWithObject:menuItem];
            [menuController setTargetRect:[self.circleTableView rectForRowAtIndexPath:pressedIndexPath] inView:self.circleTableView];
            [menuController setMenuVisible:YES animated:YES];
        }
    }
}


-(void)emailMenuButtonPressed:(UIMenuController*)menuController {
    
    EmailMenuItem *menuItem = [[[UIMenuController sharedMenuController] menuItems] objectAtIndex:0];
    if (menuItem.indexPath) {
        [self resignFirstResponder];
        [self sendEmailForEntryAtIndexPath:menuItem.indexPath];
    }
}


-(void)sendEmailForEntryAtIndexPath:(NSIndexPath*)indexPath {
    
	SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:self.pinchedIndexPath.section];
    // In production, send the appropriate message.
    NSLog(@"Send email to %@", sectionInfo);
}


-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    [self dismissModalViewControllerAnimated:YES];
    if (result == MFMailComposeResultFailed) {
        // In production, display an appropriate message to the user.
        NSLog(@"Mail send failed with error: %@", error);
    }
}

-(void)handleTableViewCheckbox:(id)sender
{
    SelectCircleTableCell *clickedCell = (SelectCircleTableCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.circleSelectTableView indexPathForCell:clickedCell];
    //    [clickedCell.9 setImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
    if ([selectedCircleCheckArr containsObject:[circleListDetailGlobalArray objectAtIndex:clickedButtonPath.row]])
    {
        [selectedCircleCheckArr removeObject:[circleListDetailGlobalArray objectAtIndex:clickedButtonPath.row]];
        [clickedCell.circrcleCheckbox setImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
        NSLog(@"removed");
    }
    else
    {
        [selectedCircleCheckArr addObject:[circleListDetailGlobalArray objectAtIndex:clickedButtonPath.row]];
        [clickedCell.circrcleCheckbox setImage:[UIImage imageNamed:@"checkbox_checked.png"] forState:UIControlStateNormal];
        NSLog(@"added");
    }
    NSLog(@"circle name %@",((UserCircle *)[circleListDetailGlobalArray objectAtIndex:clickedButtonPath.row]).circleName);
    [self.circleSelectTableView reloadData];
    NSLog(@"selectedCircleCheckArr: %@",selectedCircleCheckArr); 
}

-(UIImage *)getImageFromPeopleListByuserId:(NSString *)userId
{
    for (int i=0; i<[smAppDelegate.peopleList count]; i++)
    {
        NSLog(@"id %@ %@",((LocationItemPeople *)[smAppDelegate.peopleList objectAtIndex:i]).userInfo.userId,userId);
        if ([((LocationItemPeople *)[smAppDelegate.peopleList objectAtIndex:i]).userInfo.userId isEqualToString:userId])
        {
            NSLog(@"image found");
            return ((LocationItemPeople *)[smAppDelegate.peopleList objectAtIndex:i]).itemIcon;
        }
    }
    NSLog(@"image not found");
    return [UIImage imageNamed:@"thum.png"];
}

-(NSMutableArray *)getCircleListByUser:(NSString *)userId
{
    NSMutableArray *circleList=[[NSMutableArray alloc] init];
    for(int i=0;i<[circleListDetailGlobalArray count];i++)
    {
        UserCircle *circle=[[UserCircle alloc] init];
        circle=[circleListDetailGlobalArray objectAtIndex:i];
        for (int j=0; j<[((UserCircle *)[circleListDetailGlobalArray objectAtIndex:i]).friends count]; j++)
        {
            UserFriends *userFrnd=[((UserCircle *)[circleListDetailGlobalArray objectAtIndex:i]).friends objectAtIndex:j];
            if ([userFrnd.userId isEqualToString:userId])
            {
                [circleList addObject:circle];
            }
        }
    }
    NSLog(@"circleList %@",circleList);
    return circleList;
}

-(UserFriends *)getFriendById:(NSString *)userId
{
    for(int i=0; i<[friendListGlobalArray count]; i++)
    {
        if([((UserFriends *)[friendListGlobalArray objectAtIndex:i]).userId isEqualToString:userId])
        {
            return [friendListGlobalArray objectAtIndex:i];
        }
    }
    return [friendListGlobalArray objectAtIndex:[friendListGlobalArray count]-1];
}

-(NSString *)getUserIdFromIndexpath:(NSIndexPath *)index
{
    NSString *userId;
    UserCircle *circle =[circleListDetailGlobalArray objectAtIndex:index.section];
    userId=((UserFriends *)[circle.friends objectAtIndex:index.row]).userId;
    return userId;
}

- (void)getAllCircleDone:(NSNotification *)notif
{
    NSLog(@"notification: %@",[notif object]);
    for (int i=0; i<[circleListDetailGlobalArray count]; i++)
    {
        NSLog(@"((UserCircle *)[circleListDetailGlobalArray objectAtIndex:i]).circleName %@",((UserCircle *)[circleListDetailGlobalArray objectAtIndex:i]).friends) ;
        NSLog(@"%@",((UserCircle *)[circleListDetailGlobalArray objectAtIndex:i]).friends);
        for (int c=0; c<[((UserCircle *)[circleListDetailGlobalArray objectAtIndex:i]).friends count]; c++)
        {
            UserFriends *userFnd= [((UserCircle *)[circleListDetailGlobalArray objectAtIndex:i]).friends objectAtIndex:c];
            NSLog(@"userFnd.userName %@",userFnd.userName);
        }
    }
//    [smAppDelegate hideActivityViewer];
//    [smAppDelegate.window setUserInteractionEnabled:YES];
//    [self.circleTableView reloadData];
//    [self.view setNeedsDisplay];
    self.userCircle=circleListDetailGlobalArray;
    [self initData];
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    [self.circleTableView reloadData];
    [self.view setNeedsDisplay];
    [self.circleSelectTableView reloadData];
    NSLog(@"self.circleSelectTableView %@",self.circleSelectTableView);
    [self.circleCreateView setNeedsDisplay];    
}

-(IBAction)saveRenameCircle:(id)sender
{
    if ([renameTextField.text isEqualToString:@""])
    {
        [UtilityClass showAlert:@"" :@"Please enter circle name"];
    }
    else
    {
        [renameTextField resignFirstResponder];
        [renameUIView removeFromSuperview];    
        
        [smAppDelegate showActivityViewer:self.view];
        [smAppDelegate.window setUserInteractionEnabled:NO];
        
        renameCircleName=renameTextField.text;
        UserCircle* circle= ((UserCircle *)[circleListDetailGlobalArray objectAtIndex:renameCircleOndex]);
        circle.circleName= renameCircleName;
        [rc renameCircleByCircleId:@"Auth-Token" :smAppDelegate.authToken :circle.circleID:renameCircleName];
        [circleListDetailGlobalArray replaceObjectAtIndex:renameCircleOndex withObject:circle];
        self.userCircle=[circleListDetailGlobalArray mutableCopy];
        [self initData];
        [renameTextField setText:@""];
    }
}

-(IBAction)cancelRenameCircle:(id)sender
{
    [renameTextField resignFirstResponder];    
    [renameUIView removeFromSuperview];
}

-(void)renameCircle:(int)index
{
    NSLog(@"renameUIView index %d %@ %@ %@ %@",index,renameUIView,renameTextField,self.view,self);
    renameCircleOndex=index;
    [self.view addSubview:renameUIView];
}

-(void)deleteCircle:(int)index
{
    [smAppDelegate showActivityViewer:self.view];
    [smAppDelegate.window setUserInteractionEnabled:NO];
    NSString *circleID;
    circleID= ((UserCircle *)[circleListDetailGlobalArray objectAtIndex:index]).circleID;
    [rc deleteCircleByCircleId:@"Auth-Token" :smAppDelegate.authToken :circleID];
    [circleListDetailGlobalArray removeObjectAtIndex:index];
    self.userCircle=[circleListDetailGlobalArray mutableCopy];

    NSLog(@"delete index %d %@",index,circleID);    
    
}

- (void)createCircleDone:(NSNotification *)notif
{
    self.userCircle=circleListDetailGlobalArray;
    [self initData];
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    [self.view setNeedsDisplay];
    openSectionIndex_ = NSNotFound;
    [self.circleTableView reloadData];
    [self.circleSelectTableView reloadData];
    NSLog(@"self.circleSelectTableView %@",circleListDetailGlobalArray);
    [self.circleCreateView setNeedsDisplay];    
    NSRange range = NSMakeRange(0, [circleListDetailGlobalArray count]-1);
    NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];                                     
    [self.circleTableView reloadSections:section withRowAnimation:UITableViewRowAnimationNone];
 
}

- (void)updateCircleDone:(NSNotification *)notif
{
    NSLog(@"in update nottification: %@",[notif object]);
    for (int i=0; i<[circleListDetailGlobalArray count]; i++)
    {
        NSLog(@"((UserCircle *)[circleListDetailGlobalArray objectAtIndex:i]).circleName %@",((UserCircle *)[circleListDetailGlobalArray objectAtIndex:i]).friends) ;
        NSLog(@"%@",((UserCircle *)[circleListDetailGlobalArray objectAtIndex:i]).friends);
        for (int c=0; c<[((UserCircle *)[circleListDetailGlobalArray objectAtIndex:i]).friends count]; c++)
        {
            UserFriends *userFnd= [((UserCircle *)[circleListDetailGlobalArray objectAtIndex:i]).friends objectAtIndex:c];
            NSLog(@"userFnd.userName %@",userFnd.userName);
        }
    }
    //    [smAppDelegate hideActivityViewer];
    //    [smAppDelegate.window setUserInteractionEnabled:YES];
    //    [self.circleTableView reloadData];
    //    [self.view setNeedsDisplay];
    self.userCircle=circleListDetailGlobalArray;
    [self initData];
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    [self.view setNeedsDisplay];
    openSectionIndex_ = NSNotFound;
    [self.circleTableView reloadData];
    [self.circleSelectTableView reloadData];
    NSLog(@"self.circleSelectTableView %@",circleListDetailGlobalArray);
    [self.circleCreateView setNeedsDisplay];    
    NSRange range = NSMakeRange(0, [circleListDetailGlobalArray count]-1);
    NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];                                     
    [self.circleTableView reloadSections:section withRowAnimation:UITableViewRowAnimationNone];
    [self.circleTableView beginUpdates];
    [self.circleTableView endUpdates];
//    [self.circleTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    [self.circleTableView  performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
    [self.circleTableView setNeedsDisplay];
    [self.circleTableView reloadData];
}

- (void)deleteCircleDone:(NSNotification *)notif
{
    [smAppDelegate hideActivityViewer];
    [self initData];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    [self.circleTableView reloadData];
    [UtilityClass showAlert:@"" :@"Circle deleted successfully"];
}

- (void)renameCircleDone:(NSNotification *)notif
{
    [smAppDelegate hideActivityViewer];
    [smAppDelegate.window setUserInteractionEnabled:YES];
    [self.circleTableView reloadData];
}

-(void)addToCircle:(id)sender
{
    [selectedCircleCheckArr removeAllObjects];
    [circleSelectTableView reloadData];
    SelectCircleTableCell *clickedCell = (SelectCircleTableCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.circleTableView indexPathForCell:clickedCell];
    //get userID from indexPath
    NSString *userId=[self getUserIdFromIndexpath:clickedButtonPath];
    userID=userId;
    NSLog(@"userId %@ , %@",userId,clickedButtonPath);
    selectedCircleCheckArr=[self getCircleListByUser:userId];
    [circleSelectTableView reloadData];
    [self.view addSubview:circleCreateView];
}

-(void)removeFromCircle:(id)sender
{
    [self.view addSubview:circleCreateView];    
}

-(void)messageButtonAction:(id)sender
{
    [self.view addSubview:msgView];
}

-(IBAction)backButton:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)sendMsg:(id)sender
{
    if (([textViewNewMsg.text isEqualToString:@""]) ||([textViewNewMsg.text isEqualToString:@"Your message..."]))
    {
        [UtilityClass showAlert:@"Social Maps" :@"Enter message"];
    }
    else {
    CircleListTableCell *clickedCell = (CircleListTableCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.circleTableView indexPathForCell:clickedCell];

    [textViewNewMsg resignFirstResponder];
    [msgView removeFromSuperview];
    NSString * subject = [NSString stringWithFormat:@"Message from %@ %@", smAppDelegate.userAccountPrefs.firstName,
                          smAppDelegate.userAccountPrefs.lastName];
    
    NSMutableArray *userIDs=[[NSMutableArray alloc] init];
    
    NSString *userId = [self getUserIdFromIndexpath:clickedButtonPath];
    [userIDs addObject:userId];
    NSLog(@"user id %@", userIDs);
    
    RestClient *restClient = [[[RestClient alloc] init] autorelease];
    [restClient sendMessage:subject content:textViewNewMsg.text recipients:userIDs authToken:@"Auth-Token" authTokenVal:smAppDelegate.authToken];
    }
}

-(IBAction)cancelMsg:(id)sender
{
    [textViewNewMsg resignFirstResponder];
    [msgView removeFromSuperview];
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (!(textView.textColor == [UIColor blackColor])) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    return YES;
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (!(textView.textColor == [UIColor lightGrayColor])) {
        textView.text = @"Your message...";
        textView.textColor = [UIColor lightGrayColor];
    }
}

-(void)beganEditing:(UITextField *)searchBar
{
    //UIControl need to config here
    CGRect textFieldRect =
	[self.view.window convertRect:searchBar.bounds fromView:searchBar];
    
    CGRect viewRect =
	[self.view.window convertRect:self.view.bounds fromView:self.view];
	
	CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
	midline - viewRect.origin.y
	- MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
	(MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
	* viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
	if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
	UIInterfaceOrientation orientation =
	[[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
	CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
    
}

-(void)endEditing
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];    
    [self.view setFrame:viewFrame];    
    [UIView commitAnimations];    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self beganEditing:circleNameTextField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self endEditing];
}
#pragma mark Memory management


- (void)dealloc {
    [labelNotifCount release];
    [super dealloc];
}
@end
